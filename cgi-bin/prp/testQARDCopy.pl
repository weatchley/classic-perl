#!/usr/local/bin/perl -w

# Component Description
#
# $Source: /usr/local/homes/higashis/www/gov.doe.ocrwm.ydappdev/rcs/prp/perl/RCS/testQARDCopy.pl,v $
# $Revision: 1.3 $
# $Date $
# $Author: higashis $
# $Locker: higashis $
# $Log: testQARDCopy.pl,v $
# Revision 1.3  2009/01/16 19:40:49  higashis
# *** empty log message ***
#

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

my $command = (defined ($scrcgi -> param("command"))) ? $scrcgi -> param("command") : "write_request";
my $username = (defined($scrcgi->param("loginusername"))) ? $scrcgi->param("loginusername") : "";
my $password = (defined($scrcgi->param("password"))) ? $scrcgi->param("password") : "";
my $userid = (defined($scrcgi->param("loginusersid"))) ? $scrcgi->param("loginusersid") : "";
my $error = "";
my $dbh = db_connect();

my $oldQID = 30; #for revision 20
my $newQID = 31; #for revision 21
my $oldRev = 20;
my $newRev = 21;

my $csr1;

print $scrcgi->header('text/html');
print "<html>\n<head>\n";
print "<meta http-equiv=expires content=now>\n";
print "<title>QARD Copy</title>\n";
print "</head>\n";

print "<body background=#eeeeee text=#002299 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";

$dbh->{LongTruncOk} = 0;
$dbh->{LongReadLen} = 10000;

print "<b>Running</b><br><br>\n";

my $sqlcode = "INSERT INTO $schema.qardtoc (id,title,tocid,revisionid,enteredby,dateentered,lastupdated,updatedby,isdeleted, helper) ";
$sqlcode .= "(SELECT $schema.qardtoc_id_seq.NEXTVAL,title,tocid,$newQID,enteredby,dateentered,lastupdated,updatedby,isdeleted, id ";
$sqlcode .= " FROM $schema.qardtoc WHERE revisionid=$oldQID AND isdeleted='F')";

#print "$sqlcode<br>\n<br>\n";
print "<p>Copy 'qardtoc'</p>\n";
$dbh->do($sqlcode);

$sqlcode = "INSERT INTO $schema.qardtable1a (id,item,nrcsource,nrcdescription,standardsource,standarddescription,position,justification,";
$sqlcode .= "revisionid,enteredby,dateentered,lastupdated,updatedby,subid,isdeleted,helper) ";
$sqlcode .= "(SELECT $schema.qardtable1a_id_seq.NEXTVAL,item,nrcsource,nrcdescription,standardsource,standarddescription,position,justification,";
$sqlcode .= "$newQID,enteredby,dateentered,lastupdated,updatedby,subid,isdeleted,id FROM $schema.qardtable1a WHERE revisionid=$oldQID ";
$sqlcode .= "AND isdeleted='F')";
#print "$sqlcode<br>\n<br>\n";
$dbh->do($sqlcode);


$sqlcode = "INSERT INTO $schema.qardsection (id,sectionid,title,text,enteredby,dateentered,lastupdated,updatedby,status,tocid,qardrevid,";
$sqlcode .= "isdeleted,subid,sorter,types,istoc,helper) ";
$sqlcode .= "(SELECT $schema.qardsection_id_seq.NEXTVAL,sectionid,title,text,enteredby,dateentered,lastupdated,updatedby,status,tocid,";
$sqlcode .= "$newQID,isdeleted,subid,sorter,types,istoc,id FROM $schema.qardsection WHERE qardrevid=$oldQID AND isdeleted='F')";
#print "$sqlcode<br>\n<br>\n";
print "<p>Copy 'qardsection'</p>\n";
$dbh->do($sqlcode);

$sqlcode = "SELECT id, helper FROM $schema.qardtoc WHERE revisionid=$newQID";
#print "$sqlcode<br>\n<br>\n";
$csr1 = $dbh->prepare($sqlcode);
$csr1->execute;
while (my ($id,$helper) = $csr1->fetchrow_array) {
    $sqlcode = "UPDATE $schema.qardsection SET tocid=$id WHERE tocid=$helper AND qardrevid=$newQID";
#print "$sqlcode<br>\n<br>\n";
    $dbh->do($sqlcode);
}


$sqlcode = "INSERT INTO $schema.matrix (id,title,sourceid,qardid,enteredby,dateentered,lastupdated,updatedby,isdeleted,";
$sqlcode .= "statusid,dateapproved,approvedby,rejectionrationale,helper) ";
$sqlcode .= "(SELECT $schema.matrix_id_seq.NEXTVAL,title,sourceid,$newQID,enteredby,dateentered,lastupdated,updatedby,isdeleted,";
$sqlcode .= "statusid,NULL,NULL,rejectionrationale,id FROM $schema.matrix WHERE qardid=$oldQID AND isdeleted='F')";
#print "$sqlcode<br>\n<br>\n";
print "<p>Copy 'matrix'</p>\n";
$dbh->do($sqlcode);


$sqlcode = "SELECT id,helper FROM $schema.qardtable1a WHERE revisionid=$newQID";
#print "$sqlcode<br>\n<br>\n";
#print "<p>Process 'requirementtable1a'</p>\n";

# 03/21/08 - sh	

print "<p>Process 'requirementtable1a'</p>\n";
$csr1 = $dbh->prepare($sqlcode);
$csr1->execute;
while (my ($id,$helper) = $csr1->fetchrow_array) {
    #$sqlcode = "SELECT requirementid,table1aid FROM $schema.requirementtable1a WHERE table1aid=$helper";
    # 03/21/08 - sh	
    	$sqlcode = "SELECT requirementid,table1aid FROM $schema.requirementtable1a WHERE table1aid=$helper and rid=$oldQID";
#print "$sqlcode<br>\n<br>\n";
    my $csr2 = $dbh->prepare($sqlcode);
    $csr2->execute;
    while (my ($requirementid, $table1aid) = $csr2->fetchrow_array) {
        #$sqlcode = "INSERT INTO $schema.requirementtable1a (requirementid, table1aid) VALUES ($requirementid, $id)";
      	# 03/21/08 - sh
      		$sqlcode = "INSERT INTO $schema.requirementtable1a (requirementid, table1aid, rid) VALUES ($requirementid, $id, $newQID)";
#print "$sqlcode<br>\n<br>\n";
        $dbh->do($sqlcode);
    }
}



$sqlcode = "SELECT id,helper FROM $schema.matrix WHERE qardid=$newQID";
#print "$sqlcode<br>\n<br>\n";
print "<p>Process 'qardmatrix'</p>\n";
$csr1 = $dbh->prepare($sqlcode);
$csr1->execute;
while (my ($id,$helper) = $csr1->fetchrow_array) {
    $sqlcode = "SELECT matrixid,qardsectionid,sourcerequirementid,TO_CHAR(lastupdated,'YYYYMMDD-HH24MISS'),updatedby,sourcetypeabbrev ";
    $sqlcode .= "FROM $schema.qardmatrix WHERE matrixid=$helper";
#print "$sqlcode<br>\n<br>\n";
    my $csr2 = $dbh->prepare($sqlcode);
    $csr2->execute;
    while (my ($matrixid,$qardsectionid,$sourcerequirementid,$lastupdated,$updatedby,$sourcetypeabbrev) = $csr2->fetchrow_array) {
        $sqlcode = "SELECT id, isdeleted FROM $schema.qardsection WHERE helper=$qardsectionid AND qardrevid=$newQID";
#print "$sqlcode<br>\n<br>\n";
        my ($qsID, $isdeleted) = $dbh->selectrow_array($sqlcode);
        
        if ($isdeleted eq 'F') {
            $sqlcode = "INSERT INTO $schema.qardmatrix (matrixid,qardsectionid,sourcerequirementid,lastupdated,updatedby,sourcetypeabbrev) ";
            $sqlcode .= "VALUES ($id,$qsID,$sourcerequirementid,TO_DATE('$lastupdated','YYYYMMDD-HH24MISS'),";
            $sqlcode .= ((defined($updatedby) && $updatedby >= 0) ? $updatedby : "NULL") . ", ";
            $sqlcode .= ((defined($sourcetypeabbrev) && $sourcetypeabbrev gt " ") ? "'$sourcetypeabbrev'" : "NULL") . ")";
#print "$sqlcode<br>\n<br>\n";
            $dbh->do($sqlcode);
        }
    }
}

# 03/21/08 - sh	
#print "<p>Process 'srnotes'</p>\n";
#    	$sqlcode = "SELECT srid,ocrwmposition,ocrwmjustification,rid FROM $schema.srnotes WHERE rid=$oldQID";
#    $csr1 = $dbh->prepare($sqlcode);
#    $csr1->execute;
#    while (my ($srid,$ocrwmposition,$ocrwmjustification,$rid) = $csr1->fetchrow_array) {
#      		$sqlcode = "INSERT INTO $schema.srnotes (srid,ocrwmposition,ocrwmjustification,rid) VALUES ($srid,$ocrwmposition,$ocrwmjustification,$rid, $newQID)";
#        $dbh->do($sqlcode);
#    }

$sqlcode = "SELECT id,title FROM $schema.matrix WHERE qardid=$newQID";
print "$sqlcode<br>\n<br>\n";
my $oldText = "Revision $oldRev";
my $newText = "Revision $newRev";
print "<p>Process 'matrix' title revision rename from '$oldText' to '$newText'</p>\n";
$csr1 = $dbh->prepare($sqlcode);
$csr1->execute;
while (my ($id,$title) = $csr1->fetchrow_array) {
    $title =~ s/$oldText/$newText/g;
    print "$title<br>";
    $sqlcode = "UPDATE $schema.matrix SET title=" . $dbh->quote($title) . " WHERE id=$id";
    $dbh->do($sqlcode);
}

$dbh->commit;
print "<p><b>Done</b></p>\n";

print "</body>\n</html>\n";
my $stat = db_disconnect($dbh);



