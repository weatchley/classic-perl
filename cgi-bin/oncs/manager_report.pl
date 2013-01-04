#!/usr/local/bin/newperl -w

# CGI user login for the CRD
#
# $Source$
#
# $Revision$
#
# $Date$
#
# $Author$
#
# $Locker$
#
# $Log$
#
# get all required libraries and modules
use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

my $oncscgi = new CGI;
my $sqlcommand;
my $sqlcommand2;
my $cgiaction;
my $csr;
my $csr2;
my $status;
my @values;
my @values2;
my $displayval;
my $displayval2;
my $roleid;
my %commitmentlevelhash;
my $filtervalue;
my $defaultfiltervalue;
my $filterstring;

#=============================================================================================================
#    Subroutines
#=============================================================================================================

###################################################################################################################################
sub getDisplayString {                                                                                                            #
###################################################################################################################################
   my ($str, $maxlen) = @_;
   if (length ($str) > $maxlen) {
      $str = substr ($str, 0, $maxlen + 1);
      $str =~ s/\s+\S+$//;
      $str =~ s/\s+$//;
      $str .= '...';
   }
   return ($str);
}

#=============================================================================================================
#=============================================================================================================



# tell the browser that this is an html page using the header method
print $oncscgi->header('text/html');

# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();

# fill the hash of commitment levels and descriptions for use in the picklist
%commitmentlevelhash = get_lookup_values($dbh, 'commitmentlevel', 'description', 'commitmentlevelid');

my $username = $oncscgi->param('loginusername');
my $usersid = $oncscgi->param('loginusersid');
if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq ""))
  {
  print <<openloginpage;
  <script type="text/javascript">
  <!-- 
  parent.location='/cgi-bin/oncs/oncs_user_login.pl';
  //-->
  </script>
openloginpage
  exit 1;
  }

# output page header
print <<pageheader;
<html>
<head>
<meta name="pragma" content="no-cache">
<meta name="expires" content="0">
<meta http-equiv="expires" content="0">
<meta http-equiv="pragma" content="no-cache">
<title>CMS Manager Report</title>
<!-- include external javascript code -->
<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>

<!-- page specific javascript code -->
<script language="JavaScript" type="text/javascript">
<!--
if (parent == self) // not in frames
  {
  location = '/cgi-bin/oncs/oncs_user_login.pl';
  };

function DisplayIssue (id) {
    // function to popup a window with an issue's information
    var loc;
    loc = '/cgi-bin/oncs/readoldissues.pl?loginusersid=$usersid&loginusername=$username&issueselect=' + id + '&cgiaction=report_popup';
    PopIt(loc,'oncs_popup');
};


//function DisplayCommitment (id,message) {
function DisplayCommitment (id) {
    // function to popup a window with a commitment's information
    var loc;
    loc = '/cgi-bin/oncs/readcommitments.pl?loginusersid=$usersid&loginusername=$username&commitmentid=' + id + '&cgiaction=report_popup';
    PopIt(loc,'oncs_popup');
    //alert(message);
};

function DisplayDefinitions ()
  {
  var loc;
  loc = '/cgi-bin/oncs/commit_level_definitions.pl?loginusersid=$usersid&loginusername=$username'
  PopIt(loc, 'oncs_popup');
  };

function submitsort (sortvalue)
  {
  // function changes the sort field and submits the form.
  document.reportfilter.sortval.value = sortvalue;
  document.reportfilter.submit ();
  };

//-->
</script>
</head>
pageheader

$defaultfiltervalue = $commitmentlevelhash{"Regulatory Commitment"};

$filtervalue = $oncscgi->param('commitmentlevel');
$filtervalue = ($filtervalue) ? $filtervalue : $defaultfiltervalue;
print <<bodystart1;
<body  background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
<form name=reportfilter method=post action="/cgi-bin/oncs/manager_report.pl">
<input type=hidden name=loginusersid value=$usersid>
<input type=hidden name=loginusername value=$username>
<input type=hidden name=sortval value=''>
<center>
<input type=button value=Definitions name=btndefinitions onclick="DisplayDefinitions()">
&nbsp;
<select name=commitmentlevel>
<option value='-1'>All Commitments
bodystart1
    foreach my $key (sort keys %commitmentlevelhash)
      {
      my $selectedtext = ($commitmentlevelhash{$key} == $filtervalue) ? " selected" : "";
      print "<option value=\"$commitmentlevelhash{$key}\"$selectedtext>$key\n";
      }
print <<bodystart2;
</select>
<input type=submit value=Go name=submit_reportfilter>
</center>
<br>
bodystart2

$dbh->{LongTruncOk} = 1;
$dbh->{LongReadLen} = 1000;

# determine sort to use
$filterstring = "";
if ($filtervalue > 0)
  {
  $filterstring = " AND com.commitmentlevelid = $filtervalue";
  }
#my $orderby = 'ORDER BY cat.description,com.commitdate';
my $orderby = 'ORDER BY com.commitdate DESC,cat.description';
my $sortorder = $oncscgi->param('sortval');
$sortorder = (defined($sortorder)) ? $sortorder : 'commitment_datedesc';
my $catsort='category';
my $cdatesort='commitment_date';
my $leadsort='lead';

if ($sortorder eq 'category') {$orderby = 'ORDER BY cat.description,com.commitdate';$catsort='categorydesc';}
if ($sortorder eq 'categorydesc') {$orderby = 'ORDER BY cat.description DESC,com.commitdate';$catsort='category';}
if ($sortorder eq 'commitment_date') {$orderby = 'ORDER BY com.commitdate,cat.description';$cdatesort='commitment_datedesc';}
if ($sortorder eq 'commitment_datedesc') {$orderby = 'ORDER BY com.commitdate DESC,cat.description';$cdatesort='commitment_date';}
if ($sortorder eq 'lead') {$orderby = 'ORDER BY lname,fname,cat.description,com.commitdate';$leadsort='leaddesc';}
if ($sortorder eq 'leaddesc') {$orderby = 'ORDER BY lname DESC,fname DESC,cat.description,com.commitdate';$leadsort='lead';}

# generate sql lookup statement
$roleid = lookup_role_by_name($dbh, "DOE Functional Lead");
$sqlcommand = "SELECT cat.description,issue.issueid,issue.text,TO_CHAR(issue.entereddate,'MM/DD/YYYY'),com.commitmentid,TO_CHAR(com.commitdate,'MM/DD/YYYY'),com.text, NVL(uncr.lastname, '') fname, NVL(uncr.firstname, '') lname, NVL(TO_CHAR(com.duedate, 'MM/DD/YYYY'), ' '), stat.description ";
$sqlcommand .= "FROM $SCHEMA.category cat, $SCHEMA.issue issue, $SCHEMA.commitment com, $SCHEMA.usernamecommitmentroles uncr, $SCHEMA.status stat ";
$sqlcommand .= "WHERE ((cat.categoryid=issue.categoryid) AND (com.issueid=issue.issueid) AND ((com.commitmentid = uncr.commitmentid(+)) AND uncr.roleid(+) = $roleid) AND (com.statusid = stat.statusid(+))) $filterstring $orderby";
#print "$sqlcommand<br>\n";

eval {
    $dbh->{RaiseError} = 1;
    $csr = $dbh->prepare($sqlcommand);
    $status = $csr->execute;
    print "<center><table border=0 width=750>\n";
    print "<tr bgcolor=#d0d0d0>\n";
#    print "<td valign=top><b><a href=/cgi-bin/oncs/manager_report.pl?loginusersid=$usersid&loginusername=$username&sort=$catsort>Category</a></b></td>\n";
    print "<td valign=top><b><a href=javascript:submitsort('$catsort');>Category</a></b></td>\n";
    print "<td valign=top><b>Issue</b></td>\n";
#    print "<td valign=top><b><a href=/cgi-bin/oncs/manager_report.pl?loginusersid=$usersid&loginusername=$username&sort=$cdatesort>Commitment Date</a></b></td>\n";
    print "<td valign=top align=center><b><a href=javascript:submitsort('$cdatesort');>Commitment Date</a></b></td>\n";
    print "<td valign=top><b>Commitment</b></td>\n";
    print "<td valign=top><b>Status</b></td>\n";
    print "<td valign=top align=center><b>Date Due to Commitment Maker</b></td>\n";
#    print "<td valign=top><b><a href=/cgi-bin/oncs/manager_report.pl?loginusersid=$usersid&loginusername=$username&sort=$leadsort>DOE Lead</a></b></td></tr>\n";
    print "<td valign=top><b><a href=javascript:submitsort('$leadsort')>DOE&nbsp;Lead</a></b></td></tr>\n";
    my $tableline=1;
    my $color;
    my $savewarn = $^W;
    #$^W =0;
    while (@values = $csr->fetchrow_array) {
        for (my $i=0; $i<=8; $i++) {
            #if (!(defined($values[$i]))) {$values[$i]='&nbsp;';}
            if (!(defined($values[$i]))) {$values[$i]='';}
        }
        $color = '#ffffff'; unless ($tableline%2 == 0) { $color = '#f0f0f0';}
        $tableline++;
        $displayval = $values[2];
        $displayval2 = $values[6];
        $displayval =~ s/'/''/g;
        $displayval =~ s/\n/\\n/g;
        $displayval2 =~ s/'/''/g;
        $displayval2 =~ s/\n/\\n/g;
        print "<tr bgcolor=$color><td valign=top>$values[0]</td><td valign=top><a href=\"javascript:DisplayIssue($values[1]);\">" . substr("0000$values[1]", -5) . " - " . getDisplayString($values[2],80) . "</a></td><td valign=top>$values[5]</td><td valign=top><a href=\"javascript:DisplayCommitment($values[4]);\">" . substr("0000$values[4]", -5) . " - " . getDisplayString($values[6],80) . "</a></td><td valign=top>$values[10]</td><td valign=top>$values[9]</td>\n";
        #$sqlcommand2 = "SELECT org.name FROM $SCHEMA.committedorg com, $SCHEMA.organization org WHERE (com.organizationid=org.organizationid) AND com.commitmentid = $values[4]";
        #$csr2 = $dbh->prepare($sqlcommand2);
        #$status = $csr2->execute;
        #while (@values2 = $csr2->fetchrow_array) {
        #    print "$values2[0]<br>\n";
        #}
        #$csr2->finish;
        #print "&nbsp;</td>\n";
        print "<td valign=top>$values[8] $values[7]</td>\n";
        print "</tr>\n";
    }
    $csr->finish;
    print "</table></center>\n";
    $^W = $savewarn;
};

$dbh->{RaiseError} = 0;
if ($@) {
    # handle error
    my $alertstring = errorMessage($dbh, $username, $usersid, 'issues/commitments', "", "Error retreiving data for report01", $@);
    $alertstring =~ s/"/'/g;
    print <<erroralert;
      <script language=javascript>
        <!--
        alert("$alertstring");
        //-->
      </script>
erroralert
}

&oncs_disconnect($dbh);

print <<bodyend;
</form>
</body>
</html>
bodyend

