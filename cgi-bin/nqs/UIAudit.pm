##
# $Source: /usr/local/homes/higashis/www/gov.doe.ocrwm.ydappdev/rcs/qa/perl/RCS/UIAudit.pm,v $
#
# $Revision: 1.34 $ 
#
# $Date: 2009/10/02 00:08:55 $
#
# $Author: higashis $
#
# $Locker: higashis $
#
# $Log: UIAudit.pm,v $
# Revision 1.34  2009/10/02 00:08:55  higashis
# fixed endTable issue
#
# Revision 1.33  2009/09/30 22:34:36  higashis
# edit link in doView... section
#
# Revision 1.32  2009/09/22 18:20:47  higashis
# major version release.
#
# Revision 1.31  2009/03/24 20:47:39  patelr
# added delete attachment function
#
# Revision 1.30  2009/01/28 00:21:30  patelr
# edited doViewAudit to allow internal leads to edit QA reports.  Bug fixed.
#
# Revision 1.29  2009/01/16 21:08:34  patelr
# revised doEditAudit to include attachment code
#
# Revision 1.26  2008/10/21 19:15:53  higashis
# *** empty log message ***
#
# Revision 1.24  2008/10/20 17:50:08  higashis
# for excel integrated report.
#
# Revision 1.23  2007/10/26 17:53:26  dattam
# All occurences of "QARD" changed to "QA".
#
# Revision 1.22  2007/10/03 16:50:28  dattam
# sub doBrowseAudit modified so that for FY08, the browse screen integrates the Internal Audits issued by "SNL", "BSC", or "OCRWM" under one header, and separates the audits issued by EM/RW
#
# Revision 1.21  2007/09/26 17:38:36  dattam
# Sub getExternalAuditDisplayID modified to change the External Audit numbering scheme for FY 2008
# Sub writeTableHeader modified for FY 2008 external audits, Sub doViewAudit modified not to show "Issued By" for FY 2008 external audits
# Sub doBrowseAudit modified so that there is no separation of external audits between the issued by organizations
#
# Revision 1.20  2007/08/20 18:33:32  dattam
# Modified javascript function validateAudit to check for radio button "rescheduled"
#
# Revision 1.19  2007/04/23 16:48:27  dattam
# sub doViewAudit modified to allow SNL as an editing organization, to allow edit privilege to selected user groups
# Added new radio button called "Overall Results"
# sub writeState, doBrowseAudit modified to change the Status drop down value, and to change value of status
#
# Revision 1.18  2005/10/31 23:10:05  starkeyj
# modified javascript subroutine validateAudit to make sure otherID is entered for assessments of type 'other'
# modified doBrowseAudit to select and dipslay assessments of type 'other'
# modified getInitialValues to include otherID
# modified doViewAudit to add a the qardstring as a parameter when calling writeConditionReport
# modified writeConditionReport to include qard string
# added new subroutine doEditAuditOther for entering assessments of type 'other'
#
# Revision 1.17  2005/10/04 17:28:53  starkeyj
# modified getInternalAuditDisplayID  to remove "C" and "P" from audit display and display OQA for OCRWM for years gt 2005
#
# Revision 1.16  2005/07/12 15:12:32  dattam
# modified subroutine writeSuborgSelect - added SuborgidList string while calling getOrgLocation.
#
# Revision 1.15  2005/02/02 20:44:08  starkeyj
# modified the javascript function reportWindow to check for the type of database or report to display
# modified doViewAudit to change label for Add/Edit ReportLog No and added an if condition before displaying the link
# modified doEditReportLink to remove the choice for entry to the ATS database
#
# Revision 1.14  2005/01/10 00:26:56  starkeyj
# modified the following subroutines to select or dicplay the MOL number:  getInitialValues, doBrowseAudit,
# doViewAudit, doEditAudit
# modified doEditAudit, dobrowseAudit, and writeState for BSC external audit status drop down and display
#
# Revision 1.13  2004/12/20 16:56:41  starkeyj
# modified writeConditionReports to check for CR Numbers entered as 0 and display the text No CRs Issued
# and does not provide a link to edit the record
#
# Revision 1.12  2004/10/21 18:58:16  starkeyj
# modified dobrowseAudit to separate OQA and BSc audits
# modified writeTableHeader to display issuedBy in header for external audits
#
# Revision 1.11  2004/09/29 21:36:01  starkeyj
# modified writeIssuedBy and calls to writeIssuedBy to pass table parameter
# removed <br> from status formula in doBrowseAudit
#
# Revision 1.10  2004/09/16 20:05:55  starkeyj
# modified doEditAudit to add a drop down to select OCRWM or BSCX as the issuer of an internal audit
# modified writeIssuedBy subroutine to change the text OQA to OCRWM
# modified getInternalAuditDisplayID to check for BSC as issuer in years 2005 and greater
# These changes are for Work Request 15, aka SCR 82
#
# Revision 1.9  2004/08/26 22:36:15  starkeyj
# modified doViewAudit to add quotation marks around javascript call to submitEditReport
#
# Revision 1.8  2004/08/18 17:31:57  starkeyj
# modified editReportLink to include a choice of database to retrieve reports and added form verification
# modified writeFiscalyearSelect to remove 'onChange' javascript function call
# modified all calls relating to report links to add the new database field
#
# Revision 1.7  2004/07/01 22:02:55  starkeyj
# modified doViewAudit to add edit privileges to OQA for EM audits
#
# Revision 1.6  2004/06/28 14:13:59  starkeyj
# modified writeTeamLead to add a table parameter to pass to the getTeamLeads subroutine
# modified doEditAudit to add a table parameter to pass to the writeTeamLead subroutine
#
# Revision 1.5  2004/05/30 22:00:00  starkeyj
# modified doBrowseAudit to include team members for all audits and location for EM/RW and external audits
# modified doViewAudit to add a 'Back to Previous' link
#
# Revision 1.4  2004/04/19 19:55:17  starkeyj
# modified writeConditionReport to add 'N/A'
#
# Revision 1.3  2004/04/19 19:42:33  starkeyj
# modified viewAudit to show $notes instead of the word 'status'
#
# Revision 1.2  2004/04/07 16:15:06  starkeyj
# removed the OCRWM and EM choices from issuedby list on new external audits
#
# Revision 1.1  2004/04/07 15:08:05  starkeyj
# Initial revision
#
#
#
package UIAudit;
use strict;
#use SharedHeader qw(:Constants);
#use UI_Widgets qw(:Functions);
#use DBShared qw(:Functions);
use OQA_Widgets qw(:Functions);
use OQA_specific qw(:Functions);
use NQS_Header qw(:Constants);
use Tables qw(:Functions);
use DBAudit qw(:Functions);
use DBConditionReports qw(:Functions);
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
      &doHeader                  	&doFooter          	&getInitialValues	
      &doBrowseAudit			&doEditAudit		&doCreateSurveillance	
      &doViewAudit			&doEditResults		&doEditReportlink
      &doGetAvailableSequence		&writeQARDcheckbox      &doEditAuditOther
      &doBrowseAuditXsl		&doHeaderXsl			
    )]
);
%EXPORT_TAGS =( 
    Functions => [qw(
      &doHeader                  	&doFooter          	&getInitialValues	
      &doBrowseAudit			&doEditAudit		&doCreateSurveillance	
      &doViewAudit			&doEditResults		&doEditReportlink
      &doGetAvailableSequence           &writeQARDcheckbox      &doEditAuditOther
      &doBrowseAuditXsl		&doHeaderXsl		
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
       auditID => (defined($mycgi->param("auditID"))) ? $mycgi->param("auditID") : 0,
       selection => (defined($mycgi->param("audit_selection"))) ? $mycgi->param("audit_selection") : "all",
       fiscalyear => (defined($mycgi->param("fiscalyear"))) ? $mycgi->param("fiscalyear") : "50",
       fy => (defined($mycgi->param("fy"))) ? $mycgi->param("fy") : $mycgi->param("fiscalyear"),
       leadid => (defined($mycgi->param("leadid"))) ? $mycgi->param("leadid") : 0,
       team => (defined($mycgi->param("team"))) ? $mycgi->param("team") : "",
       scope => (defined($mycgi->param("scope"))) ? $mycgi->param("scope") : "",
       otherid => (defined($mycgi->param("otherid"))) ? $mycgi->param("otherid") : "",
       forecast => (defined($mycgi->param("forecast"))) ? $mycgi->param("forecast") : "",
       start => (defined($mycgi->param("start"))) ? $mycgi->param("start") : "",
       end => (defined($mycgi->param("end"))) ? $mycgi->param("end") : "",
       completed => (defined($mycgi->param("completed"))) ? $mycgi->param("completed") : "",
       effectiveness => (defined($mycgi->param("effectiveness"))) ? $mycgi->param("effectiveness") : "",
       adequacy => (defined($mycgi->param("adequacy"))) ? $mycgi->param("adequacy") : "",
       implementation => (defined($mycgi->param("implementation"))) ? $mycgi->param("implementation") : "",
       state => (defined($mycgi->param("state"))) ? $mycgi->param("state") : "",
       title => (defined($mycgi->param("title"))) ? $mycgi->param("title") : "",
       org0 => (defined($mycgi->param("org0"))) ? $mycgi->param("org0") : 0,
       org1 => (defined($mycgi->param("org1"))) ? $mycgi->param("org1") : 0,
       org2 => (defined($mycgi->param("org2"))) ? $mycgi->param("org2") : 0,
       org3 => (defined($mycgi->param("org3"))) ? $mycgi->param("org3") : 0,
       org4 => (defined($mycgi->param("org4"))) ? $mycgi->param("org4") : 0,
       org5 => (defined($mycgi->param("org5"))) ? $mycgi->param("org5") : 0,
       org6 => (defined($mycgi->param("org6"))) ? $mycgi->param("org6") : 0,
       loc0 => (defined($mycgi->param("loc0"))) ? $mycgi->param("loc0") : 0,
       loc1 => (defined($mycgi->param("loc1"))) ? $mycgi->param("loc1") : 0,
       loc2 => (defined($mycgi->param("loc2"))) ? $mycgi->param("loc2") : 0,
       loc3 => (defined($mycgi->param("loc3"))) ? $mycgi->param("loc3") : 0,
       loc4 => (defined($mycgi->param("loc4"))) ? $mycgi->param("loc4") : 0,
       loc5 => (defined($mycgi->param("loc5"))) ? $mycgi->param("loc5") : 0,
       loc6 => (defined($mycgi->param("loc6"))) ? $mycgi->param("loc6") : 0,
       supplier => (defined($mycgi->param("supplier"))) ? $mycgi->param("supplier") : 0,
       product => (defined($mycgi->param("product"))) ? $mycgi->param("product") : "",
       suborgstring => (defined($mycgi->param("suborgstring"))) ? $mycgi->param("suborgstring") : 0,
       notes => (defined($mycgi->param("notes"))) ? $mycgi->param("notes") : "",
       issuedto => (defined($mycgi->param("issuedto"))) ? $mycgi->param("issuedto") : 0,
       issuedby => (defined($mycgi->param("issuedby"))) ? $mycgi->param("issuedby") : 0,
       status => (defined($mycgi->param("status"))) ? $mycgi->param("status") : "",
       qardstring => (defined($mycgi->param("qardstring"))) ? $mycgi->param("qardstring") : "",
       procedures => (defined($mycgi->param("procedures"))) ? $mycgi->param("procedures") : "",
       mol => (defined($mycgi->param("mol"))) ? $mycgi->param("mol") : "",
       rescheduletext => (defined($mycgi->param("rescheduletext"))) ? $mycgi->param("rescheduletext") : "",
       results => (defined($mycgi->param("results"))) ? $mycgi->param("results") : "",
       overall => (defined($mycgi->param("overall"))) ? $mycgi->param("overall") : "",
       type => (defined($mycgi->param("type"))) ? $mycgi->param("type") : "I",
       auditType => (defined($mycgi->param("auditType"))) ? $mycgi->param("auditType") : "",
       int_ext => (defined($mycgi->param("int_ext"))) ? $mycgi->param("int_ext") : 0,
       newfyselect => (defined($mycgi->param("newfyselect"))) ? $mycgi->param("newfyselect") : "0",
       newCRnum => (defined($mycgi->param("newCRnum"))) ? $mycgi->param("newCRnum") : 0,
       crcount => (defined($mycgi->param("crcount"))) ? $mycgi->param("crcount") : 0,
       newFUnum => (defined($mycgi->param("newFUnum"))) ? $mycgi->param("newFUnum") : 0,
       fucount => (defined($mycgi->param("fucount"))) ? $mycgi->param("fucount") : 0,
       table => (defined($mycgi->param("table"))) ? $mycgi->param("table") : "",
       reportlink => (defined($mycgi->param("reportlink"))) ? $mycgi->param("reportlink") : '',
       dbname => (defined($mycgi->param("dbname"))) ? $mycgi->param("dbname") : '',
       displayid => (defined($mycgi->param("displayid"))) ? $mycgi->param("displayid") : '',
       tag => (defined($mycgi->param("tag"))) ? $mycgi->param("tag") : "",
       seq => (defined($mycgi->param("seq"))) ? $mycgi->param("seq") : 0,
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
    function submitEditAudit(script, command, audit, table, crid, funum, bpid) {
    	if (command == 'viewAudit' || command == 'browse') {document.$form.tag.value = '';}
        var generatedfrom = ((table == "internal") ? 'IA' : 'EA');
        document.$form.command.value = command;
        document.$form.auditID.value = audit;
        document.$form.generatorid.value = audit;
        document.$form.table.value = table;
        document.$form.generatedfrom.value = generatedfrom;
        document.$form.CRid.value = crid;
        document.$form.bpnum.value = bpid;
        document.$form.funum.value = funum;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'workspace';
        	//alert(document.$form.displayid.value);
        document.$form.submit();
    }
    function submitGetSequence(script, command, table, type) {
        document.$form.command.value = command;
        document.$form.table.value = table;
        document.$form.type.value = type;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'control';
        document.$form.submit();
    }
    function submitEditReport(script, command, audit, reportlink,displayid,table,dbname) {
        document.$form.command.value = command;
        document.$form.auditID.value = audit;
        document.$form.table.value = table;
        document.$form.reportlink.value = reportlink;
        document.$form.dbname.value = dbname;
        document.$form.displayid.value = displayid;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'workspace';
        document.$form.submit();
    }
    function submitReportLink (script, command) {
	document.$form.cgiaction.value = command;
	document.$form.action = '$path' + script + '.pl';
	document.$form.target = 'control';
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
		if (document.$form.suborg) {
			document.$form.org1.value = '';
			document.$form.org2.value = '';
			document.$form.org1.disabled = true;
			document.$form.org2.disabled = true;
			document.$form.suborg.disabled = false;
		}

	}
	else {
		if (document.$form.suborg) {
			document.$form.org1.disabled = false;
			document.$form.org2.disabled = false;
			document.$form.suborg.selectedIndex = 0; // so it looks like all items were deselected
			document.$form.suborg.selectedIndex = -1; // and so they are
			document.$form.suborg.disabled = true;
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
    function availableIDs () {
	document.$form.action = '$path' + 'audit2.pl';
	document.$form.cgiaction.value = 'available_IDs';
	document.$form.target = 'control';
	document.$form.submit();
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
   
   	if (isBlank(val)) {val = 'mm/yyyy';}
   	if (val != 'mm/yyyy') {
   		datestr = val.split("/");
   		if (datestr[0] == val) {
   			alert(datestr[0] + ' is not valid');
   			valid = 0;
   		}
   		else if (!(datestr[0] > 0 && datestr[0] < 13)) {
   			alert(datestr[0] + ' is not a valid month');
   			valid = 0;
   		}
   		else if (!(isnumeric(datestr[1]))) {
		   	alert(datestr[1] + ' is not a valid year');
		   	valid = 0;
   		}
   	}
  	if (!valid) {e.focus();}
    }
    function isnumeric(s) {
	if (s.length != 4) return false;
 	for(var i = 0; i < s.length; i++) {
	  var c = s.charAt(i);
	  if ((c < '0') || (c > '9')) return false;
	}
 	return true;
    }
    function isBlank(s) {
	for (var i=0; i<s.length; i++) {
  		var c = s.charAt(i);
  		if ((c != ' ') && (c != '\\n') && (c != '\\t') ) {return false;}
	}
	return true;
    }
    function deleteAuditAttachment(script, command, audit, reportlink,displayid,table,dbname) {
        document.$form.command.value = command;
        document.$form.auditID.value = audit;
        document.$form.table.value = table;
        document.$form.reportlink.value = reportlink;
        document.$form.dbname.value = dbname;
        document.$form.displayid.value = displayid;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'workspace';
        document.$form.submit();
    }
    function validateAudit(script, command) {
        //alert(script);
        //alert(command);
        //alert(document.$form.table.value);
    	var errors = "";
    	var msg;
	var qardstr = "";
	var suborgstr = "";
	var type = 0;
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
    	if (document.$form.auditType) {
    		if (document.$form.table.value != "internal") {	
	    		for (var i=0;i<document.$form.auditType.length;i++) {
	    			if (document.$form.auditType[i].checked) {type = 1;}
	    		}
	    		if (!type) {
	    			errors += "- An Audit Type must be selected\\n";
	    		}
    		}
    	}
    	
    	if (document.$form.otherid) {
    	    if (document.$form.otherid.value == '')
    	        {errors += "- An Other Id value must be supplied\\n";}
    	}
    	
	if ( (document.$form.forecast.value == 'mm/yyyy' || isBlank(document.$form.forecast.value) || document.$form.forecast.value.length == 0)
	   && (isBlank(document.$form.start.value) || document.$form.start.value.length == 0) )
	{errors += "- A 'Plan' Date and/or 'Start Date' must be supplied\\n";}
	
	if (document.$form.table.value == "internal") {
		//if (document.$form.org0.value == 0 && document.$form.loc0.value == 0 ) {errors += "- Organizations / Locations must be selected\\n";}
	}
	
	if (document.$form.table.value == "external") {
		if (document.$form.supplier.value == 0 ) {errors += "- A Supplier must be selected\\n";}
		if (document.$form.loc0.value == 0 ) {errors += "- A Location must be selected \\n";}
	}	
	
    //	if (document.$form.issuedby.type != 'hidden' && !document.$form.issuedby[0].checked && !document.$form.issuedby[1].checked) {errors += "- The Issued By field must have a value\\n";}
    
        if (document.$form.issuedto) {
        	if (document.$form.issuedto.value == 0) {errors += "- The Issued To field must have a value. \\n";}
        }

    	if (isblank(document.$form.scope.value)) {
		errors += "- The Audit Scope Summary must be completed.\\n";
    	}
    	if (document.$form.rescheduled) {
	    if (document.$form.rescheduled[1].checked && isblank(document.$form.rescheduletext.value)) {
		errors += "- The Reschedule Info field must have a value when the recheduled button is selected.\\n";
	    }
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
END_OF_BLOCK
    $output .= &doMultipartHeader(schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'T', includeJSWidgets => 'F');
    
    $output .= "<input type=hidden name=type value=$settings{type}>\n";
    $output .= "<input type=hidden name=tag value=$settings{tag}>\n";
    $output .= "<input type=hidden name=auditID value=$settings{auditID}>\n";
    $output .= "<input type=hidden name=CRid value=$settings{CRid}>\n";
    $output .= "<input type=hidden name=funum value=$settings{funum}>\n";
    $output .= "<input type=hidden name=bpnum value=$settings{bpnum}>\n";
    $output .= "<input type=hidden name=fiscalyear value=$settings{fiscalyear}>\n";
    $output .= "<input type=hidden name=reportlink value=''>\n";
    $output .= "<input type=hidden name=dbname value=''>\n";
    $output .= "<input type=hidden name=newCRnum value=''>\n";
    $output .= "<input type=hidden name=crcount value=''>\n";
    $output .= "<input type=hidden name=newFUnum value=''>\n";
    $output .= "<input type=hidden name=fucount value=''>\n";
    $output .= "<input type=hidden name=newBPnum value=''>\n";
    $output .= "<input type=hidden name=bpcount value=''>\n";
    $output .= "<input type=hidden name=generatedfrom value=''>\n";
    $output .= "<input type=hidden name=generatorid value=''>\n";
    $output .= "<input type=hidden name=table value=$settings{table}>\n";
    $output .= "<input type=hidden name=qardstring value=$settings{qardstring}>\n";
    $output .= "<input type=hidden name=suborgstring value=$settings{suborgstring}>\n";
    $output .= "<input type=hidden name=selection value=$settings{selection}>\n";
    $output .= "<input type=hidden name=audit_selection value=$settings{selection}>\n";
    $output .= "<input type=hidden name=displayid>\n";
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
    #$output .= "content-disposition: attachment; filename=qa-integratred-audit.xls\n\n"; 
    $output .= "content-disposition: inline; filename=qa-integratred-audit.xls\n\n"; 
    
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
sub doBrowseAuditXsl {  # routine to do display audits
###################################################################################################################################
    my %args = (
        title => 'Audit',
        selection => 'all', # all
        type => 'I', # all
        userID => 0, # all
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    my $count = 0;
   	#my $numColumns = 4;
   my $numColumns = 13;
    my $lead;
    my $location;
    my $auditid;
    my $status;
    
    if (substr($args{selection},0,8) eq 'internal' || $args{selection} eq 'all' || $args{selection} eq 'other') {
		    	my @auditList = &getAudit(dbh => $args{dbh}, schema => $args{schema},fiscalyear => substr($args{fiscalyear},-2), single=>0, selection=>$args{selection},table=>'internal');
		    	my $orgid = 0;
		    	my $other = '';
		    	my $display;
		    	my $num = 0;
		    	    	
		    	 #print "\n<br>*** $args{selection} <br>\n";
		   
		    	for (my $i = 0; $i < $#auditList; $i++) {
			    		my ($auditid,$fiscalyear,$seq,$type,$issuedto,$leadid,$team,$scope,$forecast,$modified,$approver,$approvaldate,
			    		$cancelled,$begindate,$enddate,$completiondate,$notes,$issuedby,$approver2,$approval2date,$reportlink,$qard,
			    		$procedures,$reschedule,$results,$overall,$title,$state,$adequacy,$implementation,$effectiveness,$mol,$otherid,$supplier,$product,$dbname) = 
			    		($auditList[$i]{auditid},$auditList[$i]{fy},$auditList[$i]{seq},$auditList[$i]{type},$auditList[$i]{issuedto},
			    		$auditList[$i]{lead},$auditList[$i]{team},$auditList[$i]{scope},$auditList[$i]{forecast},$auditList[$i]{modified},
			    		$auditList[$i]{approver},$auditList[$i]{approvaldate},$auditList[$i]{cancelled},$auditList[$i]{begindate},
			    		$auditList[$i]{enddate},$auditList[$i]{completion_date},$auditList[$i]{notes},$auditList[$i]{issuedby},$auditList[$i]{approver2},
			    		$auditList[$i]{approval2date},$auditList[$i]{reportlink},$auditList[$i]{qard},$auditList[$i]{procedures},$auditList[$i]{reschedule},
			    		$auditList[$i]{results},$auditList[$i]{overall},$auditList[$i]{title},$auditList[$i]{state},$auditList[$i]{adequacy},$auditList[$i]{implementation},
			    		$auditList[$i]{effectiveness},$auditList[$i]{mol},$auditList[$i]{otherid},$auditList[$i]{supplier},$auditList[$i]{product},$auditList[$i]{dblink});   
			 	    	my $suborg;
				    	my $org;
				      	my $issueby = &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedby);
						my $issueto = &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedto);
							
					if ($issuedby != 3) {
						    		         	
				      	   $status = defined($reschedule) ? "Rescheduled" : defined($cancelled) && $cancelled eq 'Y' ? "Cancelled" : defined($state) && $state eq 'Cancelled' ? "Cancelled" : defined($state) && $state eq 'Postponed' ? "Postponed" :
				      	   #defined($completiondate) ? $reportlink ? "<a href=\"javascript:reportWindow('$reportlink','$dbname');\">Report Approved</a><br>$completiondate" : "Report Approved<br>$completiondate" : 
				      	   defined($state) && $state eq 'Field Work Complete' ? "Field Work<br>Complete $enddate" : defined($state) && $state eq 'Complete' ? "Complete<br>$enddate" : defined($state) && $state eq 'In Progress' ? "In Progress<br>$begindate" : defined($forecast) ? 
				      	   "Scheduled<br>$forecast" : "$begindate&nbsp;";   	
				      	
				      	   if ($leadid != 0) {$lead = &getFullUserName(dbh => $args{dbh}, schema => $args{schema},userID=>$leadid);}
					   else {$lead = 'TBD';}
					   my @org = &getOrganization(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear});
					   my @suborg = &getSuborganization(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear});
				           #my $location;
				           
				           #my @location = &getLocation(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear},table=>'internal') if ($issueby eq 'EM');
				           #for (my $j = 0; $j < $#location; $j++) {
				    		#$location .= (($j != 0) ? "; " : "") . "$location[$j]{city}, $location[$j]{state}" . ($location[$j]{country} eq 'CAN' ? "CAN" : "");
				           #}
				          
				           #print STDERR "\n !!!\n";
				          
				           my @location = &getLocation(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear => $args{fiscalyear},table=>$args{table});
						    for (my $j = 0; $j < $#location; $j++) {
						    	$location .= (($j != 0) ? "; " : "") . "$location[$j]{city} $location[$j]{province}, $location[$j]{state}" . ($location[$j]{country} eq 'CAN' ? "CAN" : "");
						     }
				          print $location;
				          for (my $j = 0; $j < $#org; $j++) {
				    		$org .= (($j != 0) ? ", " : "") . "$org[$j]{orgabbr}";
				           }
				       	   
				       @suborg = &getSuborganization(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear});
				   	   for (my $j = 0; $j < $#suborg; $j++) {
				   		$suborg .= (($j != 0) ? ", " : "") . "$suborg[$j]{suborg}";
				   	   }
				   	   if (($issuedby == 62) || ($issuedby == 63) || ($issuedby == 64)) {
				   	       if ($other eq '') {
				   	              $output .= &writeTableHeaderXsl(issuedby=>'Other',flag=>$orgid,type=>'Internal');
				   	              $other = "Others";
				   	       }
				   	   } 
				   	   else {
				   	        if (($issuedby != $orgid) && ($fiscalyear <= 07)) {
				   	 	    $output .= &writeTableHeaderXsl(issuedby=>$issueby,flag=>$orgid,type=>'Internal');
				   		    $orgid = $issuedby;
				   	        }
				   	        if ($fiscalyear > 07) {
				   	            if ($num == 0) {
				   	                $output .= &writeTableHeaderXsl(issuedby=>"",flag=>$orgid,type=>'Internal');
				   	                $num = 1;
			                            } 
			                        }
				   	        
				   	   }
						   	  if ($otherid ne '') {
						   	      $display = $otherid;
						   	  }
						      else  {
						              $display = getInternalAuditDisplayID(issuedby=>$issueby,issuedto=>$issueto,table=>$args{table},fiscalyear=>$args{fiscalyear},seq=>$seq,type=>$type);
						      }
				      $output .= "<tr>\n";
				      
				      $output .= &addCol (value => "$issueby",align=>"center nowrap",valign=>"top");
				      $output .= &addCol (value => "$issueto",align=>"center nowrap",valign=>"top");
				      $output .= &addCol (value => "$args{fiscalyear}",align=>"center nowrap",valign=>"top");				      
				     	$output .= &addCol (value => "$display",align=>"center nowrap",valign=>"top");
				     	
					 	$output .= &addCol (value => "$begindate",align=>"center nowrap",valign=>"top");
					 	$output .= &addCol (value => "$enddate",align=>"center nowrap",valign=>"top");
					 	
					 	#$output .= &addCol (value => "$lead" . (defined($team) ? "<br><br>Members: $team": "") ,valign=>"top",width=>120);
					 	$output .= &addCol (value => "$lead" ,valign=>"top",width=>120);
					 	$output .= &addCol (value => "$org<br>" . (($suborg) ? "Suborganization:&nbsp;$suborg<br>" : "") . ($issueby eq 'EM' ? "Location: $location<br>" : "") . (defined($title) ? "$title" : "$scope"),valign=>"top");
					 	
					 	#$output .= &addCol (value => "$location",valign=>"top");
					 	$output .= &addCol (value => (($title eq 'OCRWM and BSC East') ? "Washington , DC" : "Las Vegas, NV"),valign=>"top");
					 	
					 	$output .= &addCol (value => "$title",valign=>"top");
					 	
					 	$output .= &addCol (value => "$scope",valign=>"top");
					 	$output .= &addCol (value => "$status",valign=>"top");
					 	$output .= &addCol (value => "$completiondate",valign=>"top");
				     $output .= &endRow();
				      }
			}
			$output .= &endTable;
			
    }
    
    if (substr($args{selection},0,8) eq 'internal' || $args{selection} eq 'all' || $args{selection} eq 'other') {
        	my @auditList = &getAudit(dbh => $args{dbh}, schema => $args{schema},fiscalyear => substr($args{fiscalyear},-2), single=>0, selection=>$args{selection},table=>'internal');
        	my $orgid = 0;
        	my $other = '';
        	my $display;
        	
        	 #print "\n<br>*** $args{selection} <br>\n";
       
        	for (my $i = 0; $i < $#auditList; $i++) {
        		my ($auditid,$fiscalyear,$seq,$type,$issuedto,$leadid,$team,$scope,$forecast,$modified,$approver,$approvaldate,
        		$cancelled,$begindate,$enddate,$completiondate,$notes,$issuedby,$approver2,$approval2date,$reportlink,$qard,
        		$procedures,$reschedule,$results,$overall,$title,$state,$adequacy,$implementation,$effectiveness,$mol,$otherid,$supplier,$product,$dbname) = 
        		($auditList[$i]{auditid},$auditList[$i]{fy},$auditList[$i]{seq},$auditList[$i]{type},$auditList[$i]{issuedto},
        		$auditList[$i]{lead},$auditList[$i]{team},$auditList[$i]{scope},$auditList[$i]{forecast},$auditList[$i]{modified},
        		$auditList[$i]{approver},$auditList[$i]{approvaldate},$auditList[$i]{cancelled},$auditList[$i]{begindate},
        		$auditList[$i]{enddate},$auditList[$i]{completion_date},$auditList[$i]{notes},$auditList[$i]{issuedby},$auditList[$i]{approver2},
        		$auditList[$i]{approval2date},$auditList[$i]{reportlink},$auditList[$i]{qard},$auditList[$i]{procedures},$auditList[$i]{reschedule},
        		$auditList[$i]{results},$auditList[$i]{overall},$auditList[$i]{title},$auditList[$i]{state},$auditList[$i]{adequacy},$auditList[$i]{implementation},
        		$auditList[$i]{effectiveness},$auditList[$i]{mol},$auditList[$i]{otherid},$auditList[$i]{supplier},$auditList[$i]{product},$auditList[$i]{dblink});   
     	    	my $suborg;
    	    	my $org;
    	      	my $issueby = &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedby);
    		my $issueto = &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedto);
    		
    		if ($issuedby == 3) {
    				         	
    	      	   $status = defined($reschedule) ? "Rescheduled" : defined($cancelled) && $cancelled eq 'Y' ? "Cancelled" : defined($state) && $state eq 'Cancelled' ? "Cancelled" : defined($state) && $state eq 'Postponed' ? "Postponed" :
    	      	   #defined($completiondate) ? $reportlink ? "<a href=\"javascript:reportWindow('$reportlink','$dbname');\">Report Approved</a><br>$completiondate" : "Report Approved<br>$completiondate" : 
    	      	   defined($state) && $state eq 'Field Work Complete' ? "Field Work<br>Complete $enddate" : defined($state) && $state eq 'Complete' ? "Complete<br>$enddate" : defined($state) && $state eq 'In Progress' ? "In Progress<br>$begindate" : defined($forecast) ? 
    	      	   "Scheduled<br>$forecast" : "$begindate&nbsp;";   	
    	      	
    	      	   if ($leadid != 0) {$lead = &getFullUserName(dbh => $args{dbh}, schema => $args{schema},userID=>$leadid);}
    		   else {$lead = 'TBD';}
    		   my @org = &getOrganization(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear});
    		   my @suborg = &getSuborganization(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear});
    	           my $location;
    	           my @location = &getLocation(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear},table=>'internal') if ($issueby eq 'EM');
    	           for (my $j = 0; $j < $#org; $j++) {
    	    		$org .= (($j != 0) ? ", " : "") . "$org[$j]{orgabbr}";
    	           }
    	           for (my $j = 0; $j < $#location; $j++) {
    	    		$location .= (($j != 0) ? "; " : "") . "$location[$j]{city}, $location[$j]{state}" . ($location[$j]{country} eq 'CAN' ? "CAN" : "");
    	           }
    	       	   @suborg = &getSuborganization(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear});
    	   	   for (my $j = 0; $j < $#suborg; $j++) {
    	   		$suborg .= (($j != 0) ? ", " : "") . "$suborg[$j]{suborg}";
    	   	   }
    	   	   if (($issuedby == 62) || ($issuedby == 63) || ($issuedby == 64)) {
    	   	       if ($other eq '') {
    	   	              $output .= &writeTableHeaderXsl(issuedby=>'Other',flag=>$orgid,type=>'Internal');
    	   	              $other = "Others";
    	   	       }
    	   	   } 
    	   	   else {
    	   	        if ($issuedby != $orgid)  {
    	   	 	    $output .= &writeTableHeaderXsl(issuedby=>$issueby,flag=>$orgid,type=>'Internal');
    	   		    $orgid = $issuedby;
    	   	        }
    	   	           	   	        
    	           }
    	   	
    	   	  if ($otherid ne '') {
    	   	      $display = $otherid;
    	   	  }
    	          else  {
    	              $display = getInternalAuditDisplayID(issuedby=>$issueby,issuedto=>$issueto,table=>$args{table},fiscalyear=>$args{fiscalyear},seq=>$seq,type=>$type);
    	          }
    	      	  $output .= "<tr>\n";
    	      
    	      #$output .= &addCol (value => "$display",align=>"center nowrap",valign=>"top");
    		  #$output .= &addCol (value => "Lead: $lead" . (defined($team) ? "<br><br>Members: $team": "") ,valign=>"top",width=>120);
    		  #$output .= &addCol (value => "Organization: $org<br>" . (($suborg) ? "Suborganization:&nbsp;$suborg<br>" : "") . ($issueby eq 'EM' ? "Location: $location<br>" : "") . (defined($title) ? "$title" : "$scope"),valign=>"top");
    		  #$output .= &addCol (value => "$status",valign=>"top");
    		  
    		  		   $output .= &addCol (value => "$issueby",align=>"center nowrap",valign=>"top");
				       $output .= &addCol (value => "$issueto",align=>"center nowrap",valign=>"top");
				       $output .= &addCol (value => "$args{fiscalyear}",align=>"center nowrap",valign=>"top");				      
				     	$output .= &addCol (value => "$display",align=>"center nowrap",valign=>"top");
				     	
					 	$output .= &addCol (value => "$begindate",align=>"center nowrap",valign=>"top");
					 	$output .= &addCol (value => "$enddate",align=>"center nowrap",valign=>"top");
					 	
					 	$output .= &addCol (value => "$lead",valign=>"top",width=>120);
					 	$output .= &addCol (value => "$org<br>" . (($suborg) ? "Suborganization:&nbsp;$suborg<br>" : "") . ($issueby eq 'EM' ? "Location: $location<br>" : "") . (defined($title) ? "$title" : "$scope"),valign=>"top");
					 	
					 	$output .= &addCol (value => "$location",valign=>"top");
					 	$output .= &addCol (value => "$title",valign=>"top");
					 	
					 	$output .= &addCol (value => "$scope",valign=>"top");
					 	$output .= &addCol (value => "$status",valign=>"top");
					 	$output .= &addCol (value => "$completiondate",valign=>"top");
    		  
    	    	  $output .= &endRow();
    	      }
    	}
    	$output .= &endTable;
    	
        }
   
    if (substr($args{selection},0,8) eq 'external' || $args{selection} eq 'all' || $args{selection} eq 'other') {
   
    	my @auditList = &getAudit(dbh => $args{dbh}, schema => $args{schema},fiscalyear => substr($args{fiscalyear},-2), single=>0, selection=>$args{selection},table=>'external');
    	my $orgid = 0;
    	my $other = '';
    	my $display;
    	my $num = 0;
    	    
    	for (my $i = 0; $i < $#auditList; $i++) {
    		my ($auditid,$fiscalyear,$seq,$type,$issuedto,$leadid,$team,$scope,$forecast,$modified,$approver,$approvaldate,
    		$cancelled,$begindate,$enddate,$completiondate,$notes,$issuedby,$approver2,$approval2date,$reportlink,$qard,
    		$procedures,$reschedule,$results,$overall,$title,$state,$adequacy,$implementation,$effectiveness,$mol,$otherid,$supplier,$product,$dbname) = 
    		($auditList[$i]{auditid},$auditList[$i]{fy},$auditList[$i]{seq},$auditList[$i]{type},$auditList[$i]{issuedto},
    		$auditList[$i]{lead},$auditList[$i]{team},$auditList[$i]{scope},$auditList[$i]{forecast},$auditList[$i]{modified},
    		$auditList[$i]{approver},$auditList[$i]{approvaldate},$auditList[$i]{cancelled},$auditList[$i]{begindate},
    		$auditList[$i]{enddate},$auditList[$i]{completion_date},$auditList[$i]{notes},$auditList[$i]{issuedby},$auditList[$i]{approver2},
    		$auditList[$i]{approval2date},$auditList[$i]{reportlink},$auditList[$i]{qard},$auditList[$i]{procedures},$auditList[$i]{reschedule},
    		$auditList[$i]{results},$auditList[$i]{overall},$auditList[$i]{title},$auditList[$i]{state},$auditList[$i]{adequacy},$auditList[$i]{implementation},
    		$auditList[$i]{effectiveness},$auditList[$i]{mol},$auditList[$i]{otherid},$auditList[$i]{supplier},$auditList[$i]{product},$auditList[$i]{dblink});   
 	 	    	my $suborg;
		    	my $org;
		    	my $issueby = &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedby);
		    	my $issueto = &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedto);
		      	
		      	$status = defined($reschedule) ? "Rescheduled" : defined($cancelled) && $cancelled eq 'Y' ? "Cancelled" : defined($state) && $state eq 'Cancelled' ? "Cancelled" : 
		      	#defined($completiondate) ? $reportlink ? "<a href=\"javascript:reportWindow('$reportlink','$dbname');\">Report Approved</a> $completiondate" : "Report Approved $completiondate" : 
	      		defined($state) && $state eq 'Field Work Complete' ? "Field Work<br>Complete $enddate" : defined($state) && $state eq 'Complete' ?  "Complete $enddate" :
	      		defined($state) && $state eq 'In Progress' ? "In Progress<br>$begindate" : defined($forecast) ? "Scheduled<br>$forecast" : "$begindate&nbsp;";   	  	
		      	
		      	if ($leadid != 0) {$lead = &getFullUserName(dbh => $args{dbh}, schema => $args{schema},userID=>$leadid);}
			else {$lead = 'TBD';}
			my @supplier = &getSupplier(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear});
		        my $location;
		        my @location = &getLocation(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear},table=>'external');
    			for (my $j = 0; $j < $#location; $j++) {
    				$location .= (($j != 0) ? "; " : "") . "$location[$j]{city} $location[$j]{province}, $location[$j]{state}" . ($location[$j]{country} eq 'CAN' ? "CAN" : "");
    			}
    			if (($issuedby == 62) || ($issuedby == 63) || ($issuedby == 64)) {
			     if ($other eq '') {
		                  $output .= &writeTableHeaderXsl(issuedby=>'Other',flag=>$orgid,type=>'External');
			          $other = "Others";
			     }
			}
			else {
			      if (($issuedby != $orgid) && ($fiscalyear <= 07)) {
				  $output .= &writeTableHeaderXsl(issuedby=>$issueby,flag=>$orgid,type=>'External');
				  $orgid = $issuedby;
			      }
			      if ($fiscalyear > 07) {
			      	   if ($num == 0) {
			      	       $output .= &writeTableHeaderXsl(issuedby=>"",flag=>$orgid,type=>'External');
			      	       $num = 1;
			           } 
                              }
	   	        }
	   		if ($otherid ne '') {
		            $display = $otherid;
	   	        }
	   	        else {
		   	    $display = getExternalAuditDisplayID(issuedby=>$issueby,issuedto=>$issueto,table=>$args{table},fiscalyear=>$args{fiscalyear},seq=>$seq,type=>$type);
		   	}
		      	$output .= "<tr>\n";
				    #$output .= &addCol (value => "$display",align=>"center nowrap",valign=>"top");
					#$output .= &addCol (value => "Lead: $lead" . (defined($team) ? "<br><br>Members: $team": "") ,valign=>"top",width=>120);
					#$output .= &addCol (value => "Supplier: $supplier[0]{supplier}<br>Location: $location<br>" . (defined($title) ? "$title" : "$scope"),valign=>"top");
					#$output .= &addCol (value => "$status",valign=>"top");
					
						$output .= &addCol (value => "$issueby",align=>"center nowrap",valign=>"top");
				      	$output .= &addCol (value => "$issueto",align=>"center nowrap",valign=>"top");
				      	$output .= &addCol (value => "$args{fiscalyear}",align=>"center nowrap",valign=>"top");				      
				     	$output .= &addCol (value => "$display",align=>"center nowrap",valign=>"top");
				     	
					 	$output .= &addCol (value => "$begindate",align=>"center nowrap",valign=>"top");
					 	$output .= &addCol (value => "$enddate",align=>"center nowrap",valign=>"top");
					 	
					 	$output .= &addCol (value => "$lead" ,valign=>"top",width=>120);
					 	$output .= &addCol (value => "$org<br>" . (($suborg) ? "Suborganization:&nbsp;$suborg<br>" : "") . ($issueby eq 'EM' ? "Location: $location<br>" : "") . (defined($title) ? "$title" : "$scope"),valign=>"top");
					 	
					 	$output .= &addCol (value => "$location",valign=>"top");
					 	$output .= &addCol (value => "$title",valign=>"top");
					 	
					 	$output .= &addCol (value => "$scope",valign=>"top");
					 	$output .= &addCol (value => "$status",valign=>"top");
					 	$output .= &addCol (value => "$completiondate",valign=>"top");
					
		    	$output .= &endRow();
	}
	$output .= &endTable;
    }   
    return($output);
}

###################################################################################################################################
sub doBrowseAudit {  # routine to do display audits
###################################################################################################################################
    my %args = (
        title => 'Audit',
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
    my $auditid;
    my $status;
    
   # print STDERR "\n @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n";
    
    if (substr($args{selection},0,8) eq 'internal' || $args{selection} eq 'all' || $args{selection} eq 'other') {
	    	my @auditList = &getAudit(dbh => $args{dbh}, schema => $args{schema},fiscalyear => substr($args{fiscalyear},-2), single=>0, selection=>$args{selection},table=>'internal');
	    	my $orgid = 0;
	    	my $other = '';
	    	my $display;
	    	my $num = 0;    	
	    	
	    	 #print "\n<br>*** $args{selection} <br>\n";
	   
	   		$output .= "<table cellpadding=2 cellspacing=0 border=1 align=center width=600>\n";
	   
	    	for (my $i = 0; $i < $#auditList; $i++) {
	    		my ($auditid,$fiscalyear,$seq,$type,$issuedto,$leadid,$team,$scope,$forecast,$modified,$approver,$approvaldate,
	    		$cancelled,$begindate,$enddate,$completiondate,$notes,$issuedby,$approver2,$approval2date,$reportlink,$qard,
	    		$procedures,$reschedule,$results,$overall,$title,$state,$adequacy,$implementation,$effectiveness,$mol,$otherid,$supplier,$product,$dbname) = 
	    		($auditList[$i]{auditid},$auditList[$i]{fy},$auditList[$i]{seq},$auditList[$i]{type},$auditList[$i]{issuedto},
	    		$auditList[$i]{lead},$auditList[$i]{team},$auditList[$i]{scope},$auditList[$i]{forecast},$auditList[$i]{modified},
	    		$auditList[$i]{approver},$auditList[$i]{approvaldate},$auditList[$i]{cancelled},$auditList[$i]{begindate},
	    		$auditList[$i]{enddate},$auditList[$i]{completion_date},$auditList[$i]{notes},$auditList[$i]{issuedby},$auditList[$i]{approver2},
	    		$auditList[$i]{approval2date},$auditList[$i]{reportlink},$auditList[$i]{qard},$auditList[$i]{procedures},$auditList[$i]{reschedule},
	    		$auditList[$i]{results},$auditList[$i]{overall},$auditList[$i]{title},$auditList[$i]{state},$auditList[$i]{adequacy},$auditList[$i]{implementation},
	    		$auditList[$i]{effectiveness},$auditList[$i]{mol},$auditList[$i]{otherid},$auditList[$i]{supplier},$auditList[$i]{product},$auditList[$i]{dblink});   
	 	    	my $suborg;
		    	my $org;
		      	my $issueby = &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedby);
		      	
    			print STDERR "\n *****************************************************************************". $issuedby ."*****************************************************************************\n";
		      	
				my $issueto = &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedto);
					
					if ($issuedby != 3) {	    		         	
				      	   	$status = defined($reschedule) ? "Rescheduled" : defined($cancelled) && $cancelled eq 'Y' ? "Cancelled" : defined($state) && $state eq 'Cancelled' ? "Cancelled" : defined($state) && $state eq 'Postponed' ? "Postponed" :
				      	   	defined($completiondate) ? $reportlink ? "<a href=\"javascript:reportWindow('$reportlink','$dbname');\">Report Approved</a><br>$completiondate" : "Report Approved<br>$completiondate" : 
				      	   	defined($state) && $state eq 'Field Work Complete' ? "Field Work<br>Complete $enddate" : defined($state) && $state eq 'Complete' ? "Complete<br>$enddate" : defined($state) && $state eq 'In Progress' ? "In Progress<br>$begindate" : defined($forecast) ? 
				      	   	"Scheduled<br>$forecast" : "$begindate&nbsp;";   	
				      		      	
				      	   if ($leadid != 0) {$lead = &getFullUserName(dbh => $args{dbh}, schema => $args{schema},userID=>$leadid);}
					   	   else {$lead = 'TBD';}
					  	   my @org = &getOrganization(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear});
					       my @suborg = &getSuborganization(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear});
				           my $location;
				           my @location = &getLocation(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear},table=>'internal') if ($issueby eq 'EM');
				           for (my $j = 0; $j < $#org; $j++) {
				    		$org .= (($j != 0) ? ", " : "") . "$org[$j]{orgabbr}";
				           }
				           for (my $j = 0; $j < $#location; $j++) {
				    		$location .= (($j != 0) ? "; " : "") . "$location[$j]{city}, $location[$j]{state}" . ($location[$j]{country} eq 'CAN' ? "CAN" : "");
				           }
				       	   @suborg = &getSuborganization(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear});
				   	   
				   	   	   for (my $j = 0; $j < $#suborg; $j++) {
				   		    $suborg .= (($j != 0) ? ", " : "") . "$suborg[$j]{suborg}";
				   	       }
				   	  
				   	  	   if (($issuedby == 62) || ($issuedby == 63) || ($issuedby == 64)) {
				   	      		 if ($other eq '') {
				   	            	  $output .= &writeTableHeader(issuedby=>'Other',flag=>$orgid,type=>'Internal');
				   	              	  $other = "Others";
				   	       		 }
				   	   		} else {
					   	        if (($issuedby != $orgid) && ($fiscalyear <= 07)) {
					   	 	    $output .= &writeTableHeader(issuedby=>$issueby,flag=>$orgid,type=>'Internal');
					   		    $orgid = $issuedby;
					   	        }
					   	        if ($fiscalyear > 07) {
					   	            if ($num == 0) {
					   	                $output .= &writeTableHeader(issuedby=>"",flag=>$orgid,type=>'Internal');
					   	                $num = 1;
				                            } 
				                }
				   	   		}
				   	
					   	  if ($otherid ne '') {
					   	      $display = $otherid;
					   	  }  else  {
					              $display = getInternalAuditDisplayID(issuedby=>$issueby,issuedto=>$issueto,table=>$args{table},fiscalyear=>$args{fiscalyear},seq=>$seq,type=>$type);
					      }
					      $output .= "<tr>\n";
					      $output .= &addCol (value => "$display",url => "javascript:submitEditAudit('audit2','viewAudit',$auditid,'internal')",align=>"center nowrap",valign=>"top");
						  $output .= &addCol (value => "Lead: $lead" . (defined($team) ? "<br><br>Members: $team": "") ,valign=>"top",width=>120);
						  $output .= &addCol (value => "Organization: $org<br>" . (($suborg) ? "Suborganization:&nbsp;$suborg<br>" : "") . ($issueby eq 'EM' ? "Location: $location<br>" : "") . (defined($title) ? "$title" : "$scope"),valign=>"top");
						  $output .= &addCol (value => "$status",valign=>"top");
					      $output .= &endRow();
		      		}
				}
				#$output .= &endTable;	
    }
    
    if (substr($args{selection},0,8) eq 'internal' || $args{selection} eq 'all' || $args{selection} eq 'other') {
        	my @auditList = &getAudit(dbh => $args{dbh}, schema => $args{schema},fiscalyear => substr($args{fiscalyear},-2), single=>0, selection=>$args{selection},table=>'internal');
        	my $orgid = 0;
        	my $other = '';
        	my $display;
        	        	
        	 #print "\n<br>*** $args{selection} <br>\n";
       
        	for (my $i = 0; $i < $#auditList; $i++) {
	        		my ($auditid,$fiscalyear,$seq,$type,$issuedto,$leadid,$team,$scope,$forecast,$modified,$approver,$approvaldate,
	        		$cancelled,$begindate,$enddate,$completiondate,$notes,$issuedby,$approver2,$approval2date,$reportlink,$qard,
	        		$procedures,$reschedule,$results,$overall,$title,$state,$adequacy,$implementation,$effectiveness,$mol,$otherid,$supplier,$product,$dbname) = 
	        		($auditList[$i]{auditid},$auditList[$i]{fy},$auditList[$i]{seq},$auditList[$i]{type},$auditList[$i]{issuedto},
	        		$auditList[$i]{lead},$auditList[$i]{team},$auditList[$i]{scope},$auditList[$i]{forecast},$auditList[$i]{modified},
	        		$auditList[$i]{approver},$auditList[$i]{approvaldate},$auditList[$i]{cancelled},$auditList[$i]{begindate},
	        		$auditList[$i]{enddate},$auditList[$i]{completion_date},$auditList[$i]{notes},$auditList[$i]{issuedby},$auditList[$i]{approver2},
	        		$auditList[$i]{approval2date},$auditList[$i]{reportlink},$auditList[$i]{qard},$auditList[$i]{procedures},$auditList[$i]{reschedule},
	        		$auditList[$i]{results},$auditList[$i]{overall},$auditList[$i]{title},$auditList[$i]{state},$auditList[$i]{adequacy},$auditList[$i]{implementation},
	        		$auditList[$i]{effectiveness},$auditList[$i]{mol},$auditList[$i]{otherid},$auditList[$i]{supplier},$auditList[$i]{product},$auditList[$i]{dblink});   
	     	    	my $suborg;
	    	    	my $org;
	    	      	my $issueby = &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedby);
	    			my $issueto = &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedto);
	    		    		
	    		    print STDERR "\n %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%". $issuedby ."%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n";		
	    		    		
		    			if ($issuedby == 3) {
		    				
		    	      	   $status = defined($reschedule) ? "Rescheduled" : defined($cancelled) && $cancelled eq 'Y' ? "Cancelled" : defined($state) && $state eq 'Cancelled' ? "Cancelled" : defined($state) && $state eq 'Postponed' ? "Postponed" :
		    	      	   defined($completiondate) ? $reportlink ? "<a href=\"javascript:reportWindow('$reportlink','$dbname');\">Report Approved</a><br>$completiondate" : "Report Approved<br>$completiondate" : 
		    	      	   defined($state) && $state eq 'Field Work Complete' ? "Field Work<br>Complete $enddate" : defined($state) && $state eq 'Complete' ? "Complete<br>$enddate" : defined($state) && $state eq 'In Progress' ? "In Progress<br>$begindate" : defined($forecast) ? 
		    	      	   "Scheduled<br>$forecast" : "$begindate&nbsp;";   	
		    	      	
		    	      	   if ($leadid != 0) {$lead = &getFullUserName(dbh => $args{dbh}, schema => $args{schema},userID=>$leadid);}
		    		  	   else {$lead = 'TBD';}
		    		   
		    		   	   my @org = &getOrganization(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear});
		    		   	   my @suborg = &getSuborganization(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear});
		    	           my $location;
		    	           my @location = &getLocation(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear},table=>'internal') if ($issueby eq 'EM');
		    	           
		    	           for (my $j = 0; $j < $#org; $j++) {
		    	    		$org .= (($j != 0) ? ", " : "") . "$org[$j]{orgabbr}";
		    	           }
		    	           
		    	           for (my $j = 0; $j < $#location; $j++) {
		    	    		$location .= (($j != 0) ? "; " : "") . "$location[$j]{city}, $location[$j]{state}" . ($location[$j]{country} eq 'CAN' ? "CAN" : "");
		    	           }
		    	       	   
		    	       	   @suborg = &getSuborganization(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear});
		    	   	   
		    	   	   	   for (my $j = 0; $j < $#suborg; $j++) {
		    	   			$suborg .= (($j != 0) ? ", " : "") . "$suborg[$j]{suborg}";
		    	   	   	   }
		    	   	  
		    	   	  	   if (($issuedby == 62) || ($issuedby == 63) || ($issuedby == 64)) {
		    	   	      	 if ($other eq '') {
		    	   	              $output .= &writeTableHeader(issuedby=>'Other',flag=>$orgid,type=>'Internal');
		    	   	              $other = "Others";
		    	   	       	  }
		    	   	   	  } else {
			    	   	        if ($issuedby != $orgid)  {
			    	   	 	    $output .= &writeTableHeader(issuedby=>$issueby,flag=>$orgid,type=>'Internal');
			    	   		    $orgid = $issuedby;
			    	   	        }    	   	           	   	        
		    	           }
		    	   	
		    	   	 	 if ($otherid ne '') {
		    	   	      		$display = $otherid;
		    	   	 	 } else {
		    	              	$display = getInternalAuditDisplayID(issuedby=>$issueby,issuedto=>$issueto,table=>$args{table},fiscalyear=>$args{fiscalyear},seq=>$seq,type=>$type);
		    	         }
		    	      	 
		    	      	 $output .= "<tr>\n";
		    	      	 $output .= &addCol (value => "$display",url => "javascript:submitEditAudit('audit2','viewAudit',$auditid,'internal')",align=>"center nowrap",valign=>"top");
		    		  	 $output .= &addCol (value => "Lead: $lead" . (defined($team) ? "<br><br>Members: $team": "") ,valign=>"top",width=>120);
		    		  	 $output .= &addCol (value => "Organization: $org<br>" . (($suborg) ? "Suborganization:&nbsp;$suborg<br>" : "") . ($issueby eq 'EM' ? "Location: $location<br>" : "") . (defined($title) ? "$title" : "$scope"),valign=>"top");
		    		  	 $output .= &addCol (value => "$status",valign=>"top");
		    	    	 $output .= &endRow();
		    	      }
    		 }
    		#$output .= &endTable;    	
        } 
   
    if (substr($args{selection},0,8) eq 'external' || $args{selection} eq 'all' || $args{selection} eq 'other') {
   
    	my @auditList = &getAudit(dbh => $args{dbh}, schema => $args{schema},fiscalyear => substr($args{fiscalyear},-2), single=>0, selection=>$args{selection},table=>'external');
    	my $orgid = 0;
    	my $other = '';
    	my $display;
    	my $num = 0;    	
    	    
	    	for (my $i = 0; $i < $#auditList; $i++) {
		    		my ($auditid,$fiscalyear,$seq,$type,$issuedto,$leadid,$team,$scope,$forecast,$modified,$approver,$approvaldate,
		    		$cancelled,$begindate,$enddate,$completiondate,$notes,$issuedby,$approver2,$approval2date,$reportlink,$qard,
		    		$procedures,$reschedule,$results,$overall,$title,$state,$adequacy,$implementation,$effectiveness,$mol,$otherid,$supplier,$product,$dbname) = 
		    		($auditList[$i]{auditid},$auditList[$i]{fy},$auditList[$i]{seq},$auditList[$i]{type},$auditList[$i]{issuedto},
		    		$auditList[$i]{lead},$auditList[$i]{team},$auditList[$i]{scope},$auditList[$i]{forecast},$auditList[$i]{modified},
		    		$auditList[$i]{approver},$auditList[$i]{approvaldate},$auditList[$i]{cancelled},$auditList[$i]{begindate},
		    		$auditList[$i]{enddate},$auditList[$i]{completion_date},$auditList[$i]{notes},$auditList[$i]{issuedby},$auditList[$i]{approver2},
		    		$auditList[$i]{approval2date},$auditList[$i]{reportlink},$auditList[$i]{qard},$auditList[$i]{procedures},$auditList[$i]{reschedule},
		    		$auditList[$i]{results},$auditList[$i]{overall},$auditList[$i]{title},$auditList[$i]{state},$auditList[$i]{adequacy},$auditList[$i]{implementation},
		    		$auditList[$i]{effectiveness},$auditList[$i]{mol},$auditList[$i]{otherid},$auditList[$i]{supplier},$auditList[$i]{product},$auditList[$i]{dblink});   
		 	 	    my $suborg;
				    my $org;
				    #my $issueby = ($issuedby != 0) ? &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedby) : "";
			    	#my $issueto = ($issuedto != 0) ? &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedto) : "";
				    my $issueby = &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedby);
				    my $issueto = &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedto);
				    
				     print STDERR "\n ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^". $issuedby ."^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n";		
				      	
				    $status = defined($reschedule) ? "Rescheduled" : defined($cancelled) && $cancelled eq 'Y' ? "Cancelled" : defined($state) && $state eq 'Cancelled' ? "Cancelled" : 
				    defined($completiondate) ? $reportlink ? "<a href=\"javascript:reportWindow('$reportlink','$dbname');\">Report Approved</a> $completiondate" : "Report Approved $completiondate" : 
			      	defined($state) && $state eq 'Field Work Complete' ? "Field Work<br>Complete $enddate" : defined($state) && $state eq 'Complete' ?  "Complete $enddate" :
			      	defined($state) && $state eq 'In Progress' ? "In Progress<br>$begindate" : defined($forecast) ? "Scheduled<br>$forecast" : "$begindate&nbsp;";   	  	
				      	
				    if ($leadid != 0) {$lead = &getFullUserName(dbh => $args{dbh}, schema => $args{schema},userID=>$leadid);}
					else {$lead = 'TBD';}
					my @supplier = &getSupplier(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear});
				    my $location;
				    my @location = &getLocation(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear},table=>'external');
		    		
		    		for (my $j = 0; $j < $#location; $j++) {
		    			$location .= (($j != 0) ? "; " : "") . "$location[$j]{city} $location[$j]{province}, $location[$j]{state}" . ($location[$j]{country} eq 'CAN' ? "CAN" : "");
		    		}
		    		if (($issuedby == 62) || ($issuedby == 63) || ($issuedby == 64)) {
					     if ($other eq '') {
				              $output .= &writeTableHeader(issuedby=>'Other',flag=>$orgid,type=>'External');
					          $other = "Others";
					     }
					} else {
					      if (($issuedby != $orgid) && ($fiscalyear <= 07)) {
						  $output .= &writeTableHeader(issuedby=>$issueby,flag=>$orgid,type=>'External');
						  $orgid = $issuedby;
					      }
					      if ($fiscalyear > 07) {
					      	   if ($num == 0) {
					      	       $output .= &writeTableHeader(issuedby=>"",flag=>$orgid,type=>'External');
					      	       $num = 1;
					           } 
		                    }
			   	    }
		   			if ($otherid ne '') {
			            $display = $otherid;
		   	        }  else {
			   	    $display = getExternalAuditDisplayID(issuedby=>$issueby,issuedto=>$issueto,table=>$args{table},fiscalyear=>$args{fiscalyear},seq=>$seq,type=>$type);
			   		}
			   		
		      	$output .= "<tr>\n";
		      	$output .= &addCol (value => "$display",url => "javascript:submitEditAudit('audit2','viewAudit',$auditid,'external')",align=>"center nowrap",valign=>"top");
				$output .= &addCol (value => "Lead: $lead" . (defined($team) ? "<br><br>Members: $team": "") ,valign=>"top",width=>120);
				$output .= &addCol (value => "Supplier: $supplier[0]{supplier}<br>Location: $location<br>" . (defined($title) ? "$title" : "$scope"),valign=>"top");
				$output .= &addCol (value => "$status",valign=>"top");
		    	$output .= &endRow();
			}
			#$output .= &endTable;
    }   
    $output .= &endTable;
    $output .= "<script language=javascript><!--\n";
    $output .= "   document.audit2.fiscalyear.value = $args{fiscalyear};\n";
    $output .= "//--></script>\n";
    
   #print STDERR "\n @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" .$args{selection}."@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n";
   
    return($output);
}
###################################################################################################################################
sub doViewAudit {  # routine to view an audit
###################################################################################################################################
    my %args = (
        auditID => 0,
        title => 'Audit',
        userID => 0, # all
        @_,
    );
    my $org;
    my @org;
    my $suborg;
    my @suborg;
    my $location;
    my $deficiency;
    my $displayid;
    my $output = '';
    my $count = 0;
    my $numColumns = 3;
    my %userprivhash = &getUserPrivs(dbh=>$args{dbh},schema=>$args{schema},userID=>$args{userID});
    my @auditList = &getAudit(dbh => $args{dbh}, schema => $args{schema}, auditID => $args{auditID},fiscalyear => substr($args{fiscalyear},-2),table => $args{table}, single=>1);
    my $maxrev = &getMaxrevision(dbh => $args{dbh}, schema => $args{schema}, auditID => $args{auditID},fiscalyear => substr($args{fiscalyear},-2),table => $args{table});
    #my $fy = $args{fiscalyear} > 50 ? 1900 + $args{fiscalyear} : 2000 + $args{fiscalyear};
    my $fy = $args{fiscalyear};
    my ($auditid,$fiscalyear,$seq,$type,$issuedto,$lead,$team,$scope,$forecast,$modified,$approver,$approvaldate,
    $cancelled,$begindate,$enddate,$completiondate,$notes,$issuedby,$approver2,$approval2date,$reportlink,$qard,
    $procedures,$reschedule,$results,$overall,$title,$state,$adequacy,$implementation,$effectiveness,$mol,$otherid,$supplier,$product,$dbname) = 
    ($auditList[0]{auditid},$auditList[0]{fy},$auditList[0]{seq},$auditList[0]{type},$auditList[0]{issuedto},
    $auditList[0]{lead},$auditList[0]{team},$auditList[0]{scope},$auditList[0]{forecast},$auditList[0]{modified},
    $auditList[0]{approver},$auditList[0]{approvaldate},$auditList[0]{cancelled},$auditList[0]{begindate},
    $auditList[0]{enddate},$auditList[0]{completion_date},$auditList[0]{notes},$auditList[0]{issuedby},$auditList[0]{approver2},
    $auditList[0]{approval2date},$auditList[0]{reportlink},$auditList[0]{qard},$auditList[0]{procedures},$auditList[0]{reschedule},
    $auditList[0]{results},$auditList[0]{overall},$auditList[0]{title},$auditList[0]{state},$auditList[0]{adequacy},$auditList[0]{implementation},
    $auditList[0]{effectiveness},$auditList[0]{mol},$auditList[0]{otherid},$auditList[0]{supplier},$auditList[0]{product},$auditList[0]{dblink}); 
    
    if ($args{table} eq 'internal') {
    	@org = &getOrganization(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear});
   	for (my $i = 0; $i < $#org; $i++) {
   		$org .= (($i != 0) ? ", " : "") . (($args{fiscalyear} >= 2006) ? (($org[$i]{orgabbr} eq "BSC") ? "BSC" : "$org[$i]{orgname}") : "$org[$i]{orgname}");
   	}
    	@suborg = &getSuborganization(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear});
   	for (my $j = 0; $j < $#suborg; $j++) {
   		$suborg .= (($j != 0) ? ", " : "") . "$suborg[$j]{suborg}";
   	}
    } else {
    	@org = &getSupplier(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear});
   	$org = "$org[0]{supplier}";  
    }
    my $issueto = &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedto);
    my $issueby = &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedby);
    if ($otherid ne '') {
        $displayid = $otherid;
    }
    else {
        $displayid = getInternalAuditDisplayID(issuedby=>$issueby,issuedto=>$issueto,table=>$args{table},fiscalyear=>$args{fiscalyear},seq=>$seq,type=>$type) if ($args{table} eq 'internal');
        $displayid = getExternalAuditDisplayID(issuedby=>$issueby,issuedto=>$issueto,type=>$type,fiscalyear=>$args{fiscalyear},seq=>$seq,type=>$type) if ($args{table} eq 'external');
    }
    my @location = &getLocation(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear => $args{fiscalyear},table=>$args{table});
    for (my $j = 0; $j < $#location; $j++) {
    	$location .= (($j != 0) ? "; " : "") . "$location[$j]{city} $location[$j]{province}, $location[$j]{state}" . ($location[$j]{country} eq 'CAN' ? "CAN" : "");
    }
	 $output .= "<script>document.forms[0].displayid.value='$displayid';</script> ";
    $output .= "<br><table width=650 border=0 cellspacing=4 cellpadding=1>\n";
    $output .= "<tr><td colspan=3 align=center><b><font color=black>\n";
    $output .= "$displayid </font></b></td></tr>\n";
    $output .= "<tr height=10></tr>\n";
    if ($fy <= 2007)  {
        $output .= "<tr>" . &addCol(value => "<b>Issued By: &nbsp;<font color=black>$issueby</font></b>");
    }
    $output .= &addCol(value => "<b>Issued To: &nbsp;<font color=black>$issueto</font></b>");
    $output .= &addCol(value => "<b>Fiscal Year:&nbsp;<font color=black>$args{fiscalyear}</font></b>");
    $output .= &endRow();
    if (defined($reschedule)) {
    	$output .= "<tr>" . &addCol(value => "<b>Rescheduled:&nbsp;<font color=black>$reschedule</font></b>",colspan=>$numColumns);
    }
    else {
    	$output .= "<tr>" . &addCol(value => "<b>Plan:&nbsp;<font color=black>$forecast</font></b>");
	$output .= &addCol(value => "<b>Status:&nbsp;<font color=black>$state</font></b>",colspan=>2);
    	$output .= &endRow();
    	$output .= "<tr>" . &addCol(value => "<b>Start Date:&nbsp;<font color=black>$begindate</font></b>");
    	$output .= &addCol(value => "<b>End Date:&nbsp;<font color=black>$enddate</font></b>");
    	$output .= &addCol(value => "<b>Report Approved:&nbsp;<font color=black>$completiondate</font></b>");
    }
    $output .= &endRow();
    $output .= "<tr>" . &addCol(value => "<b>Team Lead:&nbsp;<font color=black>" . (($lead == 0) ? "TBD" : &getFullUserName(dbh => $args{dbh}, schema => $args{schema},userID=>$lead)) . "</font></b>");
    $output .= &addCol(value => "<b>Team Members:&nbsp;<font color=black> " . (defined($team) ? "$team" : "TBD") . "</font></b>",colspan=>2);
    $output .= &endRow();
    $output .= "<tr>" . &addCol(value => "<b>" . (($args{table} eq 'internal') ? "Organization: " : "Supplier: " ) . "&nbsp;&nbsp;<font color=black>$org</font></b>" . (($suborg) ? "<br><b>Suborganization:&nbsp;&nbsp;<font color=black>$suborg</font></b>" : "" ),valign=>"top",colspan=>3);
    $output .= &endRow();
    $output .= "<tr>" . &addCol(value => "<b>Location:&nbsp;&nbsp;<font color=black>$location</font></b>",valign=>"top",colspan=>3);
    $output .= &endRow();
    $output .= "<tr>" . &addCol(value => "<b>Audit Title:&nbsp;&nbsp;<font color=black>$title</font></b>",valign=>"top",colspan=>3);
    $output .= &endRow();
    $output .= "<tr>" . &addCol(value => "<b>Audit Scope Summary:&nbsp;&nbsp;<font color=black>$scope</font></b>",valign=>"top",colspan=>3);
    $output .= &endRow();
    #$output .= "<tr>" . &addCol(value => "<b>QA Elements:&nbsp;<font color=black>" . &writeQARD(qard=>"$qard") . "</font></b>",valign=>"top",colspan=>3,fontSize=>2);
    #$output .= &endRow();
    #$output .= "<tr>" . &addCol(value => "<b>Procedures:&nbsp;<font color=black>$procedures</font></b>",valign=>"top",colspan=>3,fontSize=>2);
    #$output .= &endRow();
    #$output .= "<tr>" . &addCol(value => "<b>Comments:&nbsp;&nbsp;<font color=black>$notes</font></b>",valign=>"top",colspan=>3,fontSize=>2);
    #$output .= &endRow();
    if($mol){
    $output .= "<tr>" . &addCol(value => "<b>Accession #:&nbsp;&nbsp;<font color=black><a href='http://rms.ymp.gov/api/records/".$mol."_images.pdf' target=_blank>$mol</a></font></b> (Click the # to view the report saved in RISWEB)",valign=>"top",colspan=>3,fontSize=>2);
    $output .= &endRow();
    }else{
   $output .= "<tr>" . &addCol(value => "<b>Accession #:&nbsp;&nbsp;<font color=black>$mol</font></b>",valign=>"top",colspan=>3,fontSize=>2);
   $output .= &endRow(); 	
    }
    #$output .= "<tr>" . &addCol(value => "<b>Adequacy:&nbsp;&nbsp;<font color=black>$adequacy</font></b>",fontSize=>2);
    #$output .= &addCol(value => "<b>Implementation:&nbsp;&nbsp;<font color=black>$implementation</font></b>",fontSize=>2);
    #$output .= &addCol(value => "<b>Effectiveness:&nbsp;&nbsp;<font color=black>$effectiveness</font></b>",fontSize=>2);
    #$output .= &endRow();
    #$output .= "<tr>" . &addCol(value => "<b>Results:&nbsp;<font color=black>$results</font></b>",valign=>"top",colspan=>$numColumns,fontSize=>2);
    #$output .= &endRow();
    $output .= &addCol(value => "<b>Overall Results:&nbsp;&nbsp;<font color=black>$overall</font></b>",valign=>"top",colspan=>3, fontSize=>2);
    $output .= &endRow();
   # my $editallowed = (($userprivhash{'Developer'} == 1 || 
   #        ( (($userprivhash{'OQA Supplier Administration'} == 1 && (($issueby eq 'OQA') || ($issueby eq 'GAO') || ($issueby eq 'PAT') || ($issueby eq 'OIG'))) || ($userprivhash{'BSC Supplier Administration'} == 1 && $issueby eq 'BSC') || ($userprivhash{'SNL Supplier Administration'} == 1 && $issueby eq 'SNL')) && $args{table} eq 'external') 
   #        || ((($userprivhash{'OQA Internal Administration'} == 1 && ($issueby eq 'OQA'|| $issueby eq 'OCRWM' || $issueby eq 'EM' || $issueby eq 'GAO' || $issueby eq 'PAT' || $issueby eq 'OIG')) || ($userprivhash{'BSC Internal Administration'} == 1 && ($issueby eq 'BSC'|| $issueby eq 'OCRWM' )) || ($userprivhash{'SNL Internal Administration'} == 1 && $issueby eq 'SNL')) && $args{table} eq 'internal')
   #        || (((($userprivhash{'OQA Internal Lead'} == 1 || $userprivhash{'SNL Internal Lead'} == 1 || $userprivhash{'BSC Internal Lead'} == 1) && $args{table} eq 'internal') 
   #      || (($userprivhash{'OQA Supplier Lead'} == 1 || $userprivhash{'SNL Supplier Lead'} == 1 || $userprivhash{'BSC Supplier Lead'} == 1) && $args{table} eq 'external'))  && (!$lead || $lead == $args{userID}))));

    my $editallowed = 
    (
    	($userprivhash{'Developer'} == 1)
    	||($userprivhash{'Team Lead'} == 1)
    	||($userprivhash{'OQA Supplier General Access'} == 1)
    	||($userprivhash{'OQA Internal General Access'} == 1)   
    	||($userprivhash{'OQA Surveillance General Access'} == 1)   
    	||($userprivhash{'BSC Internal General Access'} == 1)   
    	||($userprivhash{'BSC Surveillance General Access'} == 1)   
    	||($userprivhash{'BSC Supplier General Access'} == 1)   
    	||($userprivhash{'SNL Supplier General Access'} == 1)   
    	||($userprivhash{'SNL Internal General Access'} == 1)   
    	||($userprivhash{'SNL Surveillance General Access'} == 1)   
    	
    	||($userprivhash{'OQA Internal Administration'} == 1)
    	||($userprivhash{'OQA Surveillance Administration'} == 1)
    	||($userprivhash{'OQA Supplier Administration'} == 1)
    	||($userprivhash{'BSC Internal Administration'} == 1)
    	||($userprivhash{'BSC Surveillance Administration'} == 1)
    	||($userprivhash{'BSC Supplier Administration'} == 1)
    	||($userprivhash{'SNL Supplier Administration'} == 1)
    	||($userprivhash{'SNL Internal Administration'} == 1)
    	||($userprivhash{'SNL Surveillance Administration'} == 1)
	);

    $output .= &writeConditionReport(dbh => $args{dbh}, schema => $args{schema}, auditID => $auditid, generatedfrom => ($args{table} eq 'internal' ? 'IA' : 'EA'),fiscalyear => substr($args{fiscalyear},-2),table=>$args{table},edit=>$editallowed, qardstring=>$args{qardstring});
    #$output .= &writeConditionReportFollowup(dbh => $args{dbh}, schema => $args{schema}, auditID => $auditid, generatedfrom => ($args{table} eq 'internal' ? 'IA' : 'EA'), fiscalyear => $args{fiscalyear},single=>1,table=>$args{table},edit=>$editallowed);
    #$output .= &writeConditionReportOQA(dbh => $args{dbh}, schema => $args{schema}, auditID => $auditid, generatedfrom => ($args{table} eq 'internal' ? 'IA' : 'EA'),fiscalyear => substr($args{fiscalyear},-2),table=>$args{table},edit=>$editallowed, qardstring=>$args{qardstring});
    #$output .= &writeBestPractice(dbh => $args{dbh}, schema => $args{schema}, auditID => $auditid, generatedfrom => ($args{table} eq 'internal' ? 'IA' : 'EA'), fiscalyear => substr($args{fiscalyear},-2),single=>1,table=>$args{table},edit=>$editallowed);

    $output .= "<tr>" . &addCol(value=>"<b>View Report</b><br>&nbsp;&nbsp;&nbsp;<a href=\"javascript:reportWindow('$reportlink','$dbname');\"><img src=$NQSImagePath/report.gif></a>",colspan=>$numColumns) if ($reportlink);
   if ($editallowed) {
        
        if (($issueby eq 'GAO') || ($issueby eq 'PAT') || ($issueby eq 'OIG')) {
             $output .= "<tr><td colspan=$numColumns align=center><a href=javascript:submitEditAudit('audit2','editAuditOther',$auditid,'$args{table}')>Edit Audit</a>\n";
        }
        else {
             $output .= "<tr><td colspan=$numColumns align=center><a href=javascript:submitEditAudit('audit2','editAudit',$auditid,'$args{table}')>Edit Audit</a>\n";
        }
        if ($args{fiscalyear} >= 2003) {
    		#$output .= "&nbsp;&nbsp;&nbsp;&nbsp;<a href=javascript:submitEditAudit('conditionReports','createCondition',$auditid,'$args{table}')>Add Condition Report</a>\n";
    			#$output .= "&nbsp;&nbsp;&nbsp;&nbsp;<a href=javascript:submitEditAudit('conditionReports','createConditionOQA',$auditid,'$args{table}')>Add Condition Report For OQA</a>\n";
    		#$output .= "&nbsp;&nbsp;&nbsp;&nbsp;<a href=javascript:submitEditAudit('conditionReports','browseConditions',$auditid,'$args{table}')>Add Follow-up to Condition Report</a>\n";
    		#$output .= "<br><a href=javascript:submitEditAudit('conditionReports','createBestPractice',$auditid,'$args{table}')>Add Best Practice</a>\n";
    		#$output .= "&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"javascript:submitEditReport('audit2','editReportlink',$auditid,'$reportlink','$displayid','$args{table}','$dbname')\">" . ($reportlink ? "Edit " : "Add ") . "Correspondence Control Report Log No.</a>\n" if (!$dbname || $dbname eq 'CC');
    			#$output .= "&nbsp;&nbsp;&nbsp;&nbsp;<a href=javascript:submitEditAudit('audit2','processCancelAudit',$auditid,'$args{table}')>Cancel Audit</a>\n";
    			
    		#$output .= "&nbsp;&nbsp;&nbsp;&nbsp;<a href=javascript:submitEditAudit('audit2','processDeleteAudit',$auditid,'$args{table}')>Delete Audit</a>\n" if ($maxrev == 0 && !$completiondate);
    		
    		if(
    			($userprivhash{'Developer'} == 1)
    			||($userprivhash{'OQA Internal Administration'} == 1)
		    	||($userprivhash{'OQA Surveillance Administration'} == 1)
		    	||($userprivhash{'OQA Supplier Administration'} == 1)
		    	||($userprivhash{'BSC Internal Administration'} == 1)
		    	||($userprivhash{'BSC Surveillance Administration'} == 1)
		    	||($userprivhash{'BSC Supplier Administration'} == 1)
		    	||($userprivhash{'SNL Supplier Administration'} == 1)
		    	||($userprivhash{'SNL Internal Administration'} == 1)
		    	||($userprivhash{'SNL Surveillance Administration'} == 1)
    		){
    		$output .= "&nbsp;&nbsp;&nbsp;&nbsp;<a href=javascript:submitEditAudit('audit2','processDeleteAudit',$auditid,'$args{table}')>Delete Audit</a>\n";
    		}
    	}
    	$output .= "</td></tr>\n";
    }
    $output .= &endTable . "<br><br><br>\n";
    $output .= "<input type=hidden name=reportlink value='$reportlink'>\n";
    $output .= "<input type=hidden name=dbname value='$dbname'>\n";
    $output .= "<center><a href=\"./audit2.pl?userid=$args{userID}&schema=$args{schema}&command=browse&fiscalyear=$args{fiscalyear}&audit_selection=$args{selection}\"><b>Return to Previous Page</b></a></center><br>\n";

    return($output);
}
###################################################################################################################################
sub doEditAudit {  # routine to edit an audit
###################################################################################################################################
     my %args = (
         auditID => 0,
         table => '',
         title => 'Audit',
         userID => 0, # all
         @_,
     );
     my $org;
     my $suborg;
     my $location;
     my $deficiency;
     my $output = '';
     my $count = 0;
     my $numColumns = 3;
     my @auditList = &getAudit(dbh => $args{dbh}, schema => $args{schema}, auditID => $args{auditID},fiscalyear => substr($args{fiscalyear},2),table => $args{table}, single=>1);
     #my $fy = $args{fiscalyear} > 50 ? 1900 + $args{fiscalyear} : 2000 + $args{fiscalyear};
     my $fy = $args{fiscalyear};
     my ($auditid,$fiscalyear,$seq,$type,$issuedto,$lead,$team,$scope,$forecast,$modified,$approver,$approvaldate,
     $cancelled,$begindate,$enddate,$completiondate,$notes,$issuedby,$approver2,$approval2date,$reportlink,$qard,
     $procedures,$reschedule,$results,$overall,$title,$state,$adequacy,$implementation,$effectiveness,$mol,$supplier,$product) = 
     ($auditList[0]{auditid},$auditList[0]{fy},$auditList[0]{seq},$auditList[0]{type},$auditList[0]{issuedto},
     $auditList[0]{lead},$auditList[0]{team},$auditList[0]{scope},$auditList[0]{forecast},$auditList[0]{modified},
     $auditList[0]{approver},$auditList[0]{approvaldate},$auditList[0]{cancelled},$auditList[0]{begindate},
     $auditList[0]{enddate},$auditList[0]{completion_date},$auditList[0]{notes},$auditList[0]{issuedby},$auditList[0]{approver2},
     $auditList[0]{approval2date},$auditList[0]{reportlink},$auditList[0]{qard},$auditList[0]{procedures},$auditList[0]{reschedule},
     $auditList[0]{results},$auditList[0]{overall},$auditList[0]{title},$auditList[0]{state},$auditList[0]{adequacy},$auditList[0]{implementation},
     $auditList[0]{effectiveness},$auditList[0]{mol},$auditList[0]{supplier},$auditList[0]{product});  

     my $issueto = ($issuedto) ? &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedto) : 0;
     my $issueby = ($issuedby) ? &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedby) : 0;
     
     my @type_array = ($args{table} eq 'internal') ? ("C","P") : ("SA","SFE") ;
  #   my $displayid = $args{auditID} == 0 ? 'New ' . ($args{table} eq 'internal' ? 'Internal ' : 'External ') . 'Audit for FY <select name=newfyselect>\n<option value=4>2004</select>' : getInternalAuditDisplayID(issuedby=>$issueby,issuedto=>$issueto,table=>$args{table},type=>$type,fiscalyear=>$fy,seq=>$seq);
     my $displayid = $args{tag} eq 'new' || $args{tag} eq 'newem' ? "" : $args{table} eq 'internal' ? 
     getInternalAuditDisplayID(issuedby=>$issueby,issuedto=>$issueto,table=>$args{table},type=>$type,fiscalyear=>$fy,seq=>$seq,edit=>1) :
     getExternalAuditDisplayID(issuedby=>$issueby,issuedto=>$issueto,table=>$args{table},type=>$type,fiscalyear=>$fy,seq=>$seq,edit=>1);
     $output .= "<script>document.forms[0].displayid.value='$displayid';</script> ";
     $output .= "<br><table width=650 border=0 cellspacing=1 cellpadding=1 align=center>\n";
     $output .= "<tr><td valign=top colspan=4 align=center><font color=black><b>$displayid</b></font>\n";
     $output .= "&nbsp;&nbsp;&nbsp;&nbsp;<a href=javascript:submitGetSequence('audit2','getSequence','$args{table}','$type')>Get Available Sequence Numbers</a>\n" if (!$seq && $args{tag} ne 'new' && $args{tag} ne 'newem');
     $output .= "</td></tr>\n";
     if ($cancelled eq 'Y') {
     	$output .= "<tr><td colspan=4 align=center><font color=red><b>Cancelled</b></font></td></tr>\n";
     }
     $output .= "<tr height=12></tr>\n";
     $output .= "<tr><td align=left><font size=-1><b>Issued By:<br>\n";
     if ($issuedby && $args{table} eq 'internal' && $issuedby != 3){$output .= "<input type=hidden name=issuedby value=$issuedby>$issueby\n";}
     #elsif ($args{table} eq 'internal' && $args{tag} eq "new" && $fy == 2004) {$output .= "<input type=hidden name=issuedby value=24>OCRWM\n";}
     #elsif ($args{table} eq 'internal' && $args{tag} eq "new" && $fy > 2004) {$output .= &writeIssuedby(dbh=>$args{dbh},schema=>$args{schema},issuedby=>(defined($issuedby) ? $issuedby : 0),table=>$args{table}) . "</font></b>";}
     elsif ($args{table} eq 'internal' && $args{tag} eq "new") {$output .= "<input type=hidden name=issuedby value=24>OCRWM\n";}
     elsif ($args{table} eq 'internal' && ($issuedby == 3 || $args{tag} eq "newem")) {$output .= "<input type=hidden name=issuedby value=3>EM/RW\n";}
     elsif ($args{table} eq 'external' && $args{tag} ne "new") {$output .= "<input type=hidden name=issuedby value=$issuedby>$issueby\n";}
     else {$output .= &writeIssuedby(dbh=>$args{dbh},schema=>$args{schema},issuedby=>(defined($issuedby) ? $issuedby : 0),table=>$args{table}) . "</font></b>";}
     
     if ($args{tag} eq "new" || $args{tag} eq "newem") {
     		 if ($args{table} eq 'external'){
     		 	$output .= "<td><input type=hidden name=issuedto value=24><b><font size=-1>Issued To:<br>OCRWM</font></b></td>\n";
     		 }	else {	
     		 	 if ($args{table} eq 'internal' && ($issuedby == 3 || $args{tag} eq "newem")){
     			$output .= &addCol(value => "<b>Issued To:<br><font size=-1>" . &writeIssuedto(dbh=>$args{dbh},schema=>$args{schema},issuedto=>(defined($issuedto)? $issuedto : 0,type=>'em')) . "</font></b>");
     		 	}else{
     		 	$output .= &addCol(value => "<b>Issued To:<br><font size=-1>" . &writeIssuedto(dbh=>$args{dbh},schema=>$args{schema},issuedto=>(defined($issuedto)? $issuedto : 0,type=>'internal')) . "</font></b>");
     		 	}
     		 }
     }
     else {$output .= "<td><input type=hidden name=issuedto value=$issuedto><b><font size=-1>Issued To:<br>$issueto</font></b></td>\n";}
     if ($args{table} eq 'external'){
     	$output .= "<td nowrap valign=top><font size=-1><b>Type:<br>\n";
     }else{
 	 $output .= "<td nowrap valign=top><font size=-1><b>\n";
     }
     if ($args{tag} ne 'new' && $args{tag} ne 'newem') {$
     	#output .= $type eq 'SA' ? "Audit" : $type eq 'SFE' ? "Survey" : "$type"; 
     	output .= $type eq 'SA' ? "Audit" : $type eq 'SFE' ? "Survey" : ""; 
     }
     else {
     	if ($args{table} eq 'internal'){
     		 #$output .= "<input type=hidden name=auditType value=P>P\n";
     		 $output .= "<input type=hidden name=auditType value=P>\n";
     	}else{
	     	foreach my $audit_type ( @type_array ) {
	     		$output .=  "<input type=radio name=auditType value=$audit_type>";
	     		if ($audit_type eq 'SA') {$output .=  "Audit &nbsp;\n";}
	     		elsif ($audit_type eq 'SFE') {$output .=  "Survey &nbsp;\n";}
	     		else {
	     			$output .=  "$audit_type&nbsp;\n";
				}
	    	}
     	}
     }
     $output .= "</b></td><td>";
     if ($args{tag} ne 'new' && $args{tag} ne 'newem') {
	$output .= "<font size=-1><b>Fiscal Year:&nbsp;&nbsp;<br>&nbsp;&nbsp;&nbsp;&nbsp;$args{fiscalyear}</b></font>\n";
	$output .= "<input type=hidden name=fy value=$fy>\n";
     }
     else {$output .= &writeFiscalyearSelect(dbh=>$args{dbh},schema=>$args{schema},selectedyear=>$args{fiscalyear},table=>$args{table});}	
     $output .= "</td></tr></table>\n";
     
     $output .= "<table width=650 border=0 cellspacing=1 cellpadding=1 align=center>\n";
     if ($args{table} eq 'internal') {
	$output .= "<tr><td valign=top>"; 
	#$output .= &writeInternalOrgSelect(dbh => $args{dbh},schema => $args{schema},auditID => $args{auditID},fiscalyear => $args{fiscalyear},table => $args{table});
		#$output .= &writeSuborgSelect(dbh => $args{dbh},schema => $args{schema},auditID => $args{auditID},fiscalyear => $args{fiscalyear},table => $args{table});
	$output .= "</td>\n<td valign=top nowrap>";
		if($args{tag} eq "newem"){
			$output .= &writeLocationSelect(dbh => $args{dbh},schema => $args{schema},auditID => $args{auditID},fiscalyear => $args{fiscalyear},table => $args{table});
		}
     }
     elsif ($args{table} eq 'external') {
     	$output .= "<tr><td colspan=2><b><font size=-1>Supplier:</font></b><br>"; 
	$output .= &writeSupplierSelect(dbh => $args{dbh},schema => $args{schema},auditID => $args{auditID},fiscalyear => $args{fiscalyear},table => $args{table});
	#$output .= "<table border=0 cellspacing=0 cellpadding=3 width=650>\n";
	#&add_supplier_form;
	$output .= "<br><b><font size=-1>Product or Service:</font></b><br><input name=product type=text maxlength=220 size=100 value='$product'>\n";
	$output .= "</td></tr>\n<tr><td valign=top nowrap>";
	$output .= &writeLocationSelect(dbh => $args{dbh},schema => $args{schema},auditID => $args{auditID},fiscalyear => $args{fiscalyear},table => $args{table});
     }
     $output .= "</td><td><table><tr><td><font size=-1><b>Plan:</b></td><td><input name=forecast type=text maxlength=15 size=15 value=" . ($forecast ? "'$forecast'" : "mm/yyyy" ) . " onBlur=checkForecast(value,this)></td></tr>\n";
     $output .= "<tr><td><font size=-1><b>Start Date:</b></td><td><input name=start type=text maxlength=15 size=15 value='$begindate' onBlur=checkDate(value,this)></td></tr>\n";
     $output .= "<tr><td><font size=-1><b>End Date:</b></td><td><input name=end type=text maxlength=15 size=15 value='$enddate' onBlur=checkDate(value,this)></td></tr>\n";
     $output .= "<tr><td><font size=-1><b>Status:</b></td>" . &addCol(value => writeState(state=>"$state",table=>$args{table},issueby=>$issueby) . "</b>") . "</tr>\n";
     $output .= "<tr><td><font size=-1><b>Report Approved:</b></td><td><input name=completed type=text maxlength=15 size=15 value='$completiondate'  onBlur=checkDate(value,this)></td></tr>\n";
     $output .= "<tr><td valign=top><font size=-1><b>Team Lead:</b></td><td>" . writeTeamLead(dbh => $args{dbh},schema => $args{schema},leadid => ($lead ? $lead : 0),table => $args{table}) . "</td></tr>\n";
     $output .= "<tr><td valign=top><font size=-1><b>Team:</b></td><td><textarea name=team rows=4 cols=20>$team</textarea></td></tr>\n";
     $output .= "</table></td></tr>\n";
     #$output .= "<tr><td colspan=3>" . &writeSuborgSelect(dbh => $args{dbh},schema => $args{schema},auditID => $args{auditID},fiscalyear => $args{fiscalyear},table => $args{table}) . "</td></tr>\n" if ($args{table} eq 'internal' && $args{tag} ne 'newem' && $issuedby != 3);
     $output .= "</table>\n<table width=650 align=center border=0 cellpadding=1 cellspacing=1>\n";
     $output .= "<tr>" . &addCol(value => "<b>Audit Title:&nbsp;&nbsp;<input type=text name=title size=80 maxlength=150 value=\"$title\"></b>",valign=>"top",colspan=>2);
     $output .= &endRow();
     $output .= "<tr><td valign=top colspan=2>\n";
     $output .= "<font size=-1><b>Audit Scope Summary:</b><br>\n";
     $output .= "<textarea name=scope rows=5 cols=80 onBlur=checkLength(value,this);>$scope</textarea><br>\n";
     $output .= "</td></tr>\n";
     #$output .= "<tr><td valign=top colspan=2>\n";
     #$output .= "<font size=-1><b>Comments:</b><br>\n";
     #$output .= "<textarea name=notes rows=3 cols=80 onBlur=checkLength(value,this);>$notes</textarea><br>\n";
     #$output .= "</td></tr>\n";
     $output .= "<tr>" . &addCol(value => "<b>Accession #:&nbsp;&nbsp;<input type=text name=mol size=50 maxlength=25 value=\"$mol\"></b>",valign=>"top",colspan=>2);
     $output .= &endRow();
     
     #if ($fy >= 2004) {
     	#$output .= "<tr>" . &addCol(value => &writeQARDcheckbox(qard=>"$qard"),valign=>"top",colspan=>2,fontSize=>2);
     	#$output .= &endRow();
     	#$output .= "<tr>" . &addCol(value => "<b>Procedures:&nbsp;&nbsp;<font color=black><input type=text name=procedures size=80 maxlength=250 value=\"$procedures\"></font></b>",valign=>"top",colspan=>2,fontSize=>2);
     	#$output .= &endRow();
     	#$output .= "<tr>" . &addCol(value => "<b>Adequacy of Requirements:</b>"); 
    	#$output .= &addCol(value => "<b>" . &writeResultsRadio(name=>"adequacy",results=>$adequacy) . "</b>",valign=>"top",fontSize=>2);
     	#$output .= &endRow();
     	#$output .= "<tr>" . &addCol(value => "<b>Implementation of Requirements:</b>");  
     	#$output .= &addCol(value => "<b>" . &writeResultsRadio(name=>"implementation",results=>$implementation) . "</b>",valign=>"top",fontSize=>2);
     	#$output .= &endRow();
     	#$output .= "<tr>" . &addCol(value => "<b>Effectiveness of Requirements:</b>"); 
     	#$output .= &addCol(value => "<b>" . &writeResultsRadio(name=>"effectiveness",results=>$effectiveness) . "</b>",valign=>"top",fontSize=>2);
     	#$output .= &endRow();
     	#$output .= "<tr>" . &addCol(value => "<b><font size=-1>Results:</font><br><font color=black><textarea name=results rows=3 cols=80 onBlur=checkLength(value,this);>$results</textarea></font></b>",valign=>"top",colspan=>3,fontSize=>3);
     	#$output .= &endRow();
     	#$output .= "<tr>" . &addCol(value => "<b>Overall Results:</b>"); 
	#$output .= &addCol(value => "<b>" . &writeOverallResultsRadio(name=>"overall",results=>$overall) . "</b>",valign=>"top",fontSize=>2);
     	#$output .= &endRow();
     	#if (!defined($reschedule)) {
     		#$output .= "<tr>" . &addCol(value => "<b>Rescheduled to new fiscal year?<br><input type=radio name=rescheduled value=no checked onClick=showHideBlockSection('no')>No&nbsp;&nbsp;&nbsp;<input type=radio name=rescheduled value=yes onClick=showHideBlockSection('yes')>Yes</b>");
     		#$output .= &addCol(value => "<span id=Reschedule Style=Display:none;>\n<b>Reschedule Info:&nbsp;</b><input type=text name=rescheduletext value='$reschedule' size=50 maxlength=400></span>",colspan=>2);
     		#$output .= &endRow();
     	#}
     #}
     
     $output .= "<tr><td colspan='4' class='rowHeader'>Attachment(s):</td></tr>";
     if ($reportlink){
     my @filenamefinal = split("/", $reportlink);
     $output .= "<tr><td colspan='4' class='rowHeader'>$filenamefinal[1] &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type='button' value='Delete' name='Delete_Attachment' onClick=\"deleteAuditAttachment('audit2','deleteAuditAttachment','$auditid','$reportlink','$displayid','$args{table}','intranet')\"><br><br></td></tr>";  
     }
     $output .= "<tr><td colspan='4' class='rowAttachment'>Please attach any supporting attachments below</td></tr>";
     $output .= "<tr><td colspan='4' class='rowAttachment'>";
     $output .= "<div id='attachments'><input type='file' name='attachment'><br></div></td></tr>";
     $output .= "</table><br><center>\n";
     $output .= "<input type=button onClick=validateAudit('audit2','processUpdateAudit'); value=\"Submit Changes\">\n" if ($args{tag} ne 'new' && $args{tag} ne 'newem' && $cancelled ne 'Y');
     $output .= "<input type=button onClick=validateAudit('audit2','processCreateAudit'); value=\"Submit\">\n" if ($args{tag} eq 'new' || $args{tag} eq 'newem');
     $output .= "</center><br><br>\n";
          
     return($output);
}
###################################################################################################################################
sub doEditAuditOther {  # routine to edit an audit
###################################################################################################################################
     my %args = (
         auditID => 0,
         title => 'Audit',
         userID => 0, # all
         @_,
     );
     my $org;
     my $suborg;
     my $location;
     my $deficiency;
     my $output = '';
     my $count = 0;
     my $numColumns = 3;
     my $table = $args{table};
     my $displayid;
     my @auditList = &getAudit(dbh => $args{dbh}, schema => $args{schema}, auditID => $args{auditID},fiscalyear => substr($args{fiscalyear},2),table => $table, single=>1);
     
     my $fy = $args{fiscalyear} > 50 ? 1900 + $args{fiscalyear} : 2000 + $args{fiscalyear};
     my ($auditid,$fiscalyear,$seq,$type,$issuedto,$lead,$team,$scope,$forecast,$modified,$approver,$approvaldate,
     $cancelled,$begindate,$enddate,$completiondate,$notes,$issuedby,$approver2,$approval2date,$reportlink,$qard,
     $procedures,$reschedule,$results,$overall,$title,$state,$adequacy,$implementation,$effectiveness,$mol,$otherid,$supplier,$product) = 
     ($auditList[0]{auditid},$auditList[0]{fy},$auditList[0]{seq},$auditList[0]{type},$auditList[0]{issuedto},
     $auditList[0]{lead},$auditList[0]{team},$auditList[0]{scope},$auditList[0]{forecast},$auditList[0]{modified},
     $auditList[0]{approver},$auditList[0]{approvaldate},$auditList[0]{cancelled},$auditList[0]{begindate},
     $auditList[0]{enddate},$auditList[0]{completion_date},$auditList[0]{notes},$auditList[0]{issuedby},$auditList[0]{approver2},
     $auditList[0]{approval2date},$auditList[0]{reportlink},$auditList[0]{qard},$auditList[0]{procedures},$auditList[0]{reschedule},
     $auditList[0]{results},$auditList[0]{overall},$auditList[0]{title},$auditList[0]{state},$auditList[0]{adequacy},$auditList[0]{implementation},
     $auditList[0]{effectiveness},$auditList[0]{mol},$auditList[0]{otherid},$auditList[0]{supplier},$auditList[0]{product}); 
     
     
     my $issueto = ($issuedto) ? &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedto) : 0;
     my $issueby = ($issuedby) ? &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedby) : 0;
     my @type_array = ($table eq 'internal') ? ("C","P") : ("SA","SFE") ;
  #   my $displayid = $args{auditID} == 0 ? 'New ' . ($args{table} eq 'internal' ? 'Internal ' : 'External ') . 'Audit for FY <select name=newfyselect>\n<option value=4>2004</select>' : getInternalAuditDisplayID(issuedby=>$issueby,issuedto=>$issueto,table=>$args{table},type=>$type,fiscalyear=>$fy,seq=>$seq);
     if ($otherid ne '') {
         $displayid = $otherid;
     }
     else {
         $displayid = $args{tag} eq 'new' || $args{tag} eq 'newem' ? "" : $table eq 'internal' ? 
         getInternalAuditDisplayID(issuedby=>$issueby,issuedto=>$issueto,table=>$table,type=>$type,fiscalyear=>$fy,seq=>$seq,edit=>1) :
         getExternalAuditDisplayID(issuedby=>$issueby,issuedto=>$issueto,table=>$table,type=>$type,fiscalyear=>$fy,seq=>$seq,edit=>1);
     }
     $output .= "<br><table width=650 border=0 cellspacing=1 cellpadding=1 align=center>\n";
     $output .= "<tr><td valign=top colspan=4 align=center><font color=black><b>$displayid</b></font>\n";
     #$output .= "&nbsp;&nbsp;&nbsp;&nbsp;<a href=javascript:submitGetSequence('audit2','getSequence','$table','$type')>Get Available Sequence Numbers</a>\n" if (!$seq && $args{tag} ne 'new' && $args{tag} ne 'newem');
     $output .= "</td></tr>\n";
     if ($cancelled eq 'Y') {
     	$output .= "<tr><td colspan=4 align=center><font color=red><b>Cancelled</b></font></td></tr>\n";
     }
     $output .= "<tr height=12></tr>\n";
     $output .= "<tr><td align=left><font size=-1><b>Issued By:<br>\n";
     
     if ($issuedby && $args{table} eq 'internal' && $issuedby != 3){$output .= "<input type=hidden name=issuedby value=$issuedby>$issueby\n";}
     elsif ($table eq 'internal' && $args{tag} eq "new" && $fy == 2004) {$output .= "<input type=hidden name=issuedby value=24>OCRWM\n";}
     elsif ($table eq 'internal' && $args{tag} eq "new" && $fy > 2004) 
           {
            $output .= "<select name=issuedby size=1>";
            $output .= "<option value=64>GAO";
            $output .= "<option value=62>OIG";
            $output .= "<option value=63>PAT";
            $output .= "</select>";
           }
     elsif ($table eq 'internal' && ($issuedby == 3 || $args{tag} eq "newem")) {$output .= "<input type=hidden name=issuedby value=3>EM/RW\n";}
     elsif ($table eq 'external' && $args{tag} ne "new") {$output .= "<input type=hidden name=issuedby value=$issuedby>$issueby\n";}
     else {$output .= "<select name=issuedby size=1>";
            $output .= "<option value=64>GAO";
            $output .= "<option value=62>OIG";
            $output .= "<option value=63>PAT";
            $output .= "</select>";
           }

     if ($args{tag} eq "new" || $args{tag} eq "newem") {$output .= &addCol(value => "<b>Issued To:<br><font size=-1>" . &writeIssuedto(dbh=>$args{dbh},schema=>$args{schema},issuedto=>(defined($issuedto)? $issuedto : 0)) . "</font></b></td>");}
     else {$output .= "<td><input type=hidden name=issuedto value=$issuedto><b><font size=-1>Issued To:<br>$issueto</font></b></td>\n";}
     if ($args{tag} ne 'new' && $args{tag} ne 'newem') {
	$output .= "<td colspan=2><font size=-1><b>Fiscal Year:&nbsp;&nbsp;<br>&nbsp;&nbsp;&nbsp;&nbsp;$args{fiscalyear}</b></font>\n";
	$output .= "<input type=hidden name=fy value=$fy>\n";
     }
     else {$output .= "<td colspan=2>" . &writeFiscalyearSelect(dbh=>$args{dbh},schema=>$args{schema},selectedyear=>$args{fiscalyear},table=>$table);}	
     $output .= "</td></tr></table>\n";
     
     $output .= "<table width=650 border=0 cellspacing=1 cellpadding=1 align=center>\n";
     if ($args{table} eq 'internal') {
	$output .= "<tr><td valign=top>"; 
	$output .= &writeInternalOrgSelect(dbh => $args{dbh},schema => $args{schema},auditID => $args{auditID},fiscalyear => $args{fiscalyear},table => $table);
	#$output .= &writeSuborgSelect(dbh => $args{dbh},schema => $args{schema},auditID => $args{auditID},fiscalyear => $args{fiscalyear},table => $args{table});
	$output .= "</td>\n<td valign=top nowrap>";
	$output .= &writeLocationSelect(dbh => $args{dbh},schema => $args{schema},auditID => $args{auditID},fiscalyear => $args{fiscalyear},table => $table);
     }
     elsif ($args{table} eq 'external') {
     	$output .= "<tr><td colspan=2><b><font size=-1>Supplier:</font></b><br>"; 
	$output .= &writeSupplierSelect(dbh => $args{dbh},schema => $args{schema},auditID => $args{auditID},fiscalyear => $args{fiscalyear},table => $table);
	#$output .= "<table border=0 cellspacing=0 cellpadding=3 width=650>\n";
	#&add_supplier_form;
	$output .= "<br><b><font size=-1>Product or Service:</font></b><br><input name=product type=text maxlength=220 size=100 value='$product'>\n";
	$output .= "</td></tr>\n<tr><td valign=top nowrap>";
	$output .= &writeLocationSelect(dbh => $args{dbh},schema => $args{schema},auditID => $args{auditID},fiscalyear => $args{fiscalyear},table => $table);
     }
     $output .= "</td><td><table><tr><td><font size=-1><b>Other Id:</b></td><td><input name=otherid type=text maxlength=15 size=15 value='$otherid'></td></tr>\n";
     $output .= "<tr><td><font size=-1><b>Plan:</b></td><td><input name=forecast type=text maxlength=15 size=15 value=" . ($forecast ? "'$forecast'" : "mm/yyyy" ) . " onBlur=checkForecast(value,this)></td></tr>\n";
     $output .= "<tr><td><font size=-1><b>Start Date:</b></td><td><input name=start type=text maxlength=15 size=15 value='$begindate' onBlur=checkDate(value,this)></td></tr>\n";
     $output .= "<tr><td><font size=-1><b>End Date:</b></td><td><input name=end type=text maxlength=15 size=15 value='$enddate' onBlur=checkDate(value,this)></td></tr>\n";
     $output .= "<tr><td><font size=-1><b>Status:</b></td>" . &addCol(value => writeState(state=>"$state",table=>$table,issueby=>$issueby) . "</b>") . "</tr>\n";
     $output .= "<tr><td><font size=-1><b>Report Approved:</b></td><td><input name=completed type=text maxlength=15 size=15 value='$completiondate'  onBlur=checkDate(value,this)></td></tr>\n";
     $output .= "<tr><td valign=top><font size=-1><b>Team Lead:</b></td><td>" . writeTeamLead(dbh => $args{dbh},schema => $args{schema},leadid => ($lead ? $lead : 0),table => $table) . "</td></tr>\n";
     $output .= "<tr><td valign=top><font size=-1><b>Team:</b></td><td><textarea name=team rows=4 cols=20>$team</textarea></td></tr>\n";
     $output .= "</table></td></tr>\n";
    # $output .= "<tr><td colspan=3>" . &writeSuborgSelect(dbh => $args{dbh},schema => $args{schema},auditID => $args{auditID},fiscalyear => $args{fiscalyear},table => $table) . "</td></tr>\n" if ($table eq 'internal' && $args{tag} ne 'newem' && $issuedby != 3);
     $output .= "</table>\n<table width=650 align=center border=0 cellpadding=1 cellspacing=1>\n";
     $output .= "<tr>" . &addCol(value => "<b>Audit Title:&nbsp;&nbsp;<input type=text name=title size=80 maxlength=150 value=\"$title\"></b>",valign=>"top",colspan=>2);
     $output .= &endRow();
     $output .= "<tr><td valign=top colspan=2>\n";
     $output .= "<font size=-1><b>Audit Scope Summary:</b><br>\n";
     $output .= "<textarea name=scope rows=5 cols=80 onBlur=checkLength(value,this);>$scope</textarea><br>\n";
     $output .= "</td></tr>\n";
     #$output .= "<tr><td valign=top colspan=2>\n";
     #$output .= "<font size=-1><b>Comments:</b><br>\n";
     #$output .= "<textarea name=notes rows=3 cols=80 onBlur=checkLength(value,this);>$notes</textarea><br>\n";
     #$output .= "</td></tr>\n";
     $output .= "<tr>" . &addCol(value => "<b>Accession #:&nbsp;&nbsp;<input type=text name=mol size=50 maxlength=25 value=\"$mol\"></b>",valign=>"top",colspan=>2);
     $output .= &endRow();
    
     #if ($fy >= 2004) {
     	#$output .= "<tr>" . &addCol(value => &writeQARDcheckbox(qard=>"$qard"),valign=>"top",colspan=>2,fontSize=>2);
     	#$output .= &endRow();
     	#$output .= "<tr>" . &addCol(value => "<b>Procedures:&nbsp;&nbsp;<font color=black><input type=text name=procedures size=80 maxlength=250 value=\"$procedures\"></font></b>",valign=>"top",colspan=>2,fontSize=>2);
     	#$output .= &endRow();
     	#$output .= "<tr>" . &addCol(value => "<b>Adequacy of Requirements:</b>"); 
    	#$output .= &addCol(value => "<b>" . &writeResultsRadio(name=>"adequacy",results=>$adequacy) . "</b>",valign=>"top",fontSize=>2);
     	#$output .= &endRow();
     	#$output .= "<tr>" . &addCol(value => "<b>Implementation of Requirements:</b>");  
     	#$output .= &addCol(value => "<b>" . &writeResultsRadio(name=>"implementation",results=>$implementation) . "</b>",valign=>"top",fontSize=>2);
     	#$output .= &endRow();
     	#$output .= "<tr>" . &addCol(value => "<b>Effectiveness of Requirements:</b>"); 
     	#$output .= &addCol(value => "<b>" . &writeResultsRadio(name=>"effectiveness",results=>$effectiveness) . "</b>",valign=>"top",fontSize=>2);
     	#$output .= &endRow();
     	#$output .= "<tr>" . &addCol(value => "<b><font size=-1>Results:</font><br><font color=black><textarea name=results rows=3 cols=80 onBlur=checkLength(value,this);>$results</textarea></font></b>",valign=>"top",colspan=>3,fontSize=>3);
     	#$output .= &endRow();
     	#$output .= "<tr>" . &addCol(value => "<b>Overall Results:</b>"); 
        #$output .= &addCol(value => "<b>" . &writeOverallResultsRadio(name=>"overall",results=>$overall) . "</b>",valign=>"top",fontSize=>2);
     	#$output .= &endRow();
     	#if (!defined($reschedule)) {
     		#$output .= "<tr>" . &addCol(value => "<b>Rescheduled to new fiscal year?<br><input type=radio name=rescheduled value=no checked onClick=showHideBlockSection('no')>No&nbsp;&nbsp;&nbsp;<input type=radio name=rescheduled value=yes onClick=showHideBlockSection('yes')>Yes</b>");
     		#$output .= &addCol(value => "<span id=Reschedule Style=Display:none;>\n<b>Reschedule Info:&nbsp;</b><input type=text name=rescheduletext value='$reschedule' size=50 maxlength=400></span>",colspan=>2);
     		#$output .= &endRow();
     	#}
     #}
     
     $output .= "<tr><td colspan='4' class='rowHeader'>Attachment(s):</td></tr>";

     $output .= "<tr><td colspan='4' class='rowAttachment'>Please attach any supporting attachments below</td></tr>";
     if ($reportlink){
     my @filenamefinal = split("/", $reportlink);
     $output .= "<tr><td colspan='4' class='rowHeader'>$filenamefinal[1] &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type='button' value='Delete' name='Delete_Attachment' onClick=\"deleteAuditAttachment('audit2','deleteAuditAttachment','$auditid','$reportlink','$displayid','$args{table}','intranet')\"><br><br></td></tr>";  
     }
     $output .= "<tr><td colspan='4' class='rowAttachment'>";
     $output .= "<div id='attachments'><input type='file' name='attachment'><br></div></td></tr>";
     $output .= "</table><br><center>\n";
     $output .= "<input type=button onClick=validateAudit('audit2','processUpdateAudit'); value=\"Submit Changes\">\n" if ($args{tag} ne 'new' && $args{tag} ne 'newem' && $cancelled ne 'Y');
     $output .= "<input type=button onClick=validateAudit('audit2','processCreateAudit'); value=\"Submit\">\n" if ($args{tag} eq 'new' || $args{tag} eq 'newem');
     $output .= "</center><br><br>\n";
          
     return($output);
}
###################################################################################################################################
sub doEditReportlink {  # routine to edit an audit reportlink
###################################################################################################################################
     my %args = (
         survID => 0,
         title => 'Audit',
         userID => 0, # all
         @_,
     );
     
     my $output = "<table border=0 cellspacing=1 cellpadding=1 width=75% align=center>\n";
     $output .= "<br><br>\n";
     $output .= "<tr><td align=center><b>$args{displayid}<br><br></b></td></tr>\n";
     $output .= "<tr><td align=left><font size=-1><b>Enter Document Log Number for Correspondence Control Database - <br></b></font></td></tr>\n";
     $output .= "<tr><td align=left><input name=reportlink type=text size=100% value='$args{reportlink}'></td></tr>\n";
     $output .= "<tr><td align=center><br><input type=button onClick=submitFormCGIResults('audit2','processEditReportlink') value=\"Submit\"></td></tr>\n";
     $output .= "</table><br>\n";
     $output .= "<input type=hidden name=dbname value=CC>\n";
	
     $output .= "<br><br>\n";
     return($output);
}
################################################################################################################################## 
sub writeQARDcheckbox {  # routine to write the checkboxes for QARD elements 
###################################################################################################################################
     my %args = (
        qard => '0000000000000000000000000', 
        @_,
     );
     my $i = 0;
     my $j = 0;
     my $selected = "";
     my $output = "<table cellpadding=0 cellspacing=0 border=0 width=650 align=center>\n";
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
    my @teamLeadList = &getTeamLeads(dbh => $args{dbh}, schema => $args{schema}, leadid => $args{leadid}, table => $args{table});
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
    my @stateList;
    @stateList = ("Scheduled","In Progress","Field Work Complete", "Complete", "Postponed", "Cancelled") if (!($args{table} eq 'external' && $args{issueby} eq 'BSC'));
    @stateList = ("Scheduled","Complete","Cancelled") if ($args{table} eq 'external' && $args{issueby} eq 'BSC');
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
	type => 'external',
	@_,
    );	
   #my @IssuedtoList = &getLookupValues(dbh => $args{dbh}, schema => $args{schema}, tablename => 'organizations', value => 'id', text => 'abbr', where => " issued_to_list = 'T' or id = $args{issuedto} ");
   #my @IssuedtoList = &getLookupValues(dbh => $args{dbh}, schema => $args{schema}, tablename => 'organizations', value => 'id', text => 'abbr', where => ($args{tag} eq 'newem' ? " abbr in ('SRNL-PDP','EM-Hanford','SRS-DWPF','WVDP-HLW','INL-SNF','EM-NSNFP','ORP-Hanfd','NNPP','BNI','USA-RS')"  : " issued_to_list = 'T' or id = $args{issuedto} "));
   #my @IssuedtoList = &getLookupValues(dbh => $args{dbh}, schema => $args{schema}, tablename => 'organizations', value => 'id', text => 'abbr', where => " abbr in ('SRNL-PDP','EM-Hanford','SRS-DWPF','WVDP-HLW','INL-SNF','EM-NSNFP','ORP-Hanfd','NNPP','BNI','USA-RS') " );
   my @IssuedtoList = &getLookupValues(dbh => $args{dbh}, schema => $args{schema}, tablename => 'organizations', value => 'id', text => 'abbr', where => ($args{type}  eq 'em'  ? " abbr in ('SRNL-PDP','EM-Hanford','SRS-DWPF','WVDP-HLW','INL-SNF','EM-NSNFP','ORP-Hanfd','NNPP','BNI','USA-RS') " : "abbr in ('OCRWM','OQA','M&O','Lead Lab')" ));
   my $output = "<select name=issuedto size=1>\n"; #<option value=0>\n";
   
   if($args{type}  eq 'internal'){
   		my @newissueorder = (3,2,0,1,4);
   		my @newissuelist;
   		@newissuelist = @IssuedtoList[@newissueorder];
   		#@newissuelist = @IssuedtoList;
   		for (my $j = 0; $j < $#newissuelist; $j++) {
    		$output .= "<option value=$newissuelist[$j]{value} " . (($args{issuedto} == $newissuelist[$j]{value}) ? "selected" : "") . ">$newissuelist[$j]{text}";
   		}
   }else{
		for (my $j = 0; $j < $#IssuedtoList; $j++) {
			$output .= "<option value=$IssuedtoList[$j]{value} " . (($args{issuedto} == $IssuedtoList[$j]{value}) ? "selected" : "") . ">$IssuedtoList[$j]{text}";
		}
   }
  $output .= "</select>\n";
    
    return($output);
}
#####################################################################################################
sub writeIssuedby {
#####################################################################################################
    my %args = (
	issuedby => 0,
	@_,
    );	
    #my @IssuedbyList = &getLookupValues(dbh => $args{dbh}, schema => $args{schema}, tablename => 'organizations', value => 'id', text => 'abbr', where =>  ($args{table} eq 'internal' ? " abbr in ('OCRWM','BSC','SNL') " : " abbr in ('OQA','BSC','SNL') "));
    my @IssuedbyList = &getLookupValues(dbh => $args{dbh}, schema => $args{schema}, tablename => 'organizations', value => 'id', text => 'abbr', where =>  ($args{table} eq 'internal' ? " abbr in ('OCRWM','BSC','SNL') " : " abbr in ('OCRWM','M&O','Lead Lab','OQA') "));
    my $output = "<select name=issuedby size=1>\n"; #<option value=0>\n";
    for (my $j = 0; $j < $#IssuedbyList; $j++) {
    	$output .= "<option value=$IssuedbyList[$j]{value} " . (($args{issuedby} == $IssuedbyList[$j]{value}) ? "selected" : "") . ">$IssuedbyList[$j]{text}";
    }
    $output .= "</select>\n";
    
    return($output);
}
####################################################################################################
sub writeDeficiencies {
####################################################################################################
    my %args = (
	auditID => 0,
	fiscalyear => 50,
	@_,
    );
    my $output = "<table cellpadding=0 cellspacing=1 border=0 width=100% align=left>\n";
    my $deficiency;
    my @deficiency = &getDeficiency(dbh=>$args{dbh},schema=>$args{schema},recordID=>$args{auditID},fiscalyear => $args{fiscalyear});
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
	auditID => 0,
	fiscalyear => 50,
	single => 0,
	edit => 0,
	@_,
    );
    my $output = "<tr><td colspan=3><table  width=100% border=0 cellspacing=4 cellpadding=1>\n";
    $output .= "<tr>" . &addCol(value => "<b>Best Practice:&nbsp;</b>",colspan=>2,fontSize=>2,valign=>"top");
    $output .= &endRow();
    my @bpList = &getBestPractice(dbh => $args{dbh}, schema => $args{schema}, auditID => $args{auditID}, fiscalyear => $args{fiscalyear}, single=>$args{single},generatedfrom => $args{generatedfrom});
    for (my $i = 0; $i < $#bpList; $i++) {
	my ($bpid,$bpsummary,$bpdate) = 
	($bpList[$i]{bpid},$bpList[$i]{bestpractice},$bpList[$i]{bpdate});  
      	$output .= "<tr><td width=100><b><font size=-1 color=black>&nbsp;&nbsp;&nbsp;" . ($args{edit} ? "<a href=javascript:submitEditAudit('conditionReports','editBestPractice',$args{auditID},'$args{table}',0,0,$bpid);>BP# $bpid</a>" : "BP# $bpid") . "</font></b></td>";
      	$output .= "<td><b><font size=-1 color=black>&nbsp;&nbsp;&nbsp;$bpsummary</font></b></td></tr>\n";
    }
    $output .= "</table></td></tr>\n";
    return($output);
}
#####################################################################################################
sub writeConditionReport {
#####################################################################################################
    my %args = (
	auditID => 0,
	fiscalyear => 50,
	edit => 0,
	@_,
    );
    my $output = "<tr><td colspan=3><table width=100% border=0 cellspacing=4 cellpadding=1>\n";
    $output .= "<tr>" . &addCol(value => "<b>Condition Reports Issued:",colspan=>3,fontSize=>2,valign=>"top");
    $output .= &endRow();
    my @crList = &getConditions(dbh => $args{dbh}, schema => $args{schema}, auditID => $args{auditID}, fiscalyear => $args{fiscalyear},generatedfrom => $args{generatedfrom});
    for (my $i = 0; $i < $#crList; $i++) {
	my ($crid,$crnum,$crlevel,$crsummary,$crdate,$crqard) = 
	($crList[$i]{crid},$crList[$i]{crnum},$crList[$i]{crlevel},$crList[$i]{crsummary},$crList[$i]{crdate},$crList[$i]{crqard});  
	if ($crnum eq '0') {
	      	$output .= "<tr><td valign=top colspan=4><b><font size=-1 color=black>&nbsp;&nbsp;&nbsp;No CRs Issued</font></b></td></tr>";	
	}
      	elsif ($crnum ne '00') {
      		$output .= "<tr><td valign=top><b><font size=-1 color=black>&nbsp;&nbsp;&nbsp;" . ($args{edit} ? "<a href=javascript:submitEditAudit('conditionReports','editCondition',$args{auditID},'$args{table}',$crid,'','');>$crnum</a>" : "$crnum") . "</font></b></td>";
      		$output .= "<td valign=top><b><font size=-1 color=black>Level:&nbsp;" .  ($crlevel eq "N" ? "N/A" : "$crlevel") . "</font></b></td>";
      		$output .= (($crsummary ne "N/A") ? "<td><b><font size=-1 color=black>Summary:&nbsp;$crsummary</font></b></td>" : "<td><b><font size=-1 color=black>Summary:&nbsp;</font></b></td>") ;
      		#$output .= "<td><b><font size=-1 color=black>Summary:&nbsp;$crsummary</font></b></td>";
      		$output .= &addCol(value => "<b><font size=-1 color=black>QA Elements:&nbsp;<font color=black>" . &writeQARD(qard=>$crqard) . "</font></b>",valign=>"top",colspan=>3,fontSize=>2);
      	}
      	else {
      	       $output .= "<tr><td valign=top nowrap><b><font size=-1 color=black>&nbsp;&nbsp;&nbsp;" . ($args{edit} ? "<a href=javascript:submitEditAudit('conditionReports','editCondition',$args{auditID},'$args{table}',$crid,'','');>Number to be assigned</a>" : "Number to be assigned") . "</font></b></td>";
	       $output .= "<td valign=top><b><font size=-1 color=black>Level:&nbsp;" .  ($crlevel eq "N" ? "N/A" : "$crlevel") . "</font></b></td>";
	       $output .= (($crsummary ne "N/A") ? "<td><b><font size=-1 color=black>Summary:&nbsp;$crsummary</font></b></td>" : "<td><b><font size=-1 color=black>Summary:&nbsp;</font></b></td>") ;
      	       $output .= &addCol(value => "<b><font size=-1 color=black>QA Elements:&nbsp;<font color=black>" . &writeQARD(qard=>$crqard) . "</font></b>",valign=>"top",colspan=>3,fontSize=>2);
      	     }
      	      
    }
    $output .= "</table></td></tr>\n";
    return($output);
}
#####################################################################################################
sub writeConditionReportFollowup {
#####################################################################################################
    my %args = (
	auditID => 0,
	fiscalyear => 50,
	single => 0,
	edit => 0,
	@_,
    );
    my $output = "<tr><td colspan=2><table width=100% border=0 cellspacing=4 cellpadding=1>\n";
    $output .= "<tr>" . &addCol(value => "<b>Follow-up to Condition Reports:&nbsp;</b>",colspan=>2,fontSize=>2,valign=>"top");
    $output .= &endRow();
    my @crfuList = &getFollowups(dbh => $args{dbh}, schema => $args{schema}, auditID => $args{auditID}, fiscalyear => substr($args{fiscalyear},-2),single=>$args{single},generatedfrom => $args{generatedfrom});
    for (my $i = 0; $i < $#crfuList; $i++) {
	my ($crfuid,$crnum,$crfunum,$crfusummary) = 
	($crfuList[$i]{crid},$crfuList[$i]{crnum},$crfuList[$i]{followupnum},$crfuList[$i]{followup});  
	$output .= "<tr><td valign=top width=104><b><font size=-1 color=black>&nbsp;&nbsp;&nbsp;" . ($args{edit} ? "<a href=javascript:submitEditAudit('conditionReports','editFollowup',$args{auditID},'$args{table}',$crfuid,$crfunum);>$crnum</a>" : "$crnum") . "</font></b></td>";
	$output .= "<td><b><font size=-1 color=black>$crfusummary</font></b></td></tr>";
    }
    $output .= "</table></td></tr>\n";
    return($output);
}
#####################################################################################################
sub writeConditionReportOQA {
#####################################################################################################
    my %args = (
	auditID => 0,
	fiscalyear => 50,
	edit => 0,
	@_,
    );
  
    my $output = "<tr><td colspan=3><table width=100% border=0 cellspacing=4 cellpadding=1>\n";
    $output .= "<tr>" . &addCol(value => "<b>OQA CR/QARD Summary:",colspan=>3,fontSize=>2,valign=>"top");
    $output .= &endRow();
    my @crList = &getConditions(dbh => $args{dbh}, schema => $args{schema}, auditID => $args{auditID}, fiscalyear => $args{fiscalyear},generatedfrom => $args{generatedfrom});
    for (my $i = 0; $i < $#crList; $i++) {
	my ($crid,$crnum,$crlevel,$crsummary,$crdate,$crqard) = 
	($crList[$i]{crid},$crList[$i]{crnum},$crList[$i]{crlevel},$crList[$i]{crsummary},$crList[$i]{crdate},$crList[$i]{crqard});  

      	if ($crnum eq '00') {
      		
      		$output .= "<tr><td valign=top><b><font size=-1 color=black>" . ($args{edit} ? "<a href=javascript:submitEditAudit('conditionReports','editCondition',$args{auditID},'$args{table}',$crid);>Edit</a>" : "Edit") . "</font></b></td>";
      		$output .= "<td valign=top><b><font size=-1 color=black>Level:&nbsp;" .  ($crlevel eq "N" ? "N/A" : "$crlevel") . "</font></b></td>";
      		$output .= &addCol(value => "<b>QARD Elements:&nbsp;<font color=black>" . &writeQARD(qard=>$crqard) . "</font></b>",valign=>"top",colspan=>3,fontSize=>2);
      		#$output .= &addCol(value => "<b>QARD Elements</b>" . &writeQARD(qard=>$args{qard}),valign=>"top",colspan=>2,fontSize=>2);
      		
      	}
    }
    $output .= "</table></tr>\n";
    return($output);
}
#####################################################################################################
sub writeInternalOrgSelect {
#####################################################################################################
    my %args = (
	auditID => 0,
	fiscalyear => 50,
	table => '',
	@_,
    );   

    my $org = 0;
    my $output = "";
    my @org = &getOrganization(dbh=>$args{dbh},schema=>$args{schema},auditID=>(defined($args{auditID}) ? $args{auditID} : 0) ,fiscalyear => $args{fiscalyear});
    $output .= "<b><font size=-1>Organizations</font></b>\n";
    for (my $i = 0; $i < 7; $i++) {
    	my $orgid = defined($org[$i]{orgid}) ? $org[$i]{orgid} : 0;
    	my @orgLocationList = &getOrgLocation(dbh => $args{dbh}, schema => $args{schema}, auditID => $args{auditID}, fiscalyear => $args{fiscalyear},organizationID => $orgid,table => $args{table});
    	$output .= "<select name=\"org$i\" size=1" . (($i == 0) ? " onChange=showHideBlockSection(value)" : "") . ">\n";
    	$output .= "<option value=0>\n" if ($i > 0);
    	for (my $j = 0; $j < $#orgLocationList; $j++) {
    		if (($orgid) && $orgid == $orgLocationList[$j]{orgid}) {
    			$output .= "<option value=$orgLocationList[$j]{orgid} selected>$orgLocationList[$j]{orgabbr}\n";
    		} elsif (defined($orgLocationList[$j]{orgid})) {
    			$output .= "<option value=$orgLocationList[$j]{orgid}>$orgLocationList[$j]{orgabbr}\n";
    		}
    	}
    	$output .= "</select>\n";   		
    } 
    return($output);
}
#####################################################################################################
sub writeSupplierSelect {
#####################################################################################################
    my %args = (
	auditID => 0,
	fiscalyear => 50,
	table => '',
	@_,
    );   
    my $org = 0;
    my $output = "";
    my $i = 0;
    my @org = &getSupplier(dbh=>$args{dbh},schema=>$args{schema},auditID=>(defined($args{auditID}) ? $args{auditID} : 0),fiscalyear => $args{fiscalyear});
   # $output .= "<tr><td colspan=3><b><font size=-1>" . (($args{table} eq 'internal') ? "Organization(s): " : "Supplier: " ) . "&nbsp;&nbsp;</font></b></td></tr>\n";
    my $orgid = defined($org[$i]{orgid}) ? $org[$i]{orgid} : 0;
    my $supplierid = defined($org[$i]{supplier}) ? $org[$i]{supplierid} : 0;
    my @orgLocationList = &getOrgLocation(dbh => $args{dbh}, schema => $args{schema}, auditID => $args{auditID}, fiscalyear => $args{fiscalyear},supplierID => $supplierid,table => $args{table});
    $output .= "<select name=\"supplier\" size=1>\n";
    for (my $j = 0; $j < $#orgLocationList; $j++) {
    	if ($org[0]{supplierid} == $orgLocationList[$j]{supplierid}) {
    		$output .= "<option value=$orgLocationList[$j]{supplierid} selected>$orgLocationList[$j]{supplier}\n";
    	} elsif (defined($orgLocationList[$j]{supplierid})) {
    		$output .= "<option value=$orgLocationList[$j]{supplierid}>$orgLocationList[$j]{supplier}\n";
    	}
    }
    $output .= "</select>\n";    	

    return($output);
}
#####################################################################################################
sub writeLocationSelect {
#####################################################################################################
    my %args = (
	auditID => 0,
	fiscalyear => 50,
	table => '',
	@_,
    );   
    my @org;
    my @suborg;
    my $org = 0;
    my $counter = $args{table} eq 'internal' ? 7 : 4;
    my $output = "<b><font size=-1>Locations</font></b>\n";
    if ($args{table} eq 'internal') {
     	@org = &getOrganization(dbh=>$args{dbh},schema=>$args{schema},auditID=>(defined($args{auditID}) ? $args{auditID} : 0) ,fiscalyear => $args{fiscalyear});
     	@suborg = &getSuborganization(dbh=>$args{dbh},schema=>$args{schema},auditID=>(defined($args{auditID}) ? $args{auditID} : 0),fiscalyear => $args{fiscalyear});
    } else {
     	@org = &getSupplier(dbh=>$args{dbh},schema=>$args{schema},auditID=>(defined($args{auditID}) ? $args{auditID} : 0),fiscalyear => $args{fiscalyear});
    }
    my @location = &getLocation(dbh=>$args{dbh},schema=>$args{schema},auditID=>(defined($args{auditID}) ? $args{auditID} : 0),fiscalyear => $args{fiscalyear},table=>$args{table});
   # $output .= "<tr><td colspan=3><b><font size=-1>" . (($args{table} eq 'internal') ? "Organization(s): " : "Supplier: " ) . "&nbsp;&nbsp;</font></b></td></tr>\n";
   # $output .= "<tr><td>";
    for (my $i = 0; $i < $counter; $i++) {
    	my $orgid = defined($org[$i]{orgid}) ? $org[$i]{orgid} : 0;
    	my $supplierid = defined($org[$i]{supplier}) ? $org[$i]{supplierid} : 0;
    	my $suborgid = defined($suborg[$i]{suborgid}) ? $suborg[$i]{suborgid} : 0;
    	my @orgLocationList = &getOrgLocation(dbh => $args{dbh}, schema => $args{schema}, auditID => $args{auditID}, fiscalyear => $args{fiscalyear},organizationID => $orgid,supplierID => $supplierid,table => $args{table});
    }
    for (my $i = 0; $i < $counter; $i++) {
    	my $locationid = defined($location[$i]{id}) ? $location[$i]{id} : 0;
    	my @orgLocationList = &getOrgLocation(dbh => $args{dbh}, schema => $args{schema}, auditID => $args{auditID}, fiscalyear => $args{fiscalyear},locationID => $locationid,table=>$args{table});
    	$output .= "<br><select name=\"loc$i\" size=1>\n" . (($i > 0) ? "<option value=0>\n" : "");
    	for (my $j = 0; $j < $#orgLocationList; $j++) {
    		if (defined($orgLocationList[$j]{locationid}) && $locationid == $orgLocationList[$j]{locationid}) {
    			$output .= "<option value=$orgLocationList[$j]{locationid} selected>$orgLocationList[$j]{city} $orgLocationList[$j]{province}, $orgLocationList[$j]{state}\n";
    		} elsif (defined($orgLocationList[$j]{locationid})) {
    			$output .= "<option value=$orgLocationList[$j]{locationid}>$orgLocationList[$j]{city} $orgLocationList[$j]{province}, $orgLocationList[$j]{state}\n";
    		}
    	}
    	$output .= "</select>\n";
    }
    return($output);
}
#####################################################################################################
sub writeSuborgSelect {
#####################################################################################################
    my %args = (
	auditID => 0,
	fiscalyear => 50,
	table => '',
	@_,
    );   
    my $output = "";
    my $i = 1;
    my @org = &getOrganization(dbh=>$args{dbh},schema=>$args{schema},auditID=>(defined($args{auditID}) ? $args{auditID} : 0) ,fiscalyear => $args{fiscalyear});
    my @suborg = &getSuborganization(dbh=>$args{dbh},schema=>$args{schema},auditID=>(defined($args{auditID}) ? $args{auditID} : 0),fiscalyear => $args{fiscalyear});
    $output .= "<b><font size=-1>BSC Suborganization:</font></b><br>\n";
    my $orgid = defined($org[0]{orgid}) ? $org[0]{orgid} : 0;
    my $suborgid = defined($suborg[0]{suborgid}) ? $suborg[0]{suborgid} : 0;
    my @suborgList = &getSuborganization(dbh => $args{dbh}, schema => $args{schema}, auditID=>(defined($args{auditID}) ? $args{auditID} : 0), fiscalyear => $args{fiscalyear});
    my $suborgidList = "(0";
    for my $suborgids (0 .. $#suborg-1) {
    	$suborgidList .= ",$suborg[$suborgids]{suborgid}";
    }
    $suborgidList .= ")";
    my @orgLocationList = &getOrgLocation(dbh => $args{dbh}, schema => $args{schema}, auditID => $args{auditID}, fiscalyear => $args{fiscalyear},table => $args{table}, where => " active = 'T' or id in $suborgidList");

    @suborgList = sort  { $a->{suborg} cmp $b->{suborg} } @suborgList;

    $output .= "<select name=\"suborg\" size=1 multiple" . (($orgid != 1) ? " disabled" : "") . ">\n<option value=0>\n";
    for (my $j = 1; $j <= $#orgLocationList; $j++) {
    	if (($suborgList[$i]{suborgid}) && $suborgList[$i]{suborgid} == $orgLocationList[$j]{suborgid}) {
    		$output .= "<option value=$orgLocationList[$j]{suborgid} selected>$orgLocationList[$j]{suborg}\n";
    		$i++;
    	} elsif (defined($orgLocationList[$j]{suborgid})) {
    		$output .= "<option value=$orgLocationList[$j]{suborgid}>$orgLocationList[$j]{suborg}\n";
    	}
    }
    $output .= "</select><font size=-1>&nbsp;&nbsp;<i>select 0, 1, or many - for BSC internal audits only</i></font>\n";

    return($output);
}
####################################################################################################
sub getInternalAuditDisplayID {
####################################################################################################
    my %args = (
	auditID => 0,
	fiscalyear => 50,
	table => 'I',
	seq => 0,
	type => '',
	issuedby => "",
	issuedto => "",
	edit => 0,
	@_,
    );   
    my $id = "";
    my $type = ($args{fiscalyear} > 2005 ? "" : ($args{type}=~ /^pb/i) ? "P" : ($args{type} eq 'P/PB') ? "P" : ($args{type} =~ /^all/i) ? "C" : "$args{type}");
    my $seq = !$args{seq} && $args{edit} ? "<input type=text name=seq maxlength=2 size=3>" : 
    !$args{seq} ? ($args{issuedby} ne "EM" ? "##" : "###" ) : $args{issuedby} eq "EM" ? lpadzero($args{seq},3) : lpadzero($args{seq},2);

    $id = ($args{fiscalyear} == 2002 || $args{fiscalyear} <= 2007) && $args{issuedby} eq "BSC" ? "BQA$type-$args{issuedto}-" . lpadzero(substr($args{fiscalyear}, 2, 2),2) . "-$seq" :
    $args{fiscalyear} <= 2002 ? "$args{issuedby}-AR$type-" . lpadzero(substr($args{fiscalyear}, 2, 2),2) . "-$seq" : 
    $args{fiscalyear} == 2003 ? $args{issuedby} eq "BSC" ? "BQA$type-$args{issuedto}-" . lpadzero(substr($args{fiscalyear}, 2, 2),2) . "-$seq" :
    "$args{issuedby}$type-$args{issuedto}-" . lpadzero(substr($args{fiscalyear}, 2, 2),2) . "-$seq" :
    $args{issuedby} eq "EM" ? lpadzero(substr($args{fiscalyear}, 2, 2),2) . "-DOE-AU-$seq" :
    ($args{fiscalyear} <= 2007 && $args{issuedby} eq "OCRWM") ? "OQA-$args{issuedto}-" . lpadzero(substr($args{fiscalyear}, 2, 2),2) . "-$seq" :
    $args{fiscalyear} >= 2008 ? "IA-" . lpadzero(substr($args{fiscalyear}, 2, 2),2) . "-$seq" :
    "$args{issuedby}$type-$args{issuedto}-" . lpadzero(substr($args{fiscalyear}, 2, 2),2) . "-$seq";

    
    return ($id);
}
####################################################################################################
sub getExternalAuditDisplayID {
####################################################################################################
    my %args = (
	auditID => 0,
	fiscalyear => 50,
	seq => 0,
	type => '',
	issuedby => "",
	issuedto => "",
	edit => 0,
	@_,
    );   
    my $seq = $args{seq} == 0 && $args{edit} ? "<input type=text name=seq maxlength=2 size=3>" : 
    $args{seq} == 0 ? "##" : 
    ($args{issuedby} eq 'BSC' && $args{fiscalyear} == 2003 && ($args{seq} == 13 || $args{seq} == 17 )) ? 
    lpadzero($args{seq},3) : lpadzero($args{seq},2);
    my $type = ($args{type} =~ /^sa/i) ? ($args{fiscalyear} <= 2007 ? "AS" : "SA") : ($args{type} =~ /^sfe/i) ? "FS" : "$args{type}";
    my $id = $args{fiscalyear} <= 2002 ? "$args{issuedto}-$args{type}-" :
    ($args{fiscalyear} <= 2007 ? ($args{issuedby} eq 'BSC' ? "BQA-$type-" : "$args{issuedby}-$type-") : "$type-");
    $id .= lpadzero(substr($args{fiscalyear}, 2, 2),2) . "-$seq";
    
    return ($id);
}
############################
sub doGetAvailableSequence {
############################
    my %args = (
	issuedby => "",
	flag => 0,
	@_,
    );   
    my $i = 0;
    my $msg;
    my $msg2;
    my $nextSequentialID;
    my @availableID;
    my @sequenceList = &getSequences(dbh => $args{dbh}, schema => $args{schema},fiscalyear => substr($args{fiscalyear},-2),type=>$args{type},table=>$args{table},issuedby=>$args{issuedby});
    for (my $j = 0; $j < $#sequenceList; $j++) { 
    	$nextSequentialID = $sequenceList[$j];
   	$i++;
   	while ($i < $nextSequentialID) {
		@availableID = @availableID + $i;
		$msg .= " " . $i ;
		$i++;
   	}
    }

    $nextSequentialID += 1;
    if ($msg) {
   	$msg2 .= "The following numbers have been skipped: ";
   	$msg2 .= $msg;
    }
    else {$msg2 .= "No sequence numbers have been skipped or deleted.";}
    $msg2 .= " \\nThe next sequential number is " . $nextSequentialID ;
    print "<script language=javascript><!--\n   alert('$msg2');\n//-->\n</script>\n";
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
    my $title;
    if ($args{issuedby} eq 'Other') {
        if ($args{type} eq 'External') {
           $title = "External Assessments by $args{issuedby}";
        }
        else {
           $title = "Internal Assessments by $args{issuedby}";
        }
    }
    else {
           $title = $args{issuedby} eq '' ? "$args{type} Audits Issued" : $args{issuedby} eq 'EM' ? "Audits Issued By EM/RW" : "$args{type} Audits Issued By $args{issuedby}";
    }
    $output .= &endTable if ($args{flag} != 0);
    $output .= "<table cellpadding=2 cellspacing=0 border=1 align=center width=600>\n";
    $output .= "<tr bgcolor=#B0C4DE>\n";
    $output .= &addCol (value => "<font color=black size=3><b>$title</b></font>", colspan=>13,align=>"center");
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
####################################################################################################
sub writeTableHeader {
####################################################################################################
    my %args = (
	issuedby => "",
	flag => 0,
	@_,
    );   
    
    my $output = "";
    my $title;
    if ($args{issuedby} eq 'Other') {
        if ($args{type} eq 'External') {
           $title = "External Assessments by $args{issuedby}";
        }
        else {
           $title = "Internal Assessments by $args{issuedby}";
        }
    }
    else {
           $title = $args{issuedby} eq '' ? "$args{type} Audits Issued" : $args{issuedby} eq 'EM' ? "Audits Issued By EM/RW" : "$args{type} Audits Issued By $args{issuedby}";
    }
    #$output .= &endTable if ($args{flag} != 0);
    #$output .= "<table cellpadding=2 cellspacing=0 border=1 align=center width=600>\n";
    $output .= "<tr bgcolor=#B0C4DE>\n";
    $output .= &addCol (value => "<font color=black size=3><b>$title</b></font>", colspan=>4,align=>"center");    
    $output .= &startRow (bgColor => "#f0f0f0");
    $output .= &addCol (value => "<b>ID</b>",align=>"center");
    $output .= &addCol (value => "<b>Team</b>",align=>"center");
    $output .= &addCol (value => "<b>Scope</b>",align=>"center");
    $output .= &addCol (value => "<b>Status</b>",align=>"center");
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
    $output .= "<font size=-1><b>Fiscal Year:</b><br>\n";
    $output .= "<select name=fy size=1>\n";
    for (my $j = 0; $j < $#fiscalyearList; $j++) {
    	$output .= "<option value=$fiscalyearList[$j]{value} " . (($args{selectedyear} == $fiscalyearList[$j]{value}) ? "selected" : "") . ">$fiscalyearList[$j]{text}";
    }
    $output .= "</select>\n";
	
    return ($output);
}
####################################################################################################################################

###################################################################################################################################


1; #return true
