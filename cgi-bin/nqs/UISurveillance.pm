#
# $Source: /usr/local/homes/higashis/www/gov.doe.ocrwm.ydappdev/rcs/qa/perl/RCS/UISurveillance.pm,v $
#
# $Revision: 1.25 $ 
#
# $Date: 2009/09/22 18:20:47 $
#
# $Author: higashis $
#
# $Locker: higashis $
#
# $Log: UISurveillance.pm,v $
# Revision 1.25  2009/09/22 18:20:47  higashis
# major version release.
#
# Revision 1.24  2009/07/20 22:05:29  higashis
# updated to the prod.
#
# Revision 1.22  2009/05/11 22:36:45  higashis
# test.
#
# Revision 1.21  2009/03/24 20:47:15  patelr
# added delete attachment function
#
# Revision 1.20  2009/02/10 20:47:09  patelr
# edited doProcessCreateSurveillance and doProcessUpdateSurveillance to allow editing of reports issued by lead lab
#
# Revision 1.19  2009/01/17 00:07:02  patelr
# WR0115 - changes for file upload
#
# Revision 1.18  2008/10/21 19:00:23  higashis
# snapshot of how it is..
#
# Revision 1.17  2008/10/20 17:50:08  higashis
# for excel integrated report.
#
# Revision 1.16  2007/10/26 17:53:26  dattam
# All occurences of "QARD" changed to "QA".
#
# Revision 1.15  2007/04/23 16:22:52  dattam
# SNL is added as a surveillance organization
# Sub doViewSurveillance, doEditSurveillance modified to add new "Overall Results" radio button
# New sub writeOverallResultsRadio added to add 3 radio buttons, Delete button added to delete an incorrectly added surveillance
# Sub getSurveillanceDisplayID modified to add SNL Surveillance ID, sub doViewSurveillance modified for
# editing privilege to SNL
# Modified sub writeState to change the Status drop down value, modified doBrowseSurveillance to change value of Status
#
# Revision 1.14  2005/07/12 15:16:51  dattam
# modified subroutine writeOrgLocationSelect - added SuborgidList string for calling getOrgLocation.
#
# Revision 1.13  2005/02/02 20:48:33  starkeyj
# modified the javascript function reportWindow to check for the type of database or report to display
# modified doViewAudit to change label for Add/Edit Report Log No and added an if condition before displaying the link
# modified doEditReportlink to remove the choice for entry to the ATS database
#
# Revision 1.12  2005/01/10 16:06:41  starkeyj
# modified javascript subroutine validateSurveillance to not check the reschedule radio button when reschedule info is updated
# (the radio button is not present after initial reschedule info has been entered)
#
# Revision 1.11  2005/01/10 00:31:22  starkeyj
# modified the following subroutines to select or display the MOL number:  getInitialValues, doBrowseSurveillance,
# doViewSurveillance, doEditSurveillance
#
# Revision 1.10  2004/12/20 16:54:16  starkeyj
# modified writeConditionReports to check for CR Numbers entered as 0 and display text No CRs Issued
# and does not provide a link to edit the record
#
# Revision 1.9  2004/12/09 23:10:55  starkeyj
# added subroutine writeFiscalyearSelect and modified doEditSurveillance to call writeFiscalyearSelect
# for SCR 85
#
# Revision 1.8  2004/08/26 18:01:11  starkeyj
# modified doViewSurveillance, doEditSurveillance, and doEditReportLink to add delinited quotes on javascript calls for reportlink
#
# Revision 1.7  2004/08/26 14:07:39  starkeyj
# modified javascript reportWindow and submitEditReport to add dbname
# modified doEditReportLink to include a choice of database to retrieve reports and added form verification
# modified doBrowseSurveillance and doViewSurveillance to add dblink to the getSurveillance call and reportWindow call
#
# Revision 1.6  2004/05/30 22:11:52  starkeyj
# modified doViewSurveillance to add a 'Back to Previous' link
#
# Revision 1.5  2004/04/19 19:41:33  starkeyj
# modified writeConditionReport to add 'N/A'
#
# Revision 1.4  2004/04/07 15:07:23  starkeyj
# added hidden parameter generatorid
#
# Revision 1.3  2004/03/12 20:11:44  starkeyj
# added javascript functions submitEditReport and reportWindow, and the subroutine doEditReportlink
#
# Revision 1.2  2004/01/25 23:48:15  starkeyj
# for edit,view,and browse surveillance:  modified status and added title; added adequacy, implementation,
# and effectiveness of surveillance; added links to edit Best Practice, CR and Followup to CR on edit
# screen
#
# Revision 1.1  2004/01/13 13:51:34  starkeyj
# Initial revision
#
#
package UISurveillance;
use strict;
#use SharedHeader qw(:Constants);
#use UI_Widgets qw(:Functions);
#use DBShared qw(:Functions);
use OQA_Widgets qw(:Functions);
use OQA_specific qw(:Functions);
use NQS_Header qw(:Constants);
use Tables qw(:Functions);
use DBSurveillance qw(:Functions);
use DBConditionReports qw(:Functions);
use UIShared qw(:Functions);
use DBAudit qw(&getCurrentFiscalyear);
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
      &doHeader                  	&doFooter          	&getInitialValues	
      &doBrowseSurveillance		&doEditSurveillance	&doCreateSurveillance	
      &doViewSurveillance		&doEditResults		&doEditReportlink
      &doBrowseSurveillanceXsl		&doHeaderXsl
    )]
);
%EXPORT_TAGS =( 
    Functions => [qw(
      &doHeader                  	&doFooter          	&getInitialValues	
      &doBrowseSurveillance		&doEditSurveillance	&doCreateSurveillance
      &doViewSurveillance		&doEditResults		&doEditReportlink
      &doBrowseSurveillanceXsl		&doHeaderXsl
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
       survID => (defined($mycgi->param("survID"))) ? $mycgi->param("survID") : 0,
       selection => (defined($mycgi->param("surveillance_selection"))) ? $mycgi->param("surveillance_selection") : "all",
       fiscalyear => (defined($mycgi->param("fiscalyear"))) ? $mycgi->param("fiscalyear") : "50",
       leadid => (defined($mycgi->param("leadid"))) ? $mycgi->param("leadid") : 0,
       contact => (defined($mycgi->param("contact"))) ? $mycgi->param("contact") : 'NULL',
       team => (defined($mycgi->param("team"))) ? $mycgi->param("team") : "",
       scope => (defined($mycgi->param("scope"))) ? $mycgi->param("scope") : "",
       forecast => (defined($mycgi->param("forecast"))) ? $mycgi->param("forecast") : "",
       eststart => (defined($mycgi->param("eststart"))) ? $mycgi->param("eststart") : "",
       estend => (defined($mycgi->param("estend"))) ? $mycgi->param("estend") : "",
       start => (defined($mycgi->param("start"))) ? $mycgi->param("start") : "",
       end => (defined($mycgi->param("end"))) ? $mycgi->param("end") : "",
       completed => (defined($mycgi->param("completed"))) ? $mycgi->param("completed") : "",
       effectiveness => (defined($mycgi->param("effectiveness"))) ? $mycgi->param("effectiveness") : "",
       adequacy => (defined($mycgi->param("adequacy"))) ? $mycgi->param("adequacy") : "",
       implementation => (defined($mycgi->param("implementation"))) ? $mycgi->param("implementation") : "",
       state => (defined($mycgi->param("state"))) ? $mycgi->param("state") : "Scheduled",
       title => (defined($mycgi->param("title"))) ? $mycgi->param("title") : "",
       elements => (defined($mycgi->param("elements"))) ? $mycgi->param("elements") : "",
       org0 => (defined($mycgi->param("org0"))) ? $mycgi->param("org0") : 0,
       org1 => (defined($mycgi->param("org1"))) ? $mycgi->param("org1") : 0,
       org2 => (defined($mycgi->param("org2"))) ? $mycgi->param("org2") : 0,
       loc0 => (defined($mycgi->param("loc0"))) ? $mycgi->param("loc0") : 0,
       loc1 => (defined($mycgi->param("loc1"))) ? $mycgi->param("loc1") : 0,
       loc2 => (defined($mycgi->param("loc2"))) ? $mycgi->param("loc2") : 0,
       deficiency1 => (defined($mycgi->param("deficiency1"))) ? $mycgi->param("deficiency1") : "",
       deficiency2 => (defined($mycgi->param("deficiency2"))) ? $mycgi->param("deficiency2") : "",
       deficiency3 => (defined($mycgi->param("deficiency3"))) ? $mycgi->param("deficiency3") : "",
       supplier => (defined($mycgi->param("supplier"))) ? $mycgi->param("supplier") : 0,
       suborgstring => (defined($mycgi->param("suborgstring"))) ? $mycgi->param("suborgstring") : 0,
       notes => (defined($mycgi->param("notes"))) ? $mycgi->param("notes") : "",
       mol => (defined($mycgi->param("mol"))) ? $mycgi->param("mol") : "",
       issuedto => (defined($mycgi->param("issuedto"))) ? $mycgi->param("issuedto") : 0,
       issuedby => (defined($mycgi->param("issuedby"))) ? $mycgi->param("issuedby") : 0,
       status => (defined($mycgi->param("status"))) ? $mycgi->param("status") : "",
       qardstring => (defined($mycgi->param("qardstring"))) ? $mycgi->param("qardstring") : "",
       procedures => (defined($mycgi->param("procedures"))) ? $mycgi->param("procedures") : "",
       rescheduletext => (defined($mycgi->param("rescheduletext"))) ? $mycgi->param("rescheduletext") : "",
       results => (defined($mycgi->param("results"))) ? $mycgi->param("results") : "",
       overall => (defined($mycgi->param("overall"))) ? $mycgi->param("overall") : "",
       type => (defined($mycgi->param("type"))) ? $mycgi->param("type") : "I",
       int_ext => (defined($mycgi->param("int_ext"))) ? $mycgi->param("int_ext") : 0,
       newfyselect => (defined($mycgi->param("newfyselect"))) ? $mycgi->param("newfyselect") : "0",
       newCRnum => (defined($mycgi->param("newCRnum"))) ? $mycgi->param("newCRnum") : 0,
       crcount => (defined($mycgi->param("crcount"))) ? $mycgi->param("crcount") : 0,
       newFUnum => (defined($mycgi->param("newFUnum"))) ? $mycgi->param("newFUnum") : 0,
       fucount => (defined($mycgi->param("fucount"))) ? $mycgi->param("fucount") : 0,
       title => (defined($mycgi->param("title"))) ? $mycgi->param("title") : "Surveillance",
       reportlink => (defined($mycgi->param("reportlink"))) ? $mycgi->param("reportlink") : '',
       dbname => (defined($mycgi->param("dbname"))) ? $mycgi->param("dbname") : '',
       displayid => (defined($mycgi->param("displayid"))) ? $mycgi->param("displayid") : '',
       sessionID => (defined($mycgi->param("sessionid"))) ? $mycgi->param("sessionid") : "0"
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
    
    my $extraJS = "";
    $extraJS .= <<END_OF_BLOCK;
    function doBrowse(script) {
      	$form.command.value = 'browse';
       	$form.action = '$path' + script + '.pl';
        $form.submit();
    }
    function submitEditSurveillance(script, command, surveillance, crid, funum, bpid) {
        document.$form.command.value = command;
        document.$form.survID.value = surveillance;
        document.$form.CRid.value = crid;
        document.$form.bpnum.value = bpid;
        document.$form.funum.value = funum;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'workspace';
        document.$form.submit();
    }
    function submitEditReport(script, command, surveillance, reportlink,displayid,dbname) {
        document.$form.command.value = command;
        document.$form.survID.value = surveillance;
        document.$form.reportlink.value = reportlink;
        document.$form.dbname.value = dbname;
        document.$form.displayid.value = displayid;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'workspace';
        document.$form.submit();
    }
    function reportWindow (reportid, dbname) {
	var reportlink;
	if (dbname == 'CC') {
		reportlink = "http://ymln4.ymp.gov/Databases/bso/CorConSys.nsf/Correspondence%20Documents%2FBy%20Log%20Number/" + reportid + "?OpenDocument&ExpandSection=1#_Section1";
   		var myDate = new Date();
		var winName = myDate.getTime();
		document.$form.target = winName;
		var newwin = window.open("",winName);
		newwin.creator = self;
		document.$form.action = reportlink;
		$form.submit();
	} else if (dbname == 'intranet') {
		var testwin = window.open("http://$ENV{'SERVER_NAME'}/$NQSIntranetReportlinkPath/" + reportid,"displayWindow","toolbar=no,directories=no,status=no,scrollbars=yes,resizable=yes,menubar=yes");
	} else if (dbname == 'internet') {
		var testwin = window.open("http://www.ocrwm.doe.gov/$NQSInternetReportlinkPath/" + reportid,"displayWindow","toolbar=no,directories=no,status=no,scrollbars=yes,resizable=yes,menubar=yes");
	}
    }
    function showHideBlockSection(status) {
  	if (status == "yes") {
  		Reschedule.style.display='';
  		document.$form.rescheduletext.value = '';
  	}
	else if (status == "no") {Reschedule.style.display='none';}
	else if (status == "1") {
		document.$form.org1.value = '';
		document.$form.org2.value = '';
		document.$form.org1.disabled = true;
		document.$form.org2.disabled = true;
		document.$form.suborg.disabled = false;

	}
	else {
		document.$form.org1.disabled = false;
		document.$form.org2.disabled = false;
		document.$form.suborg.selectedIndex = 0; // so it looks like all items were deselected
		document.$form.suborg.selectedIndex = -1; // and so they are
		document.$form.suborg.disabled = true;
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

    function checkDate(date,e) {
	var valid = 1;
	var errormsg = "";
	var dateparts;

	if (isblank(date)) {
		valid = 1;
	}
	else  {
		var test = date.match(/[\/]+/g);
		if (!test || test.length != 2) {valid = 0 ;}
		else {
			dateparts = date.split('/');		
			var month = dateparts[0];
			var day = dateparts[1];
			var year = dateparts[2];
		}
		if (valid == 0) {
			alert ("Date should be of the format MM/DD/YYYY or MM/DD/YY");	
			valid = 0;
		}	
		if ((month < 1) || (month > 12)) {
			errormsg += month + " is not a valid month\\n";
			alert (errormsg);	
			valid = 0;
		}	
		if ((day < 1) || ((month == "01" || month == "1") && (day > 31)) || ((month == "02" || month == "2") && (day > 29))
	  	 || ((month == "03" || month == "3") && (day > 31)) || ((month == "04" || month == "4") && (day > 30))
	  	 || ((month == "05" || month == "5") && (day > 31)) || ((month == "06" || month == "6") && (day > 30))
	  	 || ((month == "07" || month == "7") && (day > 31)) || ((month == "08" || month == "8") && (day > 31))
	  	 || ((month == "09" || month == "9") && (day > 30)) || ((month == "10") && (day > 31))
	  	 || ((month == "11") && (day > 30)) || ((month == "12") && (day > 31))) {
	
			alert ("There are not " + day + " days in that month");
			valid = 0;		
		}	
		if ( !year || (year.length != 2 && year.length != 4)) {
			errormsg += year + " is not a valid year\\n";	
			valid = 0;
		}
	}
	if (!valid) {
		alert (errormsg);
		e.focus();
	}
		
	return (valid);
		
    }
    
    function checkForecast(val,e) {
        var valid = 1;
       	var datestr;
       	var errormsg = "";
       	
       	if (val != 'mm/yyyy') {
       	        datestr = val.split('/');
       	               	        
       	        if (datestr[0] == val) {
       	            errormsg += datestr[0] + " is not valid\\n";
       	            errormsg += "Please enter a date in the format MM/YYYY\\n";
		    valid = 0;
   		}
       	        else if ((datestr[0] < 1) || (datestr[0] > 12)) {
       	             errormsg += datestr[0] + " is not a valid month\\n";
       	             valid = 0;
       	        }
       	        else if ( !isnumeric(datestr[1]) || (datestr[1].length != 4)) {
       	             errormsg += datestr[1] + " is not a valid year, please enter a four digit year\\n";
       	             valid = 0;
       	        }
        }
        //else      	        
       	//{      
         //errormsg = "You must enter a date in the format MM/YYYY";
        // valid = 0;
        //}
        
          
       	if (!valid) {
       	     alert(errormsg);
       	     e.focus();
       	}
       	
      	return(valid);
    }
    function isnumeric(s) {
    	  for(var i = 0; i < s.length; i++) {
    	  var c = s.charAt(i);
    	  if ((c < '0') || (c > '9')) return false;
    	}
     	return true;
    }
    function validateSurveillance(script, command) {
    	var errors = "";
    	var msg;
	var qardstr = "";
	var suborgstr = "";
	if (document.$form.qardElement) {
		for (var j=0;j<document.$form.qardElement.length;j++) {
			if (document.$form.qardElement[j].checked) {
				qardstr += "1";
			} else {
				qardstr += "0";
			}
		}
    		document.$form.qardstring.value = qardstr;
    	}
    	
    	if (document.$form.suborg) {
		for (var j=0;j<document.$form.suborg.length;j++) {
			if (document.$form.suborg[j].selected) {
				if (suborgstr != "") {suborgstr += ",";}
				suborgstr += document.$form.suborg[j].value;
			}
		}
    		document.$form.suborgstring.value = suborgstr;  
    	}
    	
    	if (document.$form.issuedby.type != 'hidden' && !document.$form.issuedby[0].checked && !document.$form.issuedby[1].checked && !document.$form.issuedby[2].checked) {errors += "\\tThe Issued By field must have a value\\n";}
	if (document.$form.issuedto.value == 0) {errors += "\\tThe Issued To field must have a value. \\n";}

    	if (isblank(document.$form.scope.value)) {
		errors += "\\tThe Surveillance Scope Summary must be completed.\\n";
    	}
	if (document.$form.rescheduled && document.$form.rescheduled[1].checked && isblank(document.$form.rescheduletext.value)) {
		errors += "\\tThe Reschedule Info field must have a value when the recheduled button is selected.\\n";
	}    	
    	//if (document.$form.contingency.value == null || document.$form.contingency.value == "") {
	//	errors += "\\tThe Contingency text area must contain a value.\\n";
    	//}
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
    function deleteAttachment(script, command, surveillance, reportlink,displayid,dbname) {
        document.$form.command.value = command;
        document.$form.survID.value = surveillance;
        document.$form.reportlink.value = reportlink;
        document.$form.dbname.value = dbname;
        document.$form.displayid.value = displayid;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'workspace';
        document.$form.submit();
    }

END_OF_BLOCK
    $output .= &doMultipartHeader(schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'T', includeJSWidgets => 'F'); 
    $output .= "<input type=hidden name=type value=0>\n";
    $output .= "<input type=hidden name=survID value=$settings{survID}>\n";
    $output .= "<input type=hidden name=CRid value=$settings{CRid}>\n";
    $output .= "<input type=hidden name=funum value=$settings{funum}>\n";
    $output .= "<input type=hidden name=bpnum value=$settings{bpnum}>\n";
    $output .= "<input type=hidden name=fiscalyear value=$settings{fiscalyear}>\n";
    $output .= "<input type=hidden name=newCRnum value=''>\n";
    $output .= "<input type=hidden name=crcount value=''>\n";
    $output .= "<input type=hidden name=newFUnum value=''>\n";
    $output .= "<input type=hidden name=fucount value=''>\n";
    $output .= "<input type=hidden name=newBPnum value=''>\n";
    $output .= "<input type=hidden name=bpcount value=''>\n";
    $output .= "<input type=hidden name=generatedfrom value='S'>\n";
    $output .= "<input type=hidden name=generatorid value=$settings{survID}>\n";
    $output .= "<input type=hidden name=qardstring value=$settings{qardstring}>\n";
    $output .= "<input type=hidden name=suborgstring value=$settings{suborgstring}>\n";
    $output .= "<input type=hidden name=displayid>\n";
    $output .= "<input type=hidden name=reportlink value=''>\n";
    $output .= "<input type=hidden name=dbname value=''>\n";
    $output .= "<input type=hidden name=surveillance_selection value=$settings{selection}>\n";
    $output .= "<table border=0 width=750 align=center><tr><td>\n";

    return($output);
}

###################################################################################################################################
sub doHeaderXsl {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        schema => $ENV{SCHEMA},
        title => 'Export to Excel',
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
    
    $output .= "content-type: application/vnd.ms-excel\n"; 
    #$output .= "content-disposition: attachment; filename=qa-integratred-surveillance.xls\n\n"; 
    $output .= "content-disposition: inline; filename=qa-integratred-surveillance.xls\n\n"; 
    
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
sub doBrowseSurveillance {  # routine to do display surveillances
###################################################################################################################################
    my %args = (
        title => 'Surveillance',
        selection => 'all', # all
        type => 'I', # all
        userID => 0, # all
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    my $count = 0;
    my $numColumns = 4;
    my $lead;
    my $location;
    my @surveillanceList = &getSurveillance(dbh => $args{dbh}, schema => $args{schema},fiscalyear => $args{fiscalyear}, single=>0, selection=>$args{selection});
    my $orgid = 0;   
    #print "\n<br>*** $args{selection} <br>\n";
    
    $output .= &endTable if ($args{flag} != 0);
    $output .= "<table cellpadding=2 cellspacing=0 border=1 align=center width=600>\n";
    
    for (my $i = 0; $i < $#surveillanceList; $i++) {
			    	my ($surveillanceid,$fy,$contact,$elements,$team,$leadid,$issuedto,$issuedby,$scope,$approved,
			    	$cancelled,$forecast,$start,$end,$completed,$seq,$intext,$status,$qard,$reschedule,$results,$overall,$eststart,
			    	$estend,$procedures,$state,$adequacy,$implementation,$effectiveness,$title,$reportlink,$dbname,$mol) = 
			      	($surveillanceList[$i]{surveillanceid},$surveillanceList[$i]{num},$surveillanceList[$i]{contact},
			    	$surveillanceList[$i]{elements},$surveillanceList[$i]{team},$surveillanceList[$i]{leadid},$surveillanceList[$i]{issuedto},
			    	$surveillanceList[$i]{issuedby},$surveillanceList[$i]{scope},$surveillanceList[$i]{approved},
			    	$surveillanceList[$i]{cancelled},$surveillanceList[$i]{forecast},$surveillanceList[$i]{start},$surveillanceList[$i]{end},
			    	$surveillanceList[$i]{completed},$surveillanceList[$i]{seq},$surveillanceList[$i]{intext},$surveillanceList[$i]{status},
			    	$surveillanceList[$i]{qard},$surveillanceList[$i]{reschedule},$surveillanceList[$i]{results},$surveillanceList[$i]{overall},
			    	$surveillanceList[$i]{estbegindate},$surveillanceList[$i]{estenddate},$surveillanceList[$i]{procedures},
			    	$surveillanceList[$i]{state},$surveillanceList[$i]{adequacy},$surveillanceList[$i]{implementation},
			    	$surveillanceList[$i]{effectiveness},$surveillanceList[$i]{title},$surveillanceList[$i]{reportlink},$surveillanceList[$i]{dblink},
			    	$surveillanceList[$i]{mol});  
			    	my $suborg;
			    	my $org;
			    	my $issueby = &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedby);
			    	my $issueto = &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedto);
			    	
			    	#print "\n<br>*** $issueby <br>\n";
			      	
			      	$status = defined($reschedule) ? "Rescheduled" : defined($cancelled) && $cancelled eq 'Y' ? "Cancelled" : defined($state) && $state eq 'Cancelled' ? "Cancelled" : defined($state) && $state eq 'Postponed' ? "Postponed" : 
			      	defined($completed) ? $reportlink ? "<a href=\"javascript:reportWindow('$reportlink','$dbname');\">Report Approved</a> $completed" : "Report Approved $completed" : 
			      	defined($state) && $state eq 'Field Work Complete' ? "Field Work Complete $end" : defined($state) && $state eq 'Complete' ? "Complete<br>$end" : defined($state) && $state eq 'In Progress' ? "In Progress $start" : defined($eststart) ? 
			      	"Scheduled $eststart" : "$start&nbsp;";     	
			      	
			      	if ($leadid != 0) {$lead = &getFullUserName(dbh => $args{dbh}, schema => $args{schema},userID=>$leadid);}
					else {$lead = 'TBD';}
					my @org = &getOrganization(dbh=>$args{dbh},schema=>$args{schema},survID=>$surveillanceid,fiscalyear=>$args{fiscalyear}) if ($intext eq 'I');
					my @suborg = &getSuborganization(dbh=>$args{dbh},schema=>$args{schema},survID=>$surveillanceid,fiscalyear=>$args{fiscalyear}) if ($intext eq 'I');
					my @supplier = &getSupplier(dbh=>$args{dbh},schema=>$args{schema},survID=>$surveillanceid,fiscalyear=>$args{fiscalyear}) if ($intext eq 'E');
			        my $location;
			        my @location = &getLocation(dbh=>$args{dbh},schema=>$args{schema},survID=>$surveillanceid,fiscalyear=>$args{fiscalyear});
			        for (my $j = 0; $j < $#org; $j++) {
			    		$org .= (($j != 0) ? ", " : "") . "$org[$j]{orgabbr}";
			        }
			        for (my $j = 0; $j < $#location; $j++) {
			    		$location .= (($j != 0) ? "; " : "") . "$location[$j]{city}, $location[$j]{state}";
			        }
			       	@suborg = &getSuborganization(dbh=>$args{dbh},schema=>$args{schema},survID=>$surveillanceid,fiscalyear=>$args{fiscalyear});
				   	for (my $j = 0; $j < $#suborg; $j++) {
				   		$suborg .= (($j != 0) ? ", " : "") . "$suborg[$j]{suborg}";
				   	}
				   	
				   	if ($issuedby != $orgid) {
				   		#print $issueby;				   		
				   		 $output .= &writeTableHeader(issuedby=>$issueby,flag=>$orgid);
				   		 $orgid = $issuedby;
				   	}
				   	my $display = getSurveillanceDisplayID(issuedby=>$issueby,issuedto=>$issueto,intext=>$intext,fiscalyear=>$args{fiscalyear},seq=>$seq);
				
				    $output .= "<tr>\n";
				    $output .= &addCol (value => "$display",url => "javascript:submitEditSurveillance('surveillance2','viewSurveillance',$surveillanceid)",align=>"center nowrap",valign=>"top");
					$output .= &addCol (value => "$lead" ,valign=>"top",width=>120);
					$output .= &addCol (value => "Organization: $org<br>" . (($suborg) ? "Suborganization:&nbsp;$suborg<br>" : "") . (defined($title) ? "$title" : "$scope"),valign=>"top") if ($intext eq 'I');
					$output .= &addCol (value => "Supplier: $supplier[0]{supplier}<br>" . (defined($title) ? "$title" : "$scope"),valign=>"top") if ($intext eq 'E');
					$output .= &addCol (value => "$status",valign=>"top");
				    $output .= &endRow();
				    
    }
    $output .= &endTable;    
    return($output);
}

###################################################################################################################################
sub doBrowseSurveillanceXsl {  # routine to do display surveillances
###################################################################################################################################
    my %args = (
        title => 'Surveillance',
        selection => 'all', # all
        type => 'I', # all
        userID => 0, # all
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    my $count = 0;
    my $numColumns = 4;
    my $lead;
    my $location;
    my @surveillanceList = &getSurveillance(dbh => $args{dbh}, schema => $args{schema},fiscalyear => $args{fiscalyear}, single=>0, selection=>$args{selection});
    my $orgid = 0;
   
    #print "\n<br>*** $args{selection} <br>\n";
    
    for (my $i = 0; $i < $#surveillanceList; $i++) {
    	my ($surveillanceid,$fy,$contact,$elements,$team,$leadid,$issuedto,$issuedby,$scope,$approved,
    	$cancelled,$forecast,$start,$end,$completed,$seq,$intext,$status,$qard,$reschedule,$results,$overall,$eststart,
    	$estend,$procedures,$state,$adequacy,$implementation,$effectiveness,$title,$reportlink,$dbname,$mol) = 
      	($surveillanceList[$i]{surveillanceid},$surveillanceList[$i]{num},$surveillanceList[$i]{contact},
    	$surveillanceList[$i]{elements},$surveillanceList[$i]{team},$surveillanceList[$i]{leadid},$surveillanceList[$i]{issuedto},
    	$surveillanceList[$i]{issuedby},$surveillanceList[$i]{scope},$surveillanceList[$i]{approved},
    	$surveillanceList[$i]{cancelled},$surveillanceList[$i]{forecast},$surveillanceList[$i]{start},$surveillanceList[$i]{end},
    	$surveillanceList[$i]{completed},$surveillanceList[$i]{seq},$surveillanceList[$i]{intext},$surveillanceList[$i]{status},
    	$surveillanceList[$i]{qard},$surveillanceList[$i]{reschedule},$surveillanceList[$i]{results},$surveillanceList[$i]{overall},
    	$surveillanceList[$i]{estbegindate},$surveillanceList[$i]{estenddate},$surveillanceList[$i]{procedures},
    	$surveillanceList[$i]{state},$surveillanceList[$i]{adequacy},$surveillanceList[$i]{implementation},
    	$surveillanceList[$i]{effectiveness},$surveillanceList[$i]{title},$surveillanceList[$i]{reportlink},$surveillanceList[$i]{dblink},
    	$surveillanceList[$i]{mol});  
    	my $suborg;
    	my $org;
    	my $issueby = &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedby);
    	my $issueto = &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedto);
    	
    	#print "\n<br>*** $issueby <br>\n";
      	
      	$status = defined($reschedule) ? "Rescheduled" : defined($cancelled) && $cancelled eq 'Y' ? "Cancelled" : defined($state) && $state eq 'Cancelled' ? "Cancelled" : defined($state) && $state eq 'Postponed' ? "Postponed" : 
      	#defined($completed) ? $reportlink ? "<a href=\"javascript:reportWindow('$reportlink','$dbname');\">Report Approved</a> $completed" : "Report Approved $completed" : 
      	defined($completed) ? $reportlink ? "Report Approved $completed" : "Report Approved $completed" : 
      	defined($state) && $state eq 'Field Work Complete' ? "Field Work Complete $end" : defined($state) && $state eq 'Complete' ? "Complete<br>$end" : defined($state) && $state eq 'In Progress' ? "In Progress $start" : defined($eststart) ? 
      	"Scheduled $eststart" : "$start&nbsp;";     	
      	
      	if ($leadid != 0) {$lead = &getFullUserName(dbh => $args{dbh}, schema => $args{schema},userID=>$leadid);}
	else {$lead = 'TBD';}
	my @org = &getOrganization(dbh=>$args{dbh},schema=>$args{schema},survID=>$surveillanceid,fiscalyear=>$args{fiscalyear}) if ($intext eq 'I');
	my @suborg = &getSuborganization(dbh=>$args{dbh},schema=>$args{schema},survID=>$surveillanceid,fiscalyear=>$args{fiscalyear}) if ($intext eq 'I');
	my @supplier = &getSupplier(dbh=>$args{dbh},schema=>$args{schema},survID=>$surveillanceid,fiscalyear=>$args{fiscalyear}) if ($intext eq 'E');
        my $location;
        my @location = &getLocation(dbh=>$args{dbh},schema=>$args{schema},survID=>$surveillanceid,fiscalyear=>$args{fiscalyear});
        for (my $j = 0; $j < $#org; $j++) {
    		$org .= (($j != 0) ? ", " : "") . "$org[$j]{orgabbr}";
        }
        for (my $j = 0; $j < $#location; $j++) {
    		$location .= (($j != 0) ? "; " : "") . "$location[$j]{city}, $location[$j]{state}";
        }
       	@suborg = &getSuborganization(dbh=>$args{dbh},schema=>$args{schema},survID=>$surveillanceid,fiscalyear=>$args{fiscalyear});
   	for (my $j = 0; $j < $#suborg; $j++) {
   		$suborg .= (($j != 0) ? ", " : "") . "$suborg[$j]{suborg}";
   	}
   	if ($issuedby != $orgid) {
   		 $output .= &writeTableHeaderXsl(issuedby=>$issueby,flag=>$orgid);
   		 $orgid = $issuedby;
   	}
   	my $display = getSurveillanceDisplayID(issuedby=>$issueby,issuedto=>$issueto,intext=>$intext,fiscalyear=>$args{fiscalyear},seq=>$seq);
      	$output .= "<tr>\n";
    
    #$output .= &addCol (value => "$display",url => "javascript:submitEditSurveillance('surveillance2','viewSurveillance',$surveillanceid)",align=>"center nowrap",valign=>"top");
	#$output .= &addCol (value => "$lead" ,valign=>"top",width=>120);
	#$output .= &addCol (value => "Organization: $org<br>" . (($suborg) ? "Suborganization:&nbsp;$suborg<br>" : "") . (defined($title) ? "$title" : "$scope"),valign=>"top") if ($intext eq 'I');
	#$output .= &addCol (value => "Supplier: $supplier[0]{supplier}<br>" . (defined($title) ? "$title" : "$scope"),valign=>"top") if ($intext eq 'E');
	#$output .= &addCol (value => "$status",valign=>"top");
        
    		  		   $output .= &addCol (value => "$issueby",align=>"center nowrap",valign=>"top");
				       $output .= &addCol (value => "$issueto",align=>"center nowrap",valign=>"top");
				       $output .= &addCol (value => "$args{fiscalyear}",align=>"center nowrap",valign=>"top");				      
				     	$output .= &addCol (value => "$display",align=>"center nowrap",valign=>"top");
				     	
					 	$output .= &addCol (value => "$start",align=>"center nowrap",valign=>"top");
					 	$output .= &addCol (value => "$end",align=>"center nowrap",valign=>"top");
					 	
					 	$output .= &addCol (value => "$lead",valign=>"top",width=>120);
					 	$output .= &addCol (value => "$org<br>" . (($suborg) ? "Suborganization:&nbsp;$suborg<br>" : "") . ($issueby eq 'EM' ? "Location: $location<br>" : "") . (defined($title) ? "$title" : "$scope"),valign=>"top");
					 	
					 	$output .= &addCol (value => "$location",valign=>"top");
					 	$output .= &addCol (value => "$title",valign=>"top");
					 	
					 	$output .= &addCol (value => "$scope",valign=>"top");
					 	$output .= &addCol (value => "$status",valign=>"top");
					 	$output .= &addCol (value => "$completed",valign=>"top");
    		      
    	$output .= &endRow();
    }
    $output .= &endTable;
    
    return($output);
}
###################################################################################################################################
sub doViewSurveillance {  # routine to view a surveillance
###################################################################################################################################
    my %args = (
        survID => 0,
        title => 'Surveillance',
        userID => 0, # all
        @_,
    );
    my $org;
    my @org;
    my $suborg;
    my @suborg;
    my $location;
    my $deficiency;
    my $output = '';
    my $count = 0;
    my $numColumns = 3;
    my %userprivhash = &getUserPrivs(dbh=>$args{dbh},schema=>$args{schema},userID=>$args{userID});
    my @surveillanceList = &getSurveillance(dbh => $args{dbh}, schema => $args{schema}, survID => $args{survID},fiscalyear => $args{fiscalyear},single=>1);
    
    my ($surveillanceid,$fy,$contact,$elements,$team,$leadid,$issuedto,$issuedby,$scope,$approved,
    $cancelled,$forecast,$start,$end,$completed,$seq,$intext,$status,$qard,$reschedule,$results,$overall,$eststart,
    $estend,$procedures,$state,$adequacy,$implementation,$effectiveness,$title,$reportlink,$dbname,$mol) = 
    ($surveillanceList[0]{surveillanceid},$surveillanceList[0]{num},$surveillanceList[0]{contact},
    $surveillanceList[0]{elements},$surveillanceList[0]{team},$surveillanceList[0]{leadid},$surveillanceList[0]{issuedto},
    $surveillanceList[0]{issuedby},$surveillanceList[0]{scope},$surveillanceList[0]{approved},
    $surveillanceList[0]{cancelled},$surveillanceList[0]{forecast},$surveillanceList[0]{start},$surveillanceList[0]{end},
    $surveillanceList[0]{completed},$surveillanceList[0]{seq},$surveillanceList[0]{intext},$surveillanceList[0]{status},
    $surveillanceList[0]{qard},$surveillanceList[0]{reschedule},$surveillanceList[0]{results},$surveillanceList[0]{overall},
    $surveillanceList[0]{estbegindate},$surveillanceList[0]{estenddate},$surveillanceList[0]{procedures},
    $surveillanceList[0]{state},$surveillanceList[0]{adequacy},$surveillanceList[0]{implementation},
    $surveillanceList[0]{effectiveness},$surveillanceList[0]{title},$surveillanceList[0]{reportlink},
    $surveillanceList[0]{dblink},$surveillanceList[0]{mol});  

    if ($intext eq 'I') {
    	@org = &getOrganization(dbh=>$args{dbh},schema=>$args{schema},survID=>$surveillanceid,fiscalyear=>$args{fiscalyear});
   	#for (my $i = 0; $i < $#org; $i++) {
   		#$org .= (($i != 0) ? ", " : "") . "$org[$i]{orgname}";
   	#}
   	for (my $i = 0; $i < $#org; $i++) {
	   	$org .= (($i != 0) ? ", " : "") . (($args{fiscalyear} >= 2006) ? (($org[$i]{orgabbr} eq "BSC") ? "BSC" : "$org[$i]{orgname}") : "$org[$i]{orgname}");
   	}
    	@suborg = &getSuborganization(dbh=>$args{dbh},schema=>$args{schema},survID=>$surveillanceid,fiscalyear=>$args{fiscalyear});
   	for (my $j = 0; $j < $#suborg; $j++) {
   		$suborg .= (($j != 0) ? ", " : "") . "$suborg[$j]{suborg}";
   	}
    } else {
    	@org = &getSupplier(dbh=>$args{dbh},schema=>$args{schema},survID=>$surveillanceid,fiscalyear=>$args{fiscalyear});
   	$org = "$org[0]{supplier}";  
    }
    my $issueto = &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedto);
    my $issueby = &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedby);
    my $displayid = getSurveillanceDisplayID(issuedby=>$issueby,issuedto=>$issueto,intext=>$intext,fiscalyear=>$args{fiscalyear},seq=>$seq);
    my @location = &getLocation(dbh=>$args{dbh},schema=>$args{schema},survID=>$surveillanceid,fiscalyear => $args{fiscalyear});
    for (my $j = 0; $j < $#location; $j++) {
    	$location .= (($j != 0) ? "; " : "") . "$location[$j]{city}, $location[$j]{state}";
    }
    ###### next lines for old years
    my @deficiency = &getDeficiency(dbh=>$args{dbh},schema=>$args{schema},recordID=>$surveillanceid,fiscalyear => $args{fiscalyear}) if ($intext eq 'I');
    for (my $j = 0; $j < $#deficiency; $j++) {
    	$deficiency .= (($j != 0) ? ", " : "") . "$deficiency[$j]{deficiencytext}";
    }
    #######
   $output .= "<script>document.forms[0].displayid.value='$displayid';</script> ";
    $output .= "<br><table width=650 border=0 cellspacing=4 cellpadding=1>\n";
    $output .= "<tr><td colspan=3 align=center><b><font color=black>\n";
    $output .= "$displayid </font></b></td><td></tr>\n";
    $output .= "<tr height=10></tr>\n";
    $output .= "<tr>" . &addCol(value => "<b>Issued By: &nbsp;<font color=black>$issueby</font></b>");
    $output .= &addCol(value => "<b>Issued To: &nbsp;<font color=black>$issueto</font></b>");
    $output .= &addCol(value => "<b>Fiscal Year:&nbsp;<font color=black>" . (($fy < 50) ? "20" . lpadzero($fy,2) : "19" . $fy) . "</font></b>");
    $output .= &endRow();
    
    if (defined($reschedule)) {
    	$output .= "<tr>" . &addCol(value => "<b>Rescheduled:&nbsp;<font color=black>$reschedule</font></b>",colspan=>$numColumns);
    }
    else {
    	if ($args{fiscalyear} >= 2004) {
    		$output .= "<tr>" . &addCol(value => "<b>Plan:&nbsp;<font color=black>$eststart</font></b>");
    		#$output .= &addCol(value => "<b>Scheduled End:&nbsp;<font color=black>$estend</font></b>");
		$output .= &addCol(value => "<b>Status:&nbsp;<font color=black>$state</font></b>");
    		$output .= &endRow();
    	}
    	$output .= "<tr>" . &addCol(value => "<b>Start Date:&nbsp;<font color=black>$start</font></b>");
    	$output .= &addCol(value => "<b>End Date:&nbsp;<font color=black>$end</font></b>");
    	$output .= &addCol(value => "<b>Report Approved:&nbsp;<font color=black>$completed</font></b>");
    }
    $output .= &endRow();
    $output .= "<tr>" . &addCol(value => "<b>Initial Contact:&nbsp;<font color=black>$contact</font></b>");
    $output .= &addCol(value => "<b>Team Lead:&nbsp;<font color=black>" . (($leadid == 0) ? "TBD" : &getFullUserName(dbh => $args{dbh}, schema => $args{schema},userID=>$leadid)) . "</font></b>");
    $output .= &addCol(value => "<b>Team Members:&nbsp;<font color=black> " . (defined($team) ? "$team" : "TBD") . "</font></b>");
    $output .= &endRow();
    $output .= "<tr>" . &addCol(value => "<b>" . (($intext eq 'I') ? "Organization: " : "Supplier: " ) . "&nbsp;&nbsp;<font color=black>$org</font></b>" . (($suborg) ? "<br><b>Suborganization:&nbsp;&nbsp;<font color=black>$suborg</font></b>" : "" ),valign=>"top",colspan=>3);
    $output .= &endRow();
    $output .= "<tr>" . &addCol(value => "<b>Location:&nbsp;&nbsp;<font color=black>$location</font></b>",valign=>"top",colspan=>3);
    $output .= &endRow();
    if ($args{fiscalyear} >= 2004) {
    	$output .= "<tr>" . &addCol(value => "<b>Surveillance Title:&nbsp;&nbsp;<font color=black>$title</font></b>",valign=>"top",colspan=>3);
    	$output .= &endRow();
    }
    $output .= "<tr>" . &addCol(value => "<b>Surveillance Scope Summary:&nbsp;&nbsp;<font color=black>$scope</font></b>",valign=>"top",colspan=>3);
    $output .= &endRow();
    if ($args{fiscalyear} >= 2004) {
    	#$output .= "<tr>" . &addCol(value => "<b>QA Elements:&nbsp;<font color=black>" . &writeQARD(qard=>"$qard") . "</font></b>",valign=>"top",colspan=>3,fontSize=>2);
    	#$output .= &endRow();
    	#$output .= "<tr>" . &addCol(value => "<b>Procedures:&nbsp;<font color=black>$procedures</font></b>",valign=>"top",colspan=>3,fontSize=>2);
    	#$output .= &endRow();
    }
    elsif ($args{fiscalyear} <= 2003) {
    	#$output .= "<tr>" . &addCol(value => "<b>Elements:&nbsp;<font color=black>$elements</font>",valign=>"top",colspan=>3,fontSize=>2);
    	#$output .= &endRow();
    }
    #$output .= "<tr>" . &addCol(value => "<b>Comments:&nbsp;&nbsp;<font color=black>$status</font></b>",valign=>"top",colspan=>3,fontSize=>2);
    #$output .= &endRow();
    
    #$output .= "<tr>" . &addCol(value => "<b>Accession #:&nbsp;&nbsp;<font color=black>$mol</font></b>",valign=>"top",colspan=>3,fontSize=>2);
    #$output .= &endRow();
    
   if($mol){
    $output .= "<tr>" . &addCol(value => "<b>Accession #:&nbsp;&nbsp;<font color=black><a href='http://rms.ymp.gov/api/records/".$mol."_images.pdf' target=_blank>$mol</a></font></b> (Click the # to view the report saved in RISWEB)",valign=>"top",colspan=>3,fontSize=>2);
    $output .= &endRow();
    }else{
   $output .= "<tr>" . &addCol(value => "<b>Accession #:&nbsp;&nbsp;<font color=black>$mol</font></b>",valign=>"top",colspan=>3,fontSize=>2);
   $output .= &endRow(); 	
    }
    
    if ($args{fiscalyear} >= 2004) {
    	#$output .= "<tr>" . &addCol(value => "<b>Adequacy:&nbsp;&nbsp;<font color=black>$adequacy</font></b>",fontSize=>2);
    	#$output .= &addCol(value => "<b>Implementation:&nbsp;&nbsp;<font color=black>$implementation</font></b>",fontSize=>2);
    	#$output .= &addCol(value => "<b>Effectiveness:&nbsp;&nbsp;<font color=black>$effectiveness</font></b>",fontSize=>2);
    	#$output .= &endRow();
    	#$output .= "<tr>" . &addCol(value => "<b>Results:&nbsp;<font color=black>$results</font></b>",valign=>"top",colspan=>$numColumns,fontSize=>2);
    	#$output .= &endRow();
    	$output .= &addCol(value => "<b>Overall Results:&nbsp;&nbsp;<font color=black>$overall</font></b>",valign=>"top",colspan=>3, fontSize=>2);
        $output .= &endRow();
    }
    my $editallowed = ($userprivhash{'Developer'} == 1 || ($userprivhash{'OQA Surveillance Administration'} == 1 && $issueby eq 'OQA') || ($userprivhash{'SNL Surveillance Administration'} == 1 && ($issueby eq 'SNL' || $issueby eq 'Lead Lab') || ($userprivhash{'BSC Surveillance Administration'} == 1 && (($issueby eq 'BSC') || ($issueby eq 'M&O'))))
	|| (($userprivhash{'OQA Surveillance Lead'} == 1 || $userprivhash{'SNL Surveillance Lead'} == 1 || $userprivhash{'BSC Surveillance Lead'} == 1) && $leadid == $args{userID})) ? 1 : 0;
	
    if ($args{fiscalyear} <= 2003) {
    	$output .= "<tr>" . &addCol(value => "<b>Deficiencies:&nbsp;<font color=black>$deficiency</font></b>",valign=>"top",colspan=>3,fontSize=>2);
    	$output .= &endRow();
    }
    elsif ($args{fiscalyear} >= 2004) {
    	$output .= &writeConditionReport(dbh => $args{dbh}, schema => $args{schema}, survID => $surveillanceid, fiscalyear => $fy,edit=>$editallowed);
		#$output .= &writeConditionReportFollowup(dbh => $args{dbh}, schema => $args{schema}, survID => $surveillanceid, fiscalyear => $fy,single=>1,edit=>$editallowed);
		#$output .= &writeBestPractice(dbh => $args{dbh}, schema => $args{schema}, survID => $surveillanceid, fiscalyear => $fy,single=>1,edit=>$editallowed);
    }
    if ($reportlink) {
    	$output .= "<tr><td valign=top colspan=$numColumns><b>View Report</b><br>&nbsp;&nbsp;&nbsp;<a href=\"javascript:reportWindow('$reportlink','$dbname');\"><img src=$NQSImagePath/report.gif></a><br><br></td></tr>\n";
    }
   if ($editallowed) {
        $output .= "<tr><td colspan=$numColumns align=center><a href=javascript:submitEditSurveillance('surveillance2','editSurveillance',$surveillanceid)>Edit Surveillance</a>\n";
        if ($args{fiscalyear} >= 2004) {
    		#$output .= "&nbsp;&nbsp;&nbsp;&nbsp;<a href=javascript:submitEditSurveillance('conditionReports','createCondition',$surveillanceid,'S')>Add Condition Report</a>\n";
    		#$output .= "&nbsp;&nbsp;&nbsp;&nbsp;<a href=javascript:submitEditSurveillance('conditionReports','browseConditions',$surveillanceid)>Add Follow-up to Condition Report</a>\n";
    		#$output .= "<br>&nbsp;&nbsp;&nbsp;&nbsp;<a href=javascript:submitEditSurveillance('conditionReports','createBestPractice',$surveillanceid)>Add Best Practice</a>\n";
    		#$output .= "&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"javascript:submitEditReport('surveillance2','editReportlink',$surveillanceid,'$reportlink','$displayid','$dbname')\">" . ($reportlink ? "Edit " : "Add ") . "Correspondence Control Report Link</a>\n" if (!$dbname || $dbname eq 'CC');
    		$output .= "&nbsp;&nbsp;&nbsp;&nbsp;<a href=javascript:submitEditSurveillance('surveillance2','processDeleteSurveillance',$surveillanceid)>Delete Surveillance</a>\n" if (!$completed);
    	}
    	$output .= "</td></tr>\n";
    }
    $output .= &endTable . "<br><br><br>\n";
    $output .= "<input type=hidden name=reportlink value='$reportlink'>\n";
    $output .= "<input type=hidden name=dbname value='$dbname'>\n";
    $output .= "<center><a href=\"$NQSCGIDir/surveillance2.pl?userid=$args{userID}&schema=$args{schema}&command=browse&fiscalyear=$args{fiscalyear}&surveillance_selection=$args{selection}\"><b>Return to Previous Page</b></a></center><br>\n";
    	#$output .= "<br><br><center><a href=javascript:history.back() title='Click here to return to the previous page'><b>Return to Previous Page</b></a></center><br>\n";
    	#$output .= "<br>\n<center>\n<input type=button name=submitEdit value=Submit onClick=\"validateRisk('risks','processUpdateRisk')\">\n</center>\n";

    return($output);
}
###################################################################################################################################
sub doEditSurveillance {  # routine to edit a surveillance
###################################################################################################################################
     my %args = (
         survID => 0,
         title => 'Surveillance',
         userID => 0, # all
         @_,
     );
     my $org;
     my $location;
     my $deficiency;
     my $output = '';
     my $count = 0;
     my $numColumns = 3;
     my @surveillanceList = &getSurveillance(dbh => $args{dbh}, schema => $args{schema}, survID => $args{survID},fiscalyear => $args{fiscalyear},single=>1);
     
     my ($surveillanceid,$fy,$contact,$elements,$team,$leadid,$issuedto,$issuedby,$scope,$approved,
     $cancelled,$forecast,$start,$end,$completed,$seq,$intext,$status,$qard,$reschedule,$results,$overall,$eststart,
     $estend,$procedures,$state,$adequacy,$implementation,$effectiveness,$title,$reportlink,$dbname,$mol) = 
     ($surveillanceList[0]{surveillanceid},$surveillanceList[0]{num},$surveillanceList[0]{contact},
     $surveillanceList[0]{elements},$surveillanceList[0]{team},$surveillanceList[0]{leadid},$surveillanceList[0]{issuedto},
     $surveillanceList[0]{issuedby},$surveillanceList[0]{scope},$surveillanceList[0]{approved},
     $surveillanceList[0]{cancelled},$surveillanceList[0]{forecast},$surveillanceList[0]{start},$surveillanceList[0]{end},
     $surveillanceList[0]{completed},$surveillanceList[0]{seq},$surveillanceList[0]{intext},$surveillanceList[0]{status},
     $surveillanceList[0]{qard},$surveillanceList[0]{reschedule},$surveillanceList[0]{results},$surveillanceList[0]{overall},
     $surveillanceList[0]{estbegindate},$surveillanceList[0]{estenddate},$surveillanceList[0]{procedures},
     $surveillanceList[0]{state},$surveillanceList[0]{adequacy},$surveillanceList[0]{implementation},
     $surveillanceList[0]{effectiveness},$surveillanceList[0]{title},$surveillanceList[0]{reportlink},
     $surveillanceList[0]{dblink},$surveillanceList[0]{mol});  

     $output .= "<input type=hidden name=int_ext value=$args{int_ext}>\n" if ($args{survID} == 0);
     $output .= "<input type=hidden name=issuedby value=$args{issuedby}>\n" if ($args{survID} != 0);
     if ($intext eq 'I') {
     	my @org = &getOrganization(dbh=>$args{dbh},schema=>$args{schema},survID=>(defined($surveillanceid) ? $surveillanceid : 0),fiscalyear => $args{fiscalyear}) if ($intext eq 'I');
    	for (my $i = 0; $i < $#org; $i++) {
    		$org .= (($i != 0) ? ", " : "") . "$org[$i]{orgname}";
    	}
     }
#     my @deficiency = &getDeficiency(dbh=>$args{dbh},schema=>$args{schema},recordID=>$surveillanceid,fiscalyear => $args{fiscalyear}) if ($intext eq 'I');
 #    for (my $j = 0; $j < $#deficiency; $j++) {
#    	$deficiency .= (($j != 0) ? ", " : "") . "$deficiency[$j]{deficiencytext}";
#     }     
     $org = &getSupplier(dbh=>$args{dbh},schema=>$args{schema},survID=>(defined($surveillanceid) ? $surveillanceid : 0),fiscalyear => $args{fiscalyear}) if ($intext eq 'E');
     my $issueto = ($issuedto) ? &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedto) : 0;
     my $issueby = ($issuedby) ? &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedby) : 0;
     my $displayid = $args{survID} == 0 ? 'New ' . ($args{int_ext} eq 'I' ? 'Internal ' : 'External ') . "Surveillance for FY " . &writeFiscalyearSelect(dbh=>$args{dbh},schema=>$args{schema}): getSurveillanceDisplayID(issuedby=>$issueby,issuedto=>$issueto,intext=>$intext,fiscalyear=>$args{fiscalyear},seq=>$seq);
     
     if($args{survID} > 0){
     $output .= "<script>document.forms[0].displayid.value='$displayid';</script> ";
     }
     $output .= "<br><table width=650 border=0 cellspacing=4 cellpadding=1>\n";
     $output .= "<tr><td colspan=3 align=center><b><font color=black>\n";
     $output .= " $displayid </font></b></td></tr>\n";
     $output .= "<tr height=10></tr>\n";
     $output .= "<tr>" . &addCol(value => "<b>Issued By: &nbsp;<font color=black>$issueby</font></b>") if ($args{survID} != 0);
     #$output .= "<tr>" . &addCol(value => "<b>Issued By: &nbsp;<font color=black><input type=radio name=issuedby value=28>OQA&nbsp;&nbsp;<input type=radio name=issuedby value=33>SNL<input type=radio name=issuedby value=17>M&O&nbsp;&nbsp;<input type=radio name=issuedby value=1>BSC&nbsp;&nbsp;</font></b>") if ($args{survID} == 0);
     $output .= "<tr>" . &addCol(value => "<b>Issued By: &nbsp;<font color=black><input type=radio name=issuedby value=28>OQA&nbsp;&nbsp;<input type=radio name=issuedby value=33>LL<input type=radio name=issuedby value=17>M&O&nbsp;&nbsp;</font></b>") if ($args{survID} == 0);
     $output .= &addCol(value => "<b>Issued To: &nbsp;<font color=black>" . &writeIssuedto(dbh=>$args{dbh},schema=>$args{schema},issuedto=>(defined($issuedto)? $issuedto : 0),int_ext=>$args{int_ext}) . "</font></b>");
    # $output .= &addCol(value => "<b>Initial Contact:&nbsp;&nbsp;<font color=black><input type=text name=contact size=18 maxlength=50 value=\"$contact\"></font></b>");
    $output .= &addCol(value => "<input type=hidden name=contact size=18 maxlength=50 value=\"$contact\">");
     $output .= &endRow();
     if (defined($reschedule)) {
     	$output .= "<tr>" . &addCol(value => "<b>Rescheduled:&nbsp;&nbsp;</b><input type=text name=rescheduletext size=80 maxlength=400 value='$reschedule'>",colspan=>$numColumns);
     }
     else {
     	if ($args{fiscalyear} >= 2004) {
        	$output .= "<tr>" . &addCol(value => "<b>Plan:&nbsp;&nbsp;</b><input type=text name=eststart size=14 maxlength=12 onBlur=checkForecast(value,this) value=" . ($eststart ? "'$eststart'" : "mm/yyyy" ) . ">",valign => "top");
        	#$output .= &addCol(value => "<b>Scheduled End:&nbsp;&nbsp;</b><input type=text name=estend size=14 maxlength=12 onBlur=checkDate(value,this) value=$estend>",valign=>"top");
        	$output .= &addCol(value => "<b>Status:&nbsp;&nbsp;</b>" . writeState(state=>"$state") . "</b>");
     		$output .= &endRow();
     	}
        $output .= "<tr>" . &addCol(value => "<b>Start Date:&nbsp;&nbsp;</b><input type=text name=start size=14 maxlength=12 onBlur=checkDate(value,this) value=$start>",valign => "top");
        $output .= &addCol(value => "<b>End Date:&nbsp;&nbsp;</b><input type=text name=end size=14 maxlength=12 onBlur=checkDate(value,this) value=$end>",valign=>"top");
     	$output .= &addCol(value => "<b>Report Approved:&nbsp;&nbsp;</b><input type=text name=completed size=14 maxlength=12 onBlur=checkDate(value,this) value=$completed>",valign=>"top");
     }
     
     $output .= &endRow();
     $output .= "<tr>" . &addCol(value => "<b>Team Lead:&nbsp;<font color=black>" . &writeTeamLead(dbh => $args{dbh}, schema => $args{schema},leadid=>(defined($leadid) ? $leadid : 0) ) . "</font></b>");
     $output .= &addCol(value => "<b>Team Members:&nbsp;<font color=black><input type=text name=team size=50 maxlength=200 value='$team'></font></b>",colspan=>2);
     $output .= &endRow();
     	#$output .= "<tr>" . &addCol(value => "<b>" . (($intext eq 'I') ? "Organization: " : "Supplier: " ) . "&nbsp;&nbsp;<font color=black>$org</font></b>",valign=>"top",colspan=>3);
     	#$output .= &endRow();
     	#$output .= "<tr>" . &addCol(value => "<b>Location:&nbsp;&nbsp;<font color=black>" . &writeOrgLocationSelect(dbh=>$args{dbh},schema=>$args{schema},survID=>$surveillanceid,fiscalyear => $args{fiscalyear},intext => $intext) . "</font></b>",valign=>"top",colspan=>3);
     	#$output .= &endRow();
     	
     $output .= &writeOrgLocationSelect(dbh=>$args{dbh},schema=>$args{schema},survID=>$surveillanceid,fiscalyear => $args{fiscalyear},intext => ($args{int_ext} ? $args{int_ext} : $intext));
     
     if ($args{fiscalyear} >= 2004) {
     	$output .= "<tr>" . &addCol(value => "<b>Surveillance Title:<br><input type=text name=title size=80 maxlength=150 value=\"$title\"></b>",valign=>"top",colspan=>3);
     	$output .= &endRow();
     }
     $output .= "<tr>" . &addCol(value => "<b>Surveillance Scope Summary:<br><textarea name=scope rows=3 cols=80 onBlur=checkLength(value,999,this);>$scope</textarea></b>",valign=>"top",colspan=>3);
     $output .= &endRow();
     if ($args{fiscalyear} <= 2003) {
     	$output .= "<tr>" . &addCol(value => "<b>Elements:&nbsp;&nbsp;<font color=black><input type=text name=elements size=50 maxlength=50 value=\"$elements\"></font></b>",valign=>"top",colspan=>3);
     	$output .= &endRow();
     } elsif ($args{fiscalyear} >= 2004) {
     	#$output .= "<tr>" . &addCol(value => &writeQARDcheckbox(qard=>"$qard"),valign=>"top",colspan=>3,fontSize=>2);
     	#$output .= &endRow();
     	#$output .= "<tr>" . &addCol(value => "<b>Procedures:&nbsp;&nbsp;<font color=black><input type=text name=procedures size=80 maxlength=250 value=\"$procedures\"></font></b>",valign=>"top",colspan=>3,fontSize=>2);
     	#$output .= &endRow();
     }
     if ($args{fiscalyear} <= 2003) {
     	$output .= "<tr>" . &addCol(value => &writeDeficiencies(dbh=>$args{dbh},schema=>$args{schema},survID=>$surveillanceid,fiscalyear => $args{fiscalyear}),valign=>"top",colspan=>3,fontSize=>3);
     	$output .= &endRow();
     }
     #$output .= "<tr>" . &addCol(value => "<b>Comments:<br><textarea name=status rows=3 cols=80 onBlur=checkLength(value,399,this);>$status</textarea>",valign=>"top",colspan=>3);
     $output .= &endRow();
     $output .= "<tr>" . &addCol(value => "<b>Accession #:&nbsp;&nbsp;<input type=text name=mol size=50 maxlength=25 value=\"$mol\"></b>",valign=>"top",colspan=>3);
     $output .= &endRow();
    if ($args{fiscalyear} >= 2004) {
    #	$output .= "<tr>" . &addCol(value => "<b>Adequacy of Requirements:</b>"); 
    #	$output .= &addCol(value => "<b>" . &writeResultsRadio(name=>"adequacy",results=>$adequacy) . "</b>",valign=>"top",colspan=>2,fontSize=>2);
    #	$output .= &endRow();
    # 	$output .= "<tr>" . &addCol(value => "<b>Implementation of Requirements:</b>");  
    # 	$output .= &addCol(value => "<b>" . &writeResultsRadio(name=>"implementation",results=>$implementation) . "</b>",valign=>"top",colspan=>2,fontSize=>2);
    # 	$output .= &endRow();
    # 	$output .= "<tr>" . &addCol(value => "<b>Effectiveness of Requirements:</b>"); 
    # 	$output .= &addCol(value => "<b>" . &writeResultsRadio(name=>"effectiveness",results=>$effectiveness) . "</b>",valign=>"top",colspan=>2,fontSize=>2);
    # 	$output .= &endRow();
    # 	$output .= "<tr>" . &addCol(value => "<b><font size=-1>Results:</font><br><font color=black><textarea name=results rows=3 cls=80 onBlur=checkLength(value,this);>$results</textarea></font></b>",valign=>"top",colspan=>3,fontSize=>3);
    # 	$output .= &endRow();
    # 	$output .= "<tr>" . &addCol(value => "<b>Overall Results:</b>"); 
    #	$output .= &addCol(value => "<b>" . &writeOverallResultsRadio(name=>"overall",results=>$overall) . "</b>",valign=>"top",fontSize=>2);
    #     	$output .= &endRow();
     }
#     my @deficiency = &getDeficiency(dbh=>$args{dbh},schema=>$args{schema},recordID=>$surveillanceid,fiscalyear => $args{fiscalyear}) if ($intext eq 'I');
#     for (my $j = 0; $j < $#deficiency; $j++) {
#     	$deficiency .= (($j != 0) ? "; " : "") . "$deficiency[$j]{deficiencytext}";
#     }
     if ($args{fiscalyear} >= 2004 && !defined($reschedule)) {
#     	$output .= "<tr>" . &addCol(value => "<b>Rescheduled to new fiscal year?<br><input type=radio name=rescheduled value=no checked onClick=showHideBlockSection('no')>No&nbsp;&nbsp;&nbsp;<input type=radio name=rescheduled value=yes onClick=showHideBlockSection('yes')>Yes</b>");
#     	$output .= &addCol(value => "<span id=Reschedule Style=Display:none;>\n<b>Reschedule Info:&nbsp;</b><input type=text name=rescheduletext value='$reschedule' size=50 maxlength=400></span>",colspan=>2);
#     	$output .= &endRow();
     }
    # $output .= "<tr><td colspan=3 align=center><a href=javascript:submitEditSurveillance('surveillance2','editResults',$surveillanceid)>Edit Results</a></td></tr>\n";
     $output .= &endTable . "\n";
     #$output .= "<br><br><center><a href=javascript:history.back() title='Click here to return to the previous page'><b>Return to Previous Page</b></a></center><br>\n";
     
 
     $output .= "<tr><td colspan='4' class='rowHeader'>Attachment(s):</td></tr>";
     if ($reportlink){
     my @filenamefinal = split("/", $reportlink);
     $output .= "<tr><td colspan='4' class='rowHeader'>$filenamefinal[1] &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type='button' value='Delete' name='Delete_Attachment' onClick=\"deleteAttachment('surveillance2','deleteAttachment',$surveillanceid,'$reportlink','$displayid','$dbname')\"><br><br></td></tr>";  
     }        
     $output .= "<tr><td colspan='4' class='rowAttachment'>Please attach any supporting attachments below</td></tr>";
     $output .= "<tr><td colspan='4' class='rowAttachment'>";
     $output .= "<input type='file' id='attachment' name='attachment'><br></td></tr>";
     $output .= "</table><br><center>\n";
     $output .= "<br>\n<center>\n<input type=button name=submitEdit value=Submit onClick=\"validateSurveillance('surveillance2','processUpdateSurveillance')\">\n" if ($args{survID} != 0);
     $output .= "<br>\n<center>\n<input type=button name=submitEdit value=Submit onClick=\"validateSurveillance('surveillance2','processCreateSurveillance')\">\n"  if ($args{survID} == 0);
     $output .= "</form>";
     if ($args{fiscalyear} <= 2003) {
     	$output .= "&nbsp;&nbsp;&nbsp;&nbsp;<input type=button name=submitEdit value=Cancel onClick=\"validateSurveillance('surveillance2','processCancelSurveillance')\">\n</center>\n";
     }
     return($output);
}
###################################################################################################################################
sub doEditReportlink {  # routine to edit a surveillance reportlink
###################################################################################################################################
     my %args = (
         survID => 0,
         title => 'Surveillance',
         userID => 0, # all
         @_,
     );
     
     my $output = "<table border=0 cellspacing=1 cellpadding=1 width=75% align=center>\n";
     $output .= "<br><br>\n";
     $output .= "<tr><td align=center><b>$args{displayid}<br><br></b></td></tr>\n";
     $output .= "<tr><td align=left><font size=-1><b>Enter Document Log Number for Correspondence Control Database - <br></b></font></td></tr>\n";
     $output .= "<tr><td align=left><input name=reportlink type=text size=100% value='$args{reportlink}'></td></tr>\n";
     $output .= "<tr><td align=center><br><input type=button onClick=submitFormCGIResults('surveillance2','processEditReportlink') value=\"Submit\"></td></tr>\n";
     $output .= "</table><br>\n";
     $output .= "<input type=hidden name=dbname value=CC>\n";
     $output .= "<br><br>\n";
     return($output);
}
###################################################################################################################################
sub writeQARDcheckbox {  # routine to write the checkboxes for QARD elements 
###################################################################################################################################
     my %args = (
        qard => '0000000000000000000000000', 
        @_,
     );
     my $i = 0;
     my $j = 0;
     my $selected = "";
     my $output = "<table cellpadding=0 cellspacing=1 border=0 width=650 align=center>\n";
     $output .= "<tr><td colspan=9><font size=-1><b>QA Elements:</b></font></td></tr>\n";
     foreach my $element ("1.0","2.0", "3.0", "4.0", "5.0", "6.0", "7.0", "8.0", "9.0", "10.0", "11.0", "12.0", "13.0",
	"14.0", "15.0", "16.0", "17.0", "18.0", "SI", "SII", "SIII", "SIV", "SV", "App C", "N/A") {
		$i++;
     		if ($i == 13) {
     			$i = 1;
     			$output .= "</tr>\n<tr>";
		}
		$output .= "<td><font size=-1><b><input type=checkbox name=qardElement value='$element' " . ((substr($args{qard},$j,1) == 1) ? "checked" : "") . ">$element</font></b></td>\n";
		$j++;
     }
     $output .= "</tr></table>\n";
     return($output);
}
###################################################################################################################################
sub writeQARD {  # routine to write the QARD elements
###################################################################################################################################
     my %args = (
        qard => '0000000000000000000000000', 
        @_,
     );
     
     my $i = 0;
     my $selected = "";
     my $output = "";
     foreach my $element ("1.0","2.0", "3.0", "4.0", "5.0", "6.0", "7.0", "8.0", "9.0", "10.0", "11.0", "12.0", "13.0",
	"14.0", "15.0", "16.0", "17.0", "18.0", "SI", "SII", "SIII", "SIV", "SV", "App C", "N/A") {
		$output .= (substr($args{qard},$i,1) == 1) ? (($output ne "") ? ", " : "") . "$element" : "";
		$i++;
     }
     return($output);
}
#####################################################################################################
sub writeTeamLead {
#####################################################################################################	
    my %args = (
	leadid => 0,
	@_,
    );	
    my @teamLeadList = &getTeamLeads(dbh => $args{dbh}, schema => $args{schema}, leadid => $args{leadid});
    my $output = "<select name=leadid size=1>\n<option value=0>TBD\n";
    for (my $j = 0; $j < $#teamLeadList; $j++) {
    	$output .= "<option value=$teamLeadList[$j]{id} " . (($args{leadid} == $teamLeadList[$j]{id}) ? "selected" : "") . ">$teamLeadList[$j]{name}";
    }
    $output .= "</select>\n";
    
    return($output);
}
#####################################################################################################
sub writeState {
#####################################################################################################
    my %args = (
	state => "Scheduled",
	@_,
    );	
    my @stateList = ("Scheduled","In Progress","Field Work Complete", "Complete", "Postponed", "Cancelled");
    my $output = "<select name=state size=1>\n<option value=''>\n";
    for (my $j = 0; $j <= $#stateList; $j++) {
    	$output .= "<option value='$stateList[$j]'" . (($args{state} eq $stateList[$j]) ? " selected" : "") . ">$stateList[$j]";
    }
    $output .= "</select>\n";
    
    return($output);
}
#####################################################################################################
sub writeResultsRadio {
#####################################################################################################
    my %args = (
	name => "results",
	results => "NA",
	@_,
    );	
    my @resultsList = ("SAT","UNSAT","NA");
    my $output = "";
    for (my $j = 0; $j <= $#resultsList; $j++) {
    	$output .= "<input type=radio name=$args{name} value=$resultsList[$j]" . (($args{results} eq $resultsList[$j]) ? " checked" : "") . ">$resultsList[$j]&nbsp;&nbsp;&nbsp;&nbsp;";
    }
    $output .= "</select>\n";
    
    return($output);
}
#####################################################################################################
sub writeOverallResultsRadio {
#####################################################################################################
    my %args = (
	name => "results",
	results => "NA",
	@_,
    );	
    my @resultsList = ("EFFECTIVE","INEFFECTIVE","NA");
    my $output = "";
    for (my $j = 0; $j <= $#resultsList; $j++) {
    	$output .= "<input type=radio name=$args{name} value=$resultsList[$j]" . (($args{results} eq $resultsList[$j]) ? " checked" : "") . ">$resultsList[$j]&nbsp;&nbsp;&nbsp;&nbsp;";
    }
    $output .= "</select>\n";
    
    return($output);
}
#####################################################################################################
sub writeIssuedto {
#####################################################################################################
    my %args = (
	issuedto => 0,
	@_,
    );	
    
    #print STDERR "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" .$args{issuedto}. "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" ;    
    
    # if ($args{survID} != 0)    {
    # my @IssuedtoList = &getLookupValues(dbh => $args{dbh}, schema => $args{schema}, tablename => 'organizations', value => 'id', text => 'abbr', where => " issued_to_list = 'T' or id = $args{issuedto} ");
    # }else{
    #my @IssuedtoList = &getLookupValues(dbh => $args{dbh}, schema => $args{schema}, tablename => 'organizations', value => 'id', text => 'abbr', where => " abbr in ('OCRWM','M&O','Lead Lab') " );
    # }
            
    my @IssuedtoList;
    
    if($args{int_ext} eq 'I' ){
    	@IssuedtoList = &getLookupValues(dbh => $args{dbh}, schema => $args{schema}, tablename => 'organizations', value => 'id', text => 'abbr', where => ($args{issuedto} != 0 ? " issued_to_list = 'T' or id = $args{issuedto} "  : " abbr in ('OCRWM','M&O','Lead Lab','OQA') " ));
    }else{
    	@IssuedtoList = &getLookupValues(dbh => $args{dbh}, schema => $args{schema}, tablename => 'organizations', value => 'id', text => 'abbr', where => " issued_to_list = 'T' or id = $args{issuedto} ");	
    }
     
    my $output = "<select name=issuedto size=1>\n<option value=0>\n";
    
    for (my $j = 0; $j < $#IssuedtoList; $j++) {
    	$output .= "<option value=$IssuedtoList[$j]{value} " . (($args{issuedto} == $IssuedtoList[$j]{value}) ? "selected" : "") . ">$IssuedtoList[$j]{text}";
    }
    
    $output .= "</select>\n";
    return($output);
}
####################################################################################################
sub writeDeficiencies {
####################################################################################################
    my %args = (
	survID => 0,
	fiscalyear => 50,
	@_,
    );
    my $output = "<table cellpadding=0 cellspacing=1 border=0 width=100% align=left>\n";
    my $deficiency;
    my @deficiency = &getDeficiency(dbh=>$args{dbh},schema=>$args{schema},recordID=>$args{survID},fiscalyear => $args{fiscalyear});
    for (my $j = 1; $j <= 3; $j++) {
    	$output .= "<tr><td>" . ($j == 1 ? "<b><font size=-1>Deficiencies: </font></b>" : "&nbsp;") . "</td>\n<td>"; ;
    	$output .= "<input type=text name=deficiency$j size=80 maxlength=200 value=\"$deficiency[$j-1]{deficiencytext}\"></td></tr>\n";
    }
    $output .= "</table>\n";

    return($output);
}
#####################################################################################################
sub writeBestPractice {
#####################################################################################################
    my %args = (
	survID => 0,
	fiscalyear => 50,
	single => 0,
	edit => 0,
	@_,
    );
    my $output = "<tr><td colspan=3><table  width=100% border=0 cellspacing=4 cellpadding=1>\n";
    $output .= "<tr>" . &addCol(value => "<b>Best Practice:&nbsp;</b>",colspan=>2,fontSize=>2,valign=>"top");
    $output .= &endRow();
    my @bpList = &getBestPractice(dbh => $args{dbh}, schema => $args{schema}, survID => $args{survID}, fiscalyear => $args{fiscalyear}, single=>$args{single});
    for (my $i = 0; $i < $#bpList; $i++) {
	my ($bpid,$bpsummary,$bpdate) = 
	($bpList[$i]{bpid},$bpList[$i]{bestpractice},$bpList[$i]{bpdate});  
      	$output .= "<tr><td width=100><b><font size=-1 color=black>&nbsp;&nbsp;&nbsp;" . ($args{edit} ? "<a href=javascript:submitEditSurveillance('conditionReports','editBestPractice',$args{survID},0,0,$bpid);>BP# $bpid</a>" : "BP# $bpid") . "</font></b></td>";
      	$output .= "<td><b><font size=-1 color=black>&nbsp;&nbsp;&nbsp;$bpsummary</font></b></td></tr>\n";
    }
    $output .= "</table></td></tr>\n";
    return($output);
}
#####################################################################################################
sub writeConditionReport {
#####################################################################################################
    my %args = (
	survID => 0,
	fiscalyear => 50,
	edit => 0,
	@_,
    );
    my $output = "<tr><td colspan=3><table width=100% border=0 cellspacing=4 cellpadding=1>\n";
    $output .= "<tr>" . &addCol(value => "<b>Condition Reports Issued:",colspan=>3,fontSize=>2,valign=>"top");
    $output .= &endRow();
    my @crList = &getConditions(dbh => $args{dbh}, schema => $args{schema}, survID => $args{survID}, fiscalyear => $args{fiscalyear});
    for (my $i = 0; $i < $#crList; $i++) {
	my ($crid,$crnum,$crlevel,$crsummary,$crdate) = 
	($crList[$i]{crid},$crList[$i]{crnum},$crList[$i]{crlevel},$crList[$i]{crsummary},$crList[$i]{crdate}); 
	if ($crnum eq '0') {
	      	$output .= "<tr><td valign=top colspan=3><b><font size=-1 color=black>&nbsp;&nbsp;&nbsp;No CRs Issued</font></b></td></tr>";	
	}
	else {
      		$output .= "<tr><td valign=top width=70><b><font size=-1 color=black>&nbsp;&nbsp;&nbsp;" . ($args{edit} ? "<a href=javascript:submitEditSurveillance('conditionReports','editCondition',$args{survID},$crid);>$crnum</a>" : "$crnum") . "</font></b></td>";
      		$output .= "<td valign=top width=30><b><font size=-1 color=black>Level:&nbsp;" . ($crlevel eq "N" ? "N/A" : "$crlevel") . "</font></b></td>";
      		$output .= "<td><b><font size=-1 color=black>$crsummary</font></b></td></tr>";
      	}
    }
    $output .= "</table></td></tr>\n";
    return($output);
}
#####################################################################################################
sub writeConditionReportFollowup {
#####################################################################################################
    my %args = (
	survID => 0,
	fiscalyear => 50,
	single => 0,
	edit => 0,
	@_,
    );
    my $output = "<tr><td colspan=2><table width=100% border=0 cellspacing=4 cellpadding=1>\n";
    $output .= "<tr>" . &addCol(value => "<b>Follow-up to Condition Reports:&nbsp;</b>",colspan=>2,fontSize=>2,valign=>"top");
    $output .= &endRow();
    my @crfuList = &getFollowups(dbh => $args{dbh}, schema => $args{schema}, survID => $args{survID}, fiscalyear => $args{fiscalyear},single=>$args{single});
    for (my $i = 0; $i < $#crfuList; $i++) {
	my ($crfuid,$crnum,$crfunum,$crfusummary) = 
	($crfuList[$i]{crid},$crfuList[$i]{crnum},$crfuList[$i]{followupnum},$crfuList[$i]{followup});  
	$output .= "<tr><td valign=top width=104><b><font size=-1 color=black>&nbsp;&nbsp;&nbsp;" . ($args{edit} ? "<a href=javascript:submitEditSurveillance('conditionReports','editFollowup',$args{survID},$crfuid,$crfunum);>$crnum</a>" : "$crnum") . "</font></b></td>";
	$output .= "<td><b><font size=-1 color=black>$crfusummary</font></b></td></tr>";
    }
    $output .= "</table></td></tr>\n";
    return($output);
}
#####################################################################################################
sub writeOrgLocationSelect {
#####################################################################################################
    my %args = (
	survID => 0,
	fiscalyear => 50,
	intext => 'I',
	@_,
    );   
    my @org;
    my @suborg;
    my $org = 0;
    my $counter = $args{intext} eq 'I' ? 3 : 1;
    my $output = "";
    if ($args{intext} eq 'I') {
     	@org = &getOrganization(dbh=>$args{dbh},schema=>$args{schema},survID=>(defined($args{survID}) ? $args{survID} : 0) ,fiscalyear => $args{fiscalyear});
     	@suborg = &getSuborganization(dbh=>$args{dbh},schema=>$args{schema},survID=>(defined($args{survID}) ? $args{survID} : 0),fiscalyear => $args{fiscalyear});
    } else {
     	@org = &getSupplier(dbh=>$args{dbh},schema=>$args{schema},survID=>(defined($args{survID}) ? $args{survID} : 0),fiscalyear => $args{fiscalyear});
    }
    my @location = &getLocation(dbh=>$args{dbh},schema=>$args{schema},survID=>(defined($args{survID}) ? $args{survID} : 0),fiscalyear => $args{fiscalyear});
    $output .= "<tr><td colspan=3><b><font size=-1>" . (($args{intext} eq 'I') ? "Organization(s): " : "Supplier: " ) . "&nbsp;&nbsp;</font></b></td></tr>\n<tr>";
    for (my $i = 0; $i < $counter; $i++) {
    	my $orgid = defined($org[$i]{orgid}) ? $org[$i]{orgid} : 0;
    	my $supplierid = defined($org[$i]{supplier}) ? $org[$i]{supplierid} : 0;
    	my $suborgid = defined($suborg[$i]{suborgid}) ? $suborg[$i]{suborgid} : 0;
    	my @orgLocationList = &getOrgLocation(dbh => $args{dbh}, schema => $args{schema}, survID => $args{survID}, fiscalyear => $args{fiscalyear},organizationID => $orgid,supplierID => $supplierid,intext => $args{intext});
    	if ($args{intext} eq 'I') {
    		$output .= "<td>\n";
    		if($i>0){
    		$output .= "<select name=\"org$i\" size=1" . (($i == 0) ? " onChange=showHideBlockSection(value)" : "") . " style='visibility:hidden;'>\n";
    		}else{
    		$output .= "<select name=\"org$i\" size=1" . (($i == 0) ? " onChange=showHideBlockSection(value)" : "") . ">\n";	
    		}
    		#$output .= "<option value=0>\n" if ($i > 0);
    		$output .= "<option value=0>\n";
    		for (my $j = 0; $j < $#orgLocationList; $j++) {
    			if (($orgid) && $orgid == $orgLocationList[$j]{orgid}) {
    				$output .= "<option value=$orgLocationList[$j]{orgid} selected>$orgLocationList[$j]{orgabbr}\n";
    			} elsif (defined($orgLocationList[$j]{orgid})) {
    				$output .= "<option value=$orgLocationList[$j]{orgid}>$orgLocationList[$j]{orgabbr}\n";
    			}
    		}
    		$output .= "</select>\n";
    		$output .= "</td>\n";    		
    	} else {
    		$output .= "<td colspan=3><select name=\"supplier\" size=1>\n";
    		for (my $j = 0; $j < $#orgLocationList; $j++) {
    			if ($org[0]{supplierid} == $orgLocationList[$j]{supplierid}) {
    				$output .= "<option value=$orgLocationList[$j]{supplierid} selected>$orgLocationList[$j]{supplier}\n";
    			} elsif (defined($orgLocationList[$j]{supplierid})) {
    				$output .= "<option value=$orgLocationList[$j]{supplierid}>$orgLocationList[$j]{supplier}\n";
    			}
    		}
    		$output .= "</select></td>\n";    	
    	}
    }
    $output .= &endRow();
    if ($args{intext} eq 'I') {	
        $output .= "<tr style='display:none;'><td colspan=3 ><b><font size=-1>BSC Suborganization:&nbsp;&nbsp;</font></b></td></tr>\n";
        	my $i = 1;
        	my @suborg = &getSuborganization(dbh => $args{dbh}, schema => $args{schema}, survID=>(defined($args{survID}) ? $args{survID} : 0), fiscalyear => $args{fiscalyear});
        	my $orgid = defined($org[0]{orgid}) ? $org[0]{orgid} : 0;
        	my $suborgid = defined($suborg[0]{suborgid}) ? $suborg[0]{suborgid} : 0;
    		my @suborgList = &getSuborganization(dbh => $args{dbh}, schema => $args{schema}, survID=>(defined($args{survID}) ? $args{survID} : 0), fiscalyear => $args{fiscalyear});
    		my $suborgidList = "(0";
    		for my $suborgids (0 .. $#suborg-1) {
    		    $suborgidList .= ",$suborg[$suborgids]{suborgid}";
    		    }
               $suborgidList .= ")";
    		my @orgLocationList = &getOrgLocation(dbh => $args{dbh}, schema => $args{schema}, survID => $args{survID}, fiscalyear => $args{fiscalyear},intext => $args{intext} , where => " active = 'T' or id in $suborgidList ");
    		
    		@suborgList = sort  { $a->{suborg} cmp $b->{suborg} } @suborgList;
    		
    		$output .= "<tr><td colspan=3 style='display:none;'><select name=\"suborg\" size=1 multiple" . (($orgid != 1) ? " disabled" : "") . " >\n<option value=0>\n";
    		for (my $j = 1; $j <= $#orgLocationList; $j++) {
    			if (($suborgList[$i]{suborgid}) && $suborgList[$i]{suborgid} == $orgLocationList[$j]{suborgid}) {
    				$output .= "<option value=$orgLocationList[$j]{suborgid} selected>$orgLocationList[$j]{suborg}\n";
    				$i++;
    			} elsif (defined($orgLocationList[$j]{suborgid})) {
    				$output .= "<option value=$orgLocationList[$j]{suborgid}>$orgLocationList[$j]{suborg}\n";
    			}
    		}
    		$output .= "</select>&nbsp;&nbsp;<font size=-1><i>select 0, 1, or many - for BSC surveillances only</i></font></td>\n";

    	$output .= &endRow();
    }
    $output .= "<tr><td colspan=3><b><font size=-1>Location(s):&nbsp;&nbsp;</font></b></td></tr>\n<tr>";
    #for (my $i = 0; $i < 3; $i++) {
    for (my $i = 0; $i < 1; $i++) {
    	my $locationid = defined($location[$i]{id}) ? $location[$i]{id} : 0;
    	my @orgLocationList = &getOrgLocation(dbh => $args{dbh}, schema => $args{schema}, survID => $args{survID}, fiscalyear => $args{fiscalyear},locationID => $locationid);
    	$output .= "<td><select name=\"loc$i\" size=1>\n" . (($i > 0) ? "<option value=0>\n" : "");
    	for (my $j = 0; $j < $#orgLocationList; $j++) {
    		if (defined($orgLocationList[$j]{locationid}) && $locationid == $orgLocationList[$j]{locationid}) {
    			$output .= "<option value=$orgLocationList[$j]{locationid} selected>$orgLocationList[$j]{city} $orgLocationList[$j]{province}, $orgLocationList[$j]{state}\n";
    		} elsif (defined($orgLocationList[$j]{locationid})) {
    			$output .= "<option value=$orgLocationList[$j]{locationid}>$orgLocationList[$j]{city} $orgLocationList[$j]{province}, $orgLocationList[$j]{state}\n";
    		}
    	}
    	$output .= "</select></td>\n";
    }
    $output .= &endRow();

    return($output);
}
####################################################################################################
sub getSurveillanceDisplayID {
####################################################################################################
    my %args = (
	survID => 0,
	fiscalyear => 50,
	intext => 'I',
	seq => 0,
	issuedby => "",
	issuedto => "",
	@_,
    );   

    my $id = "";
    if ($args{issuedby} eq "OQA") {
    	$id = $args{fiscalyear} <= 2001 ? "$args{issuedto}-SR-" . (lpadzero(substr($args{fiscalyear},-2,2),2)) . "-" . (lpadzero($args{seq},2)) : 
    	($args{fiscalyear} == 2002 ? ($args{seq} < 10 ? "$args{issuedto}" . ($args{seq} <= 3 ? "-SR-" . (lpadzero(substr($args{fiscalyear},-2,2),2)) . "-" . lpadzero($args{seq},3) : "-" . (lpadzero(substr($args{fiscalyear},-2,2),2)) . "-S-" . lpadzero($args{seq},2)) : "$args{issuedby}-" . (lpadzero(substr($args{fiscalyear},-2,2),2)) . "-S-" . lpadzero($args{seq},2)) : 
    	"$args{issuedby}-S$args{intext}-" . (lpadzero(substr($args{fiscalyear},-2,2),2)) . "-" . lpadzero($args{seq},3));
    }
    elsif ($args{issuedby} eq "BSC") {
    	$id = $args{fiscalyear} <= 2002 ? "BSCQA-" . (lpadzero(substr($args{fiscalyear},-2,2),2)) . "-S-" . lpadzero($args{seq},3) : "BQA-S$args{intext}-" . ((lpadzero(substr($args{fiscalyear},-2,2),2)) . "-" . lpadzero($args{seq},3));
    }
        elsif ($args{issuedby} eq "M&O") {
    	$id = $args{fiscalyear} <= 2002 ? "MQA-" . (lpadzero(substr($args{fiscalyear},-2,2),2)) . "-S-" . lpadzero($args{seq},3) : "MQA-S$args{intext}-" . ((lpadzero(substr($args{fiscalyear},-2,2),2)) . "-" . lpadzero($args{seq},3));
    }
    elsif ($args{issuedby} eq "SNL") {
        $id = "SNL-S$args{intext}-" . ((lpadzero(substr($args{fiscalyear},-2,2),2)) . "-" . lpadzero($args{seq},3));
    }  
    elsif ($args{issuedby} eq "Lead Lab") {
        $id = "LQA-S$args{intext}-" . ((lpadzero(substr($args{fiscalyear},-2,2),2)) . "-" . lpadzero($args{seq},3));
    } 
    return ($id);
}
####################################################################################################
sub writeTableHeader {
####################################################################################################
    my %args = (
	issuedby => "",
	flag => 0,
	@_,
    );   
    
    my $output = "";
    #$output .= &endTable if ($args{flag} != 0);
    #$output .= "<table cellpadding=2 cellspacing=0 border=1 align=center width=600>\n";
    $output .= "<tr bgcolor=#B0C4DE>\n";
    $output .= &addCol (value => "<font size=+1>$args{issuedby} Surveillances</font>", colspan=>4,align=>"center");
    $output .= &endRow();
    $output .= &startRow (bgColor => "#f0f0f0");
    $output .= &addCol (value => "<b>ID</b>",align=>"center");
    $output .= &addCol (value => "<b>Team Lead</b>",align=>"center");
    $output .= &addCol (value => "<b>Scope</b>",align=>"center");
    $output .= &addCol (value => "<b>Status</b>",align=>"center");
    $output .= &endRow();
    
    return ($output);
}
####################################################################################################
sub writeTableHeaderXsl {
####################################################################################################
    my %args = (
	issuedby => "",
	flag => 0,
	@_,
    );   
    
    my $output = "";
    $output .= &endTable if ($args{flag} != 0);
    $output .= "<table cellpadding=2 cellspacing=0 border=1 align=center width=600>\n";
    $output .= "<tr bgcolor=#B0C4DE>\n";
    $output .= &addCol (value => "<font size=+1>$args{issuedby} Surveillances</font>", colspan=>13,align=>"center");
    $output .= &endRow();
    $output .= &startRow (bgColor => "#f0f0f0");
    $output .= &addCol (value => "<b>Issued By</b>",align=>"center");
    $output .= &addCol (value => "<b>Issued To</b>",align=>"center");
    $output .= &addCol (value => "<b>Fiscal Year</b>",align=>"center");
    $output .= &addCol (value => "<b>Number</b>",align=>"center");
    $output .= &addCol (value => "<b>Start</b>",align=>"center");
    $output .= &addCol (value => "<b>End</b>",align=>"center");
    $output .= &addCol (value => "<b>Team Lead</b>",align=>"center");
    $output .= &addCol (value => "<b>Organization</b>",align=>"center");
    $output .= &addCol (value => "<b>Location</b>",align=>"center");
    $output .= &addCol (value => "<b>Title</b>",align=>"center");
    $output .= &addCol (value => "<b>Scope</b>",align=>"center");
    $output .= &addCol (value => "<b>Status</b>",align=>"center");
    $output .= &addCol (value => "<b>Report Approved</b>",align=>"center");
    $output .= &endRow();
    
    return ($output);
}
############################
sub writeFiscalyearSelect{
############################
    my %args = (
	@_,
    );   
    my $currentFiscalyear = &getCurrentFiscalyear(dbh=>$args{dbh});
    my @fiscalyearList = &getLookupValues(dbh => $args{dbh}, schema => $args{schema}, tablename => 'fiscal_year', value => 'fiscal_year', text => 'fiscal_year',where => 'fiscal_year >= 2004'); 
    my $output = "";
    $output .= "<select name=newfyselect size=1>\n";
    for (my $j = 0; $j < $#fiscalyearList; $j++) {
    	$output .= "<option value=" . substr($fiscalyearList[$j]{value},-2,2) . " " . (($currentFiscalyear == $fiscalyearList[$j]{value}) ? "selected" : "") . ">$fiscalyearList[$j]{text}";
    }
    $output .= "</select>\n";
	
    return ($output);
}
####################################################################################################################################

###################################################################################################################################


1; #return true
