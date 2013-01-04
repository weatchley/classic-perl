# Library of UI widget routines for the DB

#
# $Source: /usr/local/homes/atchleyb/rcs/crd/perl/RCS/StoredProcedures.pm,v $
#
# $Revision: 1.1 $
#
# $Date: 2007/03/15 23:14:57 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: StoredProcedures.pm,v $
# Revision 1.1  2007/03/15 23:14:57  atchleyb
# Initial revision
#
#
#
#
package StoredProcedures;
use strict;
use Carp;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw($DBUser $CRDConnectPath $CRDServer);
#use CRD_Header qw(:Constants);
use Tie::IxHash;
use DBI;
use DBD::Oracle qw(:ora_types);

$DBUser = $ENV{'DBUser'};
$CRDConnectPath = $ENV{'CRDConnectPath'};
$CRDServer = $ENV{'CRDServer'};
#$schema = $ENV{'SCHEMA'};

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw (&process_document_entry    &process_preapproved
 );
@EXPORT_OK = qw(&process_document_entry    &process_preapproved
 );
%EXPORT_TAGS =(
    Functions => [qw(&process_document_entry    &process_preapproved
 ) ]
);


################################################################################################################
sub process_document_entry { # routine to process a new comment document from the entry tables to the main tables
################################################################################################################
    my %args = (
          id => 0,
          proofreadby => 0,
          namestatus => 0,
          newcommentor => 0,
          @_,
          );
    my $sqlcode = "";
    my $status = 1;
    my $dbh = $args{dbh};
    my $id = $args{id};
    
# get document information
    $sqlcode = "SELECT enteredby1, TO_CHAR(entrydate1, 'MM/DD/YYYY-HH24MISS'), entryremarks1, enteredby2, ";
    $sqlcode .= "TO_CHAR(entrydate2, 'MM/DD/YYYY-HH24MISS'), entryremarks2, commentor ";
    $sqlcode .= "FROM $args{schema}.document_entry WHERE id = $args{id}";
    
    my ($enteredby1, $entrydate1, $entryremarks1, $enteredby2, $entrydate2, $entryremarks2, $commentor) = 
          $args{dbh}->selectrow_array($sqlcode);

# insert new commentor
    if ($args{namestatus} == 1) {
        if ($args{newcommentor} == $commentor) {
            $sqlcode = "INSERT INTO $args{schema}.commentor (id, lastname, firstname, middlename, title, suffix, address, " .
                  "city, state, country, postalcode, areacode, phonenumber, phoneextension, faxareacode, faxnumber, " .
                  "faxextension, email, organization, position, affiliation) " .
                  "(SELECT id, lastname, firstname, middlename, title, suffix, address, city, state, country, postalcode, " .
                  "areacode, phonenumber, phoneextension, faxareacode, faxnumber, faxextension, email, organization, " .
                  "position, affiliation FROM $args{schema}.commentor_entry WHERE id = $commentor)";
            $args{dbh}->do($sqlcode);
        }
    }
    
# insert new document
    my $commentorInsert = ((defined($args{newcommentor}) && $args{newcommentor} > 0) ? $args{newcommentor} : "NULL");
    $sqlcode = "INSERT INTO $args{schema}.document (id, documenttype, datereceived, enteredby1, entrydate1, enteredby2, " .
          "entrydate2, dupsimstatus, dupsimid, hassrcomments, haslacomments, has960comments, hasenclosures, isillegible, " .
          "pagecount, addressee, signercount, namestatus, commentor, proofreadby, proofreaddate, enclosurepagecount) ".
          "(SELECT id, documenttype, datereceived, enteredby1, entrydate1, enteredby2, entrydate2, dupsimstatus, " .
          "dupsimid, hassrcomments, haslacomments, has960comments, hasenclosures, isillegible, pagecount, addressee, " .
          "signercount, namestatus, $commentorInsert, $args{proofreadby}, SYSDATE, enclosurepagecount " .
          "FROM $args{schema}.document_entry WHERE id = $args{id})";
#print STDERR "\n$sqlcode\n\n";
    $args{dbh}->do($sqlcode);
    
# delete entry document
    $sqlcode = "DELETE FROM document_entry WHERE id = $args{id}";
    $args{dbh}->do($sqlcode);

# delete entry commentor
    if ($args{namestatus} == 1) {
        $sqlcode = "DELETE FROM commentor_entry WHERE id = $commentor";
        $args{dbh}->do($sqlcode);
    }
    
# store any entered remarks
    if (defined($entryremarks1) && $entryremarks1 gt "     ") {
        $sqlcode = "INSERT INTO $args{schema}.document_remark (document, remarker, dateentered,text) " .
              "VALUES ($args{id}, $enteredby1, TO_DATE('$entrydate1', 'MM/DD/YYYY-HH24MISS'), :remarks)";
        my $csr = $dbh->prepare($sqlcode);
        $csr->bind_param(":remarks", $entryremarks1, { ora_type => ORA_CLOB, ora_field=>'text' });
        $csr->execute;
        $csr->finish;
    }
    
    if (defined($entryremarks2) && $entryremarks2 gt "     ") {
        $sqlcode = "INSERT INTO $args{schema}.document_remark (document, remarker, dateentered,text) " .
              "VALUES ($id, $enteredby2, TO_DATE('$entrydate2', 'MM/DD/YYYY-HH24MISS'), :remarks)";
#print STDERR "\n$sqlcode\n\n";
        my $csr = $dbh->prepare($sqlcode);
        $csr->bind_param(":remarks", $entryremarks2, { ora_type => ORA_CLOB, ora_field=>'text' });
        $csr->execute;
        $csr->finish;
    }
    $dbh->commit;
    $status = 0;
    
    return ($status);

}


################################################################################################################
sub process_preapproved { # routine to get a users password expiration date/time
################################################################################################################
    my %args = (
          id => 0,
          proofreadby => 0,
          proofreaddate => 0,
          @_,
          );
    my $sqlcode = "";
    my $status = 1;
    
# get preapproved text from entry table
    $sqlcode = "SELECT text, texttype, enteredby, TO_CHAR(entrydate, 'MM/DD/YYYY-HH24MISS') ";
    $sqlcode .= "FROM preapproved_text_entry WHERE id = $args{id}";
    
    my ($text, $texttype, $enteredby, $entrydate) = $args{dbh}->selectrow_array($sqlcode);

# insert new preapproved text
    $sqlcode = "INSERT INTO $args{schema}.preapproved_text VALUES ($args{id}, :text, $texttype, $enteredby, " .
          "TO_DATE('$entrydate, 'MM/DD/YYYY-HH24MISS'), $args{proofreadby}, " .
          "TO_DATE('$args{proofreaddate}', 'MM/DD/YYYY-HH24MISS'))";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->bind_param(":text", $text, { ora_type => ORA_CLOB, ora_field=>'text' });
    $csr->execute;
    $csr->finish;
    
# delete entry preapproved text
    $sqlcode = "DELETE FROM preapproved_text_entry WHERE id = $args{id}";
    $args{dbh}->do($sqlcode);

    $args{dbh}->commit;
    $status = 0;

    return ($status);

}



1; #return true
