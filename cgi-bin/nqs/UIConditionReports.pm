#
# $Source: /data/dev/rcs/qa/perl/RCS/UIConditionReports.pm,v $
#
# $Revision: 1.6 $ 
#
# $Date: 2005/10/31 23:16:41 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: UIConditionReports.pm,v $
# Revision 1.6  2005/10/31 23:16:41  starkeyj
# added 'use UIAudit qw(&writeQARDcheckbox )'
# modified javascript subroutine validateCondition to build the qard string
# modified doCreateCondition and doEditCondition to include the qard elements
# modified getInitialValues to include the qard string
# added new subroutine writeConditionCount
#
# Revision 1.5  2004/12/20 16:52:14  starkeyj
# modified javascript subroutine validateCondition to check for and validate CR numbers entered as 0
# modified doCreateCondition to check for CR numbers entered as 0 and display the text No CRs Issued
#
# Revision 1.4  2004/04/19 19:56:58  starkeyj
# modified writeLevelSelect to include 'N/A'
# modified browseConditions to display 'N/A'
#
# Revision 1.3  2004/04/07 15:01:18  starkeyj
# modified functions to allow the generation of ConditionReports, Followups, and BestPractice from
# audits in addition to surveillances
#
# Revision 1.2  2004/01/25 23:54:24  starkeyj
# added functions to edit Best Practice, CR and Followup to CR
#
# Revision 1.1  2004/01/13 13:55:41  starkeyj
# Initial revision
#
#
package UIConditionReports;
use strict;
#use SharedHeader qw(:Constants);
#use UI_Widgets qw(:Functions);
#use DBShared qw(:Functions);
use OQA_Widgets qw(:Functions);
use OQA_specific qw(:Functions);
use NQS_Header qw(:Constants);
use Tables qw(:Functions);
use DBConditionReports qw(:Functions);
use UIShared qw(:Functions);
use UIAudit qw(&writeQARDcheckbox );
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
      &doBrowseConditions		&doEditCondition	&doCreateCondition
      &doCreateFollowup			&doCreateBestPractice	&doEditFollowup
      &doEditBestPractice 
    )]
);
%EXPORT_TAGS =( 
    Functions => [qw(
      &doHeader                  	&doFooter          	&getInitialValues
      &doBrowseConditions		&doEditCondition	&doCreateCondition
      &doCreateFollowup			&doCreateBestPractice	&doEditFollowup
      &doEditBestPractice 
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
       type => (defined($mycgi->param("type"))) ? $mycgi->param("type") : 0,
       table => (defined($mycgi->param("table"))) ? $mycgi->param("table") : 0,
       survID => (defined($mycgi->param("survID"))) ? $mycgi->param("survID") : 0,
       auditID => (defined($mycgi->param("auditID"))) ? $mycgi->param("auditID") : 0,
       fiscalyear => (defined($mycgi->param("fiscalyear"))) ? $mycgi->param("fiscalyear") : "50",
       crnum => (defined($mycgi->param("crnum"))) ? $mycgi->param("crnum") : "",
       CRid => (defined($mycgi->param("CRid"))) ? $mycgi->param("CRid") : 0,
       funum => (defined($mycgi->param("funum"))) ? $mycgi->param("funum") : 0,
       bpnum => (defined($mycgi->param("bpnum"))) ? $mycgi->param("bpnum") : 0,
       conditiontext => (defined($mycgi->param("conditiontext"))) ? $mycgi->param("conditiontext") : "",
       level => (defined($mycgi->param("level"))) ? $mycgi->param("level") : "",
       qardstring => (defined($mycgi->param("qardstring"))) ? $mycgi->param("qardstring") : "",
       followup => (defined($mycgi->param("followup"))) ? $mycgi->param("followup") : 0,
       followuptext => (defined($mycgi->param("followuptext"))) ? $mycgi->param("followuptext") : "",
       bestpractice => (defined($mycgi->param("bestpractice"))) ? $mycgi->param("bestpractice") : 0,
       bestpracticetext => (defined($mycgi->param("bestpracticetext"))) ? $mycgi->param("bestpracticetext") : "",
       generatorid => (defined($mycgi->param("generatorid"))) ? $mycgi->param("generatorid") : 0,
       generatedfrom => (defined($mycgi->param("generatedfrom"))) ? $mycgi->param("generatedfrom") : "O",
       generatorfy => (defined($mycgi->param("generatorfy"))) ? $mycgi->param("generatorfy") : '50',
       title => (defined($mycgi->param("title"))) ? $mycgi->param("title") : "Condition Report",
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
    function submitEdit(script, command, CRid, funum) {
        document.$form.command.value = command;
        document.$form.CRid.value = CRid;
        document.$form.funum.value = funum;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'workspace';
        document.$form.submit();
    }
    function showHideBlockSection(status) {
  	if (status == "yes") {
  		Reschedule.style.display='';
  		document.$form.rescheduletext.value = '';
  	}
	else {Reschedule.style.display='none';}
    }
    function validateCondition(script, command, crid) {
    	var errors = ""; 
    	var qardstr = "";
    	
    	//alert(document.$form.conditiontext.value);
    	//alert(document.$form.crnum.value);
    	
    	if (isblank(document.$form.crnum.value)) {
		errors += "\\tThe Condition Report must have an ID.\\n";
    	}
    	if (document.$form.crnum.value == '0') {
    		if (confirm("You are about to enter \'No Condition Reports Issued\'.\\n\\nClick OK to continue")) {
    			if (document.$form.conditiontext.value != "") {
    				var textmsg = "The Condition Report Summary text you entered:\\n\\n";
    				textmsg += document.$form.conditiontext.value + "\\n\\n";
    				textmsg += "will be replaced with the text \'No CRs Issued\'.\\n";
    				textmsg += "This will provide consistency on forms and reports\\n\\nClick OK to continue";
    				if (!confirm(textmsg)) 
    					return false;
    			}
    			document.$form.conditiontext.value = "No CRs Issued";
    			document.$form.level.value = "N";
    		} else
    			return false;
    	}  	
    	else {
    	     if (document.$form.conditiontext.value == null || document.$form.conditiontext.value == "") {
		 errors += "\\tThe Condition Summary field must have a value.\\n";
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
    		if (command == 'processUpdateCondition' ) {
    			document.$form.CRid.value = crid;
    		}
		submitFormCGIResults(script,command);
    	}
    }
    function validateFollowup(script, command, crid, funum) {
    	var errors = "";    	
    	if (document.$form.followuptext.value == null || document.$form.followuptext.value == "") {
		errors += "\\tThe Summary field must have a value.\\n";
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
    		if (command == 'processUpdateFollowup' ) {
    			document.$form.CRid.value = crid;
    			document.$form.funum.value = funum;
    		}
		submitFormCGIResults(script,command);
    	}
    }
    function validateBestPractice(script, command) {
    	var errors = "";    	
    	if (document.$form.bestpracticetext.value == null || document.$form.bestpracticetext.value == "") {
		errors += "\\tThe Summary field must have a value.\\n";
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
    $output .= &doStandardHeader(schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'T', includeJSWidgets => 'F');
    
    $output .= "<input type=hidden name=type value=0>\n";
    $output .= "<input type=hidden name=project value=$settings{project}>\n";
    $output .= "<input type=hidden name=table value=$settings{table}>\n";
    $output .= "<input type=hidden name=condition value=$settings{condition}>\n";
    $output .= "<input type=hidden name=CRid value=$settings{CRid}>\n";
    $output .= "<input type=hidden name=crqard value=$settings{crqard}>\n";
    $output .= "<input type=hidden name=funum value=$settings{funum}>\n";
    $output .= "<input type=hidden name=generatedfrom value=$settings{generatedfrom}>\n";
    $output .= "<input type=hidden name=generatorid value=$settings{generatorid}>\n";
    $output .= "<input type=hidden name=survID value=$settings{survID}>\n";
    $output .= "<input type=hidden name=auditID value=$settings{auditID}>\n";
    $output .= "<input type=hidden name=generatorfy value=$settings{fiscalyear}>\n";
    $output .= "<input type=hidden name=fiscalyear value=$settings{fiscalyear}>\n";
    $output .= "<input type=hidden name=qardstring value=$settings{qardstring}>\n";
    #$output .= "<input type=hidden name=server value=$Server>\n";
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
sub doBrowseConditions {  # routine to do display condition reports
###################################################################################################################################
    my %args = (
        project => 0,  # null
        title => 'Condition Report',
        status => 0, # all
        userID => 0, # all
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    my $count = 0;
    my $numColumns = 2;
    my @crList = &getConditions(dbh => $args{dbh}, schema => $args{schema}, single=>0);
     
    $output .= "<table width=650 border=1 cellspacing=1 cellpadding=1>\n";
    $output .= "<tr bgcolor=\"#f0f0f0\"><td colspan=3><b><font size=-1>Condition Reports</font></b></td></tr>\n";
    $output .= &startRow (bgColor => "#f0f0f0");
    $output .= &addCol (value => "<b>CR#</b>",align=>"center");
    $output .= &addCol (value => "<b>Level</b>",align=>"center");
    $output .= &addCol (value => "<b>Summary</b>",align=>"center");
    $output .= &endRow();
    for (my $i = 0; $i < $#crList; $i++) {
    	my ($crid,$crnum,$crlevel,$crsummary,$crdate) = 
      	($crList[$i]{crid},$crList[$i]{crnum},$crList[$i]{crlevel},$crList[$i]{crsummary},$crList[$i]{crdate}); 
      	if ($crnum ne '0' && $crnum ne '00')
      	{
		$output .= "<tr><td width=100><font size=-1><a href=javascript:submitEdit('conditionReports','createFollowup',$crid)>$crnum</a></font></td>";
		$output .= "<td><font size=-1>" . ($crlevel eq "N" ? "N/A" : "$crlevel") . "</font></td>";
		$output .= "<td><font size=-1>$crsummary</font></td></tr>";
	}
    }
    $output .= &endTable;
    
    return($output);
}
###################################################################################################################################
sub doEditCondition {  # routine to edit a condition report
###################################################################################################################################
    my %args = (
        type => 0,  # null
        CRid => 0,
        title => 'Condition Report',
        @_,
    );
    my $output = '';
    my $count = 0;
    my $numColumns = 2;
    my @conditionList = &getConditions(dbh => $args{dbh}, schema => $args{schema}, CRid => $args{CRid},single=>1);
     
    $output .= "<table cellpadding=4 cellspacing=0 border=0 align=center width=700>\n";
    $output .= "<tr>\n";
    $output .= &addCol (value => "<font size=+1>Edit Condition Report</font>", colspan=>$numColumns,align=>"center");
    $output .= &endRow();
    
    my ($id,$crnum,$conditiontext,$level,$qard) = 
    ($conditionList[0]{crid},$conditionList[0]{crnum},$conditionList[0]{crsummary},$conditionList[0]{crlevel},$conditionList[0]{crqard});  
    if ($crnum eq'00') {
    	$output .= "<tr>\n";
    	$output .= &addCol (value => "<br><b>To express 'No Condition Reports Issued,' enter 0 (zero) as the CR #<br>When the CR# is unknown, enter 00 (two zeros) as the CR #</b>",valign=>"top",colspan=>2);
    	$output .= &endRow();
    }
    $output .= "<tr>\n";
    $output .= &addCol (value => "<b>CR #:</b>",valign=>"top");
    if ($crnum eq'00') {
        $output .= &addCol (value => "<input type=text name=crnum value='$crnum'>");
    }
    else {
        $output .= "<input type=hidden name=crnum value='$crnum'>\n";
        $output .= &addCol (value => "<b>$crnum</b>");
    }
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<b>Level:</b>",valign=>"top");
    $output .= &addCol (value => &writeLevelSelect(conditionID => $args{CRid},level=>$level));
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<b>Condition Summary:</b>",valign=>"top");
    $output .= &addCol (value => "<textarea name=conditiontext cols=80 rows=10>$conditiontext</textarea>");
    $output .= &endRow();
    $output .= "<tr>\n" . &addCol(value => &writeQARDcheckbox(qard=>$qard),valign=>"top",colspan=>2,fontSize=>2);
    $output .= &endTable;
    $output .= "<br>\n<center>\n<input type=button name=submitEdit value=Submit onClick=\"validateCondition('conditionReports','processUpdateCondition',$args{CRid})\">\n</center>\n";

    return($output);
}
###################################################################################################################################
sub doCreateCondition {  # routine to create a condition report
###################################################################################################################################
    my %args = (
        type => 0,  # null
        title => 'Condition Report',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    my $numColumns = 2;
     
    $output .= "<table cellpadding=4 cellspacing=0 border=0 align=center width=700>\n";
    $output .= "<tr>\n";
    $output .= &addCol (value => "<font size=+1>Condition Report</font>", colspan=>$numColumns,align=>"center");
    $output .= &endRow();
    
    $output .= "<tr>\n";
    $output .= &addCol (value => "<br><b>To express 'No Condition Reports Issued,' enter 0 (zero) as the CR #<br>When the CR# is unknown, enter 00 (two zeros) as the CR #</b>",valign=>"top",colspan=>2);
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<b>CR #:</b>",valign=>"top");
    $output .= &addCol (value => "<input type=text name=crnum>");
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<b>Level:</b>",valign=>"top");
    $output .= &addCol (value => &writeLevelSelect());
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<b>Condition Summary:</b>",valign=>"top");
    $output .= &addCol (value => "<textarea name=conditiontext cols=80 rows=10></textarea>");
    $output .= &endRow();
    $output .= "<tr>\n" . &addCol(value => &writeQARDcheckbox(qard=>""),valign=>"top",colspan=>2,fontSize=>2);
    $output .= &endRow();
    $output .= &endTable;
    $output .= "<br>\n<center>\n<input type=button name=submitEdit value=Submit onClick=\"validateCondition('conditionReports','processCreateCondition')\">\n</center>\n";

    return($output);
}

###################################################################################################################################
sub doCreateFollowup {  # routine to create follow-up to a condition report
###################################################################################################################################
    my %args = (
        type => 0,  # null
        title => 'Condition Report',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    my $numColumns = 2;
    my @conditionList = &getConditions(dbh => $args{dbh}, schema => $args{schema}, CRid => $args{CRid}, single=>1);     
    my ($crnum,$conditiontext,$level) = 
    ($conditionList[0]{crnum},$conditionList[0]{conditiontext},$conditionList[0]{level});  

    $output .= "<table cellpadding=4 cellspacing=0 border=0 align=center width=700>\n";
    $output .= &addSpacerRow (columns => $numColumns);
    $output .= &addSpacerRow (columns => $numColumns);
    $output .= "<tr>\n";
    $output .= &addCol (value => "<font size=+1>Follow-up to Condition Report</font>", colspan=>$numColumns,align=>"center");
    $output .= &endRow();
    $output .= &addSpacerRow (columns => $numColumns);
    $output .= "<tr>\n";
    $output .= &addCol (value => "<b>CR #:</b>",valign=>"top");
    $output .= &addCol (value => "<b>$crnum</b>");
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<b>Follow-up Summary:</b>",valign=>"top");
    $output .= &addCol (value => "<textarea name=followuptext cols=80 rows=7></textarea>");
    $output .= &endRow();
    $output .= &endTable;
    $output .= "<br>\n<center>\n<input type=button name=submitEdit value=Submit onClick=\"validateFollowup('conditionReports','processCreateFollowup',$args{CRid})\">\n</center>\n";

    return($output);
}
###################################################################################################################################
sub doEditFollowup {  # routine to edit a follow-up to a condition report
###################################################################################################################################
    my %args = (
        type => 0,  # null
        title => 'Condition Report',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    my $numColumns = 2;
    my @followupList = &getFollowups(dbh => $args{dbh}, schema => $args{schema}, CRid => $args{CRid}, funum => $args{funum}, single=>1);     
    my ($crnum,$funum,$followup) = 
    ($followupList[0]{crnum},$followupList[0]{followupnum},$followupList[0]{followup});  

    $output .= "<table cellpadding=4 cellspacing=0 border=0 align=center width=700>\n";
    $output .= &addSpacerRow (columns => $numColumns);
    $output .= &addSpacerRow (columns => $numColumns);
    $output .= "<tr>\n";
    $output .= &addCol (value => "<font size=+1>Follow-up to Condition Report</font>", colspan=>$numColumns,align=>"center");
    $output .= &endRow();
    $output .= &addSpacerRow (columns => $numColumns);
    $output .= "<tr>\n";
    $output .= &addCol (value => "<b>CR #:</b>",valign=>"top");
    $output .= &addCol (value => "<b>$crnum</b>");
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<b>Follow-up Summary:</b>",valign=>"top");
    $output .= &addCol (value => "<textarea name=followuptext cols=80 rows=7>$followup</textarea>");
    $output .= &endRow();
    $output .= &endTable;
    $output .= "<br>\n<center>\n<input type=button name=submitEdit value=Submit onClick=\"validateFollowup('conditionReports','processUpdateFollowup',$args{CRid},$funum)\">\n</center>\n";

    return($output);
}
###################################################################################################################################
sub doCreateBestPractice {  # routine to create a Best Practice
###################################################################################################################################
    my %args = (
        type => 0,  # null
        title => 'Best Practice',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    my $numColumns = 1;
     
    $output .= "<table cellpadding=4 cellspacing=0 border=0 align=center width=700>\n";
    $output .= &addSpacerRow (columns => $numColumns);
    $output .= "<tr>\n";
    $output .= &addCol (value => "<font size=+1>Best Practice</font>", align=>"center");
    $output .= &endRow();
    $output .= &addSpacerRow (columns => $numColumns);
    $output .= "<tr>\n";
    $output .= &addCol (value => "<b>Best Practice Summary:<br></b>");
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<textarea name=bestpracticetext cols=80 rows=4></textarea>");
    $output .= &endRow();
    $output .= &endTable;
    $output .= "<br>\n<center>\n<input type=button name=submitEdit value=Submit onClick=\"validateBestPractice('conditionReports','processCreateBestPractice')\">\n</center>\n";

    return($output);
}
###################################################################################################################################
sub doEditBestPractice {  # routine to update a Best Practice
###################################################################################################################################
    my %args = (
        type => 0,  # null
        title => 'Best Practice',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    my $numColumns = 1; 

    my @bpList = &getBestPractice(dbh => $args{dbh}, schema => $args{schema}, bpnum => $args{bpnum}, single=>1);
    my ($bpid,$bpsummary,$bpdate) = 
    ($bpList[0]{bpid},$bpList[0]{bestpractice},$bpList[0]{bpdate});  
    $output .= "<input type=hidden name=bpnum value=$args{bpnum}>\n";
    $output .= "<table cellpadding=4 cellspacing=0 border=0 align=center width=700>\n";
    $output .= &addSpacerRow (columns => $numColumns);
    $output .= "<tr>\n";
    $output .= &addCol (value => "<font size=+1>Best Practice</font>", align=>"center");
    $output .= &endRow();
    $output .= &addSpacerRow (columns => $numColumns);
    $output .= "<tr>\n";
    $output .= &addCol (value => "<b>Best Practice Summary:<br></b>");
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "<textarea name=bestpracticetext cols=80 rows=4>$bpsummary</textarea>");
    $output .= &endRow();
    $output .= &endTable;
    $output .= "<br>\n<center>\n<input type=button name=submitEdit value=Submit onClick=\"validateBestPractice('conditionReports','processUpdateBestPractice')\">\n</center>\n";

    return($output);
}
#####################################################################################################
sub writeLevelSelect {
#####################################################################################################
    my %args = (
	level => 'A',
	@_,
    );
    my $level;
    my @levelList = ('A','B','C','D','N');
    my $output = "<select name=level size=1>\n";
    for (my $j = 0; $j <= $#levelList; $j++) {
    	$level = $levelList[$j] eq 'N' ? "N/A" : "$levelList[$j]";
    	$output .= "<option value=$levelList[$j]" . (($args{level} eq $levelList[$j]) ? " selected" : "") . ">$level\n";
    }
    $output .= "</select>\n";
    
    return($output);
}
####################################################################################################################################

###################################################################################################################################


1; #return true
