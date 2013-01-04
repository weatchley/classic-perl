#
# $Source: /data/dev/rcs/qa/perl/RCS/UIMetricReports.pm,v $
#
# $Revision: 1.2 $ 
#
# $Date: 2004/06/14 20:31:31 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: UIMetricReports.pm,v $
# Revision 1.2  2004/06/14 20:31:31  starkeyj
# modified doBrowseAudit to select by scheduled start dates instead of actual start dates, and
# added scheduled start date to surveillance table
#
# Revision 1.1  2004/05/30 22:21:47  starkeyj
# Initial revision
#
#

package UIMetricReports;
use strict;
#use SharedHeader qw(:Constants);
#use UI_Widgets qw(:Functions);
#use DBShared qw(:Functions);
use OQA_Widgets qw(:Functions);
use OQA_specific qw(:Functions);
use NQS_Header qw(:Constants);
use Tables qw(:Functions);
use DBMetricReports qw(:Functions);
use DBAudit qw(getAudit);
use DBSurveillance qw(getSurveillance);
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
      &doBrowseAudit			      
    )]
);
%EXPORT_TAGS =( 
    Functions => [qw(
      &doHeader                  	&doFooter          	&getInitialValues	
      &doBrowseAudit			      
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
       survID => (defined($mycgi->param("survID"))) ? $mycgi->param("survID") : 0,
       selection => (defined($mycgi->param("audit_selection"))) ? $mycgi->param("audit_selection") : "all",
       fiscalyear => (defined($mycgi->param("fiscalyear"))) ? $mycgi->param("fiscalyear") : "50",
       fy => (defined($mycgi->param("fy"))) ? $mycgi->param("fy") : $mycgi->param("fiscalyear"),
       leadid => (defined($mycgi->param("leadid"))) ? $mycgi->param("leadid") : 0,
       team => (defined($mycgi->param("team"))) ? $mycgi->param("team") : "",
       scope => (defined($mycgi->param("scope"))) ? $mycgi->param("scope") : "",
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
       rescheduletext => (defined($mycgi->param("rescheduletext"))) ? $mycgi->param("rescheduletext") : "",
       results => (defined($mycgi->param("results"))) ? $mycgi->param("results") : "",
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
       displayid => (defined($mycgi->param("displayid"))) ? $mycgi->param("displayid") : '',
       tag => (defined($mycgi->param("tag"))) ? $mycgi->param("tag") : "",
       seq => (defined($mycgi->param("seq"))) ? $mycgi->param("seq") : 0,
       metricReport => (defined($mycgi->param("metric_report"))) ? $mycgi->param("metric_report") : 0,
       month => (defined($mycgi->param("month"))) ? $mycgi->param("month") : 0,
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
    function submitView(script,command,fy,id,table) {
        document.$form.table.value = table;
        document.$form.fiscalyear.value = fy;
        document.$form.command.value = command;
        document.$form.auditID.value = id;
        document.$form.survID.value = id;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'workspace';
        document.$form.submit();
    }
END_OF_BLOCK
    $output .= &doStandardHeader(schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'T', includeJSWidgets => 'F');
    
    $output .= "<table border=0 width=750 align=center><tr><td>\n";
    $output .= "<input type=hidden name=auditID>\n";
    $output .= "<input type=hidden name=survID>\n";
    $output .= "<input type=hidden name=table>\n";
    $output .= "<input type=hidden name=fiscalyear>\n";
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
    my $numColumns = 7;
    my $lead;
    my $location;
    my $auditid;
    my $status;
    my @recordList;
    my @org;
    my @suborg;
    my @location;
    my @supplier;
    my $auditFlag = 0;
    my $surveillanceFlag = 0;
    my $table;
    my $display;
    my $actualyear = $settings{month} > 9 && $settings{month} < 13 ? $settings{fiscalyear} - 1 : $settings{fiscalyear};
    my $where;
    if ($settings{metricReport} eq "Internal_Audit") {
    	$where =  " AND to_char(forecast_date,'YYYYMM') = '$actualyear" . lpadzero($settings{month},2) . "'";
    	@recordList = &getAudit(dbh => $args{dbh}, schema => $args{schema},fiscalyear => substr($args{fiscalyear},-2), single=>0, selection=>'all',table=>'internal',where=>$where);
	$auditFlag = 1;
	$table = "internal";
    } elsif ($settings{metricReport} eq "OCRWM_Internal_Audit") {
    	$where =  " AND to_char(forecast_date,'YYYYMM') = '$actualyear" . lpadzero($settings{month},2) . "'";
    	@recordList = &getAudit(dbh => $args{dbh}, schema => $args{schema},fiscalyear => substr($args{fiscalyear},-2), single=>0, selection=>'internal_ocrwm',table=>'internal',where=>$where);
	$auditFlag = 1;
	$table = "internal";
    } elsif($settings{metricReport} eq "BSC_Internal_Audit") {
    	$where =  " AND to_char(forecast_date,'YYYYMM') = '$actualyear" . lpadzero($settings{month},2) . "'";
    	@recordList = &getAudit(dbh => $args{dbh}, schema => $args{schema},fiscalyear => substr($args{fiscalyear},-2), single=>0, selection=>'internal_bsc',table=>'internal',where=>$where);
	$auditFlag = 1;
	$table = "internal";
    } elsif($settings{metricReport} eq "OQA_Internal_Audit") {
    	$where =  " AND to_char(forecast_date,'YYYYMM') = '$actualyear" . lpadzero($settings{month},2) . "'";
    	@recordList = &getAudit(dbh => $args{dbh}, schema => $args{schema},fiscalyear => substr($args{fiscalyear},-2), single=>0, selection=>'internal_oqa',table=>'internal',where=>$where);
	$auditFlag = 1;
	$table = "internal";
    } elsif($settings{metricReport} eq "External_Audit") {
    	$where =  " AND to_char(forecast_date,'YYYYMM') = '$actualyear" . lpadzero($settings{month},2) . "'";
    	@recordList = &getAudit(dbh => $args{dbh}, schema => $args{schema},fiscalyear => substr($args{fiscalyear},-2), single=>0, selection=>'external_all',table=>'external',where=>$where);
	$auditFlag = 1;
	$table = "external";
    } elsif($settings{metricReport} eq "BSC_Surveillance") {
    	$where =  " AND to_char(estbegin_date,'YYYYMM') = '$actualyear" . lpadzero($settings{month},2) . "'";
	@recordList = &getSurveillance(dbh => $args{dbh}, schema => $args{schema},fiscalyear => $args{fiscalyear}, single=>0, selection=>'BSC',where=>$where);
	$surveillanceFlag = 1;
    } elsif($settings{metricReport} eq "OQA_Surveillance") {
    	$where =  " AND to_char(estbegin_date,'YYYYMM') = '$actualyear" . lpadzero($settings{month},2) . "'";
	@recordList = &getSurveillance(dbh => $args{dbh}, schema => $args{schema},fiscalyear => $args{fiscalyear}, single=>0, selection=>'OQA',where=>$where);
	$surveillanceFlag = 1;
    } elsif($settings{metricReport} eq "BSC_Internal_Surveillance") {
    	$where =  " AND to_char(estbegin_date,'YYYYMM') = '$actualyear" . lpadzero($settings{month},2) . "'";
	@recordList = &getSurveillance(dbh => $args{dbh}, schema => $args{schema},fiscalyear => $args{fiscalyear}, single=>0, selection=>'BSC',where=>$where . "AND int_ext = 'I'");
	$surveillanceFlag = 1;
    } elsif($settings{metricReport} eq "OQA_Internal_Surveillance") {
    	$where =  " AND to_char(estbegin_date,'YYYYMM') = '$actualyear" . lpadzero($settings{month},2) . "'";
    	@recordList = &getSurveillance(dbh => $args{dbh}, schema => $args{schema},fiscalyear => $args{fiscalyear}, single=>0, selection=>'OQA',where=>$where . "AND int_ext = 'I'");
	$surveillanceFlag = 1;
    } elsif($settings{metricReport} eq "BSC_External_Surveillance") {
    	$where =  " AND to_char(estbegin_date,'YYYYMM') = '$actualyear" . lpadzero($settings{month},2) . "'";
	@recordList = &getSurveillance(dbh => $args{dbh}, schema => $args{schema},fiscalyear => $args{fiscalyear}, single=>0, selection=>'BSC',where=>$where . "AND int_ext = 'E'");
	$surveillanceFlag = 1;
    } elsif($settings{metricReport} eq "OQA_External_Surveillance") {
    	$where =  " AND to_char(estbegin_date,'YYYYMM') = '$actualyear" . lpadzero($settings{month},2) . "'";
	@recordList = &getSurveillance(dbh => $args{dbh}, schema => $args{schema},fiscalyear => $args{fiscalyear}, single=>0, selection=>'OQA',where=>$where . "AND int_ext = 'E'");
	$surveillanceFlag = 1;
    }
 
    $output .= &writeTableHeader(type=>$settings{metricReport});
    	for (my $i = 0; $i < $#recordList; $i++) {
    		my ($auditid,$fiscalyear,$seq,$type,$issuedto,$leadid,$team,$scope,$forecast,$modified,$approver,$approvaldate,
    		$cancelled,$begindate,$enddate,$completiondate,$notes,$issuedby,$approver2,$approval2date,$reportlink,$qard,
    		$procedures,$reschedule,$results,$title,$state,$adequacy,$implementation,$effectiveness,$supplier,$product,
    		$intext,$surveillanceid,$start,$end,$completed,$scheduled) = 
    		($recordList[$i]{auditid},$recordList[$i]{fy},$recordList[$i]{seq},$recordList[$i]{type},$recordList[$i]{issuedto},
    		$recordList[$i]{lead},$recordList[$i]{team},$recordList[$i]{scope},$recordList[$i]{forecast},$recordList[$i]{modified},
    		$recordList[$i]{approver},$recordList[$i]{approvaldate},$recordList[$i]{cancelled},$recordList[$i]{begindate},
    		$recordList[$i]{enddate},$recordList[$i]{completion_date},$recordList[$i]{notes},$recordList[$i]{issuedby},$recordList[$i]{approver2},
    		$recordList[$i]{approval2date},$recordList[$i]{reportlink},$recordList[$i]{qard},$recordList[$i]{procedures},$recordList[$i]{reschedule},
    		$recordList[$i]{results},$recordList[$i]{title},$recordList[$i]{state},$recordList[$i]{adequacy},$recordList[$i]{implementation},
    		$recordList[$i]{effectiveness},$recordList[$i]{supplier},$recordList[$i]{product},$recordList[$i]{intext},
    		$recordList[$i]{surveillanceid},$recordList[$i]{start},$recordList[$i]{end},$recordList[$i]{completed},$recordList[$i]{estbegindate}); 
      		
 	    	my $suborg;
	    	my $org;
	    	my $issueby = &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedby);
	    	my $issueto = &getIssuedOrg(dbh=>$args{dbh},schema=>$args{schema},orgID=>$issuedto);
	      	
	      	$status = defined($reschedule) ? "Rescheduled" : defined($cancelled) && $cancelled eq 'Y' ? "Cancelled" : defined($state) && $state eq 'Cancelled' ? "Cancelled" : 
	      	defined($completiondate) ? $reportlink ? "Report Approved<br>$completiondate" : "Report Approved<br>$completiondate" : 
	      	defined($state) && $state eq 'Field Work<br>Complete' ? "Field Work<br>Complete $enddate" : defined($state) && $state eq 'In Progress' ? "In Progress<br>$begindate" : defined($forecast) ? 
	      	"Scheduled $forecast" : "$begindate&nbsp;";     	
	      	
	      	if ($leadid != 0) {$lead = &getFullUserName(dbh => $args{dbh}, schema => $args{schema},userID=>$leadid);}
		else {$lead = 'TBD';}
		@org = &getAuditOrganization(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear}) if ($auditFlag && $table eq 'internal');
		@suborg = &getAuditSuborganization(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear}) if ($auditFlag && $table eq 'internal');
	        @location = &getAuditLocation(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear}) if ($auditFlag && $table eq 'internal');
		@org = &getSurveillanceOrganization(dbh=>$args{dbh},schema=>$args{schema},survID=>$surveillanceid,fiscalyear=>$args{fiscalyear}) if ($surveillanceFlag && $intext eq 'I');
		@suborg = &getSurveillanceSuborganization(dbh=>$args{dbh},schema=>$args{schema},survID=>$surveillanceid,fiscalyear=>$args{fiscalyear}) if ($surveillanceFlag && $intext eq 'I');
		@supplier = &getSurveillanceSupplier(dbh=>$args{dbh},schema=>$args{schema},survID=>$surveillanceid,fiscalyear=>$args{fiscalyear}) if ($surveillanceFlag && $intext eq 'E');
        	@location = &getSurveillanceLocation(dbh=>$args{dbh},schema=>$args{schema},survID=>$surveillanceid,fiscalyear=>$args{fiscalyear}) if ($surveillanceFlag);
	        for (my $j = 0; $j < $#org; $j++) {
	    		$org .= (($j != 0) ? ", " : "") . "$org[$j]{orgabbr}";
	        }
	        for (my $j = 0; $j < $#location; $j++) {
	    		$location .= (($j != 0) ? "; " : "") . "$location[$j]{city}, $location[$j]{state}";
	        }
	       	@suborg = &getAuditSuborganization(dbh=>$args{dbh},schema=>$args{schema},auditID=>$auditid,fiscalyear=>$args{fiscalyear}) if ($auditFlag && $table eq 'internal');
		@suborg = &getSurveillanceSuborganization(dbh=>$args{dbh},schema=>$args{schema},survID=>$surveillanceid,fiscalyear=>$args{fiscalyear}) if ($surveillanceFlag && $intext eq 'I');
	   	for (my $j = 0; $j < $#suborg; $j++) {
	   		$suborg .= (($j != 0) ? ", " : "") . "$suborg[$j]{suborg}";
	   	}

	   	$display = getInternalAuditDisplayID(issuedby=>$issueby,issuedto=>$issueto,table=>$args{table},fiscalyear=>$args{fiscalyear},seq=>$seq,type=>$type) if ($auditFlag && $table eq 'internal');
	   	$display = getExternalAuditDisplayID(issuedby=>$issueby,issuedto=>$issueto,table=>$args{table},fiscalyear=>$args{fiscalyear},seq=>$seq,type=>$type) if ($auditFlag && $table eq 'external');
	   	$display = getSurveillanceDisplayID(issuedby=>$issueby,issuedto=>$issueto,intext=>$intext,fiscalyear=>$args{fiscalyear},seq=>$seq) if ($surveillanceFlag);
	      	$output .= "<tr>\n";
	      	my $id = $auditFlag ? $auditid : $surveillanceid;
	      	my $script = $auditFlag ? "audit2" : "surveillance2";
	      	my $command = $auditFlag ? "viewAudit" : "viewSurveillance";
    		$output .= &addCol (value => "$display&nbsp;",url=>"javascript:submitView('$script','$command',$args{fiscalyear},$id,'$table')",align=>"center nowrap");
		$output .= &addCol (value => "Organization: $org<br>" . (($suborg) ? "Suborganization:&nbsp;$suborg<br>" : "") . (defined($title) ? "$title" : "$scope"),valign=>"top") if ($surveillanceFlag && $intext eq 'I');
		$output .= &addCol (value => "Supplier: $supplier[0]{supplier}<br>" . (defined($title) ? "$title" : "$scope"),valign=>"top") if ($surveillanceFlag && $intext eq 'E');
		$output .= &addCol (value => "Organization: $org<br>" . (($suborg) ? "Suborganization:&nbsp;$suborg<br>" : "") . (defined($title) ? "$title" : "$scope"),valign=>"top") if ($auditFlag && $table eq 'internal');
		$output .= &addCol (value => "Supplier: $supplier[0]{supplier}<br>" . (defined($title) ? "$title" : "$scope"),valign=>"top") if ($auditFlag && $table eq 'external');
    		$output .= &addCol (value => "$status",align=>"center");
    		$output .= &addCol (value => ($auditFlag ? "$completiondate&nbsp;" : "$completed&nbsp;"),align=>"center");
    		$output .= &addCol (value => ($auditFlag ? "$forecast&nbsp;" : "$scheduled&nbsp;"),align=>"center");
    		$output .= &addCol (value => ($auditFlag ? "$begindate&nbsp;" : "$start&nbsp;"),align=>"center");
    		$output .= &addCol (value => ($auditFlag ? "$enddate&nbsp;" : "$end&nbsp;"),align=>"center");
	    	$output .= &endRow();
	}
	$output .= &endTable;
 
 
    return($output);
}

#####################################################################################################
sub writeState {
#####################################################################################################
    my %args = (
	state => "Scheduled",
	@_,
    );	
    my @stateList = ("Scheduled","In Progress","Field Work Complete","Cancelled");
    my $output = "<select name=state size=1>\n<option value=''>\n";
    for (my $j = 0; $j <= $#stateList; $j++) {
    	$output .= "<option value='$stateList[$j]'" . (($args{state} eq $stateList[$j]) ? " selected" : "") . ">$stateList[$j]";
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
    my @IssuedtoList = &getLookupValues(dbh => $args{dbh}, schema => $args{schema}, tablename => 'organizations', value => 'id', text => 'abbr', where => " issued_to_list = 'T' or id = $args{issuedto} ");
    my $output = "<select name=issuedto size=1>\n"; #<option value=0>\n";
    for (my $j = 0; $j < $#IssuedtoList; $j++) {
    	$output .= "<option value=$IssuedtoList[$j]{value} " . (($args{issuedto} == $IssuedtoList[$j]{value}) ? "selected" : "") . ">$IssuedtoList[$j]{text}";
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
    my @IssuedbyList = &getLookupValues(dbh => $args{dbh}, schema => $args{schema}, tablename => 'organizations', value => 'id', text => 'abbr', where =>  " abbr in ('OQA','BSC') ");
    my $output = "<select name=issuedby size=1>\n"; #<option value=0>\n";
    for (my $j = 0; $j < $#IssuedbyList; $j++) {
    	$output .= "<option value=$IssuedbyList[$j]{value} " . (($args{issuedby} == $IssuedbyList[$j]{value}) ? "selected" : "") . ">$IssuedbyList[$j]{text}";
    }
    $output .= "</select>\n";
    
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
    my $type = ($args{type}=~ /^pb/i) ? "P" : ($args{type} eq 'P/PB') ? "P" : ($args{type} =~ /^all/i) ? "C" : "$args{type}";
    my $seq = !$args{seq} && $args{edit} ? "<input type=text name=seq maxlength=2 size=3>" : 
    !$args{seq} ? ($args{issuedby} ne "EM" ? "##" : "###" ) : $args{issuedby} eq "EM" ? lpadzero($args{seq},3) : lpadzero($args{seq},2);

    $id = $args{fiscalyear} == 2002 && $args{issuedby} eq "BSC" ? "BQA$type-$args{issuedto}-" . lpadzero(substr($args{fiscalyear}, 2, 2),2) . "-$seq" :
    $args{fiscalyear} <= 2002 ? "$args{issuedby}-AR$type-" . lpadzero(substr($args{fiscalyear}, 2, 2),2) . "-$seq" : 
    $args{fiscalyear} == 2003 ? $args{issuedby} eq "BSC" ? "BQA$type-$args{issuedto}-" . lpadzero(substr($args{fiscalyear}, 2, 2),2) . "-$seq" :
    "$args{issuedby}$type-$args{issuedto}-" . lpadzero(substr($args{fiscalyear}, 2, 2),2) . "-$seq" :
    $args{issuedby} eq "EM" ? lpadzero(substr($args{fiscalyear}, 2, 2),2) . "-DOE-AU-$seq" :
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
    $args{seq} == 0 ? "##" : lpadzero($args{seq},2);
    my $type = ($args{type} =~ /^sa/i) ? "AS" : ($args{type} =~ /^sfe/i) ? "FS" : "$args{type}";
    my $id = $args{fiscalyear} <= 2002 ? "$args{issuedto}-$args{type}-" :
    ($args{issuedby} eq 'BSC' ? "BQA-$type-" : "$args{issuedby}-$type-");
    $id .= lpadzero(substr($args{fiscalyear}, 2, 2),2) . "-$seq";
    
    return ($id);
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
    my $title = $args{type} . 's';
    $title =~ s/\_/ /g;
    $output .= &endTable if ($args{flag} != 0);
    $output .= "<table cellpadding=2 cellspacing=0 border=1 align=center width=750>\n";
    $output .= "<tr bgcolor=#B0C4DE>\n";
    $output .= &addCol (value => "<font color=black size=3><b>$title</b></font>", colspan=>7,align=>"center");
    $output .= &endRow();
    $output .= &startRow (bgColor => "#f0f0f0");
    $output .= &addCol (value => "<b>ID</b>",align=>"center");
    $output .= &addCol (value => "<b>Scope</b>",align=>"center");
    $output .= &addCol (value => "<b>Status</b>",align=>"center");
    $output .= &addCol (value => "<b>Report Approved</b>",align=>"center");
    $output .= &addCol (value => "<b>Scheduled</b>",align=>"center");
    $output .= &addCol (value => "<b>Start</b>",align=>"center");
    $output .= &addCol (value => "<b>End</b>",align=>"center");
    $output .= &endRow();
    
    return ($output);
}

####################################################################################################################################

###################################################################################################################################


1; #return true
