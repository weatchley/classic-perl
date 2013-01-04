#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/pcl/perl/RCS/UIWorkRequest.pm,v $
#
# $Revision: 1.6 $
#
# $Date: 2008/02/07 19:02:51 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIWorkRequest.pm,v $
# Revision 1.6  2008/02/07 19:02:51  atchleyb
# CREQ00019 - replaced all occurances of OPM/ITD with OGS/IT
#
# Revision 1.5  2007/11/06 19:20:20  atchleyb
# CR00019 - Add the work requests statuses of "Closed" and "Withdrawn"
#
# Revision 1.4  2004/02/25 17:37:26  munroeb
# Added binary attachment functionality to work request form.
#
# Revision 1.3  2003/11/28 21:31:43  starkeyj
# added a checkLength javascript function and added a length check for most fields
#
# Revision 1.2  2003/11/26 22:18:31  higashis
# Modified to finish workrequest logic for SCR14
#
# Revision 1.1  2003/11/13 20:46:56  starkeyj
# Initial revision
#
#
package UIWorkRequest;
use strict;
use SharedHeader qw(:Constants);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use Tables qw(:Functions);
use DBWorkRequest qw(:Functions);
use UIShared qw(:Functions);
use CGI qw(param);
use Tie::IxHash;
use Carp;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
    Functions => [qw(
      &doHeader                     &doFooter           &getInitialValues
      &doBrowseRequests         &doRequestForm      &doDisplayRequest
      &doReviewForm
    )]
);
%EXPORT_TAGS =(
    Functions => [qw(
      &doHeader                     &doFooter           &getInitialValues
      &doBrowseRequests         &doRequestForm          &doDisplayRequest
      &doReviewForm
    )]
);

my $mycgi = new CGI;

###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub getInitialValues {  # routine to get initial CGI values and return in a hash
###################################################################################################################################
    my %args = (
        dbh => "",
        @_,
    );
    my %valueHash = (
       schema => (defined($mycgi->param("schema"))) ? $mycgi->param("schema") : $ENV{'SCHEMA'},
       command => (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "browse",
       username => (defined($mycgi->param("username"))) ? $mycgi->param("username") : "",
       userid => (defined($mycgi->param("userid"))) ? $mycgi->param("userid") : "",
       project => (defined($mycgi->param("project"))) ? $mycgi->param("project") : 0,
       request => (defined($mycgi->param("request"))) ? $mycgi->param("request") : 0,
       owner => (defined($mycgi->param("owner"))) ? $mycgi->param("owner") : "",
       department => (defined($mycgi->param("department"))) ? $mycgi->param("department") : "",
       contact => (defined($mycgi->param("contact"))) ? $mycgi->param("contact") : "",
       phone => (defined($mycgi->param("phone"))) ? $mycgi->param("phone") : "",
       disposition => (defined($mycgi->param("disposition"))) ? $mycgi->param("disposition") : "",
       existing => (defined($mycgi->param("existing"))) ? $mycgi->param("existing") : 0,
       existingsystem => (defined($mycgi->param("existingsystem"))) ? $mycgi->param("existingsystem") : "",
       requirements => (defined($mycgi->param("requirements"))) ? $mycgi->param("requirements") : 0,
       email => (defined($mycgi->param("email"))) ? $mycgi->param("email") : "",
       reason => (defined($mycgi->param("reason"))) ? $mycgi->param("reason") : "",
       benefits => (defined($mycgi->param("benefits"))) ? $mycgi->param("benefits") : "",
       involvedOrgs => (defined($mycgi->param("involvedOrgs"))) ? $mycgi->param("involvedOrgs") : "",
       businessProcesses => (defined($mycgi->param("businessProcesses"))) ? $mycgi->param("businessProcesses") : "",
       daterequired => (defined($mycgi->param("daterequired"))) ? $mycgi->param("daterequired") : "",
       comments => (defined($mycgi->param("comments"))) ? $mycgi->param("comments") : "",
       status => (defined($mycgi->param("status"))) ? $mycgi->param("status") : "",
       title => (defined($mycgi->param("title"))) ? $mycgi->param("title") : "Work Request",
       sessionID => (defined($mycgi->param("sessionid"))) ? $mycgi->param("sessionid") : "0",
       email => (defined($mycgi->param("email"))) ? $mycgi->param("email") : "",
       chair => (defined($mycgi->param("chair"))) ? $mycgi->param("chair") : "",
       developmentGroup => (defined($mycgi->param("developmentGroup"))) ? $mycgi->param("developmentGroup") : "",
       projectManager => (defined($mycgi->param("projectManager"))) ? $mycgi->param("projectManager") : "",
       CCB => (defined($mycgi->param("CCB"))) ? $mycgi->param("CCB") : "",
       standards => (defined($mycgi->param("standards"))) ? $mycgi->param("standards") : "",
       safety => (defined($mycgi->param("safety"))) ? $mycgi->param("safety") : "",
       security => (defined($mycgi->param("security"))) ? $mycgi->param("security") : "",
       records => (defined($mycgi->param("records"))) ? $mycgi->param("records") : "",
       architecture => (defined($mycgi->param("architecture"))) ? $mycgi->param("architecture") : "",
       section508 => (defined($mycgi->param("section508"))) ? $mycgi->param("section508") : "",
       APSI_1Q => (defined($mycgi->param("APSI_1Q"))) ? $mycgi->param("APSI_1Q") : "",
       internet => (defined($mycgi->param("internet"))) ? $mycgi->param("internet") : "",
       privacy => (defined($mycgi->param("privacy"))) ? $mycgi->param("privacy") : "",
       reason_rej => (defined($mycgi->param("reason_rej"))) ? $mycgi->param("reason_rej") : "",
       filename => (defined($mycgi->param("filename"))) ? $mycgi->param("filename") : "",
       requestid => (defined($mycgi->param("requestid"))) ? $mycgi->param("requestid") : "",
       attachmentid => (defined($mycgi->param("attachmentid"))) ? $mycgi->param("attachmentid") : "",
       loadtype => (defined($mycgi->param("loadtype"))) ? $mycgi->param("loadtype") : ""

    );
    return (%valueHash);
}

###################################################################################################################################
sub doHeader {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        schema => $ENV{SCHEMA},
        title => 'PCL User Functions',
        displayTitle => 'T',
        @_,
    );
    my $output = "";
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $form = $args{form};
    my $path = $args{path};
    my $username = $settings{username};
    my $userid = $settings{userid};
    my $Server = $settings{server};

    my $styleSheet = "";

    $styleSheet = <<END_OF_STYLE;

<style type="text/css">

    .rowHeader {
        font-family: Helvetica, Arial;
        font-size: 14px;
        font-weight: bold;
        background: #eeeeee;
        padding: 3px;
        width: 650px;
    }

    .rowAttachment {
        font-family: Helvetica, Arial;
        font-size: 12px;
        padding: 3px;
        width: 400px;

    }

    .rowNav {
        font-family: Helvetica, Arial;
        font-size: 12px;
        padding: 3px;
        text-align: center;
    }

    .rowNav2 {
        font-family: Helvetica, Arial;
        font-size: 12px;
        padding: 3px;
        text-align: left;
    }


    a:hover,a:link,a:visited,a:active {
        color: #0000dd;
    }

</style>

END_OF_STYLE

    my $extraJS = "";
    $extraJS .= <<END_OF_BLOCK;
    function doBrowse(script) {
        $form.command.value = 'browse';
        $form.action = '$path' + script + '.pl';
        $form.submit();
    }
    function submitEditRequest(script, command, request) {
        document.$form.command.value = command;
        document.$form.request.value = request;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }

    function validateRequest(script, command) {
        var errors = "";
        var msg;

    if (command == "processCreateReview"|| command == "processUpdateReview") {
        if (isblank(document.$form.chair.value) ||
        (document.$form.chair.value == null || document.$form.chair.value == "")) {
            errors += "\\Sponsor and CCB Chair must be identified.\\n";
        }
        if (!document.$form.developmentGroup[0].checked && !document.$form.developmentGroup[1].checked) {
            errors += "\\developmentGroup must be identified.\\n";
        }
        if (isblank(document.$form.projectManager.value) ||
        (document.$form.projectManager.value == null || document.$form.projectManager.value == "")) {
            errors += "\\projectManager must be identified.\\n";
        }
        if (isblank(document.$form.CCB.value) ||
        (document.$form.CCB.value == null || document.$form.CCB.value == "")) {
            errors += "\\CCB must be identified.\\n";
        }
        if (isblank(document.$form.standards.value) ||
        (document.$form.standards.value == null || document.$form.standards.value == "")) {
            errors += "\\standards must be identified.\\n";
        }
        if (isblank(document.$form.safety.value) ||
        (document.$form.safety.value == null || document.$form.safety.value == "")) {
            errors += "\\safety must be identified.\\n";
        }
        if (isblank(document.$form.security.value) ||
        (document.$form.security.value == null || document.$form.security.value == "")) {
            errors += "\\security must be identified.\\n";
        }
        if (isblank(document.$form.records.value) ||
        (document.$form.records.value == null || document.$form.records.value == "")) {
            errors += "\\records must be identified.\\n";
        }
        if (isblank(document.$form.architecture.value) ||
        (document.$form.architecture.value == null || document.$form.architecture.value == "")) {
            errors += "\\architecture must be identified.\\n";
        }
        if (isblank(document.$form.chair.value) ||
        (document.$form.chair.value == null || document.$form.chair.value == "")) {
            errors += "\\Sponsor and CCB Chair must be identified.\\n";
        }
        if (isblank(document.$form.section508.value) ||
        (document.$form.section508.value == null || document.$form.section508.value == "")) {
            errors += "\\section508 must be identified.\\n";
        }
        if (isblank(document.$form.APSI_1Q.value) ||
        (document.$form.APSI_1Q.value == null || document.$form.APSI_1Q.value == "")) {
            errors += "\\Business Processes must be identified.\\n";
        }
        if (isblank(document.$form.internet.value) ||
        (document.$form.internet.value == null || document.$form.internet.value == "")) {
            errors += "\\internet must be identified.\\n";
        }
        if (isblank(document.$form.privacy.value) ||
        (document.$form.privacy.value == null || document.$form.privacy.value == "")) {
            errors += "\\privacy must be identified.\\n";
        }

        msg  = "______________________________________________________\\n\\n";
        msg += "The form was not submitted because of the following error(s).\\n";
        msg += "Please correct these errors(s) and re-submit.\\n";
        msg += "______________________________________________________\\n";

        if (errors != "") {
            msg += "\\n" + errors;
            alert(msg);
            return false;
        } else {
            submitFormCGIResults(script,command);
        }

    } else {
            if (isblank(document.$form.owner.value) ||
            (document.$form.owner.value == null || document.$form.owner.value == "")) {
            errors += "\\The Project Sponsor or System Owner must be identified.\\n";
            }
            if (isblank(document.$form.department.value) ||
            (document.$form.department.value == null || document.$form.department.value == "")) {
            errors += "\\The Department or Organization of the Project Sponsor or System Owner must be identified.\\n";
            }
            if (isblank(document.$form.contact.value) ||
            (document.$form.contact.value == null || document.$form.contact.value == "")) {
            errors += "\\The Contact information must be supplied.\\n";
            }
            if (isblank(document.$form.phone.value) ||
            (document.$form.phone.value == null || document.$form.phone.value == "")) {
            errors += "\\A Phone Number for the Contact person must be provided.\\n";
            }
            if (isblank(document.$form.email.value) ||
            (document.$form.email.value == null || document.$form.email.value == "")) {
            errors += "\\An email address for the Contact person must be provided.\\n";
            }
            if (!document.$form.existing[0].checked && !document.$form.existing[1].checked) {
            errors += "\\No information supplied specifying whether this affects an existing system or not.\\n";
            }
            if ((document.$form.existing[0].checked) && (isblank(document.$form.existingsystem.value) ||
            (document.$form.existingsystem.value == null || document.$form.existingsystem.value == ""))) {
            errors += "\\No information supplied specifying which existing system is affected.\\n";
            }
            if (isblank(document.$form.requirements.value) ||
            (document.$form.requirements.value == null || document.$form.requirements.value == "")) {
            errors += "\\No information supplied regarding what you need the software to do.\\n";
            }
            if (isblank(document.$form.reason.value) ||
            (document.$form.reason.value == null || document.$form.reason.value == "")) {
            errors += "\\No information supplied regarding the problems and conditions this Work Request addresses.\\n";
            }
            if (isblank(document.$form.benefits.value) ||
            (document.$form.benefits.value == null || document.$form.benefits.value == "")) {
            errors += "\\No information supplied regarding the benefits to your organization.\\n";
            }
            if (isblank(document.$form.involvedOrgs.value) ||
            (document.$form.involvedOrgs.value == null || document.$form.involvedOrgs.value == "")) {
            errors += "\\No information supplied regarding the organizations involved with this issue.\\n";
            }
            if (isblank(document.$form.businessProcesses.value) ||
            (document.$form.businessProcesses.value == null || document.$form.businessProcesses.value == "")) {
            errors += "\\No information supplied regarding the affected business processes.\\n";
            }
            if (isblank(document.$form.daterequired.value) ||
            (document.$form.daterequired.value == null || document.$form.daterequired.value == "")) {
            errors += "\\No information supplied regarding the date the software is required.\\n";
            }
            msg  = "______________________________________________________\\n\\n";
            msg += "The form was not submitted because of the following error(s).\\n";
            msg += "Please correct these errors(s) and re-submit.\\n";
            msg += "______________________________________________________\\n";
            if (errors != "") {
            msg += "\\n" + errors;
            alert(msg);
            return false;
            }
            else {
            submitFormCGIResults(script,command);
            }
    }
    }
    function showHideBlockSection(status) {
        if (status == "Pending") {
            if (Pending.style.display=='none') {
                Pending.style.display='';
                document.Pending.src ='/pcl/images/arrow_open.gif';
            } else {
                Pending.style.display='none';
                document.Pending.src ='/pcl/images/arrow_close.gif';
            }
        } else if (status == "Review") {
            if (Review.style.display=='none') {
                Review.style.display='';
                document.Review.src ='/pcl/images/arrow_open.gif';
            } else {
                Review.style.display='none';
                document.Review.src ='/pcl/images/arrow_close.gif';
            }
        } else if (status == "Approved") {
            if (Approved.style.display=='none') {
                Approved.style.display='';
                document.Approved.src ='/pcl/images/arrow_open.gif';
            } else {
                Approved.style.display='none';
                document.Approved.src ='/pcl/images/arrow_close.gif';
            }
        } else if (status == "Rejected") {
            if (Rejected.style.display=='none') {
                Rejected.style.display='';
                document.Rejected.src ='/pcl/images/arrow_open.gif';
            } else {
                Rejected.style.display='none';
                document.Rejected.src ='/pcl/images/arrow_close.gif';
            }
        } else if (status == "Closed") {
            if (Closed.style.display=='none') {
                Closed.style.display='';
                document.Closed.src ='/pcl/images/arrow_open.gif';
            } else {
                Closed.style.display='none';
                document.Closed.src ='/pcl/images/arrow_close.gif';
            }
        } else if (status == "Withdrawn") {
            if (Withdrawn.style.display=='none') {
                Withdrawn.style.display='';
                document.Withdrawn.src ='/pcl/images/arrow_open.gif';
            } else {
                Withdrawn.style.display='none';
                document.Withdrawn.src ='/pcl/images/arrow_close.gif';
            }
        }
    }
    function checkLength(val,maxlen,e) {
        var len = val.length;
        var diff = len - maxlen;
        if (diff > 0) {
            alert ("The text you have entered is " + diff + " characters too long.");
            e.focus();
        }
    }

    function addNewAttachmentWidget() {
        document.all.attachments.innerHTML = document.all.attachments.innerHTML + "<input type=file name=attachment><br>";
    }

    function attachment(lt, attachmentid, requestid, fn){
        document.workRequest.action = '$path' + 'workRequest.pl';
        document.workRequest.command.value = 'processAttachments';
        document.workRequest.filename.value = fn;
        document.workRequest.loadtype.value = lt;
        document.workRequest.attachmentid.value = attachmentid;
        document.workRequest.requestid.value = requestid;
        document.workRequest.method = "POST";
        if (lt == "attachment") {
            document.workRequest.target="cgiresults";
        } else {
            document.workRequest.target="_new";
        }

        document.workRequest.submit();
        document.workRequest.target = "";
    }

END_OF_BLOCK
    $output .= &doStandardHeader(schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle},
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'T', includeJSWidgets => 'F',useFileUpload => 'T');

    $output .= $styleSheet;
    $output .= "<input type=hidden name=type value=0>\n";
    $output .= "<input type=hidden name=project value=$settings{project}>\n";
    $output .= "<input type=hidden name=request value=$settings{request}>\n";
    $output .= "<input type=hidden name=filename value=\"\">\n";
    $output .= "<input type=hidden name=loadtype value=\"\">\n";
    $output .= "<input type=hidden name=requestid value=\"\">\n";
    $output .= "<input type=hidden name=attachmentid value=\"\">\n";

    #$output .= "<input type=hidden name=sessionid value=$settings{sessionID}>\n";
    $output .= "<table border=0 width=750 align=center><tr><td>\n";

    return($output);
}



###################################################################################################################################
sub doFooter {  # routine to generate html page footers
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";

    $output .= "</form>\n</body>\n</html>\n";

    return($output);
}


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub doBrowseRequests {  # routine to do display work requests
###################################################################################################################################
    my %args = (
        project => 0,  # null
        title => 'Work Request',
        status => 0, # all
        userID => 0, # all
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    my $count = 0;
    my $numColumns = 4;
    my $display_id;
    my @requestList;
    my @status_array = ("Pending","In Review","Approved","Rejected", "Closed", "Withdrawn");
    $output .= "<center><a href=javascript:submitEditRequest('workRequest','createRequest',0)>Create New Software Work Request</a></center><br><br>\n";
    foreach my $status ( @status_array ) {
        @requestList = &getWorkRequests(dbh => $args{dbh}, schema => $args{schema}, status => $status,single=>0);
        $status = 'Review' if ($status eq 'In Review');
        $output .= "<SPAN title=\"Click here to shrink and expand the detailed views\" onClick=showHideBlockSection(\"$status\"); style=\"cursor:hand;\" onDblClick=showHideBlockSection(status);>";
        $output .= "<table width=80% bgcolor=white border=1 bordercolor=silver align=center><tr><td width=97%><font size=3 face=arial color=gray><b>$status</b></td><td width=3% align=right><img id=$status name=$status src=/pcl/images/arrow_close.gif border=0></td></tr></table>";
    $output .= "</SPAN>";
    $output .= "<span id=\"$status\" Style=Display:none; ><br>\n";
        $output .= &startTable(columns => $numColumns, title => "Work Requests:&nbsp;&nbsp;$status", width => 600);
        $output .= &startRow (bgColor => "#f0f0f0");
        $output .= &addCol (value => "Id", align => 'center');
    $output .= &addCol (value => "Contact", align => 'center');
    $output .= &addCol (value => "Existing System/New Development", align => 'center');
    $output .= &addCol (value => "Business Processes Affected", align => 'center');
    $output .= &endRow();

        for (my $i = 0; $i < $#requestList; $i++) {
            my ($id,$owner,$contact,$email,$organization,$phone,$modifyexisting,$existingsystem,$reason,
            $benefits,$involvedOrgs,$process,$requesteddelivery,$comments,$submitted,$disposition,
            $dispositiondate,$requirements) =
            ($requestList[$i]{id},$requestList[$i]{owner},$requestList[$i]{contact},$requestList[$i]{email},
            $requestList[$i]{organization},$requestList[$i]{phone},$requestList[$i]{modifyexisting},$requestList[$i]{existingsystem},
            $requestList[$i]{reason},$requestList[$i]{benefits},$requestList[$i]{involvedorgs},$requestList[$i]{process},
            $requestList[$i]{requesteddelivery},$requestList[$i]{comments},$requestList[$i]{submitted},$requestList[$i]{disposition},
            $requestList[$i]{dispositiondate},$requestList[$i]{requirements});
            $existingsystem = defined($existingsystem) ? $existingsystem : "New Development";
            $display_id = "WR" . lpadzero($id,3);
            $output .= &startRow (bgColor => "#f0f0f0");
            if ($status eq 'Approved' && &doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$settings{userid}, privList=>[13]) ) {
                $output .= &addCol (value => "<b>$display_id</b>",url => "javascript:submitEditRequest('workRequest','createReview',$id)");
        } elsif (($status eq 'Pending' || $status eq 'Review') && &doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$settings{userid}, privList=>[12]) ) {
            $output .= &addCol (value => "<b>$display_id</b>",url => "javascript:submitEditRequest('workRequest','editRequest',$id)");
        } else {
            $output .= &addCol (value => "<b>$display_id</b>",url => "javascript:submitEditRequest('workRequest','displayRequest',$id)");
        }
        $output .= &addCol (value => "<font color=black>$contact</font>");
        $output .= &addCol (value => "<font color=black>$existingsystem</font>");
        $output .= &addCol (value => "<font color=black>$process</font>");
            $output .= &endRow();
        }
        $output .= &endTable . "<br>\n";
        $output .= "</span><br>\n";
    }

    return($output);
}
###################################################################################################################################
sub doRequestForm{  # routine to create or edit a work request
###################################################################################################################################
    my %args = (
        project => 0,  # null
        request => 0,
        title => 'Work Request',
        status => 0, # all
        userID => 0, # all
        @_,
    );
    my $output = '';
    my $count = 0;
    my $display_id;
    my $yeschecked = "";
    my $nochecked = "";
    my $numColumns = 4;
    my @requestList = &getWorkRequests(dbh => $args{dbh}, schema => $args{schema}, request => $args{request},single=>1);

    my ($id,$owner,$contact,$email,$organization,$phone,$modifyexisting,$existingsystem,$reason,
    $benefits,$involvedOrgs,$process,$requesteddelivery,$comments,$submitted,$disposition,
    $dispositiondate,$requirements) =
    ($requestList[0]{id},$requestList[0]{owner},$requestList[0]{contact},$requestList[0]{email},
    $requestList[0]{organization},$requestList[0]{phone},$requestList[0]{modifyexisting},$requestList[0]{existingsystem},
    $requestList[0]{reason},$requestList[0]{benefits},$requestList[0]{involvedorgs},$requestList[0]{process},
    $requestList[0]{requesteddelivery},$requestList[0]{comments},$requestList[0]{submitted},$requestList[0]{disposition},
    $requestList[0]{dispositiondate},$requestList[0]{requirements});
    $display_id =  $args{request} == 0 ? "" : "Edit Work Request WR" . lpadzero($id,3);
    $yeschecked = $modifyexisting eq 'Yes' ? "checked" : "";
    $nochecked = $modifyexisting eq 'No' ? "checked" : "";
    $output .= "<table cellpadding=4 cellspacing=0 border=0 align=center width=700>\n";
    $output .= "<tr>\n";
    $output .= &addCol (value => "<font size=+1>$display_id</font>", colspan=>$numColumns,align=>"center");
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<font color=black><b>Contact Information</font>",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Project Sponsor or System Owner:");
    $output .= &addCol (value => "<input type=text name=owner size=35 maxlength=99 value=\"$owner\">");
    $output .= &addCol (value => "Department:");
    $output .= &addCol (value => "<input type=text name=department size=25 maxlength=199 value=\"$organization\">");
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Contact:");
    $output .= &addCol (value => "<input type=text name=contact size=35 maxlength=99 value=\"$contact\">");
    $output .= &addCol (value => "Phone Number:");
    $output .= &addCol (value => "<input type=text name=phone size=25 maxlength=12 value=$phone>");
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Email:");
    $output .= &addCol (value => "<input type=text name=email size=45 value=$email>",colspan=>3);
    $output .= &endRow();
    if ($args{request} != 0) {
        $output .= "<tr>\n";
        $output .= &addCol (value => "Disposition:");
        $output .= &addCol (value => &buildStatusSelect(name => 'disposition',selected=>$disposition));
        $output .= &addCol (value => "Disposition Date:&nbsp;$dispositiondate",colspan=>2);
        $output .= &endRow();
    }
    $output .= "<tr>\n";
    $output .= &addCol (value => " <span id=reasonRej name=reasonRej style=display:none; >Rejected Reason :<br><textarea name=reason_rej cols=80 rows=3 onBlur=checkLength(value,999,this);></textarea></span>", colspan=>4);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<font color=black>The following information is requested to assist OGS/IT in reviewing and processing your request. Please provide as much information as you currently have available.</font>",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<font color=black><b>Software Requirements</font>",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Is this request to modify an existing system?",colspan=>2);
    $output .= &addCol (value => "<input type=radio name=existing value=1 $yeschecked>Yes&nbsp;&nbsp;&nbsp;<input type=radio name=existing value=0 $nochecked>No",colspan=>2);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "System Name:");
    $output .= &addCol (value => "<input type=text name=existingsystem size=45 value=\"$existingsystem\" maxlength=99>",colspan=>3);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "What do you want the software to do?",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<textarea name=requirements cols=80 rows=3 onBlur=checkLength(value,1999,this);>$requirements</textarea>",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<font color=black><b>Business Case for the Work Request</b></font>",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Describe the problems and conditions this Work Request will address.",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<textarea name=reason cols=80 rows=3 onBlur=checkLength(value,999,this);>$reason</textarea>",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Describe how resolving these issues will benefit your organization.",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<textarea name=benefits cols=80 rows=3 onBlur=checkLength(value,999,this);>$benefits</textarea>",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Who is involved with this issue?",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<textarea name=involvedOrgs cols=80 rows=3 onBlur=checkLength(value,499,this);>$involvedOrgs</textarea>",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "What business processes are affected by this problem?",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<textarea name=businessProcesses cols=80 rows=3 onBlur=checkLength(value,999,this);>$process</textarea>",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "When will a solution to this problem be required?",colspan=>2);
    $output .= &addCol (value => "<input type=text name=daterequired size=25 value=\"$requesteddelivery\" maxlength=49>",colspan=>2);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<br><font color=black><b>Comments/Notes</b></font><br>Please include any information about the system that was not covered by the previous questions",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<textarea name=comments cols=80 rows=3 onBlur=checkLength(value,999,this);>$comments</textarea>",colspan=>$numColumns);
    $output .= &endRow();

my $attachEdit = "";
$attachEdit = <<EOH;
<br /><br />
<table class="attachment" border="1" cellspacing="0">
<tr><td colspan="2" class="rowHeader">Attachment(s):</td></tr>
<tr><td colspan="2" class="rowAttachment">Please attach any supporting attachments below</td></tr>
<tr><td colspan="2" class="rowAttachment">
<div id="attachments"><input type="file" name="attachment"></div></td></tr>
<tr><td colspan="2" class="rowNav2"><a href="javascript://" onClick="javascript:addNewAttachmentWidget();">Create New Attachment</td></tr>
</table>

EOH

    if ($args{request} == 0) {
        $output .= &addCol (value => $attachEdit,colspan=>$numColumns);
    }

    if ($args{request} != 0) {
        my @attachView = undef();
        @attachView = getAttachments(dbh => $args{dbh}, schema => $args{schema},requestID => $args{request});
        my $qwert = "";
        if ($attachView[0]{filename}) {
            my $attachViewFinal = '<br /><br /><table class="attachment" border="1" cellspacing="0"><tr><td colspan="2" class="rowHeader">Attachment(s):</td></tr>';
            for (my $i = 0; $i < $#attachView; $i++) {
                $attachViewFinal = $attachViewFinal."<tr><td class=\"rowAttachment\">".$attachView[$i]{filename}."</td><td class=\"rowNav\"><a href=\"javascript:attachment(\'attachment\',$attachView[$i]{attachmentid},$attachView[$i]{requestid},\'$attachView[$i]{filename}\');\">Download</a> - <a href=\"javascript:attachment(\'inline\',$attachView[$i]{attachmentid},$attachView[$i]{requestid},\'$attachView[$i]{filename}\');\">View</a></td></tr>";
            }
            $attachViewFinal = $attachViewFinal."</table>";

            $output .= &addCol (value => $attachViewFinal,colspan=>$numColumns);
        }
    }

    $output .= &endTable;
    $output .= "<br>\n<center>\n<input type=button name=submitEdit value=Submit ";
    $output .= $args{request} == 0 ? "onClick=\"validateRequest('workRequest','processCreateRequest')\">" : "onClick=\"validateRequest('workRequest','processUpdateRequest')\">";
    $output .= "<br><br><center><a href=javascript:history.back() title='Click here to return to the previous page'><b>Return to Previous Page</b></a></center><br>\n";
    $output .= "\n</center>\n";

    return($output);
}
###################################################################################################################################
sub doDisplayRequest{  # routine to display a work request
###################################################################################################################################
    my %args = (
        project => 0,  # null
        request => 0,
        title => 'Work Request',
        userID => 0, # all
        @_,
    );
    my $output = '';
    my $count = 0;
    my $display_id;
    my $existing_display;
    my $numColumns = 2;
    my @requestList = &getWorkRequests(dbh => $args{dbh}, schema => $args{schema}, request => $args{request},single=>1);

    my ($id,$owner,$contact,$email,$organization,$phone,$modifyexisting,$existingsystem,$reason,
    $benefits,$involvedOrgs,$process,$requesteddelivery,$comments,$submitted,$disposition,
    $dispositiondate,$requirements,$reason_rej) =
    ($requestList[0]{id},$requestList[0]{owner},$requestList[0]{contact},$requestList[0]{email},
    $requestList[0]{organization},$requestList[0]{phone},$requestList[0]{modifyexisting},$requestList[0]{existingsystem},
    $requestList[0]{reason},$requestList[0]{benefits},$requestList[0]{involvedorgs},$requestList[0]{process},
    $requestList[0]{requesteddelivery},$requestList[0]{comments},$requestList[0]{submitted},$requestList[0]{disposition},
    $requestList[0]{dispositiondate},$requestList[0]{requirements},$requestList[0]{reason_rej});
    $display_id = "WR" . lpadzero($id,3);
    $existing_display = $modifyexisting eq 'Yes' ? $existingsystem : "No";
    $output .= &startTable(columns => $numColumns, title => "Work Request $display_id", width => 450, border=>0, padding=>1);
    $output .= "<tr>\n";
    $output .= &addCol (value => "Project Sponsor or System Owner:");
    $output .= &addCol (value => $owner);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Department:");
    $output .= &addCol (value => $organization);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Contact:");
    $output .= &addCol (value => $contact);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Phone:");
    $output .= &addCol (value => $phone);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Email:");
    $output .= &addCol (value => $email);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Modify Existing System:");
    $output .= &addCol (value => $existing_display);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Software Requirements:",valign=>'top');
    $output .= &addCol (value => $requirements);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Problems Addressed:",valign=>'top');
    $output .= &addCol (value => $reason);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Benefits:",valign=>'top');
    $output .= &addCol (value => $benefits);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Involved Organizations:",valign=>'top');
    $output .= &addCol (value => $involvedOrgs);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Business Processes Affected:",valign=>'top');
    $output .= &addCol (value => $process);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Requested Delivery:");
    $output .= &addCol (value => $requesteddelivery);
    $output .= &endRow();
    $output .= "<tr>\n";
    if (defined($comments)) {
        $output .= &addCol (value => "Comments:",valign=>'top');
        $output .= &addCol (value => $comments);
        $output .= &endRow();
    }
    $output .= "<tr>\n";
    $output .= &addCol (value => "Disposition:");
    $output .= &addCol (value => $disposition);
    $output .= &endRow();

    if ($disposition eq "Rejected") {
    $output .= "<tr>\n";
    $output .= &addCol (value => "Rejected Reason:");
    $output .= &addCol (value => $reason_rej);
    $output .= &endRow();
    }

    $output .= "<tr>\n";
    $output .= &addCol (value => "Disposition Date:");
    $output .= &addCol (value => $dispositiondate);
    $output .= &endRow();
    $output .= &endTable;

    if ($args{request} != 0) {
        my @attachView = undef();
        @attachView = getAttachments(dbh => $args{dbh}, schema => $args{schema},requestID => $args{request});
        my $qwert = "";
        if ($attachView[0]{filename}) {
            my $attachViewFinal = '<br /><br /><table class="attachment" border="1" cellspacing="0"><tr><td colspan="2" class="rowHeader">Attachment(s):</td></tr>';
            for (my $i = 0; $i < $#attachView; $i++) {
                $attachViewFinal = $attachViewFinal."<tr><td class=\"rowAttachment\">".$attachView[$i]{filename}."</td><td class=\"rowNav\"><a href=\"javascript:attachment(\'attachment\',$attachView[$i]{attachmentid},$attachView[$i]{requestid},\'$attachView[$i]{filename}\');\">Download</a> - <a href=\"javascript:attachment(\'inline\',$attachView[$i]{attachmentid},$attachView[$i]{requestid},\'$attachView[$i]{filename}\');\">View</a></td></tr>";
            }
            $attachViewFinal = $attachViewFinal."</table>";

            $output .= $attachViewFinal;
        }
    }

    if (&doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$args{userID}, privList=>[12]) && $disposition ne 'Approved' && $disposition ne 'Rejected') {
        $output .= "<br><br><center><a href=javascript:submitEditRequest('workRequest','editRequest',$id)>Edit Work Request</a></center>\n";
    }
    $output .= "<br><center><a href=javascript:history.back() title='Click here to return to the previous page'><b>Return to Previous Page</b></a></center><br>\n";
    return($output);
}
###################################################################################################################################
sub doReviewForm{  # routine to edit the review form for an approved work request
###################################################################################################################################
    my %args = (
        request => 0,
        title => 'Work Request',
        status => 0, # all
        userID => 0, # all
        @_,
    );
    my $output = '';
    my $display_id;
    my $numColumns = 2;
    my @requestList = &getWorkRequests(dbh => $args{dbh}, schema => $args{schema}, request => $args{request},single=>1);

    my ($id,$owner,$contact,$email,$organization,$phone,$modifyexisting,$existingsystem,$reason,
    $benefits,$involvedOrgs,$process,$requesteddelivery,$comments,$submitted,$disposition,
    $dispositiondate,$requirements,$CHAIR,$DEVELOPMENTGROUP,$PROJECTMANAGER,$CCB,$STANDARDS,$SAFETY,
    $SECURITY,$RECORDS,$ARCHITECTURE,$SECTION508,$APSI_1Q,$INTERNET,$PRIVACY) =
    ($requestList[0]{id},$requestList[0]{owner},$requestList[0]{contact},$requestList[0]{email},
    $requestList[0]{organization},$requestList[0]{phone},$requestList[0]{modifyexisting},$requestList[0]{existingsystem},
    $requestList[0]{reason},$requestList[0]{benefits},$requestList[0]{involvedorgs},$requestList[0]{process},
    $requestList[0]{requesteddelivery},$requestList[0]{comments},$requestList[0]{submitted},$requestList[0]{disposition},
    $requestList[0]{dispositiondate},$requestList[0]{requirements},$requestList[0]{CHAIR},$requestList[0]{DEVELOPMENTGROUP},
    $requestList[0]{PROJECTMANAGER},$requestList[0]{CCB},$requestList[0]{STANDARDS},$requestList[0]{SAFETY},
    $requestList[0]{SECURITY},$requestList[0]{RECORDS},$requestList[0]{ARCHITECTURE},$requestList[0]{SECTION508},
    $requestList[0]{APSI_1Q},$requestList[0]{INTERNET},$requestList[0]{PRIVACY});

    $display_id = "Work Request WR" . lpadzero($id,3);
    $output .= "<table cellpadding=4 cellspacing=0 border=0 align=center width=700>\n";
    $output .= "<tr>\n";
    $output .= &addCol (value => "<font size=+1><b><i>Approved Work Request-OGS/IT Review</i><br>$display_id</b></font>", colspan=>$numColumns,align=>"center");
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<font color=black><b>Assigned Roles and Responsibilities</font>",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<font color=black>The following assignments are explicitly defined for this system.  Unassigned responsibilities will be determined during future phases of project development.</font>",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<b><u>Role/Responsibility</u></b>");
    $output .= &addCol (value => "<b><u>Assignment</u></b>");
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "System Owner:");
    $output .= &addCol (value => $owner);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Sponsor and CCB Chair:");
    $output .= &addCol (value => &buildSelect(dbh => $args{dbh}, schema=>$args{schema},privilege=> '12',name=>'chair',selected=>$CHAIR));
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Assigned Development Group:");
    $output .= &addCol (value => &buildGroupRadio(dbh => $args{dbh}, schema=>$args{schema},name=>'developmentGroup',selected=>$DEVELOPMENTGROUP));
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Project Manager:");
    $output .= &addCol (value => &buildSelect(dbh => $args{dbh}, schema=>$args{schema},privilege=> '13',name=>'projectManager',selected=>$PROJECTMANAGER));
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "CCB Members:");
    $output .= &addCol (value => "<input type=text name=CCB size=45  maxlength=239 value=$CCB>");
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<font color=black><b>Imposed Standards</font>",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Please review and determine the applicable standards to this project.",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<textarea name=standards cols=80 rows=3 onBlur=checkLength(value,239,this);>$STANDARDS</textarea>",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Safety Requirements",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<textarea name=safety cols=80 rows=3 onBlur=checkLength(value,239,this);>$SAFETY</textarea>",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Security Requirements",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<textarea name=security cols=80 rows=3 onBlur=checkLength(value,239,this);>$SECURITY</textarea>",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<font color=black><b>Records Generation and Retention</b></font>",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "The following potential record sources have been identified to date.",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<textarea name=records cols=80 rows=3 onBlur=checkLength(value,239,this);>$RECORDS</textarea>",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Enterprise Architecture Review",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<textarea name=architecture cols=80 rows=3 onBlur=checkLength(value,239,this);>$ARCHITECTURE</textarea>",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Section 508 Review",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<textarea name=section508 cols=80 rows=3 onBlur=checkLength(value,239,this);>$SECTION508</textarea>",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "AP SI-1Q Applicability Review",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<textarea name=APSI_1Q cols=80 rows=3 onBlur=checkLength(value,239,this);>$APSI_1Q</textarea>",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Internet/Intranet Standards",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<textarea name=internet cols=80 rows=3 onBlur=checkLength(value,239,this);>$INTERNET</textarea>",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Privacy Act Review",colspan=>$numColumns);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<textarea name=privacy cols=80 rows=3 onBlur=checkLength(value,239,this);>$PRIVACY</textarea>",colspan=>$numColumns);
    $output .= &endRow();
    $output .= &endTable;
    if (&doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$args{userID}, privList=>[13])) {
        $output .= "<br>\n<center>\n<input type=button name=submitEdit value=Submit onClick=\"validateRequest('workRequest','processUpdateReview')\">\n";
    }
    $output .= "<br><br><center><a href=javascript:history.back() title='Click here to return to the previous page'><b>Return to Previous Page</b></a></center><br>\n";
    $output .= "\n</center>\n";

    return($output);
}

###################################################################################################################################
sub buildSelect {
###################################################################################################################################
    my %args = (
        name => "list",
        selected => 0,
        privilege => 0,
        @_,
    );
    my @privList = &getPrivilegeList(dbh=>$args{dbh},schema=>$args{schema},privilege=>$args{privilege});
    my $output = "<select name=$args{name}";
    $output .= ">\n";
    my $selected = "";
    for (my $i = 0; $i < $#privList; $i++) {
            my ($id,$firstname,$lastname,$email) =
            ($privList[$i]{id},$privList[$i]{firstname},$privList[$i]{lastname},$privList[$i]{email});
        $selected = ($args{selected} == $id) ? " selected" : "";
        $output .= "<option value=\"$id\"$selected>$firstname $lastname</option>\n";
    }
    $output .= "</select>\n";
    return($output);
}

###################################################################################################################################
sub buildStatusSelect {
###################################################################################################################################
    my %args = (
        name => "status",
        selected => "",
        @_,
    );
    my $output = "<select  onChange=\"if(this.options
    [this.selectedIndex].value==\'Rejected\'){reasonRej.style.display=\'\'}else{reasonRej.style.display=\'none\'}\" name=$args{name}";
    $output .= (defined($args{disabled}) && $args{disabled} gt "") ? " disabled" : "";
    $output .= ">\n";
    my $selected = "";
    foreach my $status ("Pending","In Review","Approved","Rejected", "Closed", "Withdrawn",) {
        $selected = ($args{selected} gt "" && $args{selected} eq $status) ? " selected" : "";
        $output .= "<option value=\"$status\"$selected>$status</option>\n";
    }
    $output .= "</select>\n";
    return($output);
}
###################################################################################################################################
sub buildGroupRadio {
###################################################################################################################################
    my %args = (
        selected => "",
        @_,
    );
    my $output = "";
    my $selected = "";
    foreach my $group ("RSIS/East", "RSIS/West") {
        $output .= "<input type=radio name=$args{name}";
        $selected = ($args{selected} gt "" && $args{selected} eq $group) ? " checked" : "";
        $output .= " value=\"$group\" $selected>$group\n&nbsp;&nbsp;";
    }
    return($output);
}
####################################################################################################################################

###################################################################################################################################


1; #return true
