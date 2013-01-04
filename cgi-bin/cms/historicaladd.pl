#!/usr/local/bin/newperl
#
# CMS Historical Commitment Association Screen
#
# $Source: /data/dev/cirs/perl/RCS/historicaladd.pl,v $
# $Revision: 1.1 $
# $Date: 2001/01/30 22:57:41 $
# $Author: naydenoa $
# $Locker:  $
#
# $Log: historicaladd.pl,v $
# Revision 1.1  2001/01/30 22:57:41  naydenoa
# Initial revision
#
#
#

use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);
use Edit_Screens;
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use Tie::IxHash;
use strict;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
tie my %lookup_values, "Tie::IxHash";

my $cmscgi = new CGI;

$SCHEMA = (defined($cmscgi->param("schema"))) ? $cmscgi->param("schema") : $SCHEMA;

# print content type header
print $cmscgi->header('text/html');

my $cgiaction = $cmscgi->param('cgiaction');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $submitonly = 0;
my $usersid = $cmscgi->param('loginusersid');
my $username = $cmscgi->param('loginusername');
my $updatetable = "commitmenthistory";

my $commitmentid = ((defined($cmscgi->param("commitmentid"))) ? $cmscgi->param("commitmentid") : "");
my $message = '';

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq "")) {
    print <<openloginpage;
    <script type="text/javascript">
    <!--
    parent.location='$ONCSCGIDir/login.pl';
    //-->
    </script>
openloginpage
    exit 1;
}

#print html
print "<html>\n";
print "<head>\n";
print "<meta name=pragma content=no-cache>\n";
print "<meta name=expires content=0>\n";
print "<meta http-equiv=expires content=0>\n";
print "<meta http-equiv=pragma content=no-cache>\n";
print "<title>Commitment Management System: Historical Commitment Association</title>\n";

print <<testlabel1;
<!-- include external javascript code -->
<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>
<script type="text/javascript">
<!--
var dosubmit = true;
if (parent == self) { // not in frames
    location = '$ONCSCGIDir/login.pl'
}
function submitForm(script, command) {
    document.$form.cgiaction.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'workspace';
    document.$form.submit();
}
function processQuery() {
    if (document.$form.selectedcommitmentid.selectedIndex == -1 || document.$form.selectedcommitmentid.options[document.$form.selectedcommitmentid.options.length - 1].selected == 1) {
	alert ('You must first select a commitment');
    }
    else {
	document.$form.commitmentid.value = document.$form.selectedcommitmentid[document.$form.selectedcommitmentid.selectedIndex].value;
	submitForm('$form','historicaladd');
    }
}
//-->
</script>
<script language="JavaScript" type="text/javascript">
<!--
doSetTextImageLabel('Associate Historical Commitments');
//-->
</script>
testlabel1

# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();
$dbh->{RaiseError} = 1;
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 1000;
print "</head>\n<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";

############################
if ($cgiaction eq "query") {
############################

    print "<table border=0 align=center width=650><tr><td>\n";
    print "<center>\n";
    print "<form name=$form enctype=\"multipart/form-data\" method=post target=\"control\">\n";
    print "<input name=cgiaction type=hidden value=\"query\">\n";
    print "<input name=loginusersid type=hidden value=$usersid>\n";
    print "<input name=loginusername type=hidden value=$username>\n";
    print "<input name=commitmentid type=hidden value=$commitmentid>\n";
    print "<input type=hidden name=schema value=$SCHEMA>\n";
    eval {
        print "<br><br><b>Commitments:</b><br><br>\n";
        print "<select size=10 name=selectedcommitmentid onDblClick=\"processQuery();\">\n";
        %lookup_values = get_lookup_values($dbh, "commitment", 'commitmentid', "text", "1=1 order by commitmentid");
        foreach my $key (keys %lookup_values) {
            print "<option value=$key>C" . lpadzero($key,5) . " - " . getDisplayString($lookup_values{$key},60) . "</option>\n";
        }
        print "<option value=blank>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; \n";
        print "</select><br><br><br>\n";
        print "<input type=button name=querysubmit value='Update Commitment' onClick=\"processQuery();\">\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$usersid,'','',"commitment update -- query page",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/\'/\'\'/g;
        print "<script language=javascript><!--\n";
        print "    alert('$message');\n";
        print "//--></script>\n";
    }
    print "</form>";
    &oncs_disconnect($dbh);
}

#######################################
if ($cgiaction eq "historicaladd") {
#######################################
    
    my $commitmentid = $cmscgi -> param ('commitmentid');
    my $comstring = formatID2 ($commitmentid, 'C');
    my $sqlcommand;
    my $cgiaction;
    my $csr;
    my @values;
    my $filtervalue;
    my $defaultfiltervalue;
    my $filterstring;
    my %commitmentlevelhash = get_lookup_values($dbh, 'commitmentlevel', 'description', 'commitmentlevelid');
    $defaultfiltervalue = $commitmentlevelhash{'Regulatory Commitment'};
    
    $filtervalue = $cmscgi->param('histrange');
    $filtervalue = ($filtervalue) ? $filtervalue : $defaultfiltervalue;

    print "<script language=javascript><!--\n";
    print "function browseHistorical(id) {\n";
    print "    var script = \'browse\';\n";
    print "    window.open (\"\", \"historicalwin\", \"height=350, width=750, status=yes, scrollbars=yes\");\n";
    print "    document.$form.target = \'historicalwin\';\n";
    print "    document.$form.action = \'$path\' + script + \'.pl\';\n";
    print "    document.$form.option.value = \'details\';\n";
    print "    document.$form.theinterface.value = \'historical\';\n";
    print "    document.$form.interfaceLevel.value = \'historicalid\';\n";
    print "    document.$form.id.value = id;\n";
    print "    document.$form.submit();\n";
    print "}\n";
    print "//-->\n</script>\n";

    print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
    print "<table border=0 align=center width=750><tr><td><br>\n";
    print "<form name=historicaladd method=post action=\"$ONCSCGIDir/historicaladd.pl\">\n";
    print "<input type=hidden name=loginusersid value=$usersid>\n";
    print "<input type=hidden name=loginusername value=$username>\n";
    print "<input type=hidden name=schema value=$SCHEMA>\n";
    print "<input type=hidden name=option value=\'\'>\n";
    print "<input type=hidden name=id value=\'\'>\n";
    print "<input type=hidden name=cgiaction value=\'historicaladd\'>\n";
    print "<input type=hidden name=commitmentid value=$commitmentid>\n";
    print "<input type=hidden name=theinterface value=\'\'>\n";
    print "<input type=hidden name=interfaceLevel value=\'\'>\n";
    print "<table width=750 align=center cellpadding=0 cellspacing=10><tr><td>";
    print "<table border=1 align=center width=650><tr><td>";
    print "<table width=100% cellpadding=0 cellspacing=0>";
    print "<tr bgcolor=#ffffff valign=top><td width=200><b>Commitment ID:</b></td><td><b>$comstring</td></tr>\n";
    print "<tr bgcolor=#eeeeee valign=top><td><b>Commitment Text: </b></td><td>";
    my ($text, $iid, $itext) = $dbh -> selectrow_array ("select c.text, i.issueid, i.text from $SCHEMA.commitment c, $SCHEMA.issue i where commitmentid = $commitmentid and i.issueid = c.issueid");
    print "$text</td></tr>";
    print "<tr bgcolor=#ffffff valign=top><td><b>Issue ID:</td><td><b>" . formatID2($iid, 'I') . "</td></tr>";
    print "<tr bgcolor=#eeeeee valign=top><td><b>Issue Text:</b></td><td>$itext</td></tr>";
    print "</table></td></tr></table></td></tr>";


    my $curlist = "";
    my ($howmany) = $dbh -> selectrow_array ("select count (*) from $SCHEMA.commitmenthistory where commitmentid = $commitmentid");
    if ($howmany > 0) {
	print "<tr><td><hr width=60%></td></tr>";
	print start_table (3, 'center', 60, 75, 610);
	print title_row ("#daaaaa", "#000000", "Currently Associated Historical Commitments");
	print add_header_row ();
	print add_col() . 'Associate';
	print add_col() . 'Historical&nbsp;ID';
	print add_col() . 'Historical Commitment Text';
	
	my $total;
	my $curhist = $dbh -> prepare ("select historicalid from $SCHEMA.commitmenthistory where commitmentid = $commitmentid");
	$curhist -> execute;
	$curlist .= "and commitmentid not in ("; 
	while (my ($historicalid) = $curhist -> fetchrow_array) {
	    $total++;
	    my ($historicaltext) = $dbh -> selectrow_array ("select text from oncs.commitment where commitmentid = $historicalid");
	    print add_row();
	    print add_col() . "<center><input type=checkbox checked name=curc$total></center>";
	    print add_col_link("javascript:browseHistorical($historicalid);") . "HC" . substr("0000$historicalid",-5);
	    print add_col() . getDisplayString ($historicaltext, 100);
	    print "<input type=hidden name=histid$total value=$historicalid>\n";
	    $curlist .= "$historicalid, ";
	}
	chop ($curlist);
	chop ($curlist);
	$curlist .= ")";
	print end_table();
	print "<input type=hidden name=total value=$total>\n</td></tr>\n";
    }
    print "<tr><td><hr width=60%><br></td></tr>";
    print "<tr><td><li><b>Associate Historical Commitments:</b>&nbsp;&nbsp;\n<select name=histrange>\n";
    my $isselected = ($filtervalue==-1) ? " selected" : "" ;
    print "<option value='' selected>Select A Level of Commitment\n";
    print "<option value=\"-1\"$isselected>All Historical Commitments\n";
    foreach my $key (sort keys %commitmentlevelhash) {
	my $selectedtext = ($commitmentlevelhash{$key} == $filtervalue) ? " selected" : "";
	print "<option value=\"$commitmentlevelhash{$key}\"$selectedtext>$key\n";
    }
    $isselected = ($filtervalue == -2) ? " selected" : "";
    print "<option value=\"-2\"$isselected>Commitments w/o Level of Commitment\n";
    print "</select>\n<input type=submit value=Go name=submit_reportfilter>\n";
    print "<br><br>\n";
    $dbh->{LongTruncOk} = 1;
    $dbh->{LongReadLen} = 1000;
    $filterstring = "";
    if ($filtervalue > 0) {
	$filterstring = "commitmentlevelid = $filtervalue";
    }
    elsif ($filtervalue == -1) {
	$filterstring = "1=1";
    }
    elsif ($filtervalue == -2) {
	$filterstring = "commitmentlevelid is null";
    }
    my $orderby = 'ORDER BY commitmentid';
    $sqlcommand = "SELECT commitmentid, text ";
    $sqlcommand .= "FROM oncs.commitment ";
    $sqlcommand .= "WHERE $filterstring $curlist $orderby";
    eval {
	$dbh->{RaiseError} = 1;
	$csr = $dbh->prepare($sqlcommand);
	$csr->execute;

	print start_table (3, 'center', 60, 75, 610);
	print title_row ("#daaaaa", "#000000", "Historical Commitments");
	print add_header_row ();
	print add_col() . 'Associate';
	print add_col() . 'Historical&nbsp;ID';
	print add_col() . 'Historical Commitment Text';
	
	my $savewarn = $^W;
	my $howmany = 0;
	while (@values = $csr->fetchrow_array) {
	    $howmany ++;
	    my ($hid, $htext) = @values;
	    my $displaycommitment = "No current commitments";
	    
	    print add_row();
	    print add_col() . "<center><input type=checkbox name=hc$howmany></center>";
	    print add_col_link("javascript:browseHistorical($hid);") . "HC" . substr("0000$hid",-5);
	    print add_col() . getDisplayString ($htext, 100);
	    print "<input type=hidden name=hid$howmany value=$hid>\n";
	}
	$csr->finish;
	print end_table();
	print "<input type=hidden name=howmany value=$howmany>\n</td></tr>\n";
	$^W = $savewarn;
    };
    $dbh->{RaiseError} = 0;
    if ($@) {
	# handle error
	my $alertstring = errorMessage($dbh, $username, $usersid, 'issues/commitments', "", "Error retreiving data for historical association", $@);
	$alertstring =~ s/\"/\'/g;
	print <<erroralert;
	<script language=javascript>
        <!--
        alert("$alertstring");
        //-->
        </script>
erroralert
    }
    print "<script langiage=\"JavaScript\" type=\"text/javascript\"><!--\n";
    print "function addhist() {\n";
    print "    var returnvalue = true;\n";
    print "    document.$form.cgiaction.value = \"addhistorical\";\n";
    print "    submitForm (\'historicaladd\', \'addhistorical\');\n";
    print "    return (returnvalue);\n";
    print "}\n";
    print "//-->\n</script>\n";
    print "<tr><td><center>\n";
    print "<input type=button name=submitupdate value=\"Add Historical Commitments\" title=\"Associate Historical Commitments\" onClick=\"addhist();\">\n";
    print "</center></td></tr></table></form><br><br><br><br></body></html>\n";    &oncs_disconnect ($dbh);
    exit 1;
}  ###############  endif historicaladd  ################

############################################
if ($cgiaction eq "addhistorical") {
############################################
    no strict 'refs';

    my $total = $cmscgi -> param ('total');
    my $howmany = $cmscgi -> param ('howmany');
    my $commitmentid = $cmscgi -> param ('commitmentid');

    my $activity = "Historical Association";
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;
    eval {
	if ($total) {
	    for (my $j=1; $j<=$total; $j++) {
		my $histid = $cmscgi -> param ("histid$j");
		my $curc = $cmscgi -> param ("curc$j");
		if (!(defined($curc))) {
		    my $deleteit;
		    $deleteit = $dbh -> prepare ("delete from $SCHEMA.commitmenthistory where commitmentid=$commitmentid and historicalid = $histid");
		    $deleteit -> execute;
		    $deleteit -> finish;
		}
	    }
	}
	if ($howmany) {
	    for (my $i=1; $i<=$howmany; $i++) {
		my $hid = $cmscgi -> param ("hid$i");
		my $hc = $cmscgi -> param ("hc$i");
		my ($intable) = $dbh -> selectrow_array ("select count (*) from $SCHEMA.commitmenthistory where commitmentid=$commitmentid and historicalid = $hid"); 
		if (defined($hc) && $intable == 0) {
		    my $inserthist;
		    $inserthist = $dbh -> prepare ("insert into $SCHEMA.commitmenthistory (commitmentid, historicalid) values ($commitmentid, $hid)");
		    $inserthist -> execute;
		    $inserthist -> finish;
		}
	    }
	}
    };
    if ($@) {
	$dbh->rollback;
	my $alertstring = errorMessage($dbh, $username, $usersid, 'commitment', "$commitmentid", $activity, $@);
	$alertstring =~ s/\"/\'/g;
	print <<pageerror;
	<script language="JavaScript" type="text/javascript">
        <!--
        alert("$alertstring");
        //-->
        </script>
pageerror
    }
    else {
	&log_activity ($dbh, 'F', $usersid, "Commitment ".&formatID2($commitmentid, 'C')." associated with Historical Commitments ");
	print <<pageresults;
	<script language="JavaScript" type="text/javascript">
	<!--
        parent.workspace.location="$ONCSCGIDir/historicaladd.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA&cgiaction=query";
        //-->
        </script>
pageresults
    }
    $dbh->commit;
    $dbh->{AutoCommit} = 1;
    $dbh->{RaiseError} = 0;
    &oncs_disconnect($dbh);
    exit 1;
} ################  endif updatecommitmenttable  ###############

print "<br><br><br><br></body></html>\n";
&oncs_disconnect($dbh);
