#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/pcl/perl/RCS/DBWorkRequest.pm,v $
#
# $Revision: 1.5 $
#
# $Date: 2008/07/10 17:41:59 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBWorkRequest.pm,v $
# Revision 1.5  2008/07/10 17:41:59  atchleyb
# Updated to send e-mail notifications of status changes to all users with the new privilege of "Work Request Notification" (3)
#
# Revision 1.4  2004/02/25 17:36:52  munroeb
# Added binary attachment functionality to work request form.
#
# Revision 1.3  2003/11/28 21:22:59  starkeyj
# modified getWorkRequests subroutine to sort in descending order
#
# Revision 1.2  2003/11/26 22:18:31  higashis
# Modified to finish workrequest logic for SCR14
#
# Revision 1.1  2003/11/13 20:46:56  starkeyj
# Initial revision
#
#
#
package DBWorkRequest;
use strict;
use SharedHeader qw(:Constants);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use Tables qw(:Functions);
use Tie::IxHash;
use DBI;
use DBD::Oracle qw(:ora_types);
use Carp;
use Mail_Utilities_Lib qw(:Functions);

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
    &getWorkRequests        &doProcessCreateWR      &doProcessUpdateWR
    &doProcessUpdateReview      &getPrivilegeList   &getAttachments
    &doProcessAttachments
);
%EXPORT_TAGS =(
    Functions => [qw(
    &getWorkRequests        &doProcessCreateWR      &doProcessUpdateWR
    &doProcessUpdateReview      &getPrivilegeList   &getAttachments
    &doProcessAttachments
    )]
);


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub getWorkRequests {  # routine to get the work requests
###################################################################################################################################
    my %args = (
        request => 0,  # null
        status => 0, # all
        single => 0,
        @_,
    );
    #$args{dbh}->{LongReadLen} = 100000000;
    my @requestList;
    my $sqlcode = "SELECT id,owner,contact,email,organization,phone,modifyexisting,existing_system, ";
    $sqlcode .= "reason,benefits,involved_orgs,business_process,requested_delivery,comments,";
    $sqlcode .= "to_char(submit_date,'MM/DD/YYYY'),disposition,to_char(disposition_date,'MM/DD/YYYY'),requirements,";
    $sqlcode .= "CHAIR,DEVELOPMENTGROUP,PROJECTMANAGER,CCB,STANDARDS,SAFETY,SECURITY,RECORDS,";
    $sqlcode .= "ARCHITECTURE,SECTION508,APSI_1Q,INTERNET,PRIVACY,reason_rej ";
    $sqlcode .= "FROM $args{schema}.work_request ";
    $sqlcode .= ($args{single}) ? "WHERE id = $args{request} " : "WHERE disposition = '$args{status}' ";
    $sqlcode .= "ORDER BY id desc";
    #print "\n $sqlcode \n";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;

    my $i = 0;
    while (($requestList[$i]{id},$requestList[$i]{owner},$requestList[$i]{contact},$requestList[$i]{email},
    $requestList[$i]{organization},$requestList[$i]{phone},$requestList[$i]{modifyexisting},$requestList[$i]{existingsystem},
    $requestList[$i]{reason},$requestList[$i]{benefits},$requestList[$i]{involvedorgs},$requestList[$i]{process},
    $requestList[$i]{requesteddelivery},$requestList[$i]{comments},$requestList[$i]{submitted},$requestList[$i]{disposition},
    $requestList[$i]{dispositiondate},$requestList[$i]{requirements}, $requestList[$i]{CHAIR},
    $requestList[$i]{DEVELOPMENTGROUP},$requestList[$i]{PROJECTMANAGER},$requestList[$i]{CCB},$requestList[$i]{STANDARDS},
    $requestList[$i]{SAFETY},$requestList[$i]{SECURITY},$requestList[$i]{RECORDS},$requestList[$i]{ARCHITECTURE},
    $requestList[$i]{SECTION508},$requestList[$i]{APSI_1Q},$requestList[$i]{INTERNET},$requestList[$i]{PRIVACY},$requestList[$i]{reason_rej}) = $csr->fetchrow_array)
    {
        $i++;
    }

    return (@requestList);
}

###################################################################################################################################
sub doProcessCreateWR {  # routine to insert a new work request into the DB
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;

    my $output = "";
    my $requestID = $args{dbh}->selectrow_array("SELECT $args{schema}.workrequest_id_seq.NEXTVAL FROM dual");

    my $requirements = $args{dbh}->quote($settings{requirements});
    my $owner = $args{dbh}->quote($settings{owner});
    my $reason = $args{dbh}->quote($settings{reason});
    my $reason_rej = $args{dbh}->quote($settings{reason_rej});
    my $benefits = $args{dbh}->quote($settings{benefits});
    my $involvedOrgs = $args{dbh}->quote($settings{involvedOrgs});
    my $businessProcesses = $args{dbh}->quote($settings{businessProcesses});
    my $daterequired = $args{dbh}->quote($settings{daterequired});
    my $comments = $args{dbh}->quote($settings{comments});
    my $department = $args{dbh}->quote($settings{department});
    my $contact = $args{dbh}->quote($settings{contact});
    my $modifyexisting = $settings{existing} == 0 ?  'No' : 'Yes' ;
    my $existingsystem = ($settings{existingsystem} eq "") ?  "NULL" : $args{dbh}->quote($settings{existingsystem});

    my $sqlcode = "INSERT INTO $args{schema}.work_request (id,owner,contact,email,organization,phone,modifyexisting,existing_system, ";
    $sqlcode .= "reason,benefits,involved_orgs,business_process,requested_delivery,comments,";
    $sqlcode .= "submit_date,disposition,disposition_date,requirements,reason_rej) ";
    $sqlcode .= "VALUES ($requestID,$owner,$contact,'$settings{email}',$department,";
    $sqlcode .= "'$settings{phone}','$modifyexisting',$existingsystem,$reason,$benefits,$involvedOrgs,";
    $sqlcode .= "$businessProcesses,$daterequired,$comments,sysdate,'Pending',sysdate,$requirements,$reason_rej)";
    #print STDERR "\n$sqlcode\n";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;

    ## Attachment Code
    #

    ## HACK - use CGI(): Yes I know that doing this volates the way the framework is supposed to work, but hey, I can't figure
    ## out how to pass multiple arbitrary <input type=file> uploads from the @settings hash. -- BEM
    #

    use CGI;
    my $q = new CGI();
    my @filenames = $q->param('attachment');

    my $index = "";

    foreach $index (@filenames) {
        if ($index) {
            my $newFilename = $index;
            $newFilename =~ s/\\/\//g;
            $newFilename =~ s!^.*/!!;  # return only the filename, remove the file path
            $newFilename =~ s/&//g;
            $newFilename =~ s/ /_/g;

            my %mimeTypes = (
                'doc' => "application/msword",
                'dot' => "application/msword",
                'rtf' => "application/msword",
                'xls' => "application/vnd.ms-excel",
                'txt' => "text/plain",
                'ppt' => "application/vnd.ms-powerpoint",
                'pdf' => "application/pdf",
            );

            my $mimetype = undef;

            (undef,$mimetype) = split(/\./,$index);
            $mimetype = $mimeTypes{$mimetype};

            $mimetype = "text/plain" if $mimetype eq "";

            my $bytesread = undef;
            my $buffer = undef;
            my $attachmentData = undef;

            while ($bytesread=read($index,$buffer,1024000)) {
                $attachmentData = $attachmentData.$buffer;
            }
            close $index;

            ## load attachment data into database
            #
            my $sql = "insert into $args{schema}.work_request_attachments (attachmentid, requestid, attachment, filename) values (work_request_attach_seq.NEXTVAL, \'$requestID\', ?, \'$newFilename\')";
            my $csr = $args{dbh}->prepare($sql);
            $csr->bind_param(1, $attachmentData, {ora_type=>ORA_BLOB, ora_field=>'attachment'});
            $csr->execute;
            $args{dbh}->commit;
            $csr->finish;
            undef $attachmentData;
        }
    }

    $args{dbh}->commit;
    $csr->finish;
    &log_activity($args{dbh},$args{schema},$args{userID},"Work Request ID $requestID inserted");

    my $DOEemail = &getEmailList(dbh=>$args{dbh},schema=>$args{schema},privilege=>'12,3');
    my $emailAddress = "$settings{email}";
    s/@/\@/g;
    my $message = "Your Work Request has been submitted to the Project Control Library.\n\n";
    $message .= "Work Request ID:  $requestID\n";
    $message .= "Project Sponsor:  $settings{owner}\nDepartment:  $settings{department}\nContact:  $settings{contact}\n";
    $message .= "Email:  $settings{email}\nPhone:  $settings{phone}\nModifcation to existing system?  $modifyexisting\n";
    $message .= ($modifyexisting eq 'Yes') ? "Existing System:  $settings{existingsystem}\n" : "" ;
    $message .= "Software Requirements:  $settings{requirements}\n";
    $message .= "Business Processes Affected:  $settings{businessProcesses}\nWhen will a solution be required?  $settings{daterequired}\n";
    $message .= "\n\nYou will be notified when your Work Request is being reviewed and when it is approved or rejected.\n";
    $message .= "You can track the status of your request by using the following link:\nhttps://$ENV{HTTP_HOST}/cgi-bin/pcl/login.pl\n";
    $message .= "\n\nDO NOT REPLY TO THIS EMAIL\n";
    #$emailAddress = "brian.munroe\@ymp.gov";
    #$DOEemail = "";
    $output .= SendMailMessage(sendTo=>"$emailAddress", copyto=>"$DOEemail",sender=>"Project_Control", subject=>"New Work Request", message=>"$message", timeStamp=>"F");

    $output .= doAlertBox(text => "Work Request $requestID successfully inserted");
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('workRequest','browse');\n";
    $output .= "//--></script>\n";

    return($output);
}
###################################################################################################################################
sub doProcessUpdateWR {  # routine to update a work request in the DB
###################################################################################################################################
    my %args = (
        request => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;

    my $output = "";
    my $statusChangedFlag = 0;
    my $TeamLeademail = "";
    my $notifyemail = "";
    my $message = "";
    my $requirements = $args{dbh}->quote($settings{requirements});
    my $owner = $args{dbh}->quote($settings{owner});
    my $reason = $args{dbh}->quote($settings{reason});
    my $reason_rej = $args{dbh}->quote($settings{reason_rej});
    my $benefits = $args{dbh}->quote($settings{benefits});
    my $involvedOrgs = $args{dbh}->quote($settings{involvedOrgs});
    my $businessProcesses = $args{dbh}->quote($settings{businessProcesses});
    my $daterequired = $args{dbh}->quote($settings{daterequired});
    my $comments = $args{dbh}->quote($settings{comments});
    my $department = $args{dbh}->quote($settings{department});
    my $contact = $args{dbh}->quote($settings{contact});
    my $modifyexisting = $settings{existing} == 0 ?  'No' : 'Yes' ;
    my $existingsystem = ($settings{existingsystem} eq "") ?  "NULL" : $args{dbh}->quote($settings{existingsystem}) ;
    my $oldDisposition = $args{dbh}->selectrow_array("SELECT disposition from $args{schema}.work_request where id = $args{request}");

    my $sqlcode = "UPDATE $args{schema}.work_request ";
    $sqlcode .= "SET requirements = $requirements, ";
    $sqlcode .= "owner = $owner, ";
    $sqlcode .= "reason = $reason, ";
    $sqlcode .= "benefits = $benefits, ";
    $sqlcode .= "involved_orgs = $involvedOrgs, ";
    $sqlcode .= "business_process = $businessProcesses, ";
    $sqlcode .= "requested_delivery = $daterequired, ";
    $sqlcode .= "comments = $comments, ";
    $sqlcode .= "organization = $department, ";
    $sqlcode .= "contact = $contact, ";
    $sqlcode .= "modifyexisting = '$modifyexisting', ";
    $sqlcode .= "existing_system = $existingsystem, ";
    $sqlcode .= "phone = '$settings{phone}', ";
    $sqlcode .= "email = '$settings{email}', ";
    $sqlcode .= "reason_rej = '$settings{reason_rej}' ";
    if ($oldDisposition ne $settings{disposition}) {
        $sqlcode .= ",disposition = '$settings{disposition}', ";
        $sqlcode .= "disposition_date = sysdate ";
        $statusChangedFlag = 1;
    }
    $sqlcode .= "WHERE id = $args{request} ";
    #print "\n$sqlcode\n";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    $args{dbh}->commit;
    $csr->finish;
    &log_activity($args{dbh},$args{schema},$args{userID},"Work Request ID $args{request} updated");

    my $emailAddress = "$settings{email}";
    s/@/\@/g;

    if ($statusChangedFlag){  ##### if there is any changes in disposition
    $message = "Work Request ID:  $args{request}\n";
    $message .= "New Status:  $settings{disposition}\n";
    if ($settings{disposition} eq 'Rejected') {
        $message .= "Rejected Reason:  $settings{reason_rej}\n";
    }
    $notifyemail = &getEmailList(dbh=>$args{dbh},schema=>$args{schema},privilege=>'3');
    if ($settings{disposition} eq 'Approved') {
        #$TeamLeademail = &getEmailList(dbh=>$args{dbh},schema=>$args{schema},privilege=>'13,14');
        $message .= "\n\nProject Sponsor:  $settings{owner}\nDepartment:  $settings{department}\nContact:  $settings{contact}\n";
        $message .= "Email:  $settings{email}\nPhone:  $settings{phone}\nModifcation to existing system?  $modifyexisting\n";
        $message .= ($modifyexisting eq 'Yes') ? "Existing System:  $settings{existingsystem}\n" : "" ;
        $message .= "Software Requirements:  $settings{requirements}\n";
        $message .= "Business Processes Affected:  $settings{businessProcesses}\nWhen will a solution be required?  $settings{daterequired}\n";
    }
    $message .= "\n\nYou can view this request by using the following link:\nhttps://$ENV{HTTP_HOST}/cgi-bin/pcl/login.pl\n";
    $message .= "\n\nDO NOT REPLY TO THIS EMAIL\n";
    $output .= SendMailMessage(sendTo=>$emailAddress,copyto=>"$notifyemail", sender=>"Project_Control", subject=>"Work Request $args{request} - Status Change", message=>"$message", timeStamp=>"F");
    }

    $output .= doAlertBox(text => "Work Request $args{request} successfully updated");
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('workRequest','browse');\n";
    $output .= "//--></script>\n";

    return($output);
}
###################################################################################################################################
sub doProcessUpdateReview {  # routine to update a review in the DB
###################################################################################################################################
    my %args = (
        request => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;

    my $output = "";
    my $developmentGroup = $args{dbh}->quote($settings{developmentGroup});
    my $CCB = $args{dbh}->quote($settings{CCB});
    my $standards = $args{dbh}->quote($settings{standards});
    my $safety = $args{dbh}->quote($settings{safety});
    my $security = $args{dbh}->quote($settings{security});
    my $records = $args{dbh}->quote($settings{records});
    my $architecture = $args{dbh}->quote($settings{architecture});
    my $section508 = $args{dbh}->quote($settings{section508});
    my $businessProcesses = $args{dbh}->quote($settings{businessProcesses});
    my $internet = $args{dbh}->quote($settings{internet});
    my $privacy = $args{dbh}->quote($settings{privacy});
    my $APSI_1Q = $args{dbh}->quote($settings{APSI_1Q});

    my $sqlcode = "UPDATE $args{schema}.work_request ";
    $sqlcode .= "SET CHAIR = $settings{chair}, ";
    $sqlcode .= "DEVELOPMENTGROUP = $developmentGroup, ";
    $sqlcode .= "PROJECTMANAGER = $settings{projectManager}, ";
    $sqlcode .= "CCB = $CCB, ";
    $sqlcode .= "STANDARDS = $standards, ";
    $sqlcode .= "SAFETY = $safety, ";
    $sqlcode .= "SECURITY = $security, ";
    $sqlcode .= "RECORDS = $records, ";
    $sqlcode .= "ARCHITECTURE = $architecture, ";
    $sqlcode .= "SECTION508 = $section508, ";
    $sqlcode .= "APSI_1Q = $APSI_1Q, ";
    $sqlcode .= "INTERNET = $internet, ";
    $sqlcode .= "PRIVACY = $privacy ";

    $sqlcode .= "WHERE id = $args{request} ";
    #print "\n$sqlcode\n";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;



    $args{dbh}->commit;
    $csr->finish;
    &log_activity($args{dbh},$args{schema},$args{userID},"Work Request ID $args{request} updated");

    $output .= doAlertBox(text => "Work Request $args{request} successfully updated");
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('workRequest','browse');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub getEmailList {  # routine to get email addresses
###################################################################################################################################
    my %args = (
        privilege => 0,
        @_,
    );
    my @emailList;
    my $sqlcode = "SELECT u.id,u.firstname,u.lastname,u.email ";
    $sqlcode .= "FROM $args{schema}.users u,  $args{schema}.user_privilege up ";
    $sqlcode .= "WHERE u.id = up.userid ";
    $sqlcode .= ($args{privilege}) ? " AND up.privilege in ($args{privilege}) " : "";
    #$sqlcode .= "ORDER BY id ";
    #print "\n $sqlcode \n";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;

    my $i = 0;
    while (($emailList[$i]{id},$emailList[$i]{firstname},$emailList[$i]{lastname},$emailList[$i]{email}) = $csr->fetchrow_array)
    {
        $i++;
    }
    my $emailList = "";
    for (my $i = 0; $i < $#emailList; $i++) {
       my ($id,$firstname,$lastname,$email) =
        ($emailList[$i]{id},$emailList[$i]{firstname},$emailList[$i]{lastname},$emailList[$i]{email});
        $emailList .= $email . ",";
    }
    chop($emailList);
    return ($emailList);
}
###################################################################################################################################
sub getPrivilegeList {  # routine to get usernames by privilege
###################################################################################################################################
    my %args = (
        privilege => 0,
        @_,
    );
    my @privList;
    my $sqlcode = "SELECT u.id,u.firstname,u.lastname,u.email ";
    $sqlcode .= "FROM $args{schema}.users u,  $args{schema}.user_privilege up ";
    $sqlcode .= "WHERE u.id = up.userid ";
    $sqlcode .= ($args{privilege}) ? " AND up.privilege in ($args{privilege}) " : "";
    #$sqlcode .= "ORDER BY id ";
    #print "\n $sqlcode \n";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;

    my $i = 0;
    while (($privList[$i]{id},$privList[$i]{firstname},$privList[$i]{lastname},$privList[$i]{email}) = $csr->fetchrow_array)
    {
        $i++;
    }

    return (@privList);
}

###################################################################################################################################
sub getAttachments {  # routine to get attachments for a given work request
###################################################################################################################################
    my %args = (
        requestID => 0,
        @_,
    );
    my @attachmentList = undef;
    my $sql = "select attachmentid, requestid, filename from $args{schema}.work_request_attachments where requestid = $args{requestID}";
    my $csr = $args{dbh}->prepare($sql);
    my $status = $csr->execute;
    my $i = 0;
    while (($attachmentList[$i]{attachmentid},$attachmentList[$i]{requestid},$attachmentList[$i]{filename}) = $csr->fetchrow_array)
    {
        $i++;
    }
    return @attachmentList;

}

###################################################################################################################################
sub doProcessAttachments {  # routine to get attachments for a given work request
###################################################################################################################################
    my %args = (
        requestID => 0,
        @_,
    );

    my $hashRef = $args{settings};
    my %settings = %$hashRef;

    $args{dbh}->{LongReadLen} = 1024 * 512 * 1000;

    my $sql = "select attachment from pcl.work_request_attachments where requestid = $settings{requestid} and attachmentid = $settings{attachmentid}";
    my $csr = $args{dbh}->prepare($sql);
    my $status = $csr->execute;
    my ($buff) = $csr->fetchrow_array();
    print "Content-Disposition: $settings{'loadtype'}; filename=$settings{'filename'};\n\n";
    print $buff;
    &db_disconnect($args{dbh});
    exit(1);
}

###################################################################################################################################
###################################################################################################################################


1; #return true

