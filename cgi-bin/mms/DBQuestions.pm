# DB Questions functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/DBQuestions.pm,v $
#
# $Revision: 1.1 $
#
# $Date: 2008/10/21 18:09:06 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBQuestions.pm,v $
# Revision 1.1  2008/10/21 18:09:06  atchleyb
# Initial revision
#
#
#
#
#
#

package DBQuestions;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use DBBusinessRules qw(:Functions);
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
      &getQuestionArray      &doProcessQuestionEntry    &createQuestionList   &getQuestionList
      &getQuestionSiteCount  &doProcessQuestionDelete
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getQuestionArray      &doProcessQuestionEntry    &createQuestionList   &getQuestionList
      &getQuestionSiteCount  &doProcessQuestionDelete
    )]
);


###################################################################################################################################
sub getQuestionArray {  # routine to get an array of questions
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );

    my $i = 0;
    my @questions;
    $args{dbh}->{LongReadLen} = 10000000;
    $args{dbh}->{LongTruncOk} = 0;
    my $sqlcode = "SELECT id, text, role FROM $args{schema}.questions WHERE 1=1 ";

    if ($args{id} > 0) {$sqlcode .= "AND id=$args{id}";}
    $sqlcode .= "ORDER BY text";
#print STDERR "\n$sqlcode\n";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    while (($questions[$i]{id}, $questions[$i]{text}, $questions[$i]{role}) = $csr->fetchrow_array) {
        ($questions[$i]{rolename}) = $args{dbh}->selectrow_array("SELECT name FROM $args{schema}.roles WHERE id=$questions[$i]{role}");
        $i++;
    }
    $csr->finish;

    return (@questions);
}


###################################################################################################################################
sub doProcessQuestionEntry {  # routine to enter a new question or update a question
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
    my $id;
    
    eval {
        ($id) = (($args{type} eq 'new') ? $args{dbh}->selectrow_array("SELECT $args{schema}.questions_id.NEXTVAL FROM dual") : ($settings{c_questionid}));
        my $text = $settings{question};
        my $role = $settings{role};
        if ($args{type} eq 'new') {
            $sqlcode = "INSERT INTO $args{schema}.questions (id, text, role) VALUES ($id, :question, $role)";
            
#print STDERR "\n$sqlcode\n\n";
            my $csr = $args{dbh}->prepare($sqlcode);
            $csr -> bind_param (":question", $text);
            $status = $csr->execute;
        } else {
            $sqlcode = "UPDATE $args{schema}.questions SET ";
            $sqlcode .= "text = :question, ";
            $sqlcode .= "role = $role ";
            $sqlcode .= "WHERE id = $id";
#print STDERR "\n$sqlcode\n\n";
            my $csr = $args{dbh}->prepare($sqlcode);
            $csr -> bind_param (":question", $text);
            $status = $csr->execute;
        }

    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1,$id);
}


###################################################################################################################################
sub createQuestionList {  # routine to create a list of questions for a PR
###################################################################################################################################
    my %args = (
        site => 0,
        @_,
    );

    my @rules = &getRuleArray(dbh=>$args{dbh}, schema=>$args{schema}, type=>11, site=>$args{site}, orderBy=>"nvalue1");
    my @questions;
    for (my $i=0; $i<$#rules; $i++) {
        $questions[$i]{prnumber} = "";
        $questions[$i]{precedence} = $rules[$i]{nvalue1};
        ($questions[$i]{text}, $questions[$i]{role}) = $args{dbh}->selectrow_array("SELECT text, role FROM $args{schema}.questions WHERE id=$rules[$i]{nvalue2}");
        $questions[$i]{answer} = 0;
    }

    return (@questions);
}


###################################################################################################################################
sub getQuestionList {  # routine to get the list of questions for a PR
###################################################################################################################################
    my %args = (
        prnumber => "",
        @_,
    );

    my $sqlcode = "SELECT prnumber, precedence, text, answer, role FROM $args{schema}.question_list WHERE prnumber='$args{prnumber}' ORDER BY precedence";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    my $i = 0;
    my @questions;
    while (($questions[$i]{prnumber}, $questions[$i]{precedence}, $questions[$i]{text}, $questions[$i]{answer}, $questions[$i]{role}) = $csr->fetchrow_array) {
        $i++;
    }
    $csr->finish;

    return (@questions);
}


###################################################################################################################################
sub getQuestionSiteCount {  # routine to get the count of how many sites question is used on
###################################################################################################################################
    my %args = (
        question => "",
        @_,
    );

    my $sqlcode = "SELECT count(*) FROM $args{schema}.rules WHERE type=11 AND nvalue2=$args{question}";
    my ($qCount) = $args{dbh}->selectrow_array($sqlcode);

    return ($qCount);
}


###################################################################################################################################
sub doProcessQuestionDelete {  # routine to delete a question
###################################################################################################################################
    my %args = (
        userID => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $sqlcode;
    my $status = 0;
    my $id;
    
    eval {
        $id = $settings{c_questionid};
        my $text = $settings{question};
        my $role = $settings{role};
        $sqlcode = "DELETE FROM $args{schema}.questions WHERE id = $id";
#print STDERR "\n$sqlcode\n\n";
        my $csr = $args{dbh}->prepare($sqlcode);
        $status = $csr->execute;

    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1,$id);
}


###################################################################################################################################

1; #return true
