# DB search functions
#
# $Source: /data/dev/rcs/plaqads/perl/RCS/DBSearch.pm,v $
#
# $Revision: 1.2 $
#
# $Date: 2005/04/04 16:21:59 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBSearch.pm,v $
# Revision 1.2  2005/04/04 16:21:59  atchleyb
# updated to allow for boolean search
#
# Revision 1.1  2004/11/09 19:09:12  atchleyb
# Initial revision
#
#
#
#
#

package DBSearch;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
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
      &searchDocuments   &searchExtractions
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &searchDocuments   &searchExtractions
    )]
);


###################################################################################################################################
sub searchDocuments {                                                                                                           #
###################################################################################################################################
    my %args = (
       searchString => '',
       caseSensitive => 'F',
       matchType => 'full', # 'full' | 'any' | 'all'
       searchTerms => '',
       @_,
    );
    $args{dbh}->{LongReadLen} = 100000000;
    $args{dbh}->{LongTruncOk} = 0;
    
    my $arrayref = $args{searchTerms};
    my @searchTerms = @$arrayref;
    
    my $searchString = (($args{caseSensitive} eq 'F') ? lc($args{searchString}) : $args{searchString});

    my $sqlcode = "SELECT d.id,dv.version,d.title,d.source,d.url,d.description,d.comments,dv.filename,dv.translation,dv.comments  " .
    "FROM $args{schema}.documents d, $args{schema}.document_versions dv WHERE d.id=dv.documentid  AND ( " .
        &buildSQLSearch(caseSensitive=>$args{caseSensitive},matchType=>$args{matchType},searchTerms=>\@searchTerms,field=>"d.title") .
        "OR " . &buildSQLSearch(caseSensitive=>$args{caseSensitive},matchType=>$args{matchType},searchTerms=>\@searchTerms,field=>"d.source") .
        "OR " . &buildSQLSearch(caseSensitive=>$args{caseSensitive},matchType=>$args{matchType},searchTerms=>\@searchTerms,field=>"d.url") .
        "OR " . &buildSQLSearch(caseSensitive=>$args{caseSensitive},matchType=>$args{matchType},searchTerms=>\@searchTerms,field=>"d.description") .
        "OR " . &buildSQLSearch(caseSensitive=>$args{caseSensitive},matchType=>$args{matchType},searchTerms=>\@searchTerms,field=>"d.comments") .
        "OR " . &buildSQLSearch(caseSensitive=>$args{caseSensitive},matchType=>$args{matchType},searchTerms=>\@searchTerms,field=>"dv.filename") .
        "OR " . &buildSQLSearch(caseSensitive=>$args{caseSensitive},matchType=>$args{matchType},searchTerms=>\@searchTerms,field=>"dv.comments") .
	") AND dv.documentid||'-'||dv.version IN (SELECT documentid||'-'||MAX (distinct version) FROM $args{schema}.document_versions GROUP BY documentid)  " .
	"ORDER BY d.id";
    my @out;
    my $i = 0;
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    while (($out[$i]{id},$out[$i]{version},$out[$i]{title},$out[$i]{source},$out[$i]{url},$out[$i]{description},
          $out[$i]{comments},$out[$i]{filename},$out[$i]{translation},$out[$i]{vcomments})=$csr->fetchrow_array) {
        $i++;
    }
    $csr->finish;
 
    return (@out);
}


###################################################################################################################################
sub searchExtractions {                                                                                                           #
###################################################################################################################################
    my %args = (
       searchString => '',
       caseSensitive => 'F',
       matchType => 'full', # 'full' | 'any' | 'all'
       searchTerms => '',
       @_,
    );
    $args{dbh}->{LongReadLen} = 100000000;
    $args{dbh}->{LongTruncOk} = 0;
    
    my $arrayref = $args{searchTerms};
    my @searchTerms = @$arrayref;
    
    my $searchString = (($args{caseSensitive} eq 'F') ? lc($args{searchString}) : $args{searchString});

    my $sqlcode = "SELECT d.title,e.sourcedoc,e.id,e.type,et.name,ev.version,ev.text,ev.context FROM $args{schema}.extraction_versions ev, " .
        "$args{schema}.extractions e, $args{schema}.documents d, $args{schema}.extraction_type et WHERE d.id=e.sourcedoc AND e.id=ev.id " .
        "AND e.type=et.id AND (" . 
        &buildSQLSearch(caseSensitive=>$args{caseSensitive},matchType=>$args{matchType},searchTerms=>\@searchTerms,field=>"ev.text") .
        "OR " . &buildSQLSearch(caseSensitive=>$args{caseSensitive},matchType=>$args{matchType},searchTerms=>\@searchTerms,field=>"ev.context") .
        ") AND ev.id||'-'||ev.version IN (SELECT id||'-'||MAX (distinct version) FROM $args{schema}.extraction_versions GROUP BY id) " .
        "ORDER BY e.sourcedoc,ev.id";
    my @out;
    my $i = 0;
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    while (($out[$i]{title},$out[$i]{sourcedoc},$out[$i]{id},$out[$i]{type},$out[$i]{typename},$out[$i]{version},$out[$i]{text})=$csr->fetchrow_array) {
        $i++;
    }
    $csr->finish;
 
    return (@out);
}


###################################################################################################################################
sub buildSQLSearch {                                                                                                              #
###################################################################################################################################
    my %args = (
        caseSensitive => 'F',
        matchType => 'full', # 'full' | 'any' | 'all'
        searchTerms => '',
        field => '',
        @_,
    );
    my $arrayref = $args{searchTerms};
    my @searchTerms = @$arrayref;
    my $out = '';
    
    $out .= "(";
    
    for (my $i=0; $i<=$#searchTerms; $i++) {
        if ($i > 0) {
            $out .= " " . (($args{matchType} eq 'any') ? "OR" : "AND") . " ";
        }
        my $temp = $searchTerms[$i];
        $temp =~ s/'/''/g;
        $out .= (($args{caseSensitive} eq 'F') ? "LOWER($args{field}) LIKE '%" . lc($temp) . "%'" : "$args{field} LIKE '%$temp%'");
    }
    
    $out .= ")";

    return ($out);
}




###################################################################################################################################
###################################################################################################################################




1; #return true
