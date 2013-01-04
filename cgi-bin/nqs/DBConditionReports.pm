#
# $Source: /data/dev/rcs/qa/perl/RCS/DBConditionReports.pm,v $
#
# $Revision: 1.4 $ 
#
# $Date: 2005/10/31 23:21:02 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: DBConditionReports.pm,v $
# Revision 1.4  2005/10/31 23:21:02  starkeyj
# modified doProcessCreateCondition and doProcessUpdateCondition to include the qard elements
# modified getConditions to select the qard elements
#
# Revision 1.3  2004/04/07 14:59:25  starkeyj
# modified ConditionReport, FollowUp, and BestPractice functions to use audit ID OR Surveillance ID
# instead of surveillance ID.
#
# Revision 1.2  2004/01/25 23:55:23  starkeyj
# added functions to edit Best Practice, CR and Followup to CR
#
# Revision 1.1  2004/01/13 13:55:41  starkeyj
# Initial revision
#
#
#
package DBConditionReports;
use strict;
#use SharedHeader qw(:Constants);
use NQS_Header qw(:Constants);
use OQA_Utilities_Lib qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use Carp;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
	&getConditions			&getFollowups 			&getBestPractice
	&doProcessCreateCondition	&doProcessCreateFollowup	&doProcessCreateBestPractice
	&doProcessUpdateCondition	&doProcessDeleteCondition	&doProcessUpdateFollowup
	&doProcessDeleteFollowup	&doProcessUpdateBestPractice
);
%EXPORT_TAGS =( 
    Functions => [qw(
	&getConditions			&getFollowups 			&getBestPractice
	&doProcessCreateCondition	&doProcessCreateFollowup	&doProcessCreateBestPractice
	&doProcessUpdateCondition	&doProcessDeleteCondition	&doProcessUpdateFollowup
	&doProcessDeleteFollowup	&doProcessUpdateBestPractice
    )]
);


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub getConditions {  # routine to get Condition Reports
###################################################################################################################################
    my %args = (
        survID => 0,  # null
        auditID => 0,  # null
        CRid => 0,  # null
        type => 0, # all
        single => 0,
        fiscalyear => 50,
        @_,
    );
    my $fy = $args{fiscalyear} > 50 ? $args{fiscalyear} + 1900 : $args{fiscalyear} + 2000;
    #$args{dbh}->{LongReadLen} = 100000000;
    my @conditionList;
    my $sqlcode = "SELECT id,crnum,crlevel,summary,to_char(crdate,'MM/DD/YYYY'),qard_elements ";
    $sqlcode .= "FROM $args{schema}.condition_report ";
    $sqlcode .= ($args{CRid}) ? "WHERE id = $args{CRid} " : " ";
    $sqlcode .= ($args{survID}) ? "WHERE generatorfy = $fy AND generatorid = $args{survID} AND generatedfrom = 'S' " : "";
    $sqlcode .= ($args{auditID}) ? "WHERE generatorfy = $fy AND generatorid = $args{auditID} AND generatedfrom = '$args{generatedfrom}' " : "";
    $sqlcode .= "ORDER BY upper(crnum) ";
  # print "\n $sqlcode \n";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    
    my $i = 0;
    while (($conditionList[$i]{crid},$conditionList[$i]{crnum},$conditionList[$i]{crlevel},
    $conditionList[$i]{crsummary},$conditionList[$i]{crdate},$conditionList[$i]{crqard}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@conditionList);
}
###################################################################################################################################
sub doProcessCreateCondition {  # routine to insert a new condition report into the DB
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    
    my $output = "";
    my $CRid = $args{dbh}->selectrow_array("SELECT $args{schema}.condition_report_seq.NEXTVAL FROM dual");

    my $crnum = $args{dbh}->quote($settings{crnum});
    my $conditiontext = $args{dbh}->quote($settings{conditiontext});


    my $sqlcode = "INSERT INTO $args{schema}.condition_report (id, crnum, crlevel, summary ";
    $sqlcode .= $settings{generatedfrom} ? ", generatedfrom" : "";
    $sqlcode .= $settings{survID} || $settings{auditID} ? ", generatorid" : "";
    $sqlcode .= $settings{survID} || $settings{auditID} ? ", generatorfy" : "";
    $sqlcode .= $settings{qardstring} ? ", qard_elements" : "";
    $sqlcode .= ") ";
    $sqlcode .= "VALUES ($CRid,$crnum,'$settings{level}',$conditiontext ";
    $sqlcode .= $settings{generatedfrom} ?",'$settings{generatedfrom}'" : "";
    $sqlcode .= $settings{survID} ? ",'$settings{survID}'" : $settings{auditID} ?  ",'$settings{auditID}'" : "";
    $sqlcode .= $settings{survID} || $settings{auditID} ? ",'$settings{generatorfy}'" : "";
    $sqlcode .= $settings{qardstring} ?",'$settings{qardstring}'" : "";
    $sqlcode .= ")";

    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    $args{dbh}->commit;
    $csr->finish;
    &log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"Condition Report $settings{crnum} (ID: $CRid) inserted");
    
    #$output .= doAlertBox(text => "Condition Report $crnum successfully inserted");
    $output .= "<script language=javascript><!--\n";
    $output .= "    document.conditionReports.table.value = '$settings{table}';\n";
    $output .= $settings{survID} ? "   submitForm('surveillance2','viewSurveillance');\n" : $settings{auditID} ? "   submitForm('audit2','viewAudit');\n" : "   submitForm('home','');\n";
    $output .= "//--></script>\n";
    
    return($output);
}
###################################################################################################################################
sub doProcessUpdateCondition {  # routine to update a condition report in the DB
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    
    my $output = "";
    my $crnum = $args{dbh}->quote($settings{crnum});
    my $conditiontext = $args{dbh}->quote($settings{conditiontext});


    my $sqlcode = "UPDATE $args{schema}.condition_report ";
    $sqlcode .= "SET crnum = $crnum, crlevel = '$settings{level}', summary = $conditiontext ,qard_elements = '$settings{qardstring}'";
    $sqlcode .= "WHERE id = $args{CRid}";

    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    $args{dbh}->commit;
    $csr->finish;
    &log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"Condition Report $settings{crnum} (ID: $args{CRid}) updated");
    
    #$output .= doAlertBox(text => "Condition Report $crnum successfully inserted");
    $output .= "<script language=javascript><!--\n";
    $output .= "    document.conditionReports.table.value = '$settings{table}';\n";
    $output .= $settings{survID} ? "   submitForm('surveillance2','viewSurveillance');\n" : $settings{auditID} ? "   submitForm('audit2','viewAudit');\n" : "   submitForm('home','');\n";
    $output .= "//--></script>\n";
    
    return($output);
}
###################################################################################################################################
sub doProcessDeleteCondition {  # routine to delete a condition report 
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    
    my $output = "";

    my $sqlcode = "UPDATE $args{schema}.condition_report ";
    $sqlcode .= "SET generatedfrom = NULL, generatorid = NULL, generatorfy = NULL ";
    $sqlcode .= "WHERE id = $args{CRid} ";

#print  "\n$sqlcode\n";    

    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    $args{dbh}->commit;
    $csr->finish;
    &log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"Condition Report $settings{crnum} (ID: $args{CRid}) deleted");
    
    #$output .= doAlertBox(text => "Condition Report $crnum successfully deleted");
    $output .= "<script language=javascript><!--\n";
    $output .= "    document.conditionReports.table.value = '$settings{table}';\n";
    $output .= $settings{survID} ? "   submitForm('surveillance2','viewSurveillance');\n" : $settings{auditID} ? "   submitForm('audit2','viewAudit');\n" : "   submitForm('home','');\n";
    $output .= "//--></script>\n";
    
    return($output);
}
###################################################################################################################################
sub getFollowups {  # routine to get Followups to Condition Reports
###################################################################################################################################
    my %args = (
        survID => 0,  # null
        auditID => 0,  # null
        CRid => 0,  # null
        type => 0, # all
        single => 0,
        fiscalyear => 50,
        @_,
    );
    #$args{dbh}->{LongReadLen} = 100000000;
    my $fy = $args{fiscalyear} > 50 ? $args{fiscalyear} + 1900 : $args{fiscalyear} + 2000;
    my @followupList;
    my $sqlcode = "SELECT crid,crnum,followupnum,followup,to_char(crfudate,'MM/DD/YYYY') ";
    $sqlcode .= "FROM $args{schema}.condition_report_follow_up crfu, $args{schema}.condition_report cr ";
    $sqlcode .= "WHERE crfu.crid = cr.id ";
    $sqlcode .= ($args{survID}) ? "AND crfu_generatorfy = $fy AND crfu_generatorid = $args{survID} AND crfu_generatedfrom = 'S' " : "";
    $sqlcode .= ($args{auditID}) ? "AND crfu_generatorfy = $fy AND crfu_generatorid = $args{auditID} AND crfu_generatedfrom = '$args{generatedfrom}' " : "";
    $sqlcode .= ($args{CRid}) ? "AND crid = $args{CRid} AND followupnum = $args{funum} " : "";
    $sqlcode .= "ORDER BY crid, followupnum ";
#   print "\n <br>$sqlcode \n";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    
    my $i = 0;
    while (($followupList[$i]{crid},$followupList[$i]{crnum},$followupList[$i]{followupnum},$followupList[$i]{followup},
    $followupList[$i]{followupdate}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@followupList);
}
###################################################################################################################################
sub doProcessCreateFollowup {  # routine to insert a new followup to a condition report 
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;

    my $output = "";

    my $FUnum = $args{dbh}->selectrow_array("SELECT max(followupnum) FROM $args{schema}.condition_report_follow_up WHERE crid = $settings{CRid}");
    $FUnum = defined($FUnum) ? $FUnum  + 1 : 1;
    my $followuptext = $args{dbh}->quote($settings{followuptext});


    my $sqlcode = "INSERT INTO $args{schema}.condition_report_follow_up (crid, followupnum, followup, crfu_generatedfrom, crfu_generatorid, crfu_generatorfy ) ";
    $sqlcode .= "VALUES ($settings{CRid},$FUnum,$followuptext,'$settings{generatedfrom}','$settings{generatorid}','$settings{generatorfy}')";

#print  "\n$sqlcode\n";    

    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    $args{dbh}->commit;
    $csr->finish;
    &log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"Condition Report Followup $FUnum for CR $settings{crnum} (ID: $settings{CRid}) inserted");
    
    #$output .= doAlertBox(text => "Condition Report followup $crnum successfully inserted");
    $output .= "<script language=javascript><!--\n";
    $output .= "    document.conditionReports.table.value = '$settings{table}';\n";
    $output .= $settings{survID} ? "   submitForm('surveillance2','viewSurveillance');\n" : $settings{auditID} ? "   submitForm('audit2','viewAudit');\n" : "   submitForm('home','');\n";
    $output .= "//--></script>\n";
    
    return($output);
}
###################################################################################################################################
sub doProcessUpdateFollowup {  # routine to update a followup to a condition report 
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;

    my $output = "";
    my $followuptext = $args{dbh}->quote($settings{followuptext});


    my $sqlcode = "UPDATE $args{schema}.condition_report_follow_up ";
    $sqlcode .=  "SET followup = $followuptext ";
    $sqlcode .= "WHERE crid = $args{CRid} AND followupnum = $args{funum} ";

#print  "\n$sqlcode\n";    

    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    $args{dbh}->commit;
    $csr->finish;
    &log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"Condition Report Followup $args{funum} for CR $settings{crnum} (ID: $settings{CRid}) updated");
    
    #$output .= doAlertBox(text => "Condition Report followup $crnum successfully updated");
    $output .= "<script language=javascript><!--\n";
    $output .= "    document.conditionReports.table.value = '$settings{table}';\n";
    $output .= $settings{survID} ? "   submitForm('surveillance2','viewSurveillance');\n" : $settings{auditID} ? "   submitForm('audit2','viewAudit');\n" : "   submitForm('home','');\n";
    $output .= "//--></script>\n";
    
    return($output);
}
###################################################################################################################################
sub doProcessDeleteFollowup {  # routine to delete a followup to a condition report 
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;

    my $output = "";

    my $csr = $args{dbh}->do("DELETE from $args{schema}.condition_report_follow_up where crid = $args{CRid} AND followupnum = $args{funum}" );
    &log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"Condition Report Followup $args{funum} for CR $settings{crnum} (ID: $settings{CRid}) deleted");
    
    #$output .= doAlertBox(text => "Condition Report followup $crnum successfully inserted");
    $output .= "<script language=javascript><!--\n";
    $output .= "    document.conditionReports.table.value = '$settings{table}';\n";
    $output .= $settings{survID} ? "   submitForm('surveillance2','viewSurveillance');\n" : $settings{auditID} ? "   submitForm('audit2','viewAudit');\n" : "   submitForm('home','');\n";
    $output .= "//--></script>\n";
    
    return($output);
}
###################################################################################################################################
sub getBestPractice {  # routine to get Best Practices
###################################################################################################################################
    my %args = (
        survID => 0,  # null
        auditID => 0,  # null
        type => 0, # all
        single => 0,
        fiscalyear => 50,
        @_,
    );
    #$args{dbh}->{LongReadLen} = 100000000;
    my $fy = $args{fiscalyear} > 50 ? $args{fiscalyear} + 1900 : $args{fiscalyear} + 2000;
    my @bestPracticeList;
    my $sqlcode = "SELECT id,bestpractice,to_char(bpdate,'MM/DD/YYYY') ";
    $sqlcode .= "FROM $args{schema}.best_practice ";
    #$sqlcode .= ($args{single}) ? " id = $args{survID} " : " ";
    $sqlcode .= ($args{survID}) ? "WHERE generatorfy = $fy AND generatorid = $args{survID} AND generatedfrom = 'S' " : "";
    $sqlcode .= ($args{auditID}) ? "WHERE generatorfy = $fy AND generatorid = $args{auditID} AND generatedfrom = '$args{generatedfrom}' " : "";
    $sqlcode .= ($args{bpnum}) ? "WHERE id = $args{bpnum} " : "";
    $sqlcode .= "ORDER BY id ";
#   print "\n $sqlcode \n";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    
    my $i = 0;
    while (($bestPracticeList[$i]{bpid},$bestPracticeList[$i]{bestpractice},
    $bestPracticeList[$i]{bpdate}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@bestPracticeList);
}
###################################################################################################################################
sub doProcessCreateBestPractice {  # routine to insert a new best practice
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;

    my $output = "";

    my $BPnum = $args{dbh}->selectrow_array("SELECT $args{schema}.best_practice_seq.NEXTVAL FROM dual");
    my $bestpractice = $args{dbh}->quote($settings{bestpracticetext});


    my $sqlcode = "INSERT INTO $args{schema}.best_practice (id, bestpractice, generatedfrom, generatorid, generatorfy ) ";
    $sqlcode .= "VALUES ($BPnum,$bestpractice,'$settings{generatedfrom}','$settings{generatorid}','$settings{generatorfy}')";

#print  "\n$sqlcode\n";    

    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    $args{dbh}->commit;
    $csr->finish;
    &log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"Best Practice inserted");
    
    #$output .= doAlertBox(text => "Best Practice $bpnum successfully inserted");
    $output .= "<script language=javascript><!--\n";
    $output .= "    document.conditionReports.table.value = '$settings{table}';\n";
    $output .= $settings{survID} ? "   submitForm('surveillance2','viewSurveillance');\n" : $settings{auditID} ? "   submitForm('audit2','viewAudit');\n" : "   submitForm('home','');\n";
    $output .= "//--></script>\n";
    
    return($output);
}
###################################################################################################################################
sub doProcessUpdateBestPractice {  # routine to update best practice
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;

    my $output = "";
    my $bestpractice = $args{dbh}->quote($settings{bestpracticetext});


    my $sqlcode = "UPDATE $args{schema}.best_practice ";
    $sqlcode .= "SET bestpractice = $bestpractice WHERE id = $args{bpnum} ";
#print  "\n$sqlcode\n";    

    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    $args{dbh}->commit;
    $csr->finish;
    &log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"Best Practice updated");
    
    #$output .= doAlertBox(text => "Best Practice $bpnum successfully updated");
    $output .= "<script language=javascript><!--\n";
    $output .= "    document.conditionReports.table.value = '$settings{table}';\n";
    $output .= $settings{survID} ? "   submitForm('surveillance2','viewSurveillance');\n" : $settings{auditID} ? "   submitForm('audit2','viewAudit');\n" : "   submitForm('home','');\n";
    $output .= "//--></script>\n";
    
    return($output);
}
###################################################################################################################################


1; #return true

