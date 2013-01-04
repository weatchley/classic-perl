# DB Business Rules functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/DBBusinessRules.pm,v $
#
# $Revision: 1.7 $
#
# $Date: 2009/07/31 22:43:26 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBBusinessRules.pm,v $
# Revision 1.7  2009/07/31 22:43:26  atchleyb
# Updates related to ACR0907_004-SWR0149   New intermediate buyer role, minor bug fixes
#
# Revision 1.6  2009/02/11 18:25:40  atchleyb
# ACR0902_004 - Fixed save for forms with multi char1 or char2 fields
#
# Revision 1.5  2008/10/21 18:06:05  atchleyb
# ACR0810_002 - Updated to allow for routing questions
#
# Revision 1.4  2008/02/11 18:20:29  atchleyb
# SCR000037 - Updates related to change request, see change request for details
#
# Revision 1.3  2007/02/07 17:28:29  atchleyb
# CR 0030 - Updated to handle default PO clauses
#
# Revision 1.2  2004/04/21 17:03:41  atchleyb
# added functions for maintaining br
#
# Revision 1.1  2004/01/08 17:06:43  atchleyb
# Initial revision
#
#
#
#
#
#

package DBBusinessRules;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use Tie::IxHash;
use DBPurchaseDocuments qw(getPDByStatus);

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
#use vars qw ();

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      &getRuleInfo    &getRuleArray    &getRuleTypesArray    &doProcessRuleEntry
);
%EXPORT_TAGS =( 
    Functions => [qw(
      &getRuleInfo    &getRuleArray    &getRuleTypesArray    &doProcessRuleEntry
    )]
);


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub getRuleInfo {
###################################################################################################################################
    my %args = (
        id => 0,
        type => 0,
        site => 0,
        @_,
    );
    
    my %rule;
    my $sqlcode = "SELECT id, name, type, site, nvalue1, nvalue2, cvalue1, cvalue2 FROM $args{schema}.rules WHERE 1=1";
    $sqlcode .= (($args{id} > 0) ? " AND id=$args{id}" : "");
    $sqlcode .= (($args{type} > 0) ? " AND type=$args{type}" : "");
    $sqlcode .= (($args{site} > 0) ? " AND site=$args{site}" : "");

    ($rule{id}, $rule{name}, $rule{type}, $rule{site}, $rule{nvalue1}, $rule{nvalue2}, 
            $rule{cvalue1}, $rule{cvalue2}) = $args{dbh}->selectrow_array($sqlcode);
    
    return (%rule);
}


###################################################################################################################################
sub getRuleArray {
###################################################################################################################################
    my %args = (
        id => 0,
        type => 0,
        site => 0,
        orderBy => 'name',
        @_,
    );
    
    my @rule;
    my $sqlcode = "SELECT id, name, type, site, nvalue1, nvalue2, cvalue1, cvalue2 FROM $args{schema}.rules WHERE 1=1 ";
    $sqlcode .= (($args{id} > 0) ? " AND id=$args{id}" : "");
    $sqlcode .= (($args{type} > 0) ? " AND type=$args{type}" : "");
    $sqlcode .= (($args{site} > 0) ? " AND site=$args{site}" : "");
    $sqlcode .= " ORDER BY $args{orderBy}";
#print STDERR "\n$sqlcode\n\n";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;

    my $i = 0;
    while (($rule[$i]{id}, $rule[$i]{name}, $rule[$i]{type}, $rule[$i]{site}, $rule[$i]{nvalue1}, $rule[$i]{nvalue2}, 
            $rule[$i]{cvalue1}, $rule[$i]{cvalue2}) = $csr->fetchrow_array) {
        $i++;
    }
    
    return (@rule);
}


###################################################################################################################################
sub getRuleTypesArray {
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );
    
    my @rule;
    my $sqlcode = "SELECT id, name FROM $args{schema}.rule_type WHERE 1=1 ";
    $sqlcode .= (($args{id} > 0) ? "AND id=$args{id} " : "");
    $sqlcode .= "ORDER BY name";
    my $i = 0;
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;

    while (($rule[$i]{id}, $rule[$i]{name}) = $csr->fetchrow_array) {
        $i++;
    }
    $csr->finish;
    
    return (@rule);
}


###################################################################################################################################
sub doProcessRuleEntry {  # routine to enter a new rule or update a rule
###################################################################################################################################
    my %args = (
        userID => 0,
        type => "",  # new or update
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $sqlcode;
    my $status = 0;
    my $ruleid = $settings{ruleid};
    my $ruleType = $settings{ruletype};
    my $siteID = $settings{siteid};
    my $ruleName;
    
    eval {
        if ($args{type} eq 'new') {
            ($ruleName) = $args{dbh}->selectrow_array("SELECT name FROM $args{schema}.rule_type WHERE id=$ruleType");
            $sqlcode = "INSERT INTO $args{schema}.rules (id, name, type, site, nvalue1, nvalue2, cvalue1, cvalue2)";
            $sqlcode .= "VALUES ($args{schema}.rules_id.NEXTVAL, '$ruleName', $ruleType, $siteID, ";
            $sqlcode .= " $settings{nvalue1},$settings{nvalue2},'$settings{cvalue1}', ";
            $sqlcode .= ((defined($settings{cvalue2}) && $settings{cvalue2} gt " ") ? "'$settings{cvalue2}'" : "NULL") . ")";
            
#print STDERR "\n$sqlcode\n\n";
            $args{dbh}->do($sqlcode);
        } else {
            if ($ruleType == 4 || $ruleType == 9 || $ruleType == 11) {
                $sqlcode = "DELETE FROM $args{schema}.rules WHERE type=$ruleType AND site=$siteID";
                $args{dbh}->do($sqlcode);
                ($ruleName) = $args{dbh}->selectrow_array("SELECT name FROM $args{schema}.rule_type WHERE id=$ruleType");
                for (my $i=0; $i<$settings{itemcount}; $i++) {
                    if ($settings{items}[$i]{nvalue1} >= 1 && $settings{items}[$i]{nvalue2} >= 1) {
                        $sqlcode = "INSERT INTO $args{schema}.rules (id, name, type, site, nvalue1, nvalue2, cvalue1, cvalue2) ";
                        $sqlcode .= "VALUES ($args{schema}.rules_id.NEXTVAL, '$ruleName $settings{items}[$i]{nvalue1}', $ruleType, $siteID, ";
                        $sqlcode .= " $settings{items}[$i]{nvalue1},$settings{items}[$i]{nvalue2}, ";
                        $sqlcode .= ((defined($settings{items}[$i]{cvalue1}) && $settings{items}[$i]{cvalue1} gt " ") ? "'$settings{items}[$i]{cvalue1}'" : "NULL") . ",";
                        $sqlcode .= ((defined($settings{items}[$i]{cvalue2}) && $settings{items}[$i]{cvalue2} gt " ") ? "'$settings{items}[$i]{cvalue2}'" : "NULL") . ")";
#print STDERR "\n$sqlcode\n\n";
                        $args{dbh}->do($sqlcode);
                    }
                }
            } elsif ($ruleType != 4 && $ruleType != 9 && $ruleType != 11) {
                $sqlcode = "UPDATE $args{schema}.rules SET ";
#print STDERR "\nrule type = $ruleType\n";
                if ($ruleType <= 3 || ($ruleType >= 6 && $ruleType <= 7) || ($ruleType >= 12 && $ruleType <= 13)) {
                    $sqlcode .= "nvalue1 = $settings{nvalue1} ";
                } elsif ($ruleType == 5 || $ruleType == 10) {
                    $sqlcode .= "nvalue1 = $settings{nvalue1}, ";
                    $sqlcode .= "nvalue2 = $settings{nvalue2} ";
                }
                $sqlcode .= "WHERE id = $ruleid";
#print STDERR "\n$sqlcode\n\n";
                $args{dbh}->do($sqlcode);
            }
        }
        $args{dbh}->commit;

    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1);
}


###################################################################################################################################
###################################################################################################################################




1; #return true
