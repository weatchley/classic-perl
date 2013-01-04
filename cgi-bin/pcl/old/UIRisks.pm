#
# $Source:  $
#
# $Revision:  $ 
#
# $Date:  $
#
# $Author:  $
#
# $Locker:  $
#
# $Log:  $
#
package UIRisks;
use strict;
use SharedHeader qw(:Constants);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use Tables qw(:Functions);
use DBRisks qw(:Functions);
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
      &doBrowseRisks		 	&doEditRisk		&doCreateRisk	
      &doRiskHistory
      
    )]
);
%EXPORT_TAGS =( 
    Functions => [qw(
      &doHeader                  	&doFooter          	&getInitialValues	
      &doBrowseRisks		 	&doEditRisk		&doCreateRisk
      &doRiskHistory
      
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
       itemType => (defined($mycgi->param("type"))) ? $mycgi->param("type") : 0,
       project => (defined($mycgi->param("project"))) ? $mycgi->param("project") : 0,
       risk => (defined($mycgi->param("risk"))) ? $mycgi->param("risk") : 0,
       risktext => (defined($mycgi->param("risktext"))) ? $mycgi->param("risktext") : "",
       status => (defined($mycgi->param("status"))) ? $mycgi->param("status") : "",
       impact => (defined($mycgi->param("impact"))) ? $mycgi->param("impact") : "",
       probability => (defined($mycgi->param("probability"))) ? $mycgi->param("probability") : "",
       contingency => (defined($mycgi->param("contingency"))) ? $mycgi->param("contingency") : "",
       title => (defined($mycgi->param("title"))) ? $mycgi->param("title") : "Risk",
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
    function submitEditRisk(script, command, risk) {
        document.$form.command.value = command;
        document.$form.risk.value = risk;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }

    function validateRisk(script, command) {
    	var errors = "";
    	var msg;
    	if (isblank(document.$form.risktext.value)) {
		errors += "\\tThe Risk text area must contain a value.\\n";
    	}
    	if (document.$form.contingency.value == null || document.$form.contingency.value == "") {
		errors += "\\tThe Contingency text area must contain a value.\\n";
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
    $output .= "<input type=hidden name=risk value=$settings{risk}>\n";
    $output .= "<input type=hidden name=projectID value=0>\n";
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
sub doBrowseRisks {  # routine to do display project risks
###################################################################################################################################
    my %args = (
        project => 0,  # null
        title => 'Risks',
        status => 0, # all
        userID => 0, # all
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    my $count = 0;
    my $numColumns = 2;
    my @riskList = &getRisks(dbh => $args{dbh}, schema => $args{schema}, project => $args{project},single=>0);
     
    $output .= "<table cellpadding=0 cellspacing=0 border=0 align=center width=600>\n";
    $output .= "<tr>\n";
    $output .= &addCol (value => "<font size=+1>Risks</font>", colspan=>$numColumns,align=>"center");
    $output .= &endRow();
    $output .= &addSpacerRow (columns => $numColumns);
    
    for (my $i = 0; $i < $#riskList; $i++) {
    	my ($riskid,$version,$risk,$probability,$impact,$status,$contingency) = 
      	($riskList[$i]{riskid},$riskList[$i]{version},$riskList[$i]{risk},$riskList[$i]{probability},
      	$riskList[$i]{impact},$riskList[$i]{status},$riskList[$i]{contingency});  
      	
      	$output .= "<tr>\n";
      	$output .= &addCol (value => "<b>Risk:</b>",url => "javascript:submitEditRisk('risks','editRisk',$riskid)");
	$output .= &addCol (value => "<font color=black>$risk</font>");
    	$output .= &endRow();
       	$output .= "<tr>\n";
       	$output .= &addCol (value => "<b>Probability:</b>");
 	$output .= &addCol (value => "<font color=black>$probability</font>");
    	$output .= &endRow();
       	$output .= "<tr>\n";
       	$output .= &addCol (value => "<b>Impact:</b>");
 	$output .= &addCol (value => "<font color=black>$impact</font>");
    	$output .= &endRow();
       	$output .= "<tr>\n";
       	$output .= &addCol (value => "<b>Contingency Plan:</b>");
 	$output .= &addCol (value => "<font color=black>$contingency</font>");
    	$output .= &endRow();    
      	$output .= "<tr>\n";
      	$output .= &addCol (value => "<b>History</b>",url => "javascript:submitEditRisk('risks','riskHistory',$riskid)");
	$output .= &addCol (value => "<font color=black>&nbsp;</font>");
    	$output .= &endRow();
    	$output .= &addSpacerRow (columns => $numColumns,height => 15);
    }
    $output .= &endTable;
    $output .= "<br><center><a href=javascript:submitForm('risks','createRisk')>Add Risk</a></center>\n";
    
    return($output);
}
###################################################################################################################################
sub doEditRisk {  # routine to edit a risk
###################################################################################################################################
    my %args = (
        project => 0,  # null
        risk => 0,
        title => 'Risks',
        status => 0, # all
        userID => 0, # all
        @_,
    );
    my $output = '';
    my $count = 0;
    my $numColumns = 2;
    my @riskList = &getRisks(dbh => $args{dbh}, schema => $args{schema}, risk => $args{risk},single=>1);
     
    $output .= "<table cellpadding=4 cellspacing=0 border=0 align=center width=700>\n";
    $output .= "<tr>\n";
    $output .= &addCol (value => "<font size=+1>Edit Risk</font>", colspan=>$numColumns,align=>"center");
    $output .= &endRow();
    
    my ($id,$version,$risk,$probability,$impact,$status,$contingency) = 
    ($riskList[0]{id},$riskList[0]{version},$riskList[0]{risk},$riskList[0]{probability},
    $riskList[0]{impact},$riskList[0]{status},$riskList[0]{contingency});  

    $output .= "<tr>\n";
    $output .= &addCol (value => "Risk:",valign=>"top");
    $output .= &addCol (value => "<textarea name=risktext cols=80 rows=3>$risk</textarea>");
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Probability:");
    $output .= &addCol (value => &buildHighMedLowSelect(selected => $probability, name => 'probability'));
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Impact:");
    $output .= &addCol (value => &buildHighMedLowSelect(selected => $impact, name => 'impact'));
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Contingency Plan:",valign=>"top");
    $output .= &addCol (value => "<textarea name=contingency cols=80 rows=3>$contingency</textarea>");
    $output .= &endRow();      	
    $output .= "<tr>\n";
    $output .= &addCol (value => "Status:");
    $output .= &addCol (value => &buildStatusSelect(selected => $status, name => 'status'));
    $output .= &endTable;
    $output .= "<br>\n<center>\n<input type=button name=submitEdit value=Submit onClick=\"validateRisk('risks','processUpdateRisk')\">\n</center>\n";

    return($output);
}
###################################################################################################################################
sub doCreateRisk {  # routine to create a risk
###################################################################################################################################
    my %args = (
        project => 0,  # null
        title => 'Risks',
        status => 0, # all
        userID => 0, # all
        @_,
    );
     my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    my $count = 0;
    my $numColumns = 2;
     
    $output .= "<table cellpadding=4 cellspacing=0 border=0 align=center width=700>\n";
    $output .= "<tr>\n";
    $output .= &addCol (value => "<font size=+1>Risks</font>", colspan=>$numColumns,align=>"center");
    $output .= &endRow();
    
    $output .= "<tr>\n";
    $output .= &addCol (value => "Risk:",valign=>"top");
    $output .= &addCol (value => "<textarea name=risktext cols=80 rows=3></textarea>");
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Probability:");
    $output .= &addCol (value => &buildHighMedLowSelect(name => 'probability'));
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Impact:");
    $output .= &addCol (value => &buildHighMedLowSelect(name => 'impact'));
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Contingency Plan:",valign=>"top");
    $output .= &addCol (value => "<textarea name=contingency cols=80 rows=3></textarea>");
    $output .= &endRow();      	
    $output .= "<tr>\n";
    $output .= &addCol (value => "Status:");
    $output .= &addCol (value => &buildStatusSelect(name => 'status'));
    $output .= &endTable;
    $output .= "<br>\n<center>\n<input type=button name=submitEdit value=Submit onClick=\"validateRisk('risks','processCreateRisk')\">\n</center>\n";

    return($output);
}
###################################################################################################################################
sub doRiskHistory {  # routine to do display the history of a project risk
###################################################################################################################################
    my %args = (
        project => 0,  # null
        title => 'Risks',
        risk => 0,
        status => 0, # all
        userID => 0, # all
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    my $count = 0;
    my $numColumns = 2;
    my @historyList = &getRiskHistory(dbh => $args{dbh}, schema => $args{schema}, risk => $args{risk});
     
    $output .= "<table cellpadding=0 cellspacing=0 border=0 align=center width=600>\n";
    $output .= "<tr>\n";
    $output .= &addCol (value => "<font size=+1>Risk History</font>", colspan=>$numColumns,align=>"center");
    $output .= &endRow();
    $output .= &addSpacerRow (columns => $numColumns);
    
    for (my $i = 0; $i < $#historyList; $i++) {
    	my ($version,$risk,$probability,$impact,$status,$contingency,$datemodified) = 
      	($historyList[$i]{version},$historyList[$i]{risk},$historyList[$i]{probability},
      	$historyList[$i]{impact},$historyList[$i]{status},$historyList[$i]{contingency},
      	$historyList[$i]{datemodified});  
      	
      	$output .= "<tr>\n";
	$output .= &addCol (value => "<b>Version:&nbsp;&nbsp$version</b>");
	$output .= &addCol (value => "Modified:&nbsp;&nbsp;$datemodified");
    	$output .= &endRow();    
      	$output .= "<tr>\n";
      	$output .= &addCol (value => "<b>Risk:</b>");
	$output .= &addCol (value => "<font color=black>$risk</font>");
    	$output .= &endRow();
       	$output .= "<tr>\n";
       	$output .= &addCol (value => "<b>Probability:</b>");
 	$output .= &addCol (value => "<font color=black>$probability</font>");
    	$output .= &endRow();
       	$output .= "<tr>\n";
       	$output .= &addCol (value => "<b>Impact:</b>");
 	$output .= &addCol (value => "<font color=black>$impact</font>");
    	$output .= &endRow();
       	$output .= "<tr>\n";
       	$output .= &addCol (value => "<b>Contingency Plan:</b>");
 	$output .= &addCol (value => "<font color=black>$contingency</font>");
    	$output .= &endRow();    
    	$output .= &addSpacerRow (columns => $numColumns,height => 15);
    }
    $output .= &endTable;
    
    return($output);
}
###################################################################################################################################
sub buildHighMedLowSelect {
###################################################################################################################################
	my %args = (
		name => "priority",
		selected => "",
		@_,
	);
	my $output = "<select name=$args{name}";
	$output .= (defined($args{disabled}) && $args{disabled} gt "") ? " disabled" : "";
	$output .= ">\n";
	my $selected = "";
	foreach my $priority ("High","Medium", "Low") {
		$selected = ($args{selected} gt "" && $args{selected} eq $priority) ? " selected" : ""; 
		$output .= "<option value=\"$priority\"$selected>$priority</option>\n";
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
	my $output = "<select name=$args{name}";
	$output .= (defined($args{disabled}) && $args{disabled} gt "") ? " disabled" : "";
	$output .= ">\n";
	my $selected = "";
	foreach my $status ("Active","Inactive") {
		$selected = ($args{selected} gt "" && $args{selected} eq $status) ? " selected" : ""; 
		$output .= "<option value=\"$status\"$selected>$status</option>\n";
	}
	$output .= "</select>\n";
	return($output);
}
####################################################################################################################################

###################################################################################################################################


1; #return true
