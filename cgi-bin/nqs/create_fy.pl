#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/nqs/perl/RCS/create_fy.pl,v $
#
# $Revision: 1.2 $
#
# $Date: 2002/09/10 00:55:33 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: create_fy.pl,v $
# Revision 1.2  2002/09/10 00:55:33  starkeyj
# modified so draft internal audit schedules can be created and dropped with
# OQA and BSC being independent of the other's draft schedule
#
# Revision 1.1  2002/07/01 23:49:55  starkeyj
# Initial revision
#
#
use NQS_Header qw(:Constants);
use OQA_Widgets qw(:Functions);
use OQA_Utilities_Lib qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

$ENV{SCRIPT_NAME} =~ m%(.*)/(.*)\..*$%;
my $path = $1;
my $form = $2;

my $NQScgi = new CGI;
my $username = defined($NQScgi->param("username")) ? $NQScgi->param("username") : "GUEST";
my $userid = defined($NQScgi->param("userid")) ? $NQScgi->param("userid") : 0;
my $schema = defined($NQScgi->param('schema')) ? uc($NQScgi->param('schema')) : "NQS";
my $server = defined($NQScgi->param("server")) ? $NQScgi->param("server") : $NQSServer;
my $cgiaction = defined($NQScgi->param('cgiaction')) ? $NQScgi->param('cgiaction') : "remove_fy";
my $create_yr = defined($NQScgi->param('create_yr')) ? $NQScgi->param('create_yr') : "";
my $remove_yr = defined($NQScgi->param('remove_yr')) ? $NQScgi->param('remove_yr') : "";
my $auditing_org = defined($NQScgi->param('org')) ? $NQScgi->param('org') : "";
my $dbh = &NQS_connect();
my @orgid = lookup_column_values($dbh, 'organizations', 'id', "abbr = '$auditing_org'");
my $orgid = $orgid[0];
print STDERR "\n $orgid \n";

print <<END_of_Multiline_Text;
Content-type: text/html

<HTML>
<HEAD>
<script src=$NQSJavaScriptPath/utilities.js></script>
<Title>Data Deficiency Tracking</Title>
<!-- include external javascript code -->
<script src="$NQSJavaScriptPath/utilities.js"></script>
<script type="text/javascript">
<!--
	var dosubmit = true;
   if (parent == self) {    // not in frames
		location = '$NQSCGIDir/login.pl'
   }
//-->

function browse(fy) {
	document.audit.fy.value = fy;
	document.audit.table.value = 'I';
	document.audit.audit_type.value = 'I';
	document.audit.cgiaction.value = 'browse_audits';
	document.$form.action = '$path' + 'audit.pl';
	document.$form.target = 'workspace';
	document.$form.submit();
}
</script>

</head>
END_of_Multiline_Text
print "<Body background=$NQSImagePath/background.gif text=#000099>\n";
print "<center>\n";
print "<form action=\"$NQSCGIDir/create_fy.pl\" method=post name=$form>\n";
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=cgiaction value=$cgiaction>\n";
print "<input type=hidden name=fy>\n";
print "<input type=hidden name=audit_type>\n";

############################
sub create_fy {
############################
   my $sqlquery = "select count(*) from $schema.fiscal_year where fiscal_year = $create_yr ";
   my $csr = $dbh->prepare($sqlquery);
	$csr->execute;
   my @values = $csr->fetchrow_array;
	my $fyExists = $values[0];
   $csr->finish;
   
   if (!$fyExists) {
		$csr = $dbh->do("insert into fiscal_year values ($create_yr)");
	}
}
############################
sub create_seq {
############################
	my $seqname = $_[0];
   my $sqlstring;
   my $csr;
   my $seqExists;
   
   my $new_fy = lpadzero(substr($create_yr,2,2),2);
   my $sqlquery = "select count(*) from all_sequences where sequence_name = upper('" . $seqname . "_" . $new_fy . "_seq') and sequence_owner = upper('$schema')";
   $csr = $dbh->prepare($sqlquery);
	$csr->execute;
   my @values = $csr->fetchrow_array;
	$seqExists = $values[0];
   $csr->finish;
   
   if (!$seqExists) {
		$csr = $dbh->do("create sequence $schema." . $seqname . "_" . lpadzero($new_fy,2) . "_seq nocache");
	}
}

############################
if ($cgiaction eq "remove_fy") {
############################
   my $sqlstring;
   my $msg;
   my $csr;
   my $current_fy;
 
   my $latest_fy = lpadzero(substr($remove_yr,2,2),2);
   my $sqlquery = "select count(*) from $schema.internal_audit where fiscal_year = $latest_fy and issuedby_org_id != $orgid ";

   $dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;

	eval {
		$csr = $dbh->do("delete from $schema.internal_audit_org_loc where fiscal_year = $latest_fy and internal_audit_id in (select id from $schema.internal_audit where fiscal_year = $latest_fy and issuedby_org_id = $orgid)");
		$csr = $dbh->do("delete from $schema.internal_audit where fiscal_year = $latest_fy and issuedby_org_id = $orgid");
	   $csr = $dbh->prepare($sqlquery);
	 	$csr->execute;
	   my @values = $csr->fetchrow_array;
	 	my $dropseq = ($values[0] > 0) ? 0 : 1;
      $csr->finish;
		if ($dropseq) {
			$csr = $dbh->do("drop sequence $schema.audit_" . $latest_fy . "_seq");
		}
      
	};
	if ($@) {
		$dbh->rollback;
		#&log_nqs_error($dbh,$schema,'T',$userid,"$username Error cancelling $table audit $id for fy $fy. $@");
		$msg = "Error removing fy $latest_fy.";
	}
	else {
		$dbh->commit;
		#&log_nqs_activity($dbh,$schema,'F',$userid,"$username cancelled $table audit $id for fy $fy");
		# LOG org and year and person that made change
		$msg = "FY $latest_fy dropped successfully";
	}
	print <<browse2;
	<script language="JavaScript" type="text/javascript">
	<!--
		 alert ('$msg');
		 parent.workspace.location="$NQSCGIDir/utilities.pl?userid=$userid&username=$username&schema=$schema&target=workspace";
	//-->
	</script>
browse2
 
}
############################
elsif ($cgiaction eq "create_schedule") {
############################
   my ($csr, $sth);
   my $msg;
   my $new_fy = $create_yr - 2000;
	my $last_fy = $new_fy - 1;
   $dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
	eval {
		&create_fy();
		&create_seq('Surveillance');
		&create_seq('Request');
		&create_seq('Audit');
		my $sqlstring = "select id,audit_type,issuedto_org_id,scope, ";
		$sqlstring .= "to_date(SUBSTR(TO_CHAR(begin_date,'MM/DD/YYYY'),1,6) || (SUBSTR(TO_CHAR(begin_date,'MM/DD/YYYY'),7,4) + 1), 'MM/DD/YYYY') as newdate, $orgid  ";
		$sqlstring .= "from $schema.internal_audit where fiscal_year = $last_fy and issuedby_org_id = $orgid and revision = 0 ";
		$sqlstring .= "and begin_date IS NOT NULL";
		$sqlstring .= " union select id,audit_type,issuedto_org_id,scope, ";
		$sqlstring .= "to_date(SUBSTR(TO_CHAR(forecast_date,'MM/DD/YYYY'),1,6) || (SUBSTR(TO_CHAR(forecast_date,'MM/DD/YYYY'),7,4) + 1), 'MM/DD/YYYY') as newdate, $orgid ";
		$sqlstring .= "from $schema.internal_audit where fiscal_year = $last_fy and issuedby_org_id = $orgid and revision = 0 ";
   	$sqlstring .= "and begin_date IS NULL order by id";

   	$csr = $dbh->prepare($sqlstring);
		$csr->execute;
		while (my ($id, $type, $issuedTo, $scope, $newDate) = $csr->fetchrow_array) {
			$scope =~ s/\'/\'\'/g;
			$sqlstring = "INSERT INTO $schema.internal_audit (id, audit_type, issuedto_org_id, scope, forecast_date, audit_seq, fiscal_year, revision, issuedby_org_id) "
			             . "VALUES (AUDIT_" . &lpadzero($new_fy, 2) . "_SEQ.NEXTVAL, '$type', $issuedTo, '$scope', '$newDate', "
			             . "0, $new_fy, 0, $orgid)";
			$dbh->do($sqlstring);
			$sqlstring = "SELECT location_id, organization_id FROM $schema.internal_audit_org_loc WHERE fiscal_year = $last_fy "
			             . "AND revision = 0 AND internal_audit_id = $id";
			$sth = $dbh->prepare($sqlstring);
			$sth->execute;
			my $num = 1;
			while (my ($loc, $org) = $sth->fetchrow_array) {
				$sqlstring = "INSERT INTO $schema.internal_audit_org_loc (id, internal_audit_id, fiscal_year, revision";
				my $sqlvalues = " VALUES ($num, AUDIT_" . &lpadzero($new_fy, 2) . "_SEQ.CURRVAL, $new_fy, 0";
			   if (defined($org)) {
			   	$sqlstring .= ", organization_id";
			   	$sqlvalues .= ", $org" ;
			   }
			   if (defined($loc)) {
			   	$sqlstring .= ", location_id";
			   	$sqlvalues .= ", $loc" ;
			   }			   
				$sqlstring .= ")" . $sqlvalues . ")";
				$dbh->do($sqlstring);
				$num++;
			}
		}
	};
	if ($@) {
		$dbh->rollback;
		$msg = "An error occured while creating the draft schedule for fiscal year $create_yr.";
	}
	else {
		$dbh->commit;
		$msg = "The draft schedule for fiscal year $create_yr was created successfully.";
	}
  #Redirect to audit scehedule page for that year and org
  print <<browse_schedule;
  	<script language="JavaScript" type="text/javascript">
  	<!--
  		alert ('$msg');
  		parent.workspace.location="$NQSCGIDir/audit.pl?userid=$userid&username=$username&schema=$schema&cgiaction=browse_audits&audit_type=internal&fy=$create_yr";
  	//-->
  	</script>
browse_schedule
	
}
print<<queryformbottom;
</form>
</center>
</body>
</html>
queryformbottom
&NQS_disconnect($dbh);
exit();



 