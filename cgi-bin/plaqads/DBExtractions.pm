# DB Extraction functions
#
# $Source: /data/dev/rcs/plaqads/perl/RCS/DBExtractions.pm,v $
#
# $Revision: 1.4 $
#
# $Date: 2004/11/19 20:55:30 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBExtractions.pm,v $
# Revision 1.4  2004/11/19 20:55:30  atchleyb
# fixed bug in selecting hash of current keywords and current categories
#
# Revision 1.3  2004/11/16 19:32:15  atchleyb
# added new browse filters
#
# Revision 1.2  2004/08/03 17:27:05  atchleyb
# added new lookup hashes to getExtractionVersionInfo to help relation lookups
#
# Revision 1.1  2004/07/27 18:27:16  atchleyb
# Initial revision
#
#
#
#
#

package DBExtractions;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UIShared qw(getFile);
use UI_Widgets qw(lpadzero getDisplayString);
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
      &getNextExtractionsID      &getExtractionArray         &getExtractionInfo         
      &doProcessExtractionEntry  &getExtrVersionInfo         &getExtractionTypes
      &getExtractionKeywords     &getExtractionCategories    &getExtractionHash
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getNextExtractionsID      &getExtractionArray         &getExtractionInfo         
      &doProcessExtractionEntry  &getExtrVersionInfo         &getExtractionTypes
      &getExtractionKeywords     &getExtractionCategories    &getExtractionHash
    )]
);


###################################################################################################################################
sub getNextExtractionsID { # routine to get the next available extractions id
###################################################################################################################################
    my %args = (
        @_,
    );
    my ($extractionsID) = $args{dbh}->selectrow_array("SELECT $args{schema}.extractions_id.NEXTVAL from DUAL");
    return ($extractionsID);
}


###################################################################################################################################
sub getExtractionArray {  # routine to get an array of extractions
###################################################################################################################################
    my %args = (
        id => 0,
        docID => 0,
        type => 0,
        linkedTo => 0,
        linkedFrom => 0,
        linkType => 0,
        where => "",
        userID => 0,
        dates => 0,
        keyword => 0,
        category => 0,
        orderBy => "id",
        @_,
    );
    $args{dbh}->{LongReadLen} = 100000000;
    $args{dbh}->{LongTruncOk} = 0;

    my $i = 0;
    my @extrc;
    my $sqlcode = "SELECT id, sourcedoc, type, location ";
    $sqlcode .= "FROM $args{schema}.extractions WHERE id>0 ";
    $sqlcode .= (($args{id} > 0) ? "AND (id = $args{id}) ": "");
    $sqlcode .= (($args{docID} > 0) ? "AND (sourcedoc = $args{docID}) ": "");
    $sqlcode .= (($args{type} > 0) ? "AND (type = $args{type}) ": "");
    $sqlcode .= (($args{userID} > 0) ? "AND (id IN (SELECT e.id FROM $args{schema}.document_versions dv, " .
                  "$args{schema}.extractions e WHERE dv.documentid=e.sourcedoc AND dv.enteredby=$args{userID})) ": "");
    $sqlcode .= (($args{dates} == 1) ? "AND (id IN (SELECT id FROM $args{schema}.extraction_versions WHERE datesaved>=ADD_MONTHS(SYSDATE,-3))) ": "");
    $sqlcode .= (($args{dates} == 2) ? "AND (id IN (SELECT id FROM $args{schema}.extraction_versions WHERE datesaved>=ADD_MONTHS(SYSDATE,-6))) ": "");
    $sqlcode .= (($args{dates} == 3) ? "AND (id IN (SELECT id FROM $args{schema}.extraction_versions WHERE datesaved>=ADD_MONTHS(SYSDATE,-12))) ": "");
    $sqlcode .= (($args{keyword} > 0) ? "AND (id IN (SELECT extraction FROM $args{schema}.extraction_keywords WHERE keyword=$args{keyword})) ": "");
    $sqlcode .= (($args{category} > 0) ? "AND (id IN (SELECT extraction FROM $args{schema}.extraction_categories WHERE category=$args{category})) ": "");
    $sqlcode .= (($args{linkedTo} > 0) ? "AND (id IN (SELECT id FROM $args{schema}.extraction_relationship " .
          "WHERE relatedid=$args{linkedTo} AND type=$args{linkType})) " : "");
    $sqlcode .= (($args{linkedFrom} > 0) ? "AND (id IN (SELECT relatedid FROM $args{schema}.extraction_relationship " .
          "WHERE id=$args{linkedFrom} AND type=$args{linkType})) " : "");
    $sqlcode .= (($args{where} gt "") ? "AND ($args{where}) ": "");
    $sqlcode .= "ORDER BY $args{orderBy}";
#print STDERR "\n$sqlcode\n";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    while (($extrc[$i]{id}, $extrc[$i]{sourcedoc}, $extrc[$i]{type}, 
            $extrc[$i]{location}) = $csr->fetchrow_array) {
        $extrc[$i]{sortid} = &lpadzero($extrc[$i]{id}, 10);
        ($extrc[$i]{typeName}) = $args{dbh}->selectrow_array("SELECT name FROM $args{schema}.extraction_type WHERE id=$extrc[$i]{type}");
        ($extrc[$i]{currentVersion}, $extrc[$i]{text}) = $args{dbh}->selectrow_array("SELECT version,text FROM $args{schema}.extraction_versions " .
              "WHERE id=$extrc[$i]{id} ORDER BY version DESC");
        $extrc[$i]{sorttext} = lc(substr($extrc[$i]{text}, 0, 80));
        $extrc[$i]{shorttext} = &getDisplayString($extrc[$i]{text}, 40);
        $extrc[$i]{shorttext2} = &getDisplayString($extrc[$i]{text}, 80);
        $i++;
    }
    $csr->finish;

    return (@extrc);
}


###################################################################################################################################
sub getExtractionInfo { # routine to get extraction info
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );
    $args{dbh}->{LongReadLen} = 100000000;
    $args{dbh}->{LongTruncOk} = 0;
    my %itemInfo;
    my @items = getExtractionArray(dbh => $args{dbh}, schema => $args{schema}, id => $args{id});
    
    my $hashref = $items[0];
    %itemInfo = %$hashref;
    
    my $sqlcode = "SELECT id, version, TO_CHAR(datesaved, 'MM/DD/YYYY HH24:MI'), savedby, text, ";
    $sqlcode .= "context FROM $args{schema}.extraction_versions WHERE id=$args{id} ORDER BY version";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    while (my ($id, $version, $datesaved, $savedby, $text, $context) = $csr->fetchrow_array) {
        $itemInfo{versions}[$version]{id} = $id;
        $itemInfo{versions}[$version]{datesaved} = $datesaved;
        $itemInfo{versions}[$version]{savedby} = $savedby;
        $itemInfo{versions}[$version]{text} = $text;
        $itemInfo{versions}[$version]{context} = $context;
        $itemInfo{currentVersion} = $version;
        $itemInfo{versions}[$version]{shorttext} = &getDisplayString($text, 40);
        $itemInfo{versions}[$version]{shorttext2} = &getDisplayString($text, 80);
    }
    $csr->finish;

    return (%itemInfo);
}


###################################################################################################################################
sub getExtrVersionInfo { # routine to get extraction version info
###################################################################################################################################
    my %args = (
        id => 0,
        version => 0,
        @_,
    );
    $args{dbh}->{LongReadLen} = 100000000;
    $args{dbh}->{LongTruncOk} = 0;
    
    my %extrInfo = getExtractionInfo(dbh => $args{dbh}, schema => $args{schema}, id => $args{id});
    my %extrVerInfo;
    my $sqlcode = "SELECT id, version, TO_CHAR(datesaved, 'MM/DD/YYYY HH24:MI'), savedby, text, context ";
    $sqlcode .= "FROM $args{schema}.extraction_versions WHERE id=$args{id} ";
    $sqlcode .= ($args{version} > 0) ? "AND version=$args{version} " : "";
    $sqlcode .= "ORDER BY version DESC";
    
    ($extrVerInfo{id}, $extrVerInfo{version}, $extrVerInfo{datesaved}, $extrVerInfo{savedby}, $extrVerInfo{text}, 
          $extrVerInfo{context}) = $args{dbh}->selectrow_array($sqlcode);

    $sqlcode = "SELECT ec.extraction, ec.category, c.text FROM $args{schema}.extraction_categories ec, $args{schema}.categories c ";
    $sqlcode .= "WHERE ec.category=c.id AND ec.extraction=$args{id} ORDER BY ec.category";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    my $i = 0;
    while (my ($extraction, $category, $categoryName) = $csr->fetchrow_array) {
        ($extrVerInfo{categories}[$i]{extraction}, $extrVerInfo{categories}[$i]{category}, $extrVerInfo{categories}[$i]{categoryName}) = 
              ($extraction, $category, $categoryName);
        $extrVerInfo{categoryHash}{$category} = $category;
        $i++;
    }
    $extrVerInfo{categoryCount} = $i;
    $csr->finish;

    $sqlcode = "SELECT ek.extraction, ek.keyword, k.text FROM $args{schema}.extraction_keywords ek, $args{schema}.keywords k ";
    $sqlcode .= "WHERE ek.keyword=k.id AND ek.extraction=$args{id} ORDER BY ek.keyword";
#print STDERR "\n$sqlcode\n\n";
    $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    $i = 0;
    while (my ($extraction, $keyword, $keywordName) = $csr->fetchrow_array) {
        ($extrVerInfo{keywords}[$i]{extraction}, $extrVerInfo{keywords}[$i]{keyword}, $extrVerInfo{keywords}[$i]{keywordName}) = 
              ($extraction, $keyword, $keywordName);
        $extrVerInfo{keywordHash}{$keyword} = $keyword;
        $i++;
    }
    $extrVerInfo{keywordCount} = $i;
    $csr->finish;

    if ($extrInfo{type} == 1) {
        $sqlcode = "SELECT id, relatedid, type FROM $args{schema}.extraction_relationship WHERE id=$args{id} ORDER BY relatedid";
    } else {
        $sqlcode = "SELECT id, relatedid, type FROM $args{schema}.extraction_relationship WHERE relatedid=$args{id} ORDER BY id";
    }
#print STDERR "\n$sqlcode\n\n";
    $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    $i = 0;
    while (my ($id, $relatedid, $type) = $csr->fetchrow_array) {
        ($extrVerInfo{relations}[$i]{id}, $extrVerInfo{relations}[$i]{relatedid}, $extrVerInfo{relations}[$i]{type}) = ($id, $relatedid, $type);
        $extrVerInfo{relationHash}{"$id-$relatedid-$type"} = "$id-$relatedid-$type";
        $extrVerInfo{idHash}{"$id"} = $id;
        $extrVerInfo{relatedidHash}{"$relatedid"} = $relatedid;
#print STDERR "* - $id-$relatedid-$type\n";
        $i++;
    }
    $extrVerInfo{relatedCount} = $i;
    $csr->finish;

    return (%extrVerInfo);
}


###################################################################################################################################
sub doProcessExtractionEntry {  # routine to enter a new extraction or update a extraction
###################################################################################################################################
    my %args = (
        userID => 0,
        type => "",  # new or update
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $id = (($args{type} eq 'new') ? &getNextExtractionsID(dbh => $args{dbh}, schema => $args{schema}) : $settings{extrid});
    my $type = $settings{type};
    my $sqlcode;
    my $status = 0;
    
    eval {
        if ($args{type} eq 'new') {
            $sqlcode = "INSERT INTO $args{schema}.extractions (id, sourcedoc, type, location) VALUES ($id, $settings{documentid}, $type, ";
            $sqlcode .= ((defined($settings{location}) && $settings{location} gt '  ') ? $args{dbh}->quote($settings{location}) : "NULL") . ")";
#print STDERR "\n$sqlcode\n\n";
            $args{dbh}->do($sqlcode);
        } else {
            $sqlcode = "UPDATE $args{schema}.extractions SET ";
            $sqlcode .= "location = " . ((defined($settings{location})) ? $args{dbh}->quote($settings{location}) : "NULL") . " ";
            $sqlcode .= "WHERE id = $id";
#print STDERR "\n$sqlcode\n\n";
            $args{dbh}->do($sqlcode);
        }
        my $doInsert = (($args{type} eq 'new') ? 'T' : 'F');
        my $version = 1;
        my %extrVersionInfo;
        if ($args{type} ne 'new') {
            %extrVersionInfo = &getExtrVersionInfo(dbh => $args{dbh}, schema => $args{schema}, id => $id);
            if ($extrVersionInfo{text} ne $settings{text} || $extrVersionInfo{context} ne $settings{context}) {
                $doInsert = 'T';
                $version = $extrVersionInfo{version} + 1;
            }
        }
        if ($doInsert eq 'T') {
            $sqlcode = "INSERT INTO $args{schema}.extraction_versions (id, version, datesaved, savedby, text, context) ";
            $sqlcode .= "VALUES ($id, $version, SYSDATE, $args{userID}, ";
            $sqlcode .= ((defined($settings{text})) ? ":text" : "NULL") . ", ";
            $sqlcode .= ((defined($settings{context})) ? ":context" : "NULL") . ") ";
#print STDERR "\n$sqlcode\n\n";
            my $csr = $args{dbh}->prepare($sqlcode);
            if (defined($settings{text})) {
                $csr -> bind_param (":text", $settings{text}, {ora_type => ORA_CLOB, ora_field => 'text'});
            }
            if (defined($settings{context})) {
                $csr -> bind_param (":context", $settings{context}, {ora_type => ORA_CLOB, ora_field => 'context'});
            }
            $status = $csr->execute;
            $csr->finish;
        }
        
        $args{dbh}->do("DELETE FROM $args{schema}.extraction_categories WHERE extraction=$id");
        my $catRef = $settings{categoryList};
        my @catList = @$catRef;
        for (my $i=0; $i<=$#catList; $i++) {
            $args{dbh}->do("INSERT INTO $args{schema}.extraction_categories (extraction, category) VALUES ($id, $catList[$i])");
        }
        
        $args{dbh}->do("DELETE FROM $args{schema}.extraction_keywords WHERE extraction=$id");
        my $keyRef = $settings{keywordList};
        my @keyList = @$keyRef;
        for (my $i=0; $i<=$#keyList; $i++) {
            $args{dbh}->do("INSERT INTO $args{schema}.extraction_keywords (extraction, keyword) VALUES ($id, $keyList[$i])");
        }
        
        if ($settings{type} == 1) {
            $args{dbh}->do("DELETE FROM $args{schema}.extraction_relationship WHERE id=$id AND type=$settings{relationtype}");
            my $rItemRef = $settings{relateditems};
            my @rItemList = @$rItemRef;
            for (my $i=0; $i<=$#rItemList; $i++) {
#print STDERR "\nINSERT INTO $args{schema}.extraction_relationship (id, relatedid, type) VALUES ($id, $rItemList[$i], $settings{relationtype})\n\n";
                $args{dbh}->do("INSERT INTO $args{schema}.extraction_relationship (id, relatedid, type) " .
                      "VALUES ($id, $rItemList[$i], $settings{relationtype})");
            }
        } else {
            $args{dbh}->do("DELETE FROM $args{schema}.extraction_relationship WHERE relatedid=$id AND type=$settings{relationtype}");
            my $rItemRef = $settings{relateditems};
            my @rItemList = @$rItemRef;
            for (my $i=0; $i<=$#rItemList; $i++) {
                $args{dbh}->do("INSERT INTO $args{schema}.extraction_relationship (id, relatedid, type) " .
                      "VALUES ($rItemList[$i], $id, $settings{relationtype})");
            }
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
sub getExtractionTypes { # routine to get an array of extraction types
###################################################################################################################################
    my %args = (
        @_,
    );
    my @types;
    my $csr = $args{dbh}->prepare("SELECT id, name FROM $args{schema}.extraction_type");
    $csr->execute;
    while (my ($id, $name) = $csr->fetchrow_array) {
        $types[$id] = $name;
    }
    $csr->finish;
    return (@types);
}


###################################################################################################################################
sub getExtractionKeywords { # routine to get a hash of current keywords for an extraction
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );
    tie my %keywords, "Tie::IxHash";
    my $csr = $args{dbh}->prepare("SELECT k.id, k.text FROM $args{schema}.keywords k, $args{schema}.extraction_keywords ek WHERE k.id=ek.keyword " .
          (($args{id} > 0) ? "AND (ek.extraction = $args{id}) ": "") .
          "ORDER BY k.text");
    $csr->execute;
    while (my ($id, $name) = $csr->fetchrow_array) {
        $keywords{$id} = $name;
    }
    $csr->finish;
    return (\%keywords);
}


###################################################################################################################################
sub getExtractionCategories { # routine to get a hash of current categories for an extraction
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );
    tie my %categories, "Tie::IxHash";
    my $csr = $args{dbh}->prepare("SELECT c.id, c.text FROM $args{schema}.categories c, $args{schema}.extraction_categories ec WHERE c.id=ec.category " .
          (($args{id} > 0) ? "AND (ec.extraction = $args{id}) ": "") .
          "ORDER BY c.text");
    $csr->execute;
    while (my ($id, $name) = $csr->fetchrow_array) {
        $categories{$id} = $name;
    }
    $csr->finish;
    return (\%categories);
}


###################################################################################################################################
sub getExtractionHash { # routine to get a hash of extractions
###################################################################################################################################
    my %args = (
        id => 0,
        type => 0,
        textLen => 80,
        selected => 'F',
        @_,
    );
    my $sqlcode;
    tie my %extr, "Tie::IxHash";
    my $csr;
    
    if ($args{selected} ne 'T') {
        $sqlcode = "SELECT e.id, e.sourcedoc ";
        $sqlcode .= "FROM $args{schema}.extractions e WHERE id>0 ";
        $sqlcode .= (($args{type} > 0) ? "AND (e.type = $args{type}) ": "");
        $sqlcode .= "ORDER BY e.sourcedoc,e.id";
    } else {
        $sqlcode = "SELECT " . (($args{type} == 1) ? "er.id" : "er.relatedid") . ", e.sourcedoc ";
        $sqlcode .= "FROM $args{schema}.extraction_relationship er, $args{schema}.extractions e WHERE e.id>0 ";
        $sqlcode .= (($args{type} == 1) ? "AND (e.id = er.id) AND (er.relatedid = $args{id}) ": "");
        $sqlcode .= (($args{type} == 2) ? "AND (e.id = er.relatedid) AND (er.id = $args{id}) ": "");
        $sqlcode .= "ORDER BY e.sourcedoc,e.id";
    }

    $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    while (my ($id, $sourcedoc) = $csr->fetchrow_array) {
        $extr{$id} = "DOC" . &lpadzero($sourcedoc,6) . " - $id - ";
        my ($version, $text) = $args{dbh}->selectrow_array("SELECT version,text FROM $args{schema}.extraction_versions " .
              "WHERE id=$id ORDER BY version DESC");
        $extr{$id} .= &getDisplayString($text, $args{textLen});
    }
    $csr->finish;
    return (\%extr);
}


###################################################################################################################################
###################################################################################################################################


1; #return true
