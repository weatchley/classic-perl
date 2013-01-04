# DB Document functions
#
# $Source: /data/dev/rcs/plaqads/perl/RCS/DBDocuments.pm,v $
#
# $Revision: 1.2 $
#
# $Date: 2004/11/16 19:31:47 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBDocuments.pm,v $
# Revision 1.2  2004/11/16 19:31:47  atchleyb
# added new brwose filters
#
# Revision 1.1  2004/07/27 18:27:16  atchleyb
# Initial revision
#
#
#
#
#

package DBDocuments;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UIShared qw(getFile);
use UI_Widgets qw(lpadzero);
use DBI;
use DBD::Oracle qw(:ora_types);
use Tie::IxHash;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
#use vars qw ();
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      &getNextDocumentsID      &getDocumentArray         &getDocumentInfo         
      &doProcessDocumentEntry  &getDocVersionInfo        &getMimeType
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getNextDocumentsID      &getDocumentArray         &getDocumentInfo         
      &doProcessDocumentEntry  &getDocVersionInfo        &getMimeType
    )]
);


###################################################################################################################################
sub getNextDocumentsID { # routine to get the next available documents id
###################################################################################################################################
    my %args = (
        @_,
    );
    my ($documentsID) = $args{dbh}->selectrow_array("SELECT $args{schema}.documents_id.NEXTVAL from DUAL");
    return ($documentsID);
}


###################################################################################################################################
sub getDocumentArray {  # routine to get an array of documents
###################################################################################################################################
    my %args = (
        startID => 0,
        endID => 0,
        userID => 0,
        dates => 0,
        where => "",
        orderBy => "id",
        @_,
    );
    $args{dbh}->{LongReadLen} = 100000000;
    $args{dbh}->{LongTruncOk} = 0;

    my $i = 0;
    my @docs;
    my $sqlcode = "SELECT id, title, source, type, url, description, cname, comments ";
    $sqlcode .= "FROM $args{schema}.documents WHERE id>0 ";
    $sqlcode .= (($args{startID} > 0) ? "AND (id>=$args{startID}) ": "");
    $sqlcode .= (($args{endID} > 0) ? "AND (id<=$args{endID}) ": "");
    $sqlcode .= (($args{userID} > 0) ? "AND (id IN (SELECT documentid FROM $args{schema}.document_versions WHERE enteredby=$args{userID})) " : "");
    $sqlcode .= (($args{dates} == 1) ? "AND (id IN (SELECT documentid FROM $args{schema}.document_versions WHERE dateentered>=ADD_MONTHS(SYSDATE,-3))) " : "");
    $sqlcode .= (($args{dates} == 2) ? "AND (id IN (SELECT documentid FROM $args{schema}.document_versions WHERE dateentered>=ADD_MONTHS(SYSDATE,-6))) " : "");
    $sqlcode .= (($args{dates} == 3) ? "AND (id IN (SELECT documentid FROM $args{schema}.document_versions WHERE dateentered>=ADD_MONTHS(SYSDATE,-12))) " : "");
    $sqlcode .= (($args{where} gt "") ? "AND ($args{where}) ": "");
    $sqlcode .= "ORDER BY $args{orderBy}";
#print STDERR "\n$sqlcode\n";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    while (($docs[$i]{id}, $docs[$i]{title}, $docs[$i]{source}, 
            $docs[$i]{type}, $docs[$i]{url}, 
            $docs[$i]{description}, $docs[$i]{cname}, 
            $docs[$i]{comments}) = $csr->fetchrow_array) {
        $docs[$i]{sorttitle} = lc($docs[$i]{title});
        $docs[$i]{sortid} = &lpadzero($docs[$i]{id}, 8);
        ($docs[$i]{typeName}) = $args{dbh}->selectrow_array("SELECT label FROM $args{schema}.document_type WHERE id=$docs[$i]{type}");
        $i++;
    }
    $csr->finish;

    return (@docs);
}


###################################################################################################################################
sub getDocumentInfo { # routine to get document info
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );
    $args{dbh}->{LongReadLen} = 100000000;
    $args{dbh}->{LongTruncOk} = 0;
    my %docInfo;
    my @docs = getDocumentArray(dbh => $args{dbh}, schema => $args{schema}, startID => $args{id}, endID => $args{id}, onlyActive => 'F');
    
    my $hashref = $docs[0];
    %docInfo = %$hashref;
    
    my $sqlcode = "SELECT documentid, version, TO_CHAR(dateentered, 'MM/DD/YYYY HH24:MI'), enteredby, filename, TO_CHAR(sourcedate, 'MM/DD/YYYY'), ";
    $sqlcode .= "sourceversion,translation FROM $args{schema}.document_versions WHERE documentid=$args{id} ORDER BY version";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    while (my ($documentid, $version, $dateentered, $enteredby, $filename, $sourcedate, $sourceversion, $translation) = $csr->fetchrow_array) {
        $docInfo{versions}[$version]{documentid} = $documentid;
        $docInfo{versions}[$version]{dateentered} = $dateentered;
        $docInfo{versions}[$version]{enteredby} = $enteredby;
        $docInfo{versions}[$version]{filename} = $filename;
        $docInfo{versions}[$version]{sourcedate} = $sourcedate;
        $docInfo{versions}[$version]{sourceversion} = $sourceversion;
        $docInfo{versions}[$version]{translation} = $translation;
        $docInfo{currentVersion} = $version;
    }
    $csr->finish;

    return (%docInfo);
}


###################################################################################################################################
sub getDocVersionInfo { # routine to get document version info
###################################################################################################################################
    my %args = (
        id => 0,
        version => 0,
        @_,
    );
    $args{dbh}->{LongReadLen} = 100000000;
    $args{dbh}->{LongTruncOk} = 0;
    
    my %docVerInfo;
    my $sqlcode = "SELECT documentid, version, dateentered, enteredby, filename, TO_CHAR(sourcedate, 'MM/DD/YYYY'), sourceversion,translation, sourcefile ";
    $sqlcode .= "FROM $args{schema}.document_versions WHERE documentid=$args{id} ";
    $sqlcode .= ($args{version} > 0) ? "AND version=$args{version} " : "";
    $sqlcode .= "ORDER BY version DESC";
    
    ($docVerInfo{documentid}, $docVerInfo{version}, $docVerInfo{dateentered}, $docVerInfo{enteredby}, $docVerInfo{filename}, 
          $docVerInfo{sourcedate}, $docVerInfo{sourceversion}, $docVerInfo{translation}, $docVerInfo{sourcefile}) = $args{dbh}->selectrow_array($sqlcode);
    $docVerInfo{mimeType} = &getMimeType(dbh => $args{dbh}, schema => $args{schema}, name=>$docVerInfo{filename});

    return (%docVerInfo);
}


###################################################################################################################################
sub doProcessDocumentEntry {  # routine to enter a new document or update a document
###################################################################################################################################
    my %args = (
        userID => 0,
        type => "",  # new or update
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $id = (($args{type} eq 'new') ? &getNextDocumentsID(dbh => $args{dbh}, schema => $args{schema}) : $settings{documentid});
    my $sqlcode;
    my $status = 0;
    
    eval {
        if ($args{type} eq 'new') {
            $sqlcode = "INSERT INTO $args{schema}.documents (id, title, source, type, url, description, comments) VALUES ($id, ";
            $sqlcode .= $args{dbh}->quote($settings{doctitle}) . ", ";
            $sqlcode .= ((defined($settings{source})) ? $args{dbh}->quote($settings{source}) : "NULL") . ", $settings{type}, ";
            $sqlcode .= ((defined($settings{url}) && $settings{url} gt "   ") ? $args{dbh}->quote($settings{url}) : "NULL") . ", ";
            $sqlcode .= ((defined($settings{description})) ? $args{dbh}->quote($settings{description}) : "NULL") . ", ";
            #$sqlcode .= ((defined($settings{comments})) ? $args{dbh}->quote($settings{comments}) : "NULL") . " ";
            $sqlcode .= "NULL) ";
#print STDERR "\n$sqlcode\n\n";
            my $csr = $args{dbh}->prepare($sqlcode);
            $status = $csr->execute;
            $csr->finish;
        } else {
            $sqlcode = "UPDATE $args{schema}.documents SET title = " .$args{dbh}->quote($settings{doctitle}) . ", ";
            $sqlcode .= "source = " . ((defined($settings{source})) ? $args{dbh}->quote($settings{source}) : "NULL") . ", ";
            $sqlcode .= "type = $settings{type}, ";
            $sqlcode .= "url = " . ((defined($settings{url})) ? $args{dbh}->quote($settings{url}) : "NULL") . ", ";
            $sqlcode .= "description = " . ((defined($settings{description})) ? $args{dbh}->quote($settings{description}) : "NULL") . " ";
            #$sqlcode .= ", comments = " . ((defined($settings{comments})) ? $args{dbh}->quote($settings{comments}) : "NULL") . ", ";
            $sqlcode .= "WHERE id = $id";
#print STDERR "\n$sqlcode\n\n";
            my $csr = $args{dbh}->prepare($sqlcode);
            $status = $csr->execute;
            $csr->finish;
        }
        my $doInsert = (($args{type} eq 'new') ? 'T' : 'F');
        my $version = 1;
        #my ($name, $fileContents) = &getFile(fileParam=>'sourcefile');
        my ($name, $fileContents) = ($args{fileName},$args{fileContents});
        my %docVersionInfo;
        if ($args{type} ne 'new') {
            %docVersionInfo = &getDocVersionInfo(dbh => $args{dbh}, schema => $args{schema}, id => $id);
            if ((defined($name) && $name gt '  ') || $docVersionInfo{sourcedate} ne $settings{sourcedate} || $docVersionInfo{sourceversion} ne $settings{sourceversion} || 
                  $docVersionInfo{translation} ne $settings{translation} || $docVersionInfo{comments} ne $settings{comments}) {
                $doInsert = 'T';
                $version = $docVersionInfo{version} + 1;
            }
        }
        if ($doInsert eq 'T') {
            $name =~ s/\\/\//g;
            $name = substr($name, (rindex($name, '/') + 1));
            $sqlcode = "INSERT INTO $args{schema}.document_versions (documentid, version, dateentered, enteredby, filename, sourcedate, sourceversion, ";
            $sqlcode .= "sourcefile, translation, comments) VALUES ($id, $version, SYSDATE, $args{userID}, ";
            if (defined($name) && $name gt '  ') {
                $sqlcode .= "'$name'";
            } elsif (defined($docVersionInfo{filename})) {
                $sqlcode .= "'$docVersionInfo{filename}'";
            }
            $sqlcode .= ", ";
            $sqlcode .= ((defined($settings{sourcedate}) || $settings{sourcedate} gt '  ') ? "TO_DATE('$settings{sourcedate}','MM/DD/YYYY')" : "NULL") . ", ";
            $sqlcode .= $args{dbh}->quote($settings{sourceversion}) . ", ";
            $sqlcode .= ((defined($name) || defined($docVersionInfo{filename})) ? ":sourcefile" : "NULL") . ", ";
            $sqlcode .= ((defined($settings{translation})) ? ":translation" : "NULL") . ", ";
            $sqlcode .= ((defined($settings{comments})) ? $args{dbh}->quote($settings{comment}) : "NULL") . ")";
 #print STDERR "\n$sqlcode\n\n";
           my $csr = $args{dbh}->prepare($sqlcode);
            if (defined($name) && $name gt '  ') {
                $csr -> bind_param (":sourcefile", $fileContents, {ora_type => ORA_BLOB, ora_field => 'sourcefile'});
            } elsif (defined($docVersionInfo{filename})) {
                $csr -> bind_param (":sourcefile", $docVersionInfo{sourcefile}, {ora_type => ORA_BLOB, ora_field => 'sourcefile'});
            }
            if (defined($settings{translation})) {
                $csr -> bind_param (":translation", $settings{translation}, {ora_type => ORA_CLOB, ora_field => 'translation'});
            }
            $status = $csr->execute;
            $csr->finish;
        }
        
        $args{dbh}->commit;

    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1,$id);
}


###################################################################################################################################
sub getMimeType {  # routine to get a mime type from a file name
###################################################################################################################################
    my %args = (
        name => 'test.txt',
        @_,
    );
    my $mimeType = "";
    my $fileType = lc(substr($args{name}, (rindex($args{name}, '.') + 1)));
    ($mimeType) = $args{dbh}->selectrow_array("SELECT mimetype FROM $args{schema}.mimetypes WHERE filetype='$fileType'");

    return ($mimeType);
}


###################################################################################################################################
###################################################################################################################################


1; #return true
