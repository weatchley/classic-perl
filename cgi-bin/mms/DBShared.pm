#!/usr/local/bin/perl -w
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/DBShared.pm,v $
# $Revision: 1.12 $
# $Date: 2009/07/13 18:59:28 $
#
# $Author: atchleyb $
# $Locker:  $
#
# $Log: DBShared.pm,v $
# Revision 1.12  2009/07/13 18:59:28  atchleyb
# Post updates missing from last release
#
# Revision 1.11  2005/10/04 20:15:08  atchleyb
# CREQ00018 - updated createSequence to have the parameter NOCACHE
#
# Revision 1.10  2005/08/18 18:32:00  atchleyb
# CR00015 - fixed problem with delegation lookup
#
# Revision 1.9  2005/06/10 23:40:07  atchleyb
# CR0011
# changed getDeptHash to use site name instead of site code
#
# Revision 1.8  2005/06/10 22:26:46  atchleyb
# CR0011
# added site name to dept lookup
#
# Revision 1.7  2005/05/27 19:55:17  atchleyb
# Updated the sitesUserHasRole funciton to optionally retun an array of sites
#
# Revision 1.6  2005/01/21 00:12:30  atchleyb
# Updated per CREQ00003 to change return value from sitesUserHasRole to have default of -1 instead of 0 (0 is for all sites)
#
# Revision 1.5  2004/06/24 21:36:43  atchleyb
# updated to allow quotes in log messages
#
# Revision 1.4  2004/02/26 23:57:29  atchleyb
# updated function sitesUserHasRole to allow text return
#
# Revision 1.3  2004/01/08 17:11:00  atchleyb
# added function to get list of site that a user has a role
#
# Revision 1.2  2003/11/28 21:28:09  atchleyb
# fixed format error in getSysdate
#
# Revision 1.1  2003/11/12 20:27:33  atchleyb
# Initial revision
#
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
      &db_connect          &db_disconnect       &getSysdate           
      &createSequence      &db_encrypt_password &updateActivityLog
      &doesUserHavePriv    &get_fullname        &get_date
      &getFullName         &getUserID           &getUserName
      &logError            &logActivity         &getLookupValues    
      &getDeptHash         &getSiteInfoArray    &doesUserHaveRole
      &getStateArray       &getCountryArray     &getFY
      &getDateOffset       &getDeptArray        &sitesUserHasRole
);
@EXPORT_OK = qw(
      &db_connect          &db_disconnect       &getSysdate           
      &createSequence      &db_encrypt_password &updateActivityLog
      &doesUserHavePriv    &get_fullname        &get_date
      &getFullName         &getUserID           &getUserName
      &logError            &logActivity         &getLookupValues    
      &getDeptHash         &getSiteInfoArray    &doesUserHaveRole
      &getStateArray       &getCountryArray     &getFY
      &getDateOffset       &getDeptArray        &sitesUserHasRole
);
%EXPORT_TAGS =(
    Functions => [qw(
      &db_connect          &db_disconnect       &getSysdate           
      &createSequence      &db_encrypt_password &updateActivityLog
      &doesUserHavePriv    &get_fullname        &get_date
      &getFullName         &getUserID           &getUserName
      &logError            &logActivity         &getLookupValues    
      &getDeptHash         &getSiteInfoArray    &doesUserHaveRole
      &getStateArray       &getCountryArray     &getFY
      &getDateOffset       &getDeptArray        &sitesUserHasRole
    ) 
]);



################################################################################################################
sub caesar {
# caesar cipher
################################################################################################################
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


################################################################################################################
sub decrypt {
# description code
################################################################################################################
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


################################################################################################################
sub getOracleID {
#
# Routine to get username/password for oracle. This is a helper function for the db_connect routine.
#
################################################################################################################
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

################################################################################################################
sub db_connect {
#
# Routine to connect to the oracle database.
#
################################################################################################################
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


################################################################################################################
sub db_disconnect {
#
# routine to disconnect from the oracle database
#
#
################################################################################################################

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


################################################################################################################
sub db_encrypt_password {
# routine to encrypt a password
################################################################################################################
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


################################################################################################################
sub getUserID {
# routine to get a user id
################################################################################################################
    my %args = (
          userName => "",
          @_,
          );

    my ($userID) = $args{dbh}->selectrow_array("SELECT id FROM $args{schema}.users WHERE username='$args{userName}'");
    
    return ($userID);
}


################################################################################################################
sub logError {
#
# Routine to insert an error into the activity log. This is a helper function called by the
# updateActivityLog routine.
#
#
################################################################################################################														  
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


################################################################################################################
sub logActivity {
#
# Routine to insert an error into the activity log. This is a helper function called by the
# updateActivityLog routine.
#
#
################################################################################################################														  
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


################################################################################################################
sub getSysdate {
#
#      Returns the system date from the oracle database.
#
################################################################################################################

    my %args = (
        schema => "$SCHEMA",
        @_,
    );	
    my $sqlquery = "SELECT TO_CHAR(sysdate, 'MM/DD/YYYY HH24:MI:SS') FROM dual";
    my $sth = $args{dbh}->prepare($sqlquery);
    $sth->execute;
    return ($sth->fetchrow_array);
}

################################################################################################################
sub updateActivityLog {
#
#     Inserts an entry into the activity log
#
#        Parameters:
#        schema      	  - database schema	
#        dbh         	  - database handle 
#        userid           - id of the user
#        logmessage       - message to be logged into the activity log
#        errorstatus      - flag to denote an error or activity
#
################################################################################################################
    my $dbh = $_[0];
    my $schema = $_[1];
    my $userId = $_[2];
    my $logmessage = $_[3];
    my $errorStatus = $_[4];
    my $type = $_[5];
    my $status = 1;
    my $sqlquery = "INSERT INTO $schema.activity_log (userid, datelogged, iserror, description, type) "
                   . "VALUES ($userId, SYSDATE, '$errorStatus', " . $dbh->quote($logmessage) . ", " . (($type != 0) ? $type : "NULL") . ")";
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


################################################################################################################
sub formatID {
#
# Returns a formatted time (either month, day, hour, second, or minute. This is a helper function for the
# errorMesage routine.
#
################################################################################################################
   return (sprintf("$_[0]%0$_[1]d", $_[2]));
}


###############################################################################################################
sub createSequence {
#
#  Create a sequence in the database schema.
#
#     	schema      	  - database schema
#     	dbh         	  - database handle
#     	seqName           - name of new sequence
#
###############################################################################################################

    my %args = (
        schema => "$SCHEMA",
        seqName => "",
        @_,
    );
    my $sqlquery = "CREATE SEQUENCE " . uc($args{schema}) . "." . uc($args{seqName}) . " MINVALUE 1 NOCACHE";
    $args{dbh}->do($sqlquery);
}


################################################################################################################
################################################################################################################


################################################################################################################
sub doesUserHavePriv {
# routine to see if a user of the DB system has a specific priv
################################################################################################################
    my %args = (
        userid => "0",
        userID => "0",
        privList => [0],
        privList2 => [0],
        privType => "number",
        @_,
    );
    if ($args{userID} != 0) {$args{userid} = $args{userID};}
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


################################################################################################################
sub getUserName {
# routine to get a user name
################################################################################################################
    my %args = (
        userID => 0,
        @_,
    );
    my ($output) = $args{dbh}->selectrow_array("SELECT username FROM $args{schema}.users WHERE id=$args{userID}");
    
    return($output);
}


################################################################################################################
sub get_fullname {
# routine to get a user's full name
################################################################################################################
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


###################################################################################################################################
sub getFullName {  # routine to get a user name
###################################################################################################################################
    my %args = (
        userID => 0,
        @_,
    );
    my ($output) = $args{dbh}->selectrow_array("SELECT firstname || ' ' || lastname FROM $args{schema}.users WHERE id=$args{userID}");
    
    return($output);
}


###################################################################################################################################
sub getLookupValues {
###################################################################################################################################
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


################################################################################################################
sub get_date {
# routine to generate an oracle friendly date
################################################################################################################
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


###################################################################################################################################
sub getDeptHash {
###################################################################################################################################
    my %args = (
        @_,
    );
    tie my %lookupHash, "Tie::IxHash";
    %lookupHash = ();
    my $lookup = $args{dbh}->prepare("SELECT d.id, d.name, si.sitecode, si.name FROM $args{schema}.departments d, $args{schema}.site_info si WHERE d.site = si.id ORDER BY si.sitecode, d.name");
    $lookup->execute;
    while (my ($id, $name, $sitecode, $sitename)= $lookup->fetchrow_array) {
        $lookupHash{$id} = "$sitename - $name";
    }
    $lookup->finish;
    return (\%lookupHash);
}


###################################################################################################################################
sub getDeptArray {
###################################################################################################################################
    my %args = (
        id => 0,
        userID =>0,
        activeOnly => 'F',
        role =>0,
        @_,
    );
    my @depts;
    my $i=0;
    my $from = (($args{userID} == 0 || $args{role} == 0) ? "" : ", $args{schema}.user_roles ur ");
    my $where = (($args{id} == 0) ? "" : " AND d.id=$args{id}");
    $where .= (($args{userID} == 0 || $args{role} == 0) ? "" : " AND si.id=ur.site AND ur.userid=$args{userID} AND ur.role=$args{role} ");
    $where .= (($args{activeOnly} eq 'T') ? " AND d.active='T' " : "");
    my $sqlcode = "SELECT d.id, d.name, si.sitecode, d.site, si.name, d.active FROM $args{schema}.departments d, $args{schema}.site_info si $from ";
    $sqlcode .= "WHERE d.site = si.id $where ORDER BY si.sitecode, d.name";
#print STDERR "\n$sqlcode\n\n";

    my $lookup = $args{dbh}->prepare($sqlcode);
    $lookup->execute;
    while (($depts[$i]{id}, $depts[$i]{name}, $depts[$i]{sitecode}, $depts[$i]{site}, $depts[$i]{sitename}, $depts[$i]{active})= $lookup->fetchrow_array) {
        $i++;
    }
    $lookup->finish;
    return (@depts);
}


###################################################################################################################################
sub getSiteInfoArray {
###################################################################################################################################
    my %args = (
        @_,
    );
    my @siteInfo;
    my $sqlcode = "SELECT id, name, shortname, longname, organization, address, city, state, zip, daddress, dcity, dstate, dzip, ";
    $sqlcode .= "phone, fax, contractnumber, salestax, taxexempt, sitecode FROM $args{schema}.site_info";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    while (my ($id, $name, $shortname, $longname, $organization, $address, $city, $state, $zip, $daddress, $dcity, $dstate, $dzip, 
               $phone, $fax, $contractnumber, $salestax, $taxexempt, $sitecode) = $csr->fetchrow_array) {
        ($siteInfo[$id]{id}, $siteInfo[$id]{name}, $siteInfo[$id]{shortname}, $siteInfo[$id]{longname}, $siteInfo[$id]{organization}, 
               $siteInfo[$id]{address}, $siteInfo[$id]{city}, $siteInfo[$id]{state}, $siteInfo[$id]{zip}, 
               $siteInfo[$id]{daddress}, $siteInfo[$id]{dcity}, $siteInfo[$id]{dstate}, $siteInfo[$id]{dzip}, 
               $siteInfo[$id]{phone}, $siteInfo[$id]{fax}, $siteInfo[$id]{contractnumber}, 
               $siteInfo[$id]{salestax}, $siteInfo[$id]{taxexempt}, $siteInfo[$id]{sitecode}) 
            = ($id, $name, $shortname, $longname, $organization, $address, $city, $state, $zip, $daddress, $dcity, $dstate, $dzip, 
               $phone, $fax, $contractnumber, $salestax, $taxexempt, $sitecode);
    }
    $csr->finish;
    return (@siteInfo);
}


################################################################################################################
sub doesUserHaveRole {
# routine to see if a user of the DB system has a specific role (or delegated role) for a site
################################################################################################################
    my %args = (
        userid => "0",
        userID => "0",
        roleList => [0],
        site => 0, # 0 = any site
        @_,
    );
    if ($args{userID} != 0) {$args{userid} = $args{userID};}
    my $status;
    my ($rows, $rows2);
    my $arrayRef = $args{roleList};
    my @roles = @$arrayRef;
    $"=',';
    my $rolelist = "(@roles)";
    $"='';
    ($rows) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.user_roles WHERE (userid = $args{userid}) AND (role IN $rolelist)" .
                   (($args{site}>0) ? " AND site=$args{site}" : ""));
    ($rows2) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.user_roles WHERE (delegatedto = $args{userid}) AND (role IN $rolelist)" .
                   " AND TO_CHAR(delegationstart, 'YYYYMMDD') <= TO_CHAR(SYSDATE, 'YYYYMMDD')" . 
                   " AND TO_CHAR(delegationstop, 'YYYYMMDD') >= TO_CHAR(SYSDATE, 'YYYYMMDD')" . 
                   (($args{site}>0) ? " AND site=$args{site}" : ""));
    $status = (($rows >0 || $rows2 >0) ? 1 : 0);
    return ($status);
}


################################################################################################################
sub sitesUserHasRole {
# routine to gen a string list of sites that a user has a role
################################################################################################################
    my %args = (
        userid => "0",
        userID => "0",
        site => 0,
        roleList => [0],
        asNumArray => 'F',
        asTextArray => 'F',
        @_,
    );
    if ($args{userID} != 0) {$args{userid} = $args{userID};}
    my $status;
    my $siteList = "-1";
    my @siteArray;
    my @siteNumArray;
    my $i = 0;
    my ($rows, $rows2);
    my $arrayRef = $args{roleList};
    my @roles = @$arrayRef;
    $"=',';
    my $rolelist = "(@roles)";
    $"='';
    my $csr = $args{dbh}->prepare("SELECT ur.site, si.sitecode FROM $args{schema}.user_roles ur, $args{schema}.site_info si " . 
                   "WHERE (ur.site=si.id) AND (ur.userid = $args{userid}) AND (ur.role IN $rolelist)" .
                   (($args{site}>0) ? " AND site=$args{site}" : ""));
    $csr->execute;
    while (my ($site, $siteCode) = $csr->fetchrow_array) {
        $siteList .= ", $site";
        $siteArray[$i] = $siteCode;
        $siteNumArray[$i] = $site;
        $i++;
    }
    $csr->finish;
    $csr = $args{dbh}->prepare("SELECT ur.site, si.sitecode FROM $args{schema}.user_roles ur, $args{schema}.site_info si " .
                   "WHERE (ur.site=si.id) AND (ur.delegatedto = $args{userid}) AND (ur.role IN $rolelist)" .
                   " AND TO_CHAR(ur.delegationstart, 'YYYYMMDD') <= TO_CHAR(SYSDATE, 'YYYYMMDD')" . 
                   " AND TO_CHAR(ur.delegationstop, 'YYYYMMDD') >= TO_CHAR(SYSDATE, 'YYYYMMDD')" . 
                   (($args{site}>0) ? " AND ur.site=$args{site}" : ""));
    $csr->execute;
    while (my ($site, $siteCode) = $csr->fetchrow_array) {
        $siteList .= ", $site";
        $siteArray[$i] = $siteCode;
        $siteNumArray[$i] = $site;
        $i++;
    }
    $siteList .= ", -1";
    $csr->finish;
    if ($args{asTextArray} eq 'T') {
        return (@siteArray);
    } elsif ($args{asNumArray} eq 'T') {
        return (@siteNumArray);
    } else {
        return ($siteList);
    }
}


###################################################################################################################################
sub getStateArray {
###################################################################################################################################
    my %args = (
        @_,
    );
    my @states;
    my $count = 0;
    my $sqlcode = "SELECT abbreviation, name FROM $args{schema}.states ORDER BY name";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    while (my ($abbreviation, $name) = $csr->fetchrow_array) {
        ($states[$count]{abbreviation}, $states[$count]{name}) = ($abbreviation, $name);
        $count++;
    }
    $csr->finish;
    return (@states);
}


###################################################################################################################################
sub getCountryArray {
###################################################################################################################################
    my %args = (
        @_,
    );
    my @country;
    my $count = 0;
    my $sqlcode = "SELECT abbreviation, name FROM $args{schema}.countries ORDER BY name";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    while (my ($abbreviation, $name) = $csr->fetchrow_array) {
        ($country[$count]{abbreviation}, $country[$count]{name}) = ($abbreviation, $name);
        $count++;
    }
    $csr->finish;
    return (@country);
}


################################################################################################################
sub getFY {
# routine to get the current Fiscal Year
################################################################################################################
    my %args = (
        @_,
    );
    my $outstring = '';
    my ($day, $month, $year);
    ($day, $month, $year) = (localtime)[3,4,5];
    $year = $year + 1900;
    $month++;
    if ($month >= 10) {$year++;}
    return ($year);
}


################################################################################################################
sub getDateOffset {
# routine to get the current Fiscal Year
################################################################################################################
    my %args = (
        offset => 3, # months
        type => 'months', # months or days
        format => 'MM/DD/YYYY', # convertion format
        @_,
    );
    my $outstring = '';
    my $date = '';
    if ($args{type} eq 'months') {
        ($date) = $args{dbh}->selectrow_array("SELECT TO_CHAR(ADD_MONTHS(SYSDATE,$args{offset}), '$args{format}') FROM dual");
    } else {
        ($date) = $args{dbh}->selectrow_array("SELECT TO_CHAR(SYSDATE+$args{offset}, '$args{format}') FROM dual");
    }

    return ($date);
}


################################################################################################################
################################################################################################################
1; #return true
