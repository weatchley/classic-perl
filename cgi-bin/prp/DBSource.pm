# DB Source functions
#
# $Source: /data/dev/rcs/prp/perl/RCS/DBSource.pm,v $
# $Revision: 1.6 $
# $Date: 2005/10/06 15:46:06 $
# $Author: naydenoa $
# $Locker:  $
#
# $Log: DBSource.pm,v $
# Revision 1.6  2005/10/06 15:46:06  naydenoa
# CREQ00065 - post-phase 3 tweaks - fixed AQAP source retrieval (guidance)
#
# Revision 1.5  2005/10/04 16:46:01  naydenoa
# CREQ00066 - add qardtypeid to insert/update statement.
#
# Revision 1.4  2005/09/28 23:03:02  naydenoa
# Minor tweaks - removed test prints; matrix processing - phase 3
#
# Revision 1.3  2005/09/27 23:14:41  naydenoa
# Phase 3 implementation
# Added functions to add and retrieve source doc types
# Tweaks in matrix processing on add/update and retrieval
#
# Revision 1.2  2004/06/15 23:10:16  naydenoa
# Added compliance matrix processing functionality - phase 1, cycle 2
#
# Revision 1.1  2004/04/22 20:31:56  naydenoa
# Initial revision
#
#

package DBSource;

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
        &processSourceEntry    &processMatrixEntry    &processUndelete
        &processAddSourceType  &getSourceType
    );
%EXPORT_TAGS =( 
    Functions => [qw(
        &processSourceEntry    &processMatrixEntry    &processUndelete
        &processAddSourceType  &getSourceType
    )]
);

########################
sub processSourceEntry {
########################
    my %args = (
         fileName => '',
         file => '',
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $qardtypeid = $settings{qardtypeid};
    $settings{sourcetitle} =~ s/\'/\'\'/g;
    $settings{sourcedesignation} =~ s/\'/\'\'/g;
    my $docdate = ($settings{docdate_year}) ? ", to_date('$settings{docdate_month}/$settings{docdate_day}/$settings{docdate_year}','MM/DD/YYYY')" : "";
    my $docdateupdate = ($settings{docdate_year}) ? ", docdate = to_date('$settings{docdate_month}/$settings{docdate_day}/$settings{docdate_year}','MM/DD/YYYY')" : "";
    my $adddocdate = ($docdate) ? ", docdate" : "";
    my $adddocimage = ""; 
    my $imageinsertstring = "";
    my $imageupdate = "";
    my $isdeleted = ($settings{isdeleted} eq "T") ? "'T'" : "'F'";
    my $url = ($settings{sourceurl}) ? "'$settings{sourceurl}'" : "NULL";
 
    my $sourcedocumentfile = $args{file};
    my $sourcefilename = $args{fileName};   
    $sourcefilename =~ s/\\/\//g;
    $sourcefilename = substr($sourcefilename,(rindex($sourcefilename,'/')+1));
    my $whereisdot = index ($sourcefilename, ".");
    my $sourcefiletype = substr ($sourcefilename, ($whereisdot + 1), 5);
    my ($mimetype) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, table => "mimetypes", where => "filetype = '$sourcefiletype'", what => "mimetype"); 
    if ($sourcefilename) {
        $adddocimage = ", document, name, imagecontenttype, imageextension";
	$imageinsertstring = ", :document, '$sourcefilename', '$mimetype', '$sourcefiletype'";
        $imageupdate = ", document = :document, name = '$sourcefilename', imagecontenttype = '$mimetype', imageextension = '$sourcefiletype'";
    }    
 
    my $sourcestr = "";
    if ($settings{isupdate} == 0) {
        $sourcestr = "insert into $args{schema}.source 
                          (id, designation, title, typeid, matrixstatusid,
                          isdeleted, url, dateentered, lastupdated, enteredby,
                          updatedby, qardtypeid $adddocdate $adddocimage)
                      values ($args{schema}.source_id_seq.nextval, 
                          '$settings{sourcedesignation}', 
                          '$settings{sourcetitle}', $settings{sourcetypeid}, 
                          $settings{sourcematrixstatusid}, $isdeleted, $url, 
                          SYSDATE, SYSDATE, $settings{userid}, 
                          $settings{userid}, $qardtypeid $docdate 
                          $imageinsertstring)";
    }
    else {
        $sourcestr = "update $args{schema}.source
                      set designation = '$settings{sourcedesignation}',
                          title = '$settings{sourcetitle}',
                          typeid = $settings{sourcetypeid},
                          matrixstatusid = $settings{sourcematrixstatusid},
                          url = $url, isdeleted = $isdeleted,
                          lastupdated = SYSDATE, updatedby = $settings{userid},
                          qardtypeid = $qardtypeid 
                          $docdateupdate $imageupdate
                      where id = $settings{sourceid}";
    }
    my $csr = $args{dbh} -> prepare ($sourcestr);
    if ($sourcefilename) {
        $csr -> bind_param(":document", $sourcedocumentfile, { ora_type => ORA_BLOB, ora_field=>'document' });
    }
    $csr -> execute;
    $csr -> finish;
    return;
}

########################
sub processMatrixEntry {
########################
    my %args = (
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    $settings{matrixtitle} =~ s/\'/\'\'/g;
    my $isdeleted = ($settings{isdeleted} eq "T") ? "'T'" : "'F'";
    my $qardtypeid = $settings{qardtypeid};
    my $sourceid = 0;
    my $sourceid2 = 0;

    $sourceid = $settings{sourceid} if ($qardtypeid == 1);
    if ($qardtypeid == 2) {
        ($sourceid) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "max(id)", table => "source", where => "typeid = 5 and qardtypeid = $qardtypeid"); 
        ($sourceid2) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "max(id)", table => "source", where => "typeid = 3 and qardtypeid = $qardtypeid"); 
    }

    my $matrixstr = "";
    if ($settings{isupdate}) {
        $matrixstr = "update $args{schema}.matrix 
                      set title = '$settings{matrixtitle}',
                          sourceid = $sourceid,
                          qardid = $settings{rid},
                          isdeleted = $isdeleted,
                          updatedby = $settings{userid},
                          lastupdated = SYSDATE
                      where id = $settings{matrixid} and sourceid = $sourceid";
    }
    else {
        $matrixstr = "insert into $args{schema}.matrix (id, title, sourceid, qardid, isdeleted, enteredby, dateentered, lastupdated, updatedby) values (matrix_id_seq.nextval, '$settings{matrixtitle}', $sourceid, $settings{rid}, $isdeleted, $settings{userid}, SYSDATE, SYSDATE, $settings{userid})";
    }
    my $csr = $args{dbh} -> prepare ($matrixstr);
    $csr -> execute;
    $csr -> finish;

    if ($qardtypeid == 2) {
        if ($settings{isupdate}) {
            $matrixstr = "update $args{schema}.matrix 
                           set title = '$settings{matrixtitle}',
                               sourceid = $sourceid2,
                               qardid = $settings{rid},
                               isdeleted = $isdeleted,
                               updatedby = $settings{userid},
                               lastupdated = SYSDATE
                           where id = $settings{matrixid} and sourceid = $sourceid2";
        }
        else {
            $matrixstr = "insert into $args{schema}.matrix (id, title, sourceid, qardid, isdeleted, enteredby, dateentered, lastupdated, updatedby) values (matrix_id_seq.currval, '$settings{matrixtitle}', $sourceid2, $settings{rid}, $isdeleted, $settings{userid}, SYSDATE, SYSDATE, $settings{userid})";
        }
        $csr = $args{dbh} -> prepare ($matrixstr);
        $csr -> execute;
        $csr -> finish;
    }

    return;
}

#####################
sub processUndelete {
#####################
    my %args = (
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $id = ($settings{what} eq "matrix") ? $settings{matrixid} : $settings{sid};
    my $undelete = "update $args{schema}.$settings{what} set isdeleted = 'F' where id = $id";
    my $csr = $args{dbh} -> do ($undelete);

    return;
}

##########################
sub processAddSourceType {
##########################
    my %args = (
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my ($id) = $args{dbh} -> selectrow_array ("select max (id) from $args{schema}.sourcetype");
    $id++;
    my $addtype = "insert into $args{schema}.sourcetype (id, description) values ($id, '$settings{sourcetype}')";
#    my $addtype = "insert into $args{schema}.sourcetype (id, description, qardtypeid) values ($id, '$settings{sourcetype}', $settings{qardtypeid})";
    my $csr = $args{dbh} -> do ($addtype);

    return; 
}

###################
sub getSourceType {
###################
    my %args = (
         where => '',
         orderby => '',
         @_,
    );
    my @stypes;
    my $i = 0;
    my $where = $args{where} ? "where $args{where}" : "";
    my $orderby = $args{orderby} ? "order by $args{orderby}" : "order by weight desc";

    my $select = "select id, description from $args{schema}.sourcetype $where $orderby";
    my $csr = $args{dbh} -> prepare ($select);
    $csr -> execute;
    while (my ($id, $desc) = $csr -> fetchrow_array) {
        $i++;
        $stypes[$i]{id} = $id;
        $stypes[$i]{description} = $desc;
    }
    $csr -> finish;

    return (@stypes);
}

###############
1; #return true

