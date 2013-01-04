#
# Sessions.pm
#
# $Source: /home/atchleyb/rcs/mms/perl/RCS/Sessions.pm,v $
#
# $Revision: 1.1 $
#
# $Date: 2003/11/12 20:30:10 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: Sessions.pm,v $
# Revision 1.1  2003/11/12 20:30:10  atchleyb
# Initial revision
#
#
#
#
package Sessions;
use strict;
use Carp;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw (%SYSHash);
use DBI;
use DBD::Oracle qw(:ora_types);

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw (
        &sessionCreate   &sessionValidate   &sessionClose
);
@EXPORT_OK = qw(
        &sessionCreate   &sessionValidate   &sessionClose
);
%EXPORT_TAGS =(
    Functions => [qw(
        &sessionCreate   &sessionValidate   &sessionClose
    ) ],
    Constants => [qw() ]
);

$ENV{'ORACLE_HOME'} = "/usr/local/oracle8";


###################################################################################################################################
sub _genID {                                 # routine to generate a session ID
###################################################################################################################################
  my @TestVals = ("0".."9","a".."k","m".."z");
  srand (time|$$);
  my $sessionID = "";
  for (my $pos = 0; ($pos < 50); $pos++) {
      $sessionID = $sessionID . $TestVals [rand (35)];
  }
  return $sessionID;
}


###################################################################################################################################
sub sessionCreate {                                 # routine to create a new session
###################################################################################################################################
    my %args = (
          userID => '',
          application => '',
          timeout => 30,
          dbh => '',
          schema => '',
          @_,
          );
    my $sessionID = '';
    
    eval {
        while ($sessionID eq '') {
            my $tempID = &_genID;
            my ($count) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.sessions WHERE id = '$tempID'");
            if ($count == 0) {$sessionID = $tempID;}
        }
        my $sqlCode = "INSERT INTO $args{schema}.sessions (application,userid,id,tcpaddress,firstused,lastused,timeout) ";
        $sqlCode .= "VALUES (" . ((defined($args{application}) && $args{application} gt ' ') ? "'$args{application}'" : 'NULL');
        $sqlCode .= ",$args{userID},'$sessionID', '$ENV{REMOTE_ADDR}', SYSDATE, SYSDATE, $args{timeout})";
print "\n<!-- $sqlCode -->\n\n";
        $args{dbh}->do($sqlCode);
        $args{dbh}->commit;
        
    };
    if ($@) {
print "\n<!-- $@ -->\n\n";
        $sessionID = -1;
    }
    return ($sessionID);
}


###################################################################################################################################
sub sessionValidate {                                 # routine to validate a session (1 = valid; 0 = timed out; -1 = error)
###################################################################################################################################
    my %args = (
          userID => '',
          dbh => '',
          schema => '',
          sessionID => 'none',
          @_,
          );
    my $status = 0;
    
    eval {
        my ($userID,$ID,$tcpaddress,$lastused,$closed,$timeout,$now) = $args{dbh}->selectrow_array("SELECT userid,id,tcpaddress,TO_CHAR(lastused,'YYYYMMDDHH24MI'),closed,timeout,TO_CHAR(SYSDATE,'YYYYMMDDHH24MI') FROM $args{schema}.sessions WHERE id='$args{sessionID}'");
        my $startTime = substr($lastused,0,8) . (substr($lastused,8,2)*60 + substr($lastused,10,2) +1000);
        my $endTime = substr($now,0,8) . (substr($now,8,2)*60 + substr($now,10,2) +1000);
        my $sessionTime = ($endTime - $startTime);
        if (not defined($userID)) {
            $status = -1;
        } elsif (defined($closed)) {
            $status = 0;
        } elsif ($sessionTime >= $timeout || $args{userID} != $userID || $tcpaddress ne $ENV{REMOTE_ADDR}) {
            $status = $args{dbh}->do("UPDATE $args{schema}.sessions SET closed=SYSDATE WHERE id = '$args{sessionID}'");
            $args{dbh}->commit;
            $status = 0;
        } else {
            $status = $args{dbh}->do("UPDATE $args{schema}.sessions SET lastused=SYSDATE WHERE id = '$args{sessionID}'");
            $status = 1;
            
        }
    };
    if ($@) {
        print STDERR "\nsessionValidate $@\n\n";
        $status = -1;
    }
    return ($status);
}


###################################################################################################################################
sub sessionClose {                                 # routine to close a session
###################################################################################################################################
    my %args = (
          dbh => '',
          schema => '',
          sessionID => 'none',
          @_,
          );
    my $status = 0;
    
    eval {
        $status = $args{dbh}->do("UPDATE $args{schema}.sessions SET closed=SYSDATE WHERE id = '$args{sessionID}'");
        $args{dbh}->commit;
        $status = 1;
    };
    if ($@) {
        $status = -1;
    }
    return ($status);
}


###################################################################################################################################
#sub validateCurrentSession {              #redirect user to login screen if session is timed out or not valid.
###################################################################################################################################
#    my %args = (
#          userID => '',
#          dbh => '',
#          schema => '',
#          sessionID => 'none',
#          @_,
#          );
#    
#    my $status = &sessionValidate(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, sessionID=>$args{sessionID});
#    if ($status == 1) {
#        return ($status);
#    } else {
#        print "content-type: text/html\n\n";
#        print "<html><header></header><body>\n";
#        print "<form name=timeout action=login.pl target=_top method=post>\n";
#        print "<input type=hidden name=test value=test>\n</form>\n";
#        print "<script language=javascript>\n<!--\n";
#        print "alert('Session has timed out or is not valid');\n";
#        print "document.timeout.submit();\n";
#        print "//-->\n</script>\n";
#    }
#}



###################################################################################################################################
sub new {       # new object  (not used)
###################################################################################################################################
    my $self = {};
    $self = { %SYSHash };
    bless $self;
    return $self;
}


###################################################################################################################################
sub AUTOLOAD {                    # proccess variable name methods
###################################################################################################################################
    my $self = shift;
    my $type = ref($self) || croak "$self is not an object";
    my $name = $AUTOLOAD;
    $name =~ s/.*://; # strip fully-qualified portion
    unless (exists $self->{$name} ) {
        croak "Can't Access '$name' field in object of class $type";
    }
    if (@_) {
        return $self->{$name} = shift;
    } else {
        return $self->{$name};
    }
}

1; #return true
