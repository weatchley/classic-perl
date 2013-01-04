# DB Section functions
#
# $Source: /data/dev/rcs/prp/perl/RCS/DBQARD.pm,v $
# $Revision: 1.12 $
# $Date: 2006/06/13 23:34:37 $
# $Author: naydenoa $
# $Locker:  $
#
# $Log: DBQARD.pm,v $
# Revision 1.12  2006/06/13 23:34:37  naydenoa
# CREQ00078 - collected past and current assigned criteria for log expansion.
# Applied to CM updates.
#
# Revision 1.11  2005/09/20 22:52:42  naydenoa
# Phase 3 development completion - see AR document for details
# Added AQAP processing and displays
# Updated QA docs statusing (from current, archived, linked to linked and image-only)
# Updated matrices to collect last update data; matrix approval
#
# Revision 1.10  2005/04/12 23:06:51  naydenoa
# Tweaked TOC retrieval - from QARD only - CREQ00051
#
# Revision 1.9  2005/04/07 18:13:55  naydenoa
# Updated to accommodate QAMP - CREQ00047
#
# Revision 1.8  2005/03/22 18:39:23  naydenoa
# Took out Table 1A retrieval function - moved to DBShared to
# enable use by UIReports as well as UIQARD - partial fulfillment
# of CREQ00043, CREQ00044
#
# Revision 1.7  2005/03/15 21:26:20  naydenoa
# Added TOC designation processing for QARD sections to enable detailed
# TOC display on browse - CREQ00036
#
# Revision 1.6  2005/02/17 16:33:35  naydenoa
# CREQ00038 - updated returned info from QARD processing in all subs
#
# Revision 1.5  2004/12/16 16:28:15  naydenoa
# Added QARD type processing, table 1a processing - phase 2 and related CR's
#
# Revision 1.4  2004/10/06 18:04:42  naydenoa
# Added subsection id provisions to section insert/update - from CREQ00007
#
# Revision 1.3  2004/09/24 16:03:33  naydenoa
# CREQ00027 rework - add subid to QARD entry/update screen, sort QARD
# sections on update select
# Checkpoint for CREQ00024 - add table1a
#
# Revision 1.2  2004/08/30 21:25:57  naydenoa
# Add "iscurrent" to insert/update - CREQ00010
#
# Revision 1.1  2004/06/16 21:53:59  naydenoa
# Initial revision
#
#

package DBQARD;

# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use Tie::IxHash;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
        &processSectionEntry     &processTOCEntry    &processRevisionEntry
        &processUndelete         &processTableEntry  &processAQAPEntry
        &processAddApprover      &getFullTOC         &processQAMPEntry
        &processMatrixEntryStoQ
    );
%EXPORT_TAGS =( 
    Functions => [qw(
        &processSectionEntry     &processTOCEntry    &processRevisionEntry
        &processUndelete         &processTableEntry  &processAQAPEntry
        &processAddApprover      &getFullTOC         &processQAMPEntry
        &processMatrixEntryStoQ
    )]
);

#########################
sub processSectionEntry {
#########################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    $settings{sectiontitle} =~ s/\'/\'\'/g;
    $settings{sectiontext} =~ s/\'/\'\'/g;
    my $sectionid = $settings{shortsectionid};
    my $revisionid = "";
    if ($settings{qardtypeid} == 2) {
         $revisionid = $settings{aqaprid};
    }
    else {
         $revisionid = $settings{rid};
    }
#print STDERR "DB: $settings{qardtypeid}\n";
    my $isupdate = $settings{isupdate};
    my $subid = ($settings{subid}) ? $settings{subid} : 0;
    my $sectionstr = "";
    my $isdeleted = ($settings{isdeleted} eq "T") ? "'T'" : "'F'";
    my $tocid = ($settings{tocid}) ? $settings{tocid} : "NULL";
    my $istoc = ($settings{istoc} eq "T") ? "'T'" : "'F'";
    if ($isupdate == 0) {
        $sectionstr = "insert into $args{schema}.qardsection 
                          (id, sectionid, title, text, 
                           tocid, qardrevid, status, isdeleted, subid, istoc,
                           enteredby, updatedby, dateentered, lastupdated) 
                       values ($args{schema}.qardsection_id_seq.nextval, 
                           '$sectionid',  '$settings{sectiontitle}', 
                           '$settings{sectiontext}', 
                           $tocid, $revisionid, '$settings{sectionstatusid}', 
                           $isdeleted, $subid, $istoc,
                           $settings{userid}, $settings{userid}, 
                           SYSDATE, SYSDATE)";
    }
    else {
        $sectionstr = "update $args{schema}.qardsection
                      set sectionid = '$sectionid',
                          title = '$settings{sectiontitle}',
                          text = '$settings{sectiontext}',
                          tocid = $tocid,
                          qardrevid = $revisionid,
                          status = '$settings{sectionstatusid}',
                          isdeleted = $isdeleted,
                          subid = $subid,
                          istoc = $istoc,
                          updatedby = $settings{userid},
                          lastupdated = SYSDATE
                      where id = $settings{sid}";
    }
#print STDERR "$sectionstr\n";
    my $csr = $args{dbh} -> prepare ($sectionstr);
    $csr -> execute;
    $csr -> finish;
    return ($sectionid, $revisionid);
}

#####################
sub processTOCEntry {
#####################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    $settings{toctitle} =~ s/\'/\'\'/g;
    my $isdeleted = ($settings{isdeleted} eq "T") ? "'T'" : "'F'";
    my $tocstr = "";
    if ($settings{isupdate}) {
        $tocstr = "update $args{schema}.qardtoc
                   set tocid = '$settings{tocid}',
                       title = '$settings{toctitle}',
                       revisionid = $settings{rid},
                       isdeleted = $isdeleted,
                       lastupdated = SYSDATE,
                       updatedby = $settings{userid}
                   where id = $settings{tid}";
    }
    else {
        $tocstr = "insert into $args{schema}.qardtoc (id, tocid, title, revisionid, isdeleted, enteredby, dateentered, updatedby, lastupdated) values ($args{schema}.qardtoc_id_seq.nextval, '$settings{tocid}', '$settings{toctitle}', $settings{rid}, $isdeleted, $settings{userid}, SYSDATE, $settings{userid}, SYSDATE)";
    }
    my $csr = $args{dbh} -> prepare ($tocstr);
    $csr -> execute;
    $csr -> finish;
    return ($settings{tocid}, $settings{rid});
}

##########################
sub processRevisionEntry {
##########################
    my %args = (
        fileName => '',
        file => '',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $qardtypeid = ($settings{qardtypeid}) ? $settings{qardtypeid} : 1;
#print STDERR "DB: $settings{qardtypeid}\n";

    my $dateeff = ($settings{dateeffective_year}) ? "dateeffective, " : "";
    my $dateeffective = ($settings{dateeffective_year}) ? "to_date('$settings{dateeffective_month}/$settings{dateeffective_day}/$settings{dateeffective_year}','MM/DD/YYYY'), " : "";  
    my $updatedateeffective = ($settings{dateeffective_year}) ? "dateeffective = to_date('$settings{dateeffective_month}/$settings{dateeffective_day}/$settings{dateeffective_year}','MM/DD/YYYY'), " : "";  
    my $dateapp = ($settings{dateapproved_year}) ? "dateapproved, " : "";
    my $dateapproved = ($settings{dateapproved_year}) ? "to_date('$settings{dateapproved_month}/$settings{dateapproved_day}/$settings{dateapproved_year}','MM/DD/YYYY'), " : ""; 
    my $updatedateapproved = ($settings{dateapproved_year}) ? "dateapproved = to_date('$settings{dateapproved_month}/$settings{dateapproved_day}/$settings{dateapproved_year}','MM/DD/YYYY'), " : ""; 
    my $appby = ($settings{approver}) ? "approvedby, " : "";
    my $approvedby = ($settings{approver}) ? "$settings{approver}, " : ""; 
    my $updateapprovedby = ($settings{approver}) ? "approvedby = $settings{approver}, " : ""; 
    my $isdeleted = ($settings{isdeleted} eq "T") ? "'T'" : "'F'";
    my $iscurrent = $settings{iscurrent};

    my $adddocimage = "";
    my $updatedocimage = "";
    my $imageinsertstring = "";
    my $imageupdate = "";

    my $qarddocumentfile = $args{file};
    my $qardfilename = $args{fileName};
    $qardfilename =~ s/\\/\//g;
    $qardfilename = substr($qardfilename,(rindex($qardfilename,'/')+1));
    my $whereisdot = index ($qardfilename, ".");
    my $qardfiletype = substr ($qardfilename, ($whereisdot + 1), 5);
    my ($mimetype) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, table => "mimetypes", where => "filetype = '$qardfiletype'", what => "mimetype");

#print STDERR "$qardfiletype  $mimetype\n";

    if ($qardfilename) {
        $adddocimage = "document, imagecontenttype, imageextension, ";
        $imageinsertstring = ":document, '$mimetype', '$qardfiletype', ";
        $imageupdate = ", document = :document, imagecontenttype = '$mimetype', imageextension = '$qardfiletype'";
    }

    my $revstr = "";
    if ($settings{isupdate} == 0) {
        $revstr = "insert into $args{schema}.qard 
                       (id, revid, status, isdeleted, iscurrent, $dateapp 
                        $appby $dateeff $adddocimage enteredby, updatedby, 
                        dateentered, lastupdated, qardtypeid) 
                   values ($args{schema}.qard_id_seq.nextval, 
                        '$settings{revid}', '$settings{status}', $isdeleted, 
                        '$iscurrent', $dateapproved $approvedby $dateeffective 
                        $imageinsertstring $settings{userid}, 
                        $settings{userid}, SYSDATE, SYSDATE, $qardtypeid)";
    }
    else {
        $revstr = "update $args{schema}.qard 
                   set revid = '$settings{revid}', 
                       status = '$settings{status}', isdeleted = $isdeleted, 
                       iscurrent = '$iscurrent', lastupdated = SYSDATE, 
                       qardtypeid = $qardtypeid,
                       $updatedateeffective $updatedateapproved 
                       $updateapprovedby updatedby = $settings{userid} 
                       $imageupdate 
                   where id = $settings{rid}"
    }
#print STDERR "$revstr\n$qardfilename\n";
    my $csr = $args{dbh} -> prepare ($revstr);
    if ($qardfilename) {
        $csr -> bind_param(":document", $qarddocumentfile, { ora_type => ORA_BLOB, ora_field=>'document' });
    }
    $csr -> execute;
    $csr -> finish;
    return ($settings{revid}, $qardtypeid);
}

#####################
sub processUndelete {
#####################
    my %args = (
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $id;
    my $table = "qard$settings{what}";
    if ($settings{what} eq "qard" || $settings{what} eq "aqap" || $settings{what} eq "qamp") {
        $id = $settings{rid};
        $table = "qard";
    }
    elsif ($settings{what} eq "toc") {
        $id = $settings{tid};
    } 
    elsif ($settings{what} eq "table1a") {
        $id = $settings{rowid};
    } 
    else {
        $id = $settings{sid};
    }
    my $undelete = "update $args{schema}.$table set isdeleted = 'F' where id = $id";
    my $csr = $args{dbh} -> do ($undelete);

    return;
}

#######################
sub processTableEntry {
#######################
    my %args = (
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $csr;
    my ($newrowid) = ($settings{rowid}) ? ($settings{rowid}) : $args{dbh} -> selectrow_array ("select $args{schema}.qardtable1a_id_seq.nextval from dual");
    my $isupdate = $settings{isupdate};
#print STDERR "-$isupdate-\n";
    $settings{nrcdescription} =~ s/\'/\'\'/g;
    $settings{standarddescription} =~ s/\'/\'\'/g;
    $settings{position} =~ s/\'/\'\'/g;
    $settings{justification} =~ s/\'/\'\'/g;
    my $position = ($settings{position}) ? "'$settings{position}'" : "NULL";
    my $justification = ($settings{justification}) ? "'$settings{justification}'" : "NULL";
    my $nrcdescription = ($settings{nrcdescription}) ? "'$settings{nrcdescription}'" : "NULL";
    my $standarddescription = ($settings{standarddescription}) ? "'$settings{standarddescription}'" : "NULL";
    my $insertorupdate = "";
    my $subid = ($settings{subid}) ? $settings{subid} : 0;
    my $isdeleted = ($settings{isdeleted} eq "T") ? "'T'" : "'F'";

    if ($isupdate) {
         $insertorupdate = "update qardtable1a
                            set item = '$settings{item}',
                                subid = $subid,
                                revisionid = $settings{rid},
                                nrcdescription = $nrcdescription,
                                standarddescription = $standarddescription,
                                position = $position,
                                justification = $justification,
                                isdeleted = $isdeleted,
                                lastupdated = SYSDATE, 
                                updatedby = $settings{userid}
                            where id = $newrowid";
    }
    else {
         $insertorupdate = "insert into qardtable1a (id, item, nrcdescription,
                                standarddescription, position, justification,
                                revisionid, enteredby, dateentered,
                                lastupdated, updatedby, subid)
                            values ($newrowid, '$settings{item}', 
                                $nrcdescription, $standarddescription, 
                                $position, $justification, $settings{rid}, 
                                $settings{userid}, sysdate, 
                                sysdate, $settings{userid}, $subid)";
    }
#print STDERR "$insertorupdate\n";
    $csr = $args{dbh} -> prepare ($insertorupdate);
    $csr -> execute;
    $csr -> finish;
    return ($newrowid);
}

######################
sub processAQAPEntry {
######################
    my %args = (
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $csr;
   
    my $revision = &processRevisionEntry (dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, userID => $args{userID}, form => $args{form}, settings => \%settings);
#    my $revision = &processAQAPEntry (dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, userID => $args{userID}, form => $args{form}, settings => \%settings);

    return ($revision);
}

######################
sub processQAMPEntry {
######################
    my %args = (
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $csr;
   
    my $revision = &processRevisionEntry (dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, userID => $args{userID}, form => $args{form}, settings => \%settings);

    return ($revision);
}

########################
sub processAddApprover {
########################
    my %args = (
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $csr;

    my $insert = "insert into qardapprover (id, name) values (qardapprover_id_seq.nextval, '$settings{approvername}')";
    $csr = $args{dbh} -> do ($insert);

    return ($settings{approvername});
}

################
sub getFullTOC {
################
    my %args = (
        where => '',
        orderby => '',
        revisionid => 0,
        @_,
    );
    my @fulltoc;
    my $i = 1;
    my $where = ($args{where}) ? " and $args{where}" : "";
    my $orderby = ($args{orderby}) ? ", $args{orderby}" : "";
=pod
    my $main = "select id, tocid, title from $args{schema}.qardtoc where revisionid = $args{revisionid} and isdeleted = 'F' $where order by id $orderby";
    my $csr = $args{dbh} -> prepare ($main);
    $csr -> execute;
    while (my ($tid, $tocid, $toctitle) = $csr -> fetchrow_array) { 
        $fulltoc[$i]{id} = $tid;
        $fulltoc[$i]{tocid} = $tocid;
        $fulltoc[$i]{title} = $toctitle; 
        $fulltoc[$i]{issec} = 0; 
=cut
        my $secondary = "select id, sectionid, title from $args{schema}.qardsection where qardrevid = $args{revisionid} and istoc = 'T' and isdeleted = 'F' $where order by tocid, sorter, sectionid, subid";
#        my $secondary = "select id, sectionid, title from $args{schema}.qardsection where istoc = 'T' and isdeleted = 'F' and tocid = $tid order by sorter, sectionid, subid";
#print STDERR "$secondary\n";
        my $csr2 = $args{dbh} -> prepare ($secondary);
        $csr2 -> execute;
        while (my ($t2id, $toc2id, $toc2title) = $csr2 -> fetchrow_array) {
#            $i++;
            $fulltoc[$i]{id} = $t2id;
            $fulltoc[$i]{tocid} = $toc2id;
            $fulltoc[$i]{title} = $toc2title;        
            $fulltoc[$i]{issec} = 1; 
            $i++;
        }
        $csr2 -> finish; 
#        $i++;
=pod
    }
    $csr -> finish;
=cut
    return (@fulltoc);
}


############################
sub processMatrixEntryStoQ {
############################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $csr;
    my $title = "";

    my $qardsectionid = ($settings{rid}) ? $settings{rid} : 0;

    my $stmt;
    my $matrixid = ($settings{matrixid}) ? $settings{matrixid} : 0;
    my $sourceid = $settings{sourceid} ? $settings{sourceid} : 0;
    ($title) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "title", table => "matrix", where => "id = $matrixid");

    my $sectRef = $settings{subsections};
    my @sectList = @$sectRef;

#=pod
    my ($sourcetype, $sourcetypeid) = $args{dbh} -> selectrow_array ("select t.abbrev, t.id from $args{schema}.source s, $args{schema}.sourcetype t where s.id = $settings{sourceid} and t.id = s.typeid");

    my $oldcriteria = "The previously assigned criteria were: ";
    my $tmpolds = "";
    my $oc = $args{dbh} -> prepare ("select c.sectionid || ' - ' || c.requirementid from $args{schema}.sourcerequirement c, $args{schema}.qardmatrix m where m.matrixid = $matrixid and m.qardsectionid = $qardsectionid and m.sourcerequirementid = c.id");
    $oc -> execute;
    while (my ($ocidlong) = $oc -> fetchrow_array) {
        $tmpolds .= "$ocidlong, ";
    }
    $oc -> finish;
    if ($tmpolds ne "") {
        chop ($tmpolds);
        chop ($tmpolds);
        $oldcriteria .= "$tmpolds.";
    }
    else {
        $oldcriteria .= "None.";
    }

    $args{dbh} -> do("DELETE FROM $args{schema}.qardmatrix WHERE matrixid = $matrixid and qardsectionid=$qardsectionid");
    my $newcriteria = "The newly assigned criteria are: ";
    my $tmpnews = "";
    for (my $i = 0; $i <= $#sectList; $i++) {
        my $sqlcode = "";
        if ($settings{qardtypeid} == 1) {
            my ($sourceidlong) = $args{dbh} -> selectrow_array ("select sectionid || ' - ' || requirementid from $args{schema}.sourcerequirement where id = $sectList[$i]");
            $tmpnews .= "$sourceidlong, ";
            my $howmanytypes = "select count (*) from $args{schema}.qardmatrix m, $args{schema}.source s, $args{schema}.sourcerequirement r where m.qardsectionid = $sectList[$i] and s.typeid <> $sourcetypeid and m.sourcerequirementid = r.id and r.sourceid = s.id";
#print STDERR "$howmanytypes\n";
            my ($whattype) = $args{dbh} -> selectrow_array ($howmanytypes);
#print STDERR "$whattype\n";
            my $updatesection = ($whattype > 0) ? $args{dbh} -> do ("update $args{schema}.qardsection set types = 'M' where id = $sectList[$i]") : $args{dbh} -> do ("update $args{schema}.qardsection set types = '$sourcetype' where id = $qardsectionid");
        }
        $sqlcode = "INSERT INTO $args{schema}.qardmatrix (matrixid, sourcerequirementid, qardsectionid, updatedby, sourcetypeabbrev) VALUES ($matrixid, $sectList[$i], $qardsectionid, $settings{userid}, '$sourcetype')";
#print STDERR "$sqlcode\n";
        $args{dbh} -> do ($sqlcode);
    }
    if ($tmpnews ne "") {
        chop ($tmpnews);
        chop ($tmpnews);
        $newcriteria .= "$tmpnews.";
    }
    else {
        $newcriteria .= "None.";
    }

#### Matrix status update ####
    my $mup = "update matrix set statusid = 1, 
                                 updatedby = $settings{userid},
                                 lastupdated = SYSDATE 
                             where id = $matrixid";
    $args{dbh} -> do ($mup);

#=cut

    return ($title, $newcriteria, $oldcriteria);
}

###############
1; #return true



