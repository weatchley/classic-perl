# DB Requirement functions
#
# $Source: /usr/local/homes/higashis/www/gov.doe.ocrwm.ydappdev/rcs/prp/perl/RCS/DBRequirement.pm,v $
# $Revision: 1.17 $
# $Date: 2006/06/14 20:36:21 $
# $Author: naydenoa $
# $Locker: higashis $
#
# $Log: DBRequirement.pm,v $
# Revision 1.17  2006/06/14 20:36:21  naydenoa
# Passed criterion id to driver.
#
# Revision 1.16  2006/06/13 23:36:18  naydenoa
# CREQ00078 - collected past and current assigned criteria for log expansion.
# Applied to CM updates.
#
# Revision 1.15  2006/01/20 16:46:52  naydenoa
# CREQ000074
# Updated matrix processing to account for deleted links in matrices when
# setting the color-coding variable for qard sections.
#
# Revision 1.14  2006/01/06 17:46:00  naydenoa
# Added return values for matrix processing.
#
# Revision 1.13  2005/12/16 23:21:06  naydenoa
# CREQ00070 - correct notes and justifications processing on matrix assignment.
#
# Revision 1.12  2005/09/28 23:01:11  naydenoa
# Minor tweaks to matrix processing - phase 3
#
# Revision 1.11  2005/09/27 23:11:35  naydenoa
# Tweaks on matrix approval processing - Phase 3 implementation
#
# Revision 1.10  2005/09/20 22:55:43  naydenoa
# Phase 3 development completion - see AR document for details
# Accommodate creation and update of AQAP matrices
#
# Revision 1.9  2005/03/15 21:27:24  naydenoa
# Added dual select processing for table 1a items assignment on
# compliance matrix entry/update - CREQ00042
#
# Revision 1.8  2005/02/17 16:35:40  naydenoa
# CREQ00034 - updated processing on matrix/requirement entry to enhance
# color-coded retrieval on browse
#
# Revision 1.7  2004/09/30 21:16:28  naydenoa
# Fixed bug with clob processing - part of CREQ00029 fulfillment
#
# Revision 1.6  2004/09/29 23:42:30  naydenoa
# Updated handling of YMP position on insert/update of source requirement -
# conversion to clob due to data size - CREQ00029
#
# Revision 1.5  2004/09/15 15:13:18  naydenoa
# Added matrix id to delete statement for matrix repopulation - CREQ00022
#
# Revision 1.4  2004/07/23 19:42:41  naydenoa
# Updated requirement entry processing (add sorter column) - CREQ00007
#
# Revision 1.3  2004/06/18 18:06:14  naydenoa
# Added OCRWM position and justification processing for source reqs - CR00004
#
# Revision 1.2  2004/06/15 23:06:05  naydenoa
# Added QARD section assignment in fulfillment of Phase 1, Cycle 2 requirements
#
# Revision 1.1  2004/04/22 20:29:11  naydenoa
# Initial revision
#
#

package DBRequirement;

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
        &processSourceRequirementEntry   &processUndelete    
        &processSourceMatrixEntry        &processApproveMatrix
    );
%EXPORT_TAGS =( 
    Functions => [qw(
        &processSourceRequirementEntry   &processUndelete
        &processSourceMatrixEntry        &processApproveMatrix
    )]
);

###################################
sub processSourceRequirementEntry {
###################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $requirementid = ($settings{requirementid}) ? "$settings{requirementid}" : "0";

    my $outstr = ""; 
    $outstr .= "<input type=hidden name=rid value=$settings{rid}>\n";
    $outstr .= "<input type=hidden name=isupdate value=$settings{isupdate}>\n";
    $outstr .= "<input type=hidden name=sourceid value=$settings{sourceid}>\n";
    $outstr .= "<input type=hidden name=sid value=$settings{sourceid}>\n";
    my $matrixid = $settings{matrixid};
    my $stmt;
    my $newid = $settings{qrid};
    $settings{qrtext} =~ s/\'/\'\'/g;

    $settings{ocrwmposition} =~ s/\'/\'\'/g;
    $settings{ocrwmjustification} =~ s/\'/\'\'/g;
    my $ocrwmposition2 = ($settings{ocrwmposition}) ? ":ocrwmposition" : "NULL";
#    my $ocrwmposition = ($settings{ocrwmposition}) ? "'$settings{ocrwmposition}'" : "NULL";
    my $ocrwmjustification = ($settings{ocrwmjustification}) ? "'$settings{ocrwmjustification}'" : "NULL";
    my $isdeleted = ($settings{isdeleted} eq "T") ? "'T'" : "'F'";
    my $table1aid = ($settings{table1aid}) ? $settings{table1aid} : "NULL";
		
		    if ($newid) {
		        $stmt = "update $args{schema}.sourcerequirement
		                 set sourceid = $settings{sourceid},
		                     sectionid = '$settings{qrsectionid}',
		                     text = '$settings{qrtext}',
		                     requirementid = $requirementid,
		                     ocrwmposition = $ocrwmposition2,
		                     ocrwmjustification = $ocrwmjustification,
		                     sorter = '$settings{sorter}',
		                     table1aid = $table1aid,
		                     isdeleted = $isdeleted,
		                     lastupdated = SYSDATE,
		                     updatedby = $settings{userid}
		                 where id = $newid";
		    }
		    else {
		        $newid = &getNextID (dbh => $args{dbh}, schema => $args{schema}, table => "sourcerequirement");
		        $stmt = "insert into $args{schema}.sourcerequirement 
		                     (id, sourceid, sectionid, text, 
		                      requirementid, isdeleted, 
		                      ocrwmposition, ocrwmjustification, sorter,
		                      dateentered, enteredby, lastupdated, updatedby) 
		                 values 
		                     ($newid, $settings{sourceid}, '$settings{qrsectionid}',
		                      '$settings{qrtext}', $requirementid, $isdeleted,
		                      $ocrwmposition2, $ocrwmjustification,'$settings{sorter}',
		                      SYSDATE, $settings{userid}, SYSDATE, $settings{userid})";
		    }
		    my $csr = $args{dbh} -> prepare ($stmt);
		    $csr -> bind_param (":ocrwmposition", $settings{ocrwmposition}, {ora_type => ORA_CLOB, ora_field => 'ocrwmposition'}) if $settings{ocrwmposition};
		    $csr -> execute;
		    $csr -> finish;
	 
    return ($outstr);
}

##############################
sub processSourceMatrixEntry {
##############################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $requirementid = ($settings{requirementid}) ? "$settings{requirementid}" : "0";

    my $stmt;
    my $newid = $settings{qrid};
    my $matrixid = ($settings{matrixid}) ? $settings{matrixid} : 0;

    my $sectRef = $settings{subsections};
    my @sectList = @$sectRef;
    my $t1aRef = $settings{table1a};
    my @t1aList = @$t1aRef;

    $settings{ocrwmposition} =~ s/\'/\'\'/g;
    $settings{ocrwmjustification} =~ s/\'/\'\'/g;
    my $ocrwmposition2 = ($settings{ocrwmposition}) ? ":ocrwmposition" : "NULL";
#    my $ocrwmposition = ($settings{ocrwmposition}) ? "'$settings{ocrwmposition}'" : "NULL";
    my $ocrwmjustification = ($settings{ocrwmjustification}) ? "'$settings{ocrwmjustification}'" : "NULL";

    my ($sourcetype, $sourcetypeid) = $args{dbh} -> selectrow_array ("select t.abbrev, t.id from $args{schema}.source s, $args{schema}.sourcetype t where s.id = $settings{sourceid} and t.id = s.typeid");
my ($criterion) = $args{dbh} -> selectrow_array ("select sectionid || ' - ' || requirementid from $args{schema}.sourcerequirement where id = $newid");

#### Add/update notes and justifications ####


	# added 02/08/08 - sh
    if ($settings{rid} >= 30) { #rid:30 == revision 20    
    	
		     $stmt = "update $args{schema}.sourcerequirement
                 set  lastupdated = SYSDATE,
                     updatedby = $settings{userid}
                 where id = $newid";
   			 my $csr = $args{dbh} -> prepare ($stmt);
    		$csr -> execute;
            $csr -> finish;
		    		    
    		my $stmt2; 
		    my $testid;	    
		    ($testid) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "rid", table => "srnotes", where => "srid = $settings{qrid} and rid = $settings{rid}")  if $settings{qrid};
		   if($testid){
		    	$stmt2 = "update $args{schema}.srnotes set ocrwmposition = $ocrwmposition2, ocrwmjustification = $ocrwmjustification  where srid = $newid and rid = $settings{rid}";
		   }else{
		    	$stmt2 = "insert into $args{schema}.srnotes (srid, ocrwmposition, ocrwmjustification,rid)	values ($newid,$ocrwmposition2, $ocrwmjustification,$settings{rid})";
		   }		    
		    my $csr2 = $args{dbh} -> prepare ($stmt2);
		    $csr2 -> bind_param (":ocrwmposition", $settings{ocrwmposition}, {ora_type => ORA_CLOB, ora_field => 'ocrwmposition'}) if $settings{ocrwmposition};
		    $csr2 -> execute;
		    $csr2 -> finish;
		    
    
    }else{

        $stmt = "update $args{schema}.sourcerequirement
                 set ocrwmposition = $ocrwmposition2,
                     ocrwmjustification = $ocrwmjustification,
                     lastupdated = SYSDATE,
                     updatedby = $settings{userid}
                 where id = $newid";
    my $csr = $args{dbh} -> prepare ($stmt);
    $csr -> bind_param (":ocrwmposition", $settings{ocrwmposition}, {ora_type => ORA_CLOB, ora_field => 'ocrwmposition'}) if $settings{ocrwmposition};
    $csr -> execute;
    $csr -> finish;

    }

####  Matrix modification ####

## reset previously associated QARD sections to N/A prior to any deletions ## 
    my $oldsections = "The previously assigned QARD sections were: ";
    my $tmpolds = "";
    if ($settings{qardtypeid} == 1) {
        my $getqardsectionsfrommatrix = $args{dbh} -> prepare ("select m.qardsectionid, s.sectionid || ' - ' || s.subid from $args{schema}.qardmatrix m, $args{schema}.qardsection s where m.matrixid = $matrixid and m.sourcerequirementid = $newid and m.qardsectionid = s.id");
        $getqardsectionsfrommatrix -> execute;
        while (my ($theqid, $thelongsectid) = $getqardsectionsfrommatrix -> fetchrow_array) {
             $tmpolds .= "$thelongsectid, ";
             my $colortypes = $args{dbh} -> prepare ("select distinct s.typeid from qardmatrix m, sourcerequirement r, source s where m.qardsectionid = $theqid and m.sourcerequirementid = r.id and r.sourceid = s.id");
             $colortypes -> execute;
             my $colortypecount = 0;
             my $ct = 0;
             my $thect = 0;
             my $tmptype = "N";
             while (my ($ct) = $colortypes -> fetchrow_array) {
                 if ($ct != $sourcetypeid) {
                     $colortypecount++;
                     $thect = $ct;
                 }
             }
             $colortypes -> finish;
             if ($colortypecount == 1) {
                 ($tmptype) = $args{dbh} -> selectrow_array ("select abbrev from $args{schema}.sourcetype where id = $thect");                 
             }
             elsif ($colortypecount > 1) {
                 $tmptype = "M";
             }
             my $prepsection = $args{dbh} -> do ("update $args{schema}.qardsection set types = '$tmptype' where id = $theqid");
        } 
        $getqardsectionsfrommatrix -> finish;
    }
    if ($tmpolds ne "") {
        chop ($tmpolds);
        chop ($tmpolds);
        $oldsections .= "$tmpolds.";
    }
    else {
        $oldsections .= "None."
    }
### end reset ###

### delete old matrix entries ###    
    $args{dbh} -> do("DELETE FROM $args{schema}.qardmatrix WHERE matrixid = $matrixid and sourcerequirementid=$newid");

### add new matrix entries and set the type variable for qard sections ###
    my $newsections = "The newly assigned QARD sections are: ";
    my $tmpnews = "";
    for (my $i = 0; $i <= $#sectList; $i++) {
        my ($longsectid) = $args{dbh} -> selectrow_array ("select sectionid || ' - ' || subid from $args{schema}.qardsection where id = $sectList[$i]");
        $tmpnews .= "$longsectid, ";
        my $sqlcode = "";
        if ($settings{qardtypeid} == 1) {
            my $howmanytypes = "select count (*) from $args{schema}.qardmatrix m, $args{schema}.source s, $args{schema}.sourcerequirement r where m.qardsectionid = $sectList[$i] and s.typeid <> $sourcetypeid and m.sourcerequirementid = r.id and r.sourceid = s.id";
            my ($whattype) = $args{dbh} -> selectrow_array ($howmanytypes);
            my $updatesection = ($whattype > 0) ? $args{dbh} -> do ("update $args{schema}.qardsection set types = 'M' where id = $sectList[$i]") : $args{dbh} -> do ("update $args{schema}.qardsection set types = '$sourcetype' where id = $sectList[$i]");
        }
        $sqlcode = "INSERT INTO $args{schema}.qardmatrix (matrixid, qardsectionid, sourcerequirementid, updatedby, sourcetypeabbrev) VALUES ($matrixid, $sectList[$i], $newid, $settings{userid}, '$sourcetype')";
        $args{dbh} -> do ($sqlcode);
    }
    if ($tmpnews ne "") {
        chop ($tmpnews);
        chop ($tmpnews);
        $newsections .= "$tmpnews.";
    }
    else {
        $newsections .= "None.";
    }

#### Matrix status update ####
    my $mup = "update matrix set statusid = 1, 
                                 updatedby = $settings{userid},
                                 lastupdated = SYSDATE 
                             where id = $matrixid";
    $args{dbh} -> do ($mup);

#### QARD Table 1A additions (if any) ####
#$settings{rid}
    if ($settings{qardtypeid} == 1) {        
        #$args{dbh} -> do ("delete from $args{schema}.requirementtable1a where requirementid = $newid");  #original 02/07/08
        
        	 if ($settings{rid} >= 30) { 	#rid:30 == revision 20
        		$args{dbh} -> do ("delete from $args{schema}.requirementtable1a where requirementid = $newid and rid =$settings{rid}");
        	 }else{
         		$args{dbh} -> do ("delete from $args{schema}.requirementtable1a where requirementid = $newid and rid is null"); 
         	}
         	
            #original 02/07/08       
	            # for (my $i = 0; $i <= $#t1aList; $i++) {    
	            #my $addt1a = "insert into $args{schema}.requirementtable1a (requirementid, table1aid) values ($newid, $t1aList[$i])";  
	            #$args{dbh} -> do ($addt1a);
	       		#}
                  
             if ($settings{rid} >= 30) { #rid:30 == revision 20             	
	             	 for (my $i = 0; $i <= $#t1aList; $i++) {            
		            	my $addt1a = "insert into $args{schema}.requirementtable1a (requirementid, table1aid, rid) values ($newid, $t1aList[$i], $settings{rid})"; 
		            	$args{dbh} -> do ($addt1a);
		       		 }
             }else{
             	    for (my $i = 0; $i <= $#t1aList; $i++) { 
             			my $addt1a = "insert into $args{schema}.requirementtable1a (requirementid, table1aid, rid) values ($newid, $t1aList[$i],null)";  
	                   $args{dbh} -> do ($addt1a);
	       		   }
             }
        
    }
    return ($matrixid, $settings{qardtypeid}, $oldsections, $newsections, $criterion);
}

#####################
sub processUndelete {
#####################
    my %args = (
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $id = $settings{qrid};

    my $undelete = "update $args{schema}.sourcerequirement set isdeleted = 'F' where id = $id";
    my $csr = $args{dbh} -> do ($undelete);

    return;
}

##########################
sub processApproveMatrix {
##########################
    my %args = (
         approve => 1,
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;

    my $status = $args{approve} ? 2 : 1;
    $settings{rationale} =~ s/\'/\'\'/g;
    my $rationale = $settings{rationale};
    $rationale = ($rationale) ? "'$rationale'" : "NULL";
    

    my $appstr = "update matrix set statusid = $status, dateapproved = SYSDATE, approvedby = $settings{userid}, rejectionrationale = $rationale where id = $settings{approvalmatrixid}";
    my $csr = $args{dbh} -> do ($appstr);

    return;
}

###############
1; #return true
