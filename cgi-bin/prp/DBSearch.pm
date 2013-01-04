# DB search functions
#
# $Source: /data/dev/rcs/prp/perl/RCS/DBSearch.pm,v $
# $Revision: 1.7 $
# $Date: 2005/10/06 15:44:50 $
# $Author: naydenoa $
# $Locker:  $
#
# $Log: DBSearch.pm,v $
# Revision 1.7  2005/10/06 15:44:50  naydenoa
# CREQ00065 - post-phase 3 tweaks - display 0 on 0th req/crit in search results
#
# Revision 1.6  2005/09/20 22:57:22  naydenoa
# Phase 3 development completion - see AR document for details
# Added AQAP search
#
# Revision 1.5  2005/02/07 22:10:47  naydenoa
# CREQ00037 - tweak to sub searchSection
#
# Revision 1.4  2004/12/15 23:04:37  naydenoa
# Add Table 1A search processing (Phase 2, CREQ00024)
#
# Revision 1.3  2004/07/19 22:43:56  naydenoa
# Fulfillment of CREQ00012
#
# Revision 1.2  2004/06/15 23:07:31  naydenoa
# Enabled search in fulfillment of Phase 1, Cycle 2 requirements
#
# Revision 1.1  2004/04/22 20:30:03  naydenoa
# Initial revision
#
#

package DBSearch;

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
        &matchFound    &searchRequirement    &searchSection
        &searchTable1A
    );
%EXPORT_TAGS =( 
    Functions => [qw(
        &matchFound    &searchRequirement    &searchSection
        &searchTable1A
    )]
);

################
sub matchFound {
################
   my %args = (
      @_,
   );
   my $out;
   if (defined($args{text})) {
       if ($args{case} gt "") {
          $out = ($args{text} =~ m/$args{searchString}/) ? 1 : 0;
       } else {
          $out = ($args{text} =~ m/$args{searchString}/i) ? 1 : 0;
       }
   } else {
       $out = 0;
   }
   return ($out);
}

#######################
sub searchRequirement {
#######################
    my %args = (
        @_,
    );
    my $rows = 0;
    my @resultArray;
    $args{dbh}->{LongTruncOk} = 1;   # fetch whole text or truncated fraction
    $args{dbh}->{LongReadLen} = 100000000;

    my $whereClause = "";
#    if ($args{project} != 0) {
#        $whereClause = "WHERE id=$args{project}";
#    }

    my $sql = "select r.id, r.sourceid, s.designation || ', Section ' || r.sectionid || ' - ' || r.requirementid, r.text from $args{schema}.sourcerequirement r, $args{schema}.source s where r.isdeleted = 'F' and r.sourceid = s.id order by r.sourceid, r.id";
    my $csr = $args{dbh}->prepare($sql);
    $csr->execute;
    while (my ($id, $sourceid, $longrequirementid, $text) = $csr->fetchrow_array) {
        if (&matchFound(text => $text, searchString => $args{searchString}, case => $args{case})) {
            $resultArray[$rows][0] = $id;
            $resultArray[$rows][1] = $sourceid;
            $resultArray[$rows][2] = $longrequirementid;
            $resultArray[$rows][3] = $text;
            $rows++;
        }
    }
    $csr->finish;
    return ($rows, @resultArray);
}

###################
sub searchSection {
###################
    my %args = (
        qardtypeid => 1,
        @_,
    );
    my $rows = 0;
    my @resultArray;
    $args{dbh}->{LongTruncOk} = 1;   # fetch whole text or truncated fraction
    $args{dbh}->{LongReadLen} = 100000000;

    my $whereClause = "";
#    if ($args{project} != 0) {
#        $whereClause = "WHERE id=$args{project}";
#    }

    my $sql = "select s.id, s.sectionid, s.subid, s.text, q.revid, q.id from $args{schema}.qardsection s, $args{schema}.qard q where q.qardtypeid = $args{qardtypeid} and s.isdeleted = 'F' and q.isdeleted = 'F' and s.qardrevid = q.id order by s.tocid, s.sectionid";
#    my $sql = "select s.id, s.sectionid, s.text, qardrevid from $args{schema}.qardsection where isdeleted = 'F' order by tocid, sectionid";
    my $csr = $args{dbh}->prepare($sql);
    $csr->execute;
    while (my ($id, $sectionid, $subid, $text, $revid, $revision) = $csr -> fetchrow_array) {
        if (&matchFound(text => $text, searchString => $args{searchString}, case => $args{case})) {
            $subid = $subid ? $subid : 0;  
            $resultArray[$rows][0] = $id;
            $resultArray[$rows][1] = "$sectionid - $subid";
            $resultArray[$rows][2] = $text;
            $resultArray[$rows][3] = $revision;
            $resultArray[$rows][4] = $revid;
            $rows++;
        }
    }
    $csr->finish;
    return ($rows, @resultArray);
}

###################
sub searchTable1A {
###################
    my %args = (
        @_,
    );
    my $rows = 0;
    my @resultArray;
    $args{dbh}->{LongTruncOk} = 1;   # fetch whole text or truncated fraction
    $args{dbh}->{LongReadLen} = 100000000;

    my $whereClause = "";
#    if ($args{project} != 0) {
#        $whereClause = "WHERE id=$args{project}";
#    }

    my $sql = "select id, item, subid, '<i>US NRC Document:</i> ' || nrcdescription || '<br><br><i>National/Industry Standard:</i> ' || standarddescription || '<br><br><i>YMP Position:</i> ' || position || '<br><br><i>Justification:</i> ' || justification, revisionid from $args{schema}.qardtable1A where isdeleted = 'F' order by revisionid, item, subid";
    my $csr = $args{dbh}->prepare($sql);
    $csr->execute;
    while (my ($id, $item, $subid, $text, $revid) = $csr -> fetchrow_array) {
        if (&matchFound(text => $text, searchString => $args{searchString}, case => $args{case})) {
            $resultArray[$rows][0] = $id;
            $resultArray[$rows][1] = $item;
            $resultArray[$rows][2] = $subid;
            $resultArray[$rows][3] = $text;
            $resultArray[$rows][4] = $revid;
            $rows++;
        }
    }
    $csr->finish;
    return ($rows, @resultArray);
}

###############
1; #return true
