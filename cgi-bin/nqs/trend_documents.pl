#!/usr/local/bin/newperl -w
#
# $Source $
#
# $Revision: 1.12 $
#
# $Date: 2002/04/08 21:13:03 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: trend_documents.pl,v $
# Revision 1.12  2002/04/08 21:13:03  starkeyj
# modified for check of user privileges (took out hard coded values)
#
# Revision 1.11  2002/03/28 22:26:31  starkeyj
# modified for SCR 24 to add a radio button for 'Q' and 'non-Q'
#
# Revision 1.10  2001/12/03 22:34:42  starkeyj
# modified to allow update of issued to org or trended org
#
# Revision 1.9  2001/11/21 18:27:44  starkeyj
# added double quotes to subject and comments variables in valdateForm function
# so entire text is passed
#
# Revision 1.8  2001/11/20 14:46:35  starkeyj
# added more form verification, after exiting fields and on add and update
#
# Revision 1.7  2001/08/29 14:24:58  starkeyj
# Modified to check for valid document type and valid supplier when exiting respective fields
#
# Revision 1.6  2001/08/16 17:23:11  starkeyj
# modified variable 'code' to have two digits instead of one
#
# Revision 1.5  2001/07/09 22:57:00  starkeyj
# added code to requery after an insert, update, or delete on a trend document
#
# Revision 1.4  2001/07/09 19:58:34  starkeyj
# modified order of transactions in eval statements
#
# Revision 1.3  2001/07/09 15:40:39  starkeyj
# changed tablesize from a 75% to 750 so form is the same on smaller screens
#
# Revision 1.2  2001/07/09 14:31:18  starkeyj
# updated to show title
#
# Revision 1.1  2001/07/06 23:04:03  starkeyj
# Initial revision
#
# 

use NQS_Header qw(:Constants);
use NQS_Utilities_Lib qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use strict;
use CGI;
use Time::localtime;


$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $DDTcgi = new CGI;
my $username = defined($DDTcgi->param("username")) ? $DDTcgi->param("username") : "GUEST";
my $userid = defined($DDTcgi->param("userid")) ? $DDTcgi->param("userid") : "None";
my $schema = defined($DDTcgi->param("schema")) ? $DDTcgi->param("schema") : "NQS";
my $Server = defined($DDTcgi->param("server")) ? $DDTcgi->param("server") : $NQSServer;
my $cgiaction = defined($DDTcgi->param("cgiaction")) ? $DDTcgi->param("cgiaction") : "query";
my $doc = $DDTcgi->param('doc');
my $issued = $DDTcgi->param('issuedtoorg');
my $trended = $DDTcgi->param('trendedorg');
my $docdate = $DDTcgi->param('date');
my $semester = $DDTcgi->param('semester');
my $quarter = $DDTcgi->param('quarter');
my $type = $DDTcgi->param('doc_type');
my $int = $DDTcgi->param('int_ext');
my $Qvalue = $DDTcgi->param('Qvalue');
my $comments = $DDTcgi->param('comments');
my $subject = $DDTcgi->param('subject');
my $codeandelement = defined($DDTcgi->param('code')) ? $DDTcgi->param('code') : 0;
my $causeandgroup = defined($DDTcgi->param('cause')) ? $DDTcgi->param('cause') : 0;
my $code = ($codeandelement) ? substr($codeandelement,2) : -1;
my $cause  = ($causeandgroup) ? substr($causeandgroup,1,1) : -1;
my $element = ($codeandelement) ? substr($codeandelement,0,2) : -1;
$element =~ s/^0// ;
my $cause_group = ($causeandgroup) ? substr($causeandgroup,0,1) : -1;
my $hw = $DDTcgi->param('hw');
my $hwproc = $DDTcgi->param('hw_proc');
my $supplier = $DDTcgi->param('supplier');
my $sequence = $DDTcgi->param('seq');
my $buttonpushed = $DDTcgi->param('buttonpushed');
my $statusmsg = defined($DDTcgi->param('statusmsg')) ? $DDTcgi->param('statusmsg') : "";
my $record = defined($DDTcgi->param('record')) ? $DDTcgi->param('record') : "first";
my $doc_count2;
my $doc_count;
my $doccode_count2;
my $doccode_count;
my $ncr_count;
my $recordnum;
my $validSupplier = 0;
my $validCode = 0;
my $validCause = 0;
my $validHW = 0;
my $validHWproc = 0;

my $dbh = &trend_connect();
$userid = get_userid($dbh, $username);
my $userpriv = get_userpriv($dbh, $username);

print <<END_of_Multiline_Text;
Content-type: text/html


<HTML>
<HEAD>
<script src=$NQSJavaScriptPath/utilities.js></script>
<Title>Data Deficiency Tracking</Title>
<script language="JavaScript1.1">
<!--
function validate(f) {
	var msg = "";
	var empty_fields = "";

	for (var i=0; i<f.length; i++) {
		var e = f.elements[i];
		if ((e.type == "text") || (e.type == "textarea") || (e.type == "select-one")) {
	   	if ((e.value == null) || (e.value == "") || (isBlank(e.value))) {
	      	empty_fields += "\\n     " + e.name;
	      	continue;
	    	}
	  	}
	}
	if (!empty_fields) {return true;}
	else {
		msg = "--------------------------------------------------------------\\n";
		msg += "The form was not submitted because of the following error(s):\\n";
		msg += "Please correct the error(s) and resubmit.\\n";
		msg += "-------------------------------------------------------------\\n\\n";
		msg += " - The following required field(s) are empty: ";
		msg += "       " + empty_fields + "\\n";

		alert(msg);
      return false;
	}
}
//-->
</script>
<script language=javascript><!--
function submitForm (script, command) {
	document.$form.cgiaction.value = command;
	document.$form.action = '$path' + script + '.pl';
	document.$form.target = 'workspace';
	document.$form.submit();
}
function query () { 
	if (isBlank(document.$form.doc.value)) {
		id = prompt("Document ID:","");
		id = id.toUpperCase();
	}
	else {
		id = document.$form.doc.value;
		id = id.toUpperCase();
	}
	if ((id != null) && (!(isBlank(id)))) {
		document.$form.doc.value = id;
		document.$form.statusmsg.value = '';
		submitForm('trend_documents', 'query');
	}
}
function requery (script, command, msg, doc, record) {
	alert (msg);
	document.$form.doc.value = doc;
	document.$form.statusmsg.value = msg;
	document.$form.record.value = record;
	document.$form.cgiaction.value = command;
	document.$form.action = '$path' + script + '.pl';
	document.$form.target = 'workspace';
	document.$form.submit();
}
function popup (msg) {
	alert (msg);
}
function update (id, command) {     
	window.open ("", "", "height=300, width=300, status=yes, resize=no, scrollbars=no");
	document.$form.sid.value = id;
	document.$form.target = 'workspace';
	submitForm('trend_documents', command);
}
function validateType(element,s) { 
	s = s.toUpperCase();
	if (s != 'A' && s != 'C' && s != 'CAR' && s != 'D' && s != 'DIR' && s != 'DR'
		&& s != 'NCR' && s != 'PR' && s != 'S' && s != 'O') {
			alert("The document type you entered is not \\nof the type A,C,CAR,D,DIR,DR,NCR,O,PR or S.");
	}
   element.value = s;
}
function validateSupplier (script, command, element, s) {
	s = s.toUpperCase();
	element.value = s;
	if (document.$form.doc_type.value == 'NCR' && !isBlank(s)) {
		document.$form.cgiaction.value = command;
		document.$form.action = '$path' + script + '.pl';
		document.$form.target = 'control';
		document.$form.submit();
	}
}
function validateHW (script, command, element, s) {
	s = s.toUpperCase();
	element.value = s;
	if (document.$form.doc_type.value == 'NCR' && !isBlank(s)) {
		document.$form.cgiaction.value = command;
		document.$form.action = '$path' + script + '.pl';
		document.$form.target = 'control';
		document.$form.submit();
	}
}
function validateHW_proc (script, command, element, s) {
	s = s.toUpperCase();
	element.value = s;
	if (document.$form.doc_type.value == 'NCR' && !isBlank(s)) {
		document.$form.cgiaction.value = command;
		document.$form.action = '$path' + script + '.pl';
		document.$form.target = 'control';
		document.$form.submit();
	}
}
function validateTrendedorg (script, command, element, s) {
	s = s.toUpperCase();
	element.value = s;
	if (!isBlank(s)) {
		document.$form.cgiaction.value = command;
		document.$form.action = '$path' + script + '.pl';
		document.$form.target = 'control';
		document.$form.submit();
	}
}
function validateIssuedtoorg (script, command, element, s) {
   s = s.toUpperCase();
   element.value = s;
   if (!isBlank(s)) {
		document.$form.cgiaction.value = command;
		document.$form.action = '$path' + script + '.pl';
		document.$form.target = 'control';
		document.$form.submit();
	}
}
function validateCode_and_element (script, command, element, s) {
   s = s.toUpperCase();
   element.value = s;
   if (!isBlank(s)) {
   	if (!(isnumeric(s))) {
	   	alert("The Code and Element must be numeric");
   	}
   	else {
			document.$form.cgiaction.value = command;
			document.$form.action = '$path' + script + '.pl';
			document.$form.target = 'control';
			document.$form.submit();
		}
	}
}
function validateCause_and_group (script, command, element, s) {
  	s = s.toUpperCase();
   element.value = s;
   if (!isBlank(s)) {
      var cause = s.substr(1);
      var group = s.substr(0,1);
      if (!(isnumeric(group))) {alert("The Cause Group must be numeric");}
      else {
			document.$form.cgiaction.value = command;
			document.$form.action = '$path' + script + '.pl';
			document.$form.target = 'control';
			document.$form.submit();
		}
	}
}
function submit_document (command) {
	var valid = 1;
	var msg = "";
	var msg2 = "";
	var msg3 = "";
	
	if (isBlank(document.$form.doc.value)) {
		msg2 += "\\n  Document";
		valid = 0;
	}
	if (isBlank(document.$form.doc_type.value)) {
		msg2 += "\\n  Document Type";
		valid = 0;
	}
	if (isBlank(document.$form.date.value)) {
		msg2 += "\\n  Document Date";
		valid = 0;
	}
	if (isBlank(document.$form.issuedtoorg.value)) {
		msg2 += "\\n  Issued To Organization";
		valid = 0;
	}
	if (isBlank(document.$form.trendedorg.value)) {
		msg2 += "\\n  Trended Organization";
		valid = 0;
	}
	if (isBlank(document.$form.int_ext.value)) {
		msg2 += "\\n  Internal / External";
		valid = 0;
	}
	if (isBlank(document.$form.code.value)) {
		msg2 += "\\n  Code";
		valid = 0;
	}
	if (isBlank(document.$form.cause.value)) {
		msg2 += "\\n  Cause";
		valid = 0;
	}
	if (isBlank(document.$form.seq.value)) {
		msg2 += "\\n  Sequence";
		valid = 0;
	}
	if (document.$form.doc_type.value == "NCR") {
		if (isBlank(document.$form.hw.value)) {
			msg2 += "\\n  HW";
			valid = 0;
		}
		if (isBlank(document.$form.hw_proc.value)) {
			msg2 += "\\n  HW Process";
			valid = 0;
		}
		if (isBlank(document.$form.supplier.value)) {
			msg2 += "\\n  Supplier";
			valid = 0;
		}
	}
	if (msg2 != "" || valid == 0 ) {
		msg = "The following fields must have values: " + msg2;
		alert(msg);
	} 
	else {
		document.$form.buttonpushed.value = command;
		document.$form.cgiaction.value = 'validateForm';
		document.$form.action = '$path' + 'trend_documents.pl';
		document.$form.target = 'control';
		document.$form.submit();
	}
	
}
function delete_doc (command) {
   document.$form.target = 'workspace';
	submitForm('trend_documents', command);
}
function stop (f) {
   alert (f.cgiaction.value);
  // return false;
}
function populate_record(id,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,r,s) {
	document.$form.reset();
	document.$form.doc.value = id;
	document.$form.semester.value = g;
	document.$form.quarter.value = f;
	document.$form.hiddensemester.value = g;
	document.$form.hiddenquarter.value = f;
	document.$form.seq.value = e;
	document.$form.issuedtoorg.value = a;
	document.$form.trendedorg.value = b;
	document.$form.int_ext.value = i;
	document.$form.code.value = c;
	document.$form.cause.value = d;
	document.$form.doc_type.value = h;
	document.$form.date.value = j;
	document.$form.comments.value = k;
	document.$form.hw.value = l;
	document.$form.hw_proc.value = m;
	document.$form.supplier.value = n;
	document.$form.subject.value = o;
	if (r == 'Y') {
		document.$form.Qvalue[0].checked = true;
	}
	else {
		document.$form.Qvalue[1].checked = true;
	}
	if (s > 0) {
		document.$form.recordnum.value = s;
	}
	document.$form.olddoc.value = id;
	document.$form.oldseq.value = e;
	document.$form.oldissued.value = a;
	document.$form.oldtrended.value = b;
	document.$form.oldcode.value = c;
	document.$form.oldcause.value = d;
}
function exit() {
	//document.$form.cgiaction.value = 'menu';
	//document.$form.action = '$path' + 'trend_home.pl';
	//document.$form.target = 'workspace';
	//document.$form.submit();
	parent.close();
}
function clear_form() {
	msg.style.visibility='hidden';	
	document.$form.reset();
}
//-->
</script>
</HEAD>
<Body bgcolor=#FFFFEO text=#000099>
<center>
<form action="$NQSCGIDir/trend_documents.pl" method=post name=trend_documents >
<input type=hidden name=statusmsg value=$statusmsg>
<input type=hidden name=username value=$username>
<input type=hidden name=userid value=$userid>
<input type=hidden name=schema value=$schema>
<input type=hidden name=cgiaction value=$cgiaction>
<input type=hidden name=record value=$record>
END_of_Multiline_Text
############################
if ($cgiaction eq "query") {
############################
	my $doc = defined($DDTcgi->param('doc')) ? $DDTcgi->param('doc') : 0;
	my $array_ref;
	$doc=~ s/\'/\'\'/g;
	&display_form();
        
	if ($doc) {
		my $recordcount = 0;
		my $outstring = "";
		my $i = 0;
		my $csr;
		my @values;
		my $code;
		my $comment;

		my $sqlstring = "SELECT dc.issued_to_org, dc.trended_org, dc.element || dc.code as code, ";
		$sqlstring .= "dc.cause_group || dc.cause as cause, dc.sequence, d.quarter, d.semester, ";
		$sqlstring .= "d.doc_type, d.int_ext, to_char(d.doc_date,'MM/DD/YYYY'), d.comments, ";
		$sqlstring .= "n.hardware, n.hw_process, n.supplier, d.subject, d.Q ";
		$sqlstring .= "from $schema.t_doc_code dc, $schema.t_document d, $schema.t_ncr n ";
		$sqlstring .= "where rtrim(d.document) = '$doc' and rtrim(dc.document) = '$doc' ";
		$sqlstring .= "and dc.trended_org = d.trended_org and dc.issued_to_org = d.issued_to_org ";
		$sqlstring .= "and n.trended_org(+) = d.trended_org and n.issued_to_org(+) = d.issued_to_org ";
		$sqlstring .= "and n.document(+) = d.document ";
		
		eval {
			$csr = $dbh->prepare($sqlstring);
			$csr->execute;
			while ( $array_ref = $csr->fetchrow_arrayref) {
				push @values, [@$array_ref];
				$i++;
			}
		};
		if ($@) {
			&log_trend_error($dbh,$schema,'T',$userid,"(user $username) Query Trend Document - Error selecting records for $doc");
			print "<font=+2 color=red><b>Error selecting records for $doc</b></font>\n"; 
		}
		else {
			if ($i == 0) {print "<font=+2 color=red><b>No Records were found for $doc</b></font>\n";}
			elsif ($i > 1) {	
				my $j = 1;
				foreach $array_ref (@values) { 
					$code = lpadzero(@$array_ref[2],3);
					my $params = "'" . $doc. "','" . @$array_ref[0] ."'," ;
					$params .= "'" . @$array_ref[1] ."'," ;
					$params .= "'" . $code ."'," ;
					$params .= "'" . @$array_ref[3] ."'," ; 
					$params .= "'" . @$array_ref[4] ."'," ;
					$params .= "'" . @$array_ref[5] . "'," ;
					$params .= "'" . @$array_ref[6] ."'," ;
					$params .= "'" . @$array_ref[7] . "'," ;
					$params .= "'" . @$array_ref[8] ."'," ;
					$params .= "'" . @$array_ref[9] . "'," ;
					$params .= (@$array_ref[10]) ? "'" . @$array_ref[10] . "'," : "'',";
					$params .= (@$array_ref[11]) ? "'" . @$array_ref[11] ."'," : "''," ;
					$params .= (@$array_ref[12]) ? "'" . @$array_ref[12] . "'," : "''," ;
					$params .= (@$array_ref[13]) ? "'" . @$array_ref[13] . "'," : "'',";
					$params .= "'" . @$array_ref[14] . "'," ;
					$params .= "'" . @$array_ref[15] . "'," ;
					$params .= "$j ";
					$outstring .= "<a href=\"javascript:populate_record($params);\"> Record " . $j;
					$outstring .= "</a>&nbsp;&nbsp;&nbsp;\n";
					if (  ($j) % 3 == 0) {
						$outstring .= "<br>";
					}
					$j++;
				}
				$outstring .= "<br>Record&nbsp;<input name=recordnum type=text maxlength=2 size=2 disabled>\n";
				$outstring .= "of &nbsp<input name=ofrecords type=text maxlength=2 size=2 disabled value=$i>\n";
				print "$outstring <br>\n";
			}
			elsif ($i == 1) {
				print "<br><input type=hidden name=recordnum>\n";
				print "<input type=hidden name=ofrecords>\n";
			}
			if ($i > 0) {
				if ($record eq "first") {$recordnum = 0;}
				else {$recordnum = $i - 1;}
				$code = lpadzero($values[$recordnum][2],3);  
				print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
				print "<!--\n";
				print "	 populate_record('$doc','$values[$recordnum][0]','$values[$recordnum][1]',\n";
				print "'$code', '$values[$recordnum][3]','$values[$recordnum][4]','$values[$recordnum][5]',\n";
				print "'$values[$recordnum][6]' ,'$values[$recordnum][7]','$values[$recordnum][8]',\n";
				print "'$values[$recordnum][9]' ,'$values[$recordnum][10]','$values[$recordnum][11]',\n";
				print "'$values[$recordnum][12]','$values[$recordnum][13]','$values[$recordnum][14]','$values[$recordnum][15]',$recordnum + 1);\n";
				print "//-->\n";
				print "</script>\n";
			}	
		}
	}
	print "</span></td></tr>\n";
	print "</table>\n";
	if ($userpriv eq 'Administrator' ) {
		print "<a href=\"$NQSCGIDir/trend_home.pl?schema=$SCHEMA&username=$username&userid=$userid\">Maintenance</a>\n";
	}
}
############################
if ($cgiaction eq "insert") {
############################
	$dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
	my $error;
	my $errormsg = "";
	my $hiddensemester = $DDTcgi->param('hiddensemester');
	my $hiddenquarter = $DDTcgi->param('hiddenquarter');

	my $documentstring = "select count(*) from $schema.t_document where document = '$doc' \n";
	$documentstring .= "and issued_to_org = '$issued' and trended_org = '$trended'";
	eval {
		my $sth = $dbh->prepare($documentstring); 
		$sth->execute();
		$doc_count = $sth->fetchrow_array();
	};
	if ($@) {
		#$errormsg .= "(user $username) Query Trend Document - Error selecting records from t_document for $doc";
		&log_trend_error($dbh,$schema,'T',$userid,"$username - Query Trend Document - Error selecting records from t_document for $doc");
	}
	else {
		my $doccodestring = "select count(*) from $schema.t_doc_code where document = '$doc' \n";
		$doccodestring .= "and issued_to_org = '$issued' and trended_org = '$trended' and ";
		$doccodestring .= "element = $element and code = $code and ";
		$doccodestring .= "cause_group = $cause_group and cause = '$cause' and sequence = $sequence";
		eval {
			my $sth2 = $dbh->prepare($doccodestring); 
			$sth2->execute();
			$doccode_count = $sth2->fetchrow_array();
		};
		if ($@) {
			#$errormsg .= "(user $username) Query Trend Document - Error selecting records from t_doc_code for $doc \n";
			&log_trend_error($dbh,$schema,'T',$userid,"$username - Query Trend Document - Error selecting records from t_doc_code for $doc - $doccodestring");
		}
		else {
			my $ncrstring = "select count(*) from $schema.t_ncr where document = '$doc' \n";
			$ncrstring .= "and issued_to_org = '$issued' and trended_org = '$trended'";
			eval {
				my $sth3 = $dbh->prepare($ncrstring); 
				$sth3->execute();
				$ncr_count = $sth3->fetchrow_array();
			};
 			if ($@) {
 				#$errormsg .= "(user $username) Query Trend Document - Error selecting records from t_ncr for $doc \n";
				&log_trend_error($dbh,$schema,'T',$userid,"$username -  Query Trend Document - Error selecting records from t_ncr for $doc ");
			}
		}
	}
	&display_form();
	if (!($@)) {
		if ((($doc_count == 0) || ($doc_count == 1)) && ($doccode_count == 0)) {
			my $sqlstring = "INSERT INTO $schema.t_document
				(document,issued_to_org,trended_org,doc_date,
				 semester,quarter,doc_type,int_ext,comments,subject,Q)
				VALUES ('$doc','$issued','$trended',to_date('$docdate','MM/DD/YYYY'),
				'$hiddensemester','$hiddenquarter','$type','$int','$comments','$subject','$Qvalue')";
			my $sqlstring2 = "INSERT INTO $schema.t_doc_code
				(document,issued_to_org,trended_org,element,
				code,cause_group,cause,sequence)
				VALUES ('$doc','$issued','$trended',$element,
				$code,$cause_group,'$cause',$sequence)";
			my $sqlstring3 = "INSERT INTO $schema.t_ncr 
				(document,issued_to_org,trended_org,hardware,hw_process,supplier)
				VALUES ('$doc','$issued','$trended','$hw','$hwproc','$supplier')";

			eval {
				if ($doc_count == 0) {
					my $csr = $dbh->prepare($sqlstring); 
					$error = $csr->execute;
					$csr->finish;
					$dbh->commit;
				}
				my $csr2 = $dbh->prepare($sqlstring2); 
				$error = $csr2->execute;
				$csr2->finish;
				$dbh->commit;
				if ($ncr_count == 0) {
					if (($hw) || ($hwproc)) {
						my $csr3 = $dbh->prepare($sqlstring3); 
						$csr3->execute;
						$csr3->finish;
						$dbh->commit;
					}
				}
			};
			if (!($@)) {
				$dbh->commit;
				&log_trend_activity($dbh,$schema,'F',$userid,"$username added trend document $doc to database");
				$statusmsg = "Record added successfully.";
				$dbh->commit;
			}
			else {
				$dbh->rollback;
				&log_trend_error($dbh,$schema,'T',$userid,"$username - error adding $doc - $@ ");
				$dbh->commit;
				$statusmsg = "Error occurred during insert. Record was not added.";
			}
		}
		else {$statusmsg =  "Record already exists.  Nothing has been added to the database.";}
	}
	else {
		$statusmsg = "Some of the data is not valid.  The record was not added to the database.";
	}
	print "</span></td></tr>\n";
	print "</table><br>\n";
	print <<requery;
	<script language="JavaScript" type="text/javascript">
	<!--
	 	requery('trend_documents','query','$statusmsg','$doc','last');
	//-->
	</script>
requery
}
############################
if ($cgiaction eq "update") {
############################
	$dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
	
	my $olddoc = $DDTcgi->param('olddoc');
	my $oldissued = $DDTcgi->param('oldissued');
	my $oldtrended = $DDTcgi->param('oldtrended');
	my $oldcodeandelement = $DDTcgi->param('oldcode');
	my $oldcauseandgroup = $DDTcgi->param('oldcause');
	my $oldcode = substr($oldcodeandelement,2);
	my $oldcause  = substr($oldcauseandgroup,1,1);
	my $oldelement = substr($oldcodeandelement,0,2);
	$oldelement =~ s/^0// ;
	my $oldcausegroup = substr($oldcauseandgroup,0,1);
	my $oldseq = $DDTcgi->param('oldseq');
	my $hiddensemester = $DDTcgi->param('hiddensemester');
	my $hiddenquarter = $DDTcgi->param('hiddenquarter');
	my $errormsg = "";
	my $sqlstring;
	my $csr;
	
	my $documentstring = "select count(*) from $schema.t_document where document = '$doc' ";
	$documentstring .= "and issued_to_org = '$oldissued' and trended_org = '$oldtrended'";
	
	my $documentstring2 = "select count(*) from $schema.t_document where document = '$doc' ";
	$documentstring2 .= "and issued_to_org = '$issued' and trended_org = '$trended'";
	
	my $doccodestring2 = "select count(*) from $schema.t_doc_code where document = '$doc' ";
	$doccodestring2 .= "and issued_to_org = '$oldissued' and trended_org = '$oldtrended'";
	
	eval {
		my $sth = $dbh->prepare($documentstring); 
		$sth->execute();
		$doc_count = $sth->fetchrow_array();
		
		my $sth2 = $dbh->prepare($documentstring2); 
		$sth2->execute();
		$doc_count2 = $sth2->fetchrow_array();
		
		my $sth3 = $dbh->prepare($doccodestring2); 
		$sth3->execute();
		$doccode_count2 = $sth3->fetchrow_array();
	};
	if ($@) {
		#$errormsg .= "(user $username) Update Trend Document - Error selecting document count where document = $doc \n";
		&log_trend_error($dbh,$schema,'T',$userid,"$username - Update Trend Document - Error selecting document count where document = $doc ");
	}
	else {
		my $doccodestring = "select count(*) from $schema.t_doc_code where document = '$doc' ";
		$doccodestring .= "and issued_to_org = '$oldissued' and trended_org = '$oldtrended' and ";
		$doccodestring .= "element = $oldelement and code = $oldcode and ";
		$doccodestring .= "cause_group = $oldcausegroup and cause = '$oldcause' and sequence = $oldseq ";
		eval {
			my $sth2 = $dbh->prepare($doccodestring); 
			$sth2->execute();
			$doccode_count = $sth2->fetchrow_array();
		};
		if ($@) {
			#$errormsg .= "(user $username) Update Trend Document - Error selecting doc code count where document = $doc \n";
			&log_trend_error($dbh,$schema,'T',$userid,"$username - Update Trend Document - Error selecting doc code count where document = $doccodestring ");
		}
		else {
			my $ncrstring = "select count(*) from $schema.t_ncr where document = '$doc' ";
			$ncrstring .= "and issued_to_org = '$oldissued' and trended_org = '$oldtrended'";
			eval {
				my $sth3 = $dbh->prepare($ncrstring); 
				$sth3->execute();
				$ncr_count = $sth3->fetchrow_array();
			};
			if ($@) {
				#$errormsg .= "(user $username) Update Trend Document - Error selecting ncr count where document = $doc \n";
				&log_trend_error($dbh,$schema,'T',$userid,"$username - Update Trend Document - Error selecting ncr count where document = $doc");
			}
		}
	}
	if (($doccode_count2 > 1) && (($issued ne $oldissued) || ($trended ne $oldtrended))) {
		$sqlstring = "INSERT INTO $schema.t_document
			(document,issued_to_org,trended_org,doc_date,
			 semester,quarter,doc_type,int_ext,comments,subject,Q)
			VALUES ('$doc','$issued','$trended',to_date('$docdate','MM/DD/YYYY'),
		   '$hiddensemester','$hiddenquarter','$type','$int','$comments','$subject','$Qvalue')";
	}
	else {
		$sqlstring = "UPDATE $schema.t_document
			 set doc_date = to_date('$docdate','MM/DD/YYYY'),
			 semester = '$hiddensemester',
			 quarter = '$hiddenquarter',
			 doc_type = '$type',
			 Q = '$Qvalue',
			 int_ext = '$int',
			 comments = '$comments',
			 subject = '$subject',
			 issued_to_org = '$issued',
			 trended_org = '$trended'
			 where document = '$doc' and issued_to_org = '$oldissued' 
			 and trended_org = '$oldtrended'";
	}
	&display_form();
	if (!($@)) {
		if ($olddoc eq $doc)  {
 			my $sqlstring2 = "UPDATE $schema.t_doc_code 
				 set element = $element ,
				 code = $code ,
				 cause_group = $cause_group,
				 cause = '$cause', 
				 sequence = $sequence,
				 issued_to_org = '$issued',
				 trended_org = '$trended'
				 where document = '$doc' and issued_to_org = '$oldissued'
				 and trended_org = '$oldtrended' and element = $oldelement
				 and code = $oldcode and cause_group = $oldcausegroup
				 and cause = '$oldcause' and sequence = $oldseq ";

			my $sqlstring3 = "UPDATE $schema.t_ncr 
				 set hardware = '$hw',
				 hw_process = '$hwproc',
				 supplier = '$supplier',
				 issued_to_org = '$issued',
				 trended_org = '$trended'
				 where document = '$doc' and issued_to_org = '$oldissued'
				 and trended_org = '$oldtrended'";
			eval { 
				if (($doc_count > 0) && ($doccode_count > 0)) {
				   if ($doccode_count2 == 1) {$csr = $dbh->do($sqlstring);}
					elsif ($doccode_count2 > 1 ) {$csr = $dbh->do($sqlstring);}
					my $csr2 = $dbh->do($sqlstring2);
					if ($ncr_count == 1) {my $csr3 = $dbh->do($sqlstring3);}
				}
			};
			if (!($@)) {
				$statusmsg = "Record updated successfully.";
				$dbh->commit;
				&log_trend_activity($dbh,$schema,'F',$userid,"$username updated trend document $doc in database");
				$dbh->commit;
			}
			else {
				$dbh->rollback;
				&log_trend_error($dbh,$schema,'T',$userid,"$username -  Error updating $doc - $@ ");
				$dbh->commit;
				$statusmsg = "Error occurred during update. Record was not updated.";
			}
		}
		else {
			$statusmsg = "This record cannot be updated.";
		}
	}
	else {
		$statusmsg = "Error updating record.";
	}
	print "</span></td></tr>\n";
	print "</table><br>\n";
	print <<requery;
	<script language="JavaScript" type="text/javascript">
	<!--
		requery('trend_documents','query','$statusmsg','$doc','last');
	//-->
	</script>
requery
}
############################
if ($cgiaction eq "delete") {
############################
	$dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
	
	my $errormsg = "";
	my $documentstring = "select count(*) from $schema.t_document where document = '$doc' ";
	$documentstring .= "and issued_to_org = '$issued' and trended_org = '$trended'";
	eval {
		my $sth = $dbh->prepare($documentstring); 
		$sth->execute();
		$doc_count = $sth->fetchrow_array();
	};
	if ($@) {
		#$errormsg .= "(user $username) Delete Trend Document - Error selecting document count where document = $doc \n";
		&log_trend_error($dbh,$schema,'T',$userid,"$username - Delete Trend Document - Error selecting document count where document = $doc ");
	}
	else {
		my $doccodestring = "select count(*) from $schema.t_doc_code where document = '$doc' ";
		$doccodestring .= "and issued_to_org = '$issued' and trended_org = '$trended'";
		eval {
			my $sth2 = $dbh->prepare($doccodestring); 
			$sth2->execute();
			$doccode_count = $sth2->fetchrow_array();
		};
		if ($@) {
			#$errormsg .= "(user $username) Delete Trend Document - Error selecting doc code count where document = $doc \n";
			&log_trend_error($dbh,$schema,'T',$userid,"$username - Delete Trend Document - Error selecting doc code count where document = $doc ");
		}
		else {
			my $ncrstring = "select count(*) from $schema.t_ncr where document = '$doc' ";
			$ncrstring .= "and issued_to_org = '$issued' and trended_org = '$trended'";
			eval {
				my $sth3 = $dbh->prepare($ncrstring); 
				$sth3->execute();
				$ncr_count = $sth3->fetchrow_array();
			};
			if ($@) {
				#$errormsg .= "(user $username) Delete Trend Document - Error selecting ncr count where document = $doc \n";
				&log_trend_error($dbh,$schema,'T',$userid,"$username -  Delete Trend Document - Error selecting ncr count where document = $doc ");
			}
		}
	}
	&display_form();
	if ((!($@)) && ($doc_count > 0)){
		my $sqlstring = "DELETE FROM $schema.t_document
			 where document = '$doc' and issued_to_org = '$issued'
			 and trended_org = '$trended'";

		my $sqlstring2 = "DELETE FROM $schema.t_doc_code 
			  where document = '$doc' and issued_to_org = '$issued'
			  and trended_org = '$trended' and element = '$element'
			  and code = $code and cause_group = $cause_group
			  and cause = '$cause' and sequence = $sequence";

		my $sqlstring3 = "DELETE FROM $schema.t_ncr 
			  where document = '$doc' and issued_to_org = '$issued'
			  and trended_org = '$trended'";

		eval {
			if (($ncr_count > 0) && ($doccode_count == 1)) {
				my $csr3 = $dbh->do($sqlstring3);
				$dbh->commit;
			}
			my $csr2 = $dbh->do($sqlstring2);	
			$dbh->commit;
			if ($doccode_count == 1) {
				my $csr = $dbh->do($sqlstring);
				$dbh->commit;
			}
		};
		if (!($@)) {
			$dbh->commit;
			&log_trend_activity($dbh,$schema,'T',$userid,"user $username deleted trend document $doc from database");
			$dbh->commit;
			$statusmsg = "Record deleted successfully.";
		}
		else {
			$dbh->rollback;
			&log_trend_error($dbh,$schema,'T',$userid,"$username - error deleting $doc - $@ ");
			$dbh->commit;
			$statusmsg = "Error occurred during delete. Record was not deleted.";
		}
	}
	else {
		$statusmsg = "Error occurred during delete. Record was not deleted.";
	}
	print "</span></td></tr>\n";
	print "</table><br>\n";
	print <<requery;
	<script language="JavaScript" type="text/javascript">
	<!--
		requery('trend_documents','query','$statusmsg','$doc', 'last');
	//-->
	</script>
requery
}
############################
if ($cgiaction eq "validateSupplier") {
############################
  	if (!(&validate_supplier($dbh, $schema, $supplier))) {
  		print "<script language=javascript type=text/javascript><!--\n   alert('Invalid Supplier');\n</script>\n";
  	}	 
}
############################
if ($cgiaction eq "validateHW") {
############################
  	if (!(&validate_HW($dbh, $schema, $hw))) {
  		print "<script language=javascript type=text/javascript><!--\n   alert('Invalid HW');\n</script>\n";
  	}	 
  	else {$validHW = 1;}
}
############################
if ($cgiaction eq "validateHW_proc") {
############################
  	if (!(&validate_HW_proc($dbh, $schema, $hwproc))) {
  		print "<script language=javascript type=text/javascript><!--\n   alert('Invalid HW Process');\n</script>\n";
  	}	 
  	else {$validHWproc = 1;}
}
############################
if ($cgiaction eq "validateTrended") {
############################
 	if (!(&validate_supplier($dbh, $schema, $trended)) && !(&validate_org($dbh, $schema, $trended))) {
 		print "<script language=javascript type=text/javascript><!--\n   alert('Invalid Trended Organization');\n</script>\n";
	} 
}
############################
if ($cgiaction eq "validateIssuedto") {
############################
  	if (!(&validate_supplier($dbh, $schema, $issued)) && !(&validate_org($dbh, $schema, $issued))) {
 		print "<script language=javascript type=text/javascript><!--\n   alert('Invalid Issued To Organization');\n</script>\n";
	} 
}
############################
if ($cgiaction eq "validate_code_and_element") {
############################
	if (!(&validate_code_and_element($dbh, $schema, $codeandelement))) {
	 		print "<script language=javascript type=text/javascript><!--\n   alert('Invalid Code and Element');\n</script>\n";
	} 
}
############################
if ($cgiaction eq "validate_cause_and_group") {
############################
	if (!(&validate_cause_and_group($dbh, $schema, $causeandgroup))) {
	 		print "<script language=javascript type=text/javascript><!--\n   alert('Invalid Cause and Group');\n</script>\n";
	} 
}
############################
if ($cgiaction eq "validateForm") {
############################
   my $olddoc = $DDTcgi->param('olddoc');
   my $oldtrended = $DDTcgi->param('oldtrended');
   my $oldissued = $DDTcgi->param('oldissued');
   my $oldcode = $DDTcgi->param('oldcode');
   my $oldcause = $DDTcgi->param('oldcause');
   my $oldseq = $DDTcgi->param('oldseq');
   my $hiddensemester = $DDTcgi->param('hiddensemester');
   my $hiddenquarter = $DDTcgi->param('hiddenquarter');
   my $msg = "";
   my $valid = 1;
	
  	print "<input type=hidden name=doc value=$doc>\n";
	print "<input type=hidden name=trendedorg value=$trended>\n";
	print "<input type=hidden name=issuedtoorg value=$issued>\n";
	print "<input type=hidden name=date value=$docdate>\n";
	print "<input type=hidden name=semester value=$semester>\n";
	print "<input type=hidden name=quarter value=$quarter>\n";
	print "<input type=hidden name=hiddensemester value=$hiddensemester>\n";
	print "<input type=hidden name=hiddenquarter value=$hiddenquarter>\n";
	print "<input type=hidden name=doc_type value=$type>\n";
	print "<input type=hidden name=Qvalue value=$Qvalue>\n";
	print "<input type=hidden name=int_ext value=$int>\n";
	print "<input type=hidden name=code value=$codeandelement>\n";
	print "<input type=hidden name=cause value=$causeandgroup>\n";
	print "<input type=hidden name=subject value=\"$subject\">\n";
	print "<input type=hidden name=comments value=\"$comments\">\n";
	print "<input type=hidden name=seq value=$sequence>\n";
	print "<input type=hidden name=supplier value=$supplier>\n";
	print "<input type=hidden name=hw value=$hw>\n";
	print "<input type=hidden name=hw_proc value=$hwproc>\n";
	print "<input type=hidden name=olddoc value=$olddoc>\n";
	print "<input type=hidden name=oldtrended value=$oldtrended>\n";
	print "<input type=hidden name=oldissued value=$oldissued>\n";
	print "<input type=hidden name=oldcode value=$oldcode>\n";
	print "<input type=hidden name=oldcause value=$oldcause>\n";
	print "<input type=hidden name=oldseq value=$oldseq>\n";
	
	if ($type eq "NCR") {
		if (!(&validate_supplier($dbh, $schema, $issued))) {
		 	$msg .= "\\n - Invalid Supplier";
		 	$valid = 0;
		}
		if (!(&validate_HW($dbh, $schema, $hw))) {
			$msg .= "\\n - Invalid HW ";
			$valid = 0;
		}
		if (!(&validate_HW_proc($dbh, $schema, $hwproc))) {
			$msg .= "\\n - Invalid HW Process";
			$valid = 0;
		}
	}
   my $isdigit = $codeandelement;
   my $isdigit2 = $cause_group;
   if ($isdigit =~ /\D/) {
   	$msg .= "\\n - Invalid Code and Element";
		$valid = 0;
   }
  	elsif (!(&validate_code_and_element($dbh, $schema, $codeandelement))) {
		$msg .= "\\n - Invalid Code and Element";
		$valid = 0;
	}
	if ($isdigit2 =~ /\D/) {
		$msg .= "\\n - Invalid Cause Group";
		$valid = 0;
	}
	elsif (!(&validate_cause_and_group($dbh, $schema, $cause, $cause_group))) {
		$msg .= "\\n - Invalid Cause and Group";
		$valid = 0;
	}
	
  	if (!$valid) {
 		print "<script language=javascript><!--\n   alert('$msg');\n//-->\n</script>\n";
	} 
	else{
	 	#print "<script language=javascript><!--\n   alert('valid document');\n//--></script>\n";
	 	if ($buttonpushed eq 'insert') {
	 		print "<script language=javascript><!--\n submitForm('trend_documents','insert');\n//--></script>\n";
	 	}
	 	elsif ($buttonpushed eq 'update') {
	 		print "<script language=javascript><!--\n submitForm('trend_documents','update');\n//--></script>\n";
	 	}
	}
}
############################
sub display_form {
############################
	my @values;
	my $title;
	my $date;
	my $int_ext;
	my ($hw,$hw_proc,$supplier);
	my $doc_type = $DDTcgi->param('doc_type');
	my ($issuedtoorg,$trendedorg,$element,$code,$cause_group,$cause,$seq,$docid,$Qvalue);
	my $i=1;
	
	print "<input type=hidden name=olddoc>\n";
	print "<input type=hidden name=oldtrended>\n";
	print "<input type=hidden name=oldissued>\n";
	print "<input type=hidden name=oldcode>\n";
	print "<input type=hidden name=oldcause>\n";
	print "<input type=hidden name=oldseq>\n";
	print "<input type=hidden name=hiddensemester>\n";
	print "<input type=hidden name=hiddenquarter>\n";
	print "<input type=hidden name=buttonpushed>\n";
	print "<hr width=80%><br>\n";
   print "<table border=0 align=center width=650>\n";
	print "<tr><td valign=top>\n";
	print "	<b>Document:</b><br>\n";
	print "	<input name=doc type=text maxlength=20 size=18 onBlur=toUpper(this,value)></td>\n";
	print " <td valign=top><b>Type:</b><br>\n";
	print "	<input name=doc_type type=text maxlength=8 size=6 onBlur=validateType(this,value);></td>\n";
	if (defined($Qvalue) && $Qvalue eq 'N') {
		print " <td valign=top><input name=Qvalue type=radio value=Y><b>&nbsp;Q</b><br>\n";
		print " <input name=Qvalue type=radio value=N checked><b>&nbsp;Non-Q</b></td>\n";
	}
	else {
		print " <td valign=top><input name=Qvalue type=radio value=Y checked><b>&nbsp;Q</b><br>\n";
		print " <input name=Qvalue type=radio value=N><b>&nbsp;Non-Q</b></td>\n";
	}
	print " <td valign=top><b>Date:</b><br>\n";
	print "	<input name=date type=text maxlength=10 size=10 onBlur=validateDate(value);>\n";
	print " <td valign=top><b>Semester:</b><br>\n";
	print "	<input name=semester type=text readonly disabled maxlength=10 size=8></td>\n";
	print " <td valign=top><b>Quarter:</b><br>\n";
	print "	<input name=quarter type=text readonly disabled maxlength=10 size=8></td>\n";
	print " </tr>\n";
	print "<tr><td colspan=6 height=20></td></tr>\n";
	print "</table>\n";
			     	
	print "<table border=0 width=700>\n";
	print " <tr><td valign=top width=30%>\n";
	print "	  <table border=1 bordercolor=#00008B align=center cellspacing=0 cellpadding=1 rules=none width=90%>\n";
	print "<th align=center colspan=2><font color=black>Organizations</font><br></th>\n";
	print "	  <tr><td  align=left><b>Issued to Org:</b></td>\n";
	print "   <td><input name=issuedtoorg type=text maxlength=10 size=10 onBlur=validateTrendedorg('trend_documents','validateIssuedto',this,value); ></td>\n";
	print "   </tr><tr><td  align=left><b>Trended Org:</b></td>\n";
	print "   <td><input name=trendedorg type=text maxlength=10 size=10 onBlur=validateIssuedtoorg('trend_documents','validateTrended',this,value);></td>\n";
	print "   </tr><tr><td  align=left><b>Int / Ext:</b></td>\n";
	print "   <td><input name=int_ext type=text maxlength=2 size=10 onBlur=toUpper(this,value)></td>\n";
	print "   </table>\n";
				
	print "<td valign=top width=23%>\n";
	print "	  <table border=1 bordercolor=#00008B align=center cellspacing=0 cellpadding=1 rules=none width=90%>\n";
	print "<th align=center colspan=2><font color=black>Trend Info</font><br></th>\n";
	print "	  <tr><td  align=left><b>Code:</b></td>\n";
	print "   <td><input name=code type=text maxlength=5 size=5 onBlur=validateCode_and_element('trend_documents','validate_code_and_element',this,value);></td>\n";
	print "   </tr><tr><td  align=left><b>Cause:</b></td>\n";
	print "   <td><input name=cause type=text maxlength=5 size=5 onBlur=validateCause_and_group('trend_documents','validate_cause_and_group',this,value);></td>\n";
	print "   </tr><tr><td  align=left><b>Sequence:</b></td>\n";
	print "   <td><input name=seq type=text maxlength=2 size=5></td>\n";
	print "   </tr>\n       </table>\n";
				
	print "<td valign=top width=47% align>\n";
	print "	  <table  border=1 bordercolor=#00008B align=center cellspacing=0 cellpadding=1 rules=none width=90%>\n";
	print "<th align=center colspan=2><font color=black>NCR Info</font><br></th>\n";
	print "	  <tr><td  align=left><b>Hardware:</b></td>\n";
	print "   <td><input name=hw type=text maxlength=10 size=10 onBlur=validateHW('trend_documents','validateHW',this,value);></td></tr>\n";
	print "	  <tr><td  align=left><b>HW Process:</b></td>\n";
	print "   <td><input name=hw_proc type=text maxlength=10 size=10 onBlur=validateHW_proc('trend_documents','validateHW_proc',this,value);></td></tr>\n";
	print "   <tr><td align=left><b>Supplier:</b></td>\n";
	print "   <td><input name=supplier type=text maxlength=10 size=10 onBlur=validateSupplier('trend_documents','validateSupplier',this,value); ></td>\n";
	print "   </tr>\n       </table>\n";
	print "</td></tr>\n";
	print "<tr><td colspan=5 height=20></td></tr>\n";

	print "<tr><td colspan=2 align=left valign=top><b>Subject:</b><br>\n";
	print "   <textarea name=subject  rows=2 cols=55></textarea>\n";
	print "<br><b>Comments:</b><br>\n";
	print "   <textarea name=comments  rows=3 cols=55></textarea></td>\n";
	print "<td align=center><input type=button onClick=clear_form(); value=\" Clear  \">\n";
	print "&nbsp;&nbsp;<input type=button onClick=submit_document('insert') value=\"   Add   \">\n";
	print "&nbsp;&nbsp;<input type=button onClick=submit_document('update') value=\"Update\">\n";
	print "<br><br><input type=button onClick=delete_doc('delete') value=\"Delete\">\n";
	print "&nbsp;&nbsp;<input type=button onClick=query() value=\" Query \">\n";
	print "&nbsp;&nbsp;<input type=button onClick=exit() value=\"    Exit    \"><br><br>\n";
	print "<span id=\"msg\">";
}
print<<queryformbottom;
</form>
</center>
</Body>
</HTML>
queryformbottom
&trend_disconnect($dbh);
exit();

