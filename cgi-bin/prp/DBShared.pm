#!/usr/local/bin/perl -w
#
# $Source: /usr/local/homes/higashis/www/gov.doe.ocrwm.ydappdev/rcs/prp/perl/RCS/DBShared.pm,v $
# $Revision: 1.18 $
# $Date: 2005/09/28 23:01:55 $
# $Author: naydenoa $
# $Locker: higashis $
#
# $Log: DBShared.pm,v $
# Revision 1.18  2005/09/28 23:01:55  naydenoa
# Minor tweks - removed test prints - phase 3
#
# Revision 1.17  2005/09/27 23:12:27  naydenoa
# Phase 3 implementation; added function to retrieve matrices info.
#
# Revision 1.16  2005/07/08 22:13:32  naydenoa
# Added type retrieval for QA docs
#
# Revision 1.15  2005/03/22 18:40:52  naydenoa
# Moved Table 1A retrieval funtion from DBQARD to enable use by
# multiple UI scripts - partial fulfillment of CREQ00043 and CREQ00044
#
# Revision 1.14  2005/03/15 21:29:47  naydenoa
# Added retrieval of istoc attribute for QARD sections - CREQ00042
#
# Revision 1.13  2005/02/17 16:36:45  naydenoa
# CREQ00034, CREQ00039 - updated QARD and requirements retrieval to add new
# columns for colors (QARD) and Table 1a linking.
#
# Revision 1.12  2004/08/30 21:32:03  naydenoa
# CREQ00010 - formatted dates on QARD rev retrieval for browse
#
# Revision 1.11  2004/08/11 15:00:46  naydenoa
# Updated sort and filtering for requirements - CREQ00015
#
# Revision 1.10  2004/08/05 17:18:13  naydenoa
# Add sort by requirement ID - CREQ00007
#
# Revision 1.9  2004/08/05 17:14:23  naydenoa
# Fixed sort - CREQ00007
#
# Revision 1.8  2004/07/23 19:49:37  naydenoa
# Misdeclared variabnle $sorter - clean-up
#
# Revision 1.7  2004/07/23 19:41:37  naydenoa
# Updated requirements retrieval - CREQ00007
#
# Revision 1.6  2004/07/19 23:15:53  naydenoa
# Fulfillment of CREQ00013
#
# Revision 1.5  2004/06/18 18:04:16  naydenoa
# Added new data retrieval for source requirements - CR00004
#
# Revision 1.4  2004/06/17 22:28:55  naydenoa
# Fixed QARD sections data retrieval - removed obsolete columns
#
# Revision 1.3  2004/06/15 23:08:23  naydenoa
# Added more options to source document retrieval in function getSourceDocs
#
# Revision 1.2  2004/04/23 23:06:10  naydenoa
# Removed test reference to non-existing column in sourcerequirement
#
# Revision 1.1  2004/04/22 20:31:15  naydenoa
# Initial revision
#
#

package DBShared;
use strict;
use Carp;
use SharedHeader qw(:Constants);
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw($DBUser $SYSConnectPath $SYSServer);
use Tie::IxHash;
use DBI;
use DBD::Oracle qw(:ora_types);

$DBUser = $ENV{'DBUser'};
$SYSConnectPath = $ENV{'SYSConnectPath'};
$SYSServer = $ENV{'SYSServer'};

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw (
      &db_connect          &db_disconnect          &getSysdate           
      &createSequence      &db_encrypt_password    &updateActivityLog
      &doesUserHavePriv    &get_fullname           &get_date
      &getFullName         &getUserID              &getUserName
      &logError            &logActivity            &getLookupValues    
      &getSingleRow        &getCount               &getSections
      &getSourceDocs       &getSourceRequirements  &getNextID
      &getQARDRevs         &getTable               &getMatrices
);
@EXPORT_OK = qw(
      &db_connect          &db_disconnect          &getSysdate           
      &createSequence      &db_encrypt_password    &updateActivityLog
      &doesUserHavePriv    &get_fullname           &get_date
      &getFullName         &getUserID              &getUserName
      &logError            &logActivity            &getLookupValues    
      &getSingleRow        &getCount               &getSections
      &getSourceDocs       &getSourceRequirements  &getNextID
      &getQARDRevs         &getTable               &getMatrices
);
%EXPORT_TAGS =(
    Functions => [qw(
      &db_connect          &db_disconnect          &getSysdate           
      &createSequence      &db_encrypt_password    &updateActivityLog
      &doesUserHavePriv    &get_fullname           &get_date
      &getFullName         &getUserID              &getUserName
      &logError            &logActivity            &getLookupValues    
      &getSingleRow        &getCount               &getSections
      &getSourceDocs       &getSourceRequirements  &getNextID
      &getQARDRevs         &getTable               &getMatrices
    ) 
]);



############
sub caesar {  # caesar cipher
############
    my $text = shift;
    my $key = shift;
    
    #key of 0 does nothing
    my $ks = $key % 26 or return $text;
    my $ke = $ks -1;
    
    my ($s, $S, $e, $E);
    $s = chr(ord('a') + $ks);
    $S = chr(ord('A') + $ks);
    $e = chr(ord('a') + $ke);
    $E = chr(ord('A') + $ke);
    
    eval "\$text =~ tr/a-zA-Z/$s-za-$e$S-ZA-$E/;";
    
    return $text;
}


#############
sub decrypt {  # description code
#############
    my %args = (
          text => '',
          key => '',
          depth => 5,
          @_,
          );
    
    my $outString = '';
    my $testKey = $args{key};
    my $text = '';
    for (my $i=0; $i<length($args{text}); $i += 3) {
        $text .= chr(substr($args{text}, $i, 3));
    }
    while (length($testKey) < (length($text) + $args{depth})) {
        $testKey .= $args{key};
    }
    
    for (my $i=0; $i<length($text); $i++) {
        my $temp = substr($text,$i,1);
        for (my $j=0; $j<$args{depth}; $j++) {
            my $keySeg = substr($testKey,($i + ($args{depth} - $j -1)),1);
            $temp = $temp ^ $keySeg;
            $temp = caesar($temp, ((26-($i+1))%26));
        }
        $outString .= $temp;
    }
    
    return ($outString);
}


#################
sub getOracleID { # Get uname/passwd for oracle. Helper fn for db_connect.
#################
    my $username = $DBUser;
    my $password;
    my $temp;
    if (open (FH, "$SYSConnectPath |")) {
       ($temp, $password) = split('//', <FH>);
        chomp($password);
        $password = decrypt(text => $password, key => $SYSPassKey);
        close (FH);
    } else {
        $username = "null";
        $password = "null";
    }
    return ($username, $password);
}

################
sub db_connect {  # Routine to connect to the oracle database.
################
    my %args = (
          server => $SYSServer,
          @_,
          );
    my $dbh;
    my $username;
    my $password;
    ($username, $password) = getOracleID;
    eval {
    	  $dbh = DBI->connect("dbi:Oracle:$args{server}",$username,$password, { RaiseError => 1, AutoCommit => 0 });
    };
    if ($@) {
        print STDERR "\nDBShared.pm/db_connect - Error Message: $@\n";
    }
    return ($dbh);
}


###################
sub db_disconnect {  # routine to disconnect from the oracle database
###################
    my $dbh = $_[0];
    my $rc;
    eval {
        $rc = $dbh->disconnect;
    };
    if ($@) {
        print STDERR "\nDBShared.pm/db_disconnect - Error Message: $@\n";
    }
    return ($rc);
}

#########################
sub db_encrypt_password {  # routine to encrypt a password
#########################
    my $input_password = $_[0];
    $input_password = $input_password;
    my $password = crypt ($input_password, "database");
    if (length($input_password)>8) {
        $password .= crypt (substr($input_password, 8), "database");
    }
    while (length($password) > 26) {
        chop ($password);
    }
    return ($password);
}

###############
sub getUserID {  # routine to get a user id
###############
    my %args = (
          userName => "",
          @_,
          );

    my ($userID) = $args{dbh}->selectrow_array("SELECT id FROM $args{schema}.users WHERE username='$args{userName}'");
    
    return ($userID);
}

##############
sub logError { # Insert error into act log. Helper called by updateActivityLog
##############
    my %args = (
        schema => "$SCHEMA",
        userID => 0,
        logMessage => "",
        errorStatus => "T",
        type => 0,
        @_,
        );	
    return(updateActivityLog ($args{dbh}, $args{schema}, $args{userID}, $args{logMessage}, $args{errorStatus}, $args{type}));
}


#################
sub logActivity { # Insert error into act log. Called by updateActivityLog
#################
    my %args = (
        schema => "$SCHEMA",
        userID => 0,
        logMessage => "",
        errorStatus => "F",
        type => 0,
        @_,
        );	
    return(updateActivityLog ($args{dbh}, $args{schema}, $args{userID}, $args{logMessage}, $args{errorStatus}, $args{type}));
}


################
sub getSysdate {  #      Returns the system date from the oracle database.
################
	my %args = (
		schema => "$SCHEMA",
		@_,
        );	
	my $sqlquery = "SELECT TO_CHAR(sysdate, 'MM/DD/YYYY HH:MI:SS') FROM dual";
	my $sth = $args{dbh}->prepare($sqlquery);
	$sth->execute;
	return ($sth->fetchrow_array);
}

#######################
sub updateActivityLog { # Inserts an entry into the activity log
#######################
# Parameters: schema       - database schema	
#             dbh          - database handle 
#             userid       - id of the user
#             logmessage   - message to be logged into the activity log
#             errorstatus  - flag to denote an error or activity
    my $dbh = $_[0];
    my $schema = $_[1];
    my $userId = $_[2];
    my $logmessage = $_[3];
    my $errorStatus = $_[4];
    my $type = $_[5];
    my $status = 1;
    my $sqlquery = "INSERT INTO $schema.activity_log (userid, datelogged, iserror, description, type) "
                   . "VALUES ($userId, SYSDATE, '$errorStatus', '$logmessage', " . (($type != 0) ? $type : "NULL") . ")";
    eval {
        $dbh->do($sqlquery);
    };
    if ($@) {
        if ($errorStatus eq 'F') {
            logError(dbh => $dbh, schema => $schema, userID => $userId, logMessage => "Error writing message to activity log");
        }
        print STDERR "\nDBShared.pm/logError - Passed Message: $logmessage\n - Error Message: \"$@\"\n";
    } else {
		$dbh->commit;
	 }
    return ($status);
}

##############
sub formatID {
##############
# Returns a formatted time (either month, day, hour, second, or minute. 
# This is a helper function for the errorMesage routine.
   return (sprintf("$_[0]%0$_[1]d", $_[2]));
}

####################
sub createSequence { #  Create a sequence in the database schema.
####################
#  schema  - database schema
#  dbh     - database handle
#  acronym - acronym of the project
	my %args = (
		schema => "$SCHEMA",
		@_,
   );
	my $sqlquery = "CREATE SEQUENCE " . uc($args{schema}) . "." . uc($args{acronym}) . "_PRODUCT_SEQ MINVALUE 1";
	$args{dbh}->do($sqlquery);
}

######################
sub doesUserHavePriv { # routine to see if user has a specific priv
######################
    my %args = (
        userid => "0",
        privList => [0],
        privList2 => [0],
        privType => "number",
        @_,
    );
    my $status;
    my $rows;
    my $arrayRef = $args{privList};
    my @privs = @$arrayRef;
    $"=',';
    my $privlist = "(@privs)";
    $"='';
    if ($args{privType} eq "number") {
        ($rows) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.user_privilege WHERE (userid = $args{userid}) and (privilege IN $privlist)");
    } else {
        ($rows) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.user_privilege up, $args{schema}.system_privilege sp WHERE (up.userid = $args{userid}) and (sp.name IN $privlist)");
    }
    $status = (($rows >0) ? 1 : 0);
    return ($status);
}

#################
sub getUserName {  # routine to get a user name
#################
    my %args = (
        userID => 0,
        @_,
    );
    my ($output) = $args{dbh}->selectrow_array("SELECT username FROM $args{schema}.users WHERE id=$args{userID}");
    
    return($output);
}

##################
sub get_fullname {  # routine to get a user's full name
##################
    my $dbh = $_[0];
    my $schema = $_[1];
    my $userid = $_[2];
    my $csr;
    my @values;
    my $fullname;
    my $sqlquery = "select firstname, lastname from $schema.users where id = $userid";
        $csr = $dbh->prepare($sqlquery);
        $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
    $fullname = $values[0] . ' ' . $values[1];
    return ($fullname);
}

#################
sub getFullName {  # routine to get a user name
#################
    my %args = (
        userID => 0,
        @_,
    );
    my ($output) = $args{dbh}->selectrow_array("SELECT firstname || ' ' || lastname FROM $args{schema}.users WHERE id=$args{userID}");
    
    return($output);
}

#####################
sub getLookupValues {
#####################
    my %args = (
        table => "",
        idColumn => "",
        nameColumn => "",
        orderBy => "",
        where => "",
        @_,
    );
    tie my %lookupHash, "Tie::IxHash";
    %lookupHash = ();
    my $orderBy = ($args{orderBy}) ? "ORDER BY $args{orderBy}" : "";
    my $where = ($args{where}) ? "WHERE $args{where}" : "";
    my $lookup = $args{dbh}->prepare("SELECT $args{idColumn}, $args{nameColumn} FROM $args{schema}.$args{table} $where $orderBy");
    $lookup->execute;
    while (my @values = $lookup->fetchrow_array) {
        $lookupHash{$values[0]} = $values[1];
    }
    $lookup->finish;
    return (\%lookupHash);
}

##############
sub get_date {  # routine to generate an oracle friendly date
##############
    my $indate = $_[0];
    my $outstring = '';
    my $day; my $month; my $year;
    my @months = ("jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec");
    if (defined ($indate) && $indate gt ' ') {
        ($month, $day, $year) = split /\//, $indate;
        $month = $month -1;
    } else {
        ($day, $month, $year) = (localtime)[3,4,5];
        $year = $year + 1900;
    }
    $outstring .= "$day-$months[$month]-$year";
    return ($outstring);
}

##################
sub getSingleRow {
##################
    my %args = (
	schema => $ENV{SCHEMA},
        what => '',
        table => '',
        where => '',
        @_,
    );
    $args{dbh}->{LongReadLen} = 100000000;
    my $where = ($args{where}) ? "where $args{where}" : "";
    my $str = "select $args{what} from $args{schema}.$args{table} $where";
    my @result = $args{dbh} -> selectrow_array ($str);
    return (@result);
}

##############
sub getCount {
##############
    my %args = (
	schema => $ENV{SCHEMA},
        what => "count (*)",
        table => '',
        where => '',
        @_,
    );
    my ($count) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => $args{what}, table => $args{table}, where => $args{where});
    return ($count);
}

#################
sub getSections {
#################
    my %args = (
        where => '',
        orderby => '',
        @_,
    );
    $args{dbh}->{LongTruncOk} = 0;
    $args{dbh}->{LongReadLen} = 10000;
    my @sections;
    my $i = 0;
    my $where = ($args{where}) ? "where $args{where}" : "";
    my $orderby = ($args{orderby}) ? "order by $args{orderby}" : "";
    my $csr = $args{dbh} -> prepare ("select id, sectionid, title, enteredby, dateentered, lastupdated, updatedby, status, text, tocid, subid, sorter, types, istoc from $args{schema}.qardsection $where $orderby");
    $csr -> execute;
    while (my ($id, $sectionid, $title, $enteredby, $dateentered, $lastupdated, $updatedby, $status, $text, $tocid, $subid, $sorter, $types, $istoc) = $csr -> fetchrow_array) {
        $i++;
        $sections[$i]{id} = $id;
        $sections[$i]{sectionid} = $sectionid;
        $sections[$i]{title} = $title;
        $sections[$i]{enteredby} = $enteredby;
        $sections[$i]{dateentered} = $dateentered;
        $sections[$i]{lastupdated} = $lastupdated;
        $sections[$i]{updatedby} = $updatedby;
        $sections[$i]{status} = $status;
        $sections[$i]{text} = $text;
        $sections[$i]{tocid} = $tocid;
        $sections[$i]{subid} = $subid;
        $sections[$i]{sorter} = $sorter;
        $sections[$i]{types} = $types;
        $sections[$i]{istoc} = $istoc;
    }
    $csr -> finish;
    return (@sections);
}
###################
sub getSourceDocs {
###################
    my %args = (
        where => '',
        orderby => '',
        @_,
		);
    my @sourcedocs;
    my $i = 0;
    my $where = ($args{where}) ? "where $args{where}" : "";
    my $orderby = ($args{orderby}) ? "order by $args{orderby}" : "order by designation";
    my $csr = $args{dbh} -> prepare ("select id, designation, title, typeid, enteredby, dateentered, lastupdated, updatedby, to_char(docdate,'Month DD, YYYY'), revision, matrixstatusid, imagecontenttype, imageextension, isdeleted, url from $args{schema}.source $where $orderby");
    $csr -> execute;
    while (my ($id, $designation, $title, $typeid, $enteredby, $dateentered, $lastupdated, $updatedby, $docdate, $revision, $matrixstatusid, $imagecontenttype, $imageextension, $isdeleted, $url) = $csr -> fetchrow_array) {
        $i++;
        $sourcedocs[$i]{id} = $id;
        $sourcedocs[$i]{designation} = $designation;
        $sourcedocs[$i]{title} = $title;
        $sourcedocs[$i]{typeid} = $typeid;
        $sourcedocs[$i]{enteredby} = $enteredby;
        $sourcedocs[$i]{dateentered} = $dateentered;
        $sourcedocs[$i]{lastupdated} = $lastupdated;
        $sourcedocs[$i]{updatedby} = $updatedby;
        $sourcedocs[$i]{docdate} = $docdate;
        $sourcedocs[$i]{revision} = $revision;
        $sourcedocs[$i]{matrixstatusid} = $matrixstatusid;
        $sourcedocs[$i]{imagecontenttype} = $imagecontenttype;
        $sourcedocs[$i]{imageextension} = $imageextension;
        $sourcedocs[$i]{isdeleted} = $isdeleted;
        $sourcedocs[$i]{url} = $url;
    }
    $csr -> finish;
    return (@sourcedocs);
}

###########################
sub getSourceRequirements {
###########################
    my %args = (
        where => '',
        orderby => '',
        @_,
		);
    my @requirements;
    my $i = 0;
    my $where = ($args{where}) ? "where isdeleted = 'F' and $args{where}" : "where isdeleted = 'F'";
    my $orderby = ($args{orderby}) ? "order by sorter desc, sectionid, $args{orderby}" : "order by sorter desc, sectionid";
    my $csr = $args{dbh} -> prepare ("select id, sourceid, sectionid, text, enteredby, dateentered, lastupdated, updatedby, requirementid, ocrwmposition, ocrwmjustification, sorter, table1aid from $args{schema}.sourcerequirement $where $orderby");
    $csr -> execute;
    while (my ($id, $sourceid, $sectionid, $text, $enteredby, $dateentered, $lastupdated, $updatedby, $requirementid, $ocrwmposition, $ocrwmjustification, $sorter, $table1aid) = $csr -> fetchrow_array) {
        $i++;
        $requirements[$i]{id} = $id;
        $requirements[$i]{sourceid} = $sourceid;
        $requirements[$i]{sectionid} = $sectionid;
        $requirements[$i]{text} = $text;
        $requirements[$i]{enteredby} = $enteredby;
        $requirements[$i]{dateentered} = $dateentered;
        $requirements[$i]{lastupdated} = $lastupdated;
        $requirements[$i]{updatedby} = $updatedby;
        $requirements[$i]{requirementid} = $requirementid;
        $requirements[$i]{ocrwmposition} = $ocrwmposition;
        $requirements[$i]{ocrwmjustification} = $ocrwmjustification;
        $requirements[$i]{sorter} = $sorter;
        $requirements[$i]{table1aid} = $table1aid;
    }
    $csr -> finish;
    return (@requirements);

}



###############
sub getNextID {
###############
    my %args = (
        table => '',
        schema => $ENV{SCHEMA},
        @_,
    );

    my $sqlstring;
    my $csr;

    $sqlstring = "select $args{schema}." . "$args{table}" . "_id_seq.nextval from dual";
    my $nextid = $args{dbh} -> selectrow_array ($sqlstring);
    return ($nextid);
}

#################
sub getQARDRevs {
#################
    my %args = (
        where => '',
        orderby => '',
        @_,
    );
    my @qardrevs;
    my $i = 0;
    my $where = ($args{where}) ? "where $args{where}" : "";
    my $orderby = ($args{orderby}) ? "order by $args{orderby}" : "";
    my $csr = $args{dbh} -> prepare ("select id, revid, to_char(dateapproved,'MM/DD/YYYY'), approvedby, to_char(dateeffective,'MM/DD/YYYY'), imagecontenttype, imageextension, enteredby, to_char(dateentered,'MM/DD/YYYY'), to_char(lastupdated,'MM/DD/YYYY'), updatedby, status, iscurrent, isdeleted, qardtypeid from $args{schema}.qard $where $orderby");
    $csr -> execute;
    while (my ($id, $revid, $dateapproved, $approvedby, $dateeffective, $imagecontenttype, $imageextension, $enteredby, $dateentered, $lastupdated, $updatedby, $status, $iscurrent, $isdeleted, $qardtypeid) = $csr -> fetchrow_array) {
        $i++;
        $qardrevs[$i]{id} = $id;
        $qardrevs[$i]{revid} = $revid;
        $qardrevs[$i]{dateapproved} = $dateapproved;
        $qardrevs[$i]{approvedby} = $approvedby;
        $qardrevs[$i]{dateeffective} = $dateeffective;
        $qardrevs[$i]{enteredby} = $enteredby;
        $qardrevs[$i]{dateentered} = $dateentered;
        $qardrevs[$i]{lastupdated} = $lastupdated;
        $qardrevs[$i]{updatedby} = $updatedby;
        $qardrevs[$i]{imagecontenttype} = $imagecontenttype;
        $qardrevs[$i]{imageextension} = $imageextension;
        $qardrevs[$i]{status} = $status;
        $qardrevs[$i]{iscurrent} = $iscurrent;
        $qardrevs[$i]{isdeleted} = $isdeleted;
        $qardrevs[$i]{qardtypeid} = $qardtypeid;
    }
    $csr -> finish;
    return (@qardrevs);
}

##############
sub getTable {
##############
    my %args = (
        where => '',
        orderby => '',
        @_,
    );
    my @table;
    my $i = 0;
    my $where = ($args{where}) ? "where $args{where}" : "";
    my $orderby = ($args{orderby}) ? "order by $args{orderby}" : "";

    my $select = "select id, item, subid, nrcdescription, standarddescription, position, justification, revisionid, enteredby, dateentered, lastupdated, updatedby from $args{schema}.qardtable1a $where $orderby";
    my $csr = $args{dbh} -> prepare ($select);
    $csr -> execute;
    while (my ($id, $item, $subid, $nrcdescription, $standarddescription, $position, $justification, $revisionid, $enteredby, $dateentered, $lastupdated, $updatedby) = $csr -> fetchrow_array) {

        $i++;
        $table[$i]{id} = $id;
        $table[$i]{item} = $item;
        $table[$i]{subid} = $subid;
        $table[$i]{nrcdescription} = $nrcdescription;
        $table[$i]{standarddescription} = $standarddescription;
        $table[$i]{position} = $position;
        $table[$i]{justification} = $justification;
        $table[$i]{revisionid} = $revisionid;
        $table[$i]{enteredby} = $enteredby;
        $table[$i]{dateentered} = $dateentered;
        $table[$i]{lastupdated} = $lastupdated;
        $table[$i]{updatedby} = $updatedby;
    } 
    $csr -> finish;
    return (@table);
}

#################
sub getMatrices {
#################
    my %args = (
        where => '',
        orderby => '',
        @_,
    );
    my @matrix;
    my $i = 0;
    my $where = ($args{where}) ? "where $args{where}" : "";
    my $orderby = ($args{orderby}) ? "order by $args{orderby}" : "";

    my $select = "select id, title, sourceid, qardid, enteredby, dateentered, lastupdated, updatedby, isdeleted, statusid, dateapproved, approvedby from $args{schema}.matrix $where $orderby";
    my $csr = $args{dbh} -> prepare ($select);
    $csr -> execute;
    while (my ($id, $title, $sourceid, $qardid, $enteredby, $dateentered, $lastupdated, $updatedby, $isdeleted, $statusid, $dateapproved, $approvedby) = $csr -> fetchrow_array) {

        $i++;
        $matrix[$i]{id} = $id;
        $matrix[$i]{title} = $title;
        $matrix[$i]{sourceid} = $sourceid;
        $matrix[$i]{qardid} = $qardid;
        $matrix[$i]{enteredby} = $enteredby;
        $matrix[$i]{dateentered} = $dateentered;
        $matrix[$i]{lastupdated} = $lastupdated;
        $matrix[$i]{updatedby} = $updatedby;
        $matrix[$i]{isdeleted} = $isdeleted;
        $matrix[$i]{statusid} = $statusid;
        $matrix[$i]{dateapproved} = $dateapproved;
        $matrix[$i]{approvedby} = $approvedby;
    } 
    $csr -> finish;

    return (@matrix);

}

###############
1; #return true
