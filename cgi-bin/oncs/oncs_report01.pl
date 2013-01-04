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
<title>CMS Report 01</title>
<!-- include external javascript code -->
<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>

<!-- page specific javascript code -->
<script language="JavaScript" type="text/javascript">
<!--
if (parent == self) // not in frames
  {
        location = '/cgi-bin/oncs/oncs_user_login.pl';
        }

function DisplayIssue (id) {
    // function to popup a window with an issue's information
    var location;
    location = '/cgi-bin/oncs/readoldissues.pl?loginusersid=$usersid&loginusername=$username&issueselect=' + id + '&cgiaction=report_popup';
    PopIt(location,'oncs_popup');
}


//function DisplayCommitment (id,message) {
function DisplayCommitment (id) {
    // function to popup a window with a commitment's information
    var location;
    location = '/cgi-bin/oncs/readcommitments.pl?loginusersid=$usersid&loginusername=$username&commitmentid=' + id + '&cgiaction=report_popup';
    PopIt(location,'oncs_popup');
    //alert(message);
}


//-->
</script>
</head>
pageheader

print <<bodystart;
<body>
<center>
<h2>Executive Commitment Report</h2>
<h4>Under Construction</h4>
</center>
bodystart

$dbh->{LongTruncOk} = 1;
$dbh->{LongReadLen} = 1000;

# determine sort to use
my $orderby = 'ORDER BY cat.description,com.commitdate';
my $sortorder = $oncscgi->param('sort');
$sortorder = (defined($sortorder)) ? $sortorder : 'category';
my $catsort='category';
my $cdatesort='commitment_date';
my $leadsort='lead';

if ($sortorder eq 'category') {$orderby = 'ORDER BY cat.description,com.commitdate';$catsort='categorydesc';}
if ($sortorder eq 'categorydesc') {$orderby = 'ORDER BY cat.description DESC,com.commitdate';$catsort='category';}
if ($sortorder eq 'commitment_date') {$orderby = 'ORDER BY com.commitdate,cat.description';$cdatesort='commitment_datedesc';}
if ($sortorder eq 'commitment_datedesc') {$orderby = 'ORDER BY com.commitdate DESC,cat.description';$cdatesort='commitment_date';}
if ($sortorder eq 'lead') {$orderby = 'ORDER BY lname,fname,cat.description,com.commitdate';$leadsort='leaddesc';}
if ($sortorder eq 'leaddesc') {$orderby = 'ORDER BY lname DESC,fname DESC,cat.description,com.commitdate';$leadsort='lead';}

#if (defined($sortorder) && $sortorder eq 'category') {$orderby = 'ORDER BY cat.description,com.commitdate';$catsort='categorydesc';}
#if (defined($sortorder) && $sortorder eq 'categorydesc') {$orderby = 'ORDER BY cat.description DESC,com.commitdate';$catsort='category';}
#if (defined($sortorder) && $sortorder eq 'commitment_date') {$orderby = 'ORDER BY com.commitdate,cat.description';$cdatesort='commitment_datedesc';}
#if (defined($sortorder) && $sortorder eq 'commitment_datedesc') {$orderby = 'ORDER BY com.commitdate DESC,cat.description';$cdatesort='commitment_date';}
#if (defined($sortorder) && $sortorder eq 'lead') {$orderby = 'ORDER BY lname,fname,cat.description,com.commitdate';$leadsort='leaddesc';}
#if (defined($sortorder) && $sortorder eq 'leaddesc') {$orderby = 'ORDER BY lname DESC,fname DESC,cat.description,com.commitdate';$leadsort='lead';}

# generate sql lookup statement
$roleid = lookup_role_by_name($dbh, "DOE Functional Lead");
$sqlcommand = "SELECT cat.description,issue.issueid,issue.text,TO_CHAR(issue.entereddate,'MM/DD/YYYY'),com.commitmentid,TO_CHAR(com.commitdate,'MM/DD/YYYY'),com.text, NVL(uncr.lastname, '') fname, NVL(uncr.firstname, '') lname ";
$sqlcommand .= "FROM $SCHEMA.category cat, $SCHEMA.issue issue, $SCHEMA.commitment com, $SCHEMA.usernamecommitmentroles uncr ";
$sqlcommand .= "WHERE (cat.categoryid(+)=issue.categoryid) AND (com.issueid=issue.issueid) AND ((com.commitmentid = uncr.commitmentid(+)) AND uncr.roleid(+) = $roleid) $orderby";

eval {
    $dbh->{RaiseError} = 1;
    $csr = $dbh->prepare($sqlcommand);
    $status = $csr->execute;
    print "<center><table border=0 width=100%>\n";
    print "<tr bgcolor=#d0d0d0>\n";
    print "<td valign=top><b><a href=/cgi-bin/oncs/?loginusersid=$usersid&loginusername=$username&sort=$catsort>Category</a></b></td>\n";
    print "<td valign=top><b>Concern</b></td>\n";
    print "<td valign=top><b><a href=/cgi-bin/oncs/oncs_report01.pl?loginusersid=$usersid&loginusername=$username&sort=$cdatesort>Commitment Date</a></b></td>\n";
    print "<td valign=top><b>Commitment</b></td>\n";
    print "<td valign=top><b>Commited To</b></td>\n";
    print "<td valign=top><b><a href=/cgi-bin/oncs/oncs_report01.pl?loginusersid=$usersid&loginusername=$username&sort=$leadsort>DOE Lead</a></b></td></tr>\n";
    my $tableline=1;
    my $color;
    my $savewarn = $^W;
    #$^W =0;
    while (@values = $csr->fetchrow_array) {
        for (my $i=0; $i<=8; $i++) {
            if (!(defined($values[$i]))) {$values[$i]='&nbsp;';}
        }
        $color = '#ffffff'; unless ($tableline%2 == 0) { $color = '#f0f0f0';}
        $tableline++;
        $displayval = $values[2];
        $displayval2 = $values[6];
        $displayval =~ s/'/''/g;
        $displayval =~ s/\n/\\n/g;
        $displayval2 =~ s/'/''/g;
        $displayval2 =~ s/\n/\\n/g;
        #print "<tr bgcolor=$color><td valign=top>$values[0]</td><td valign=top><a href=\"javascript:alert('$displayval');\">" . getDisplayString($values[2],80) . "</a></td><td valign=top>$values[5]</td><td valign=top><a href=\"javascript:alert('$displayval2');\">" . getDisplayString($values[6],80) . "</a></td><td valign=top>\n";
        #print "<tr bgcolor=$color><td valign=top>$values[0]</td><td valign=top><a href=\"javascript:DisplayIssue($values[1]);\">" . substr("0000$values[1]", -5) . " - " . getDisplayString($values[2],80) . "</a></td><td valign=top>$values[5]</td><td valign=top><a href=\"javascript:DisplayCommitment($values[4],'$displayval2');\">" . substr("0000$values[4]", -5) . " - " . getDisplayString($values[6],80) . "</a></td><td valign=top>\n";
        print "<tr bgcolor=$color><td valign=top>$values[0]</td><td valign=top><a href=\"javascript:DisplayIssue($values[1]);\">" . substr("0000$values[1]", -5) . " - " . getDisplayString($values[2],80) . "</a></td><td valign=top>$values[5]</td><td valign=top><a href=\"javascript:DisplayCommitment($values[4]);\">" . substr("0000$values[4]", -5) . " - " . getDisplayString($values[6],80) . "</a></td><td valign=top>\n";
        $sqlcommand2 = "SELECT org.name FROM $SCHEMA.committedorg com, $SCHEMA.organization org WHERE (com.organizationid=org.organizationid) AND com.commitmentid = $values[4]";
        $csr2 = $dbh->prepare($sqlcommand2);
        $status = $csr2->execute;
        while (@values2 = $csr2->fetchrow_array) {
            print "$values2[0]<br>\n";
        }
        $csr2->finish;
        print "&nbsp;</td>\n";
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
    #$status = log_history($dbh, "Report error", "T", $usersid, "", 0, "Error retrieving data for report01");
    #my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
    #$mon = ++$mon;
    #$mday = $mday;
    #$year += 1900;
    #$hour = $hour;
    #$min = $min;
    #$sec = $sec;
    #print STDERR "\n ONCS REPORT01 error: $mon/$mday/$year $hour:$min:$sec - $username/$usersid/$SCHEMA - $@\n";
    print "<script language=javascript><!--\n";
    print "   alert(\"$alertstring\");\n";
    print "//--></script>\n";
}

        

&oncs_disconnect($dbh);

print <<bodyend;
<form name=params>
<input type=hidden name=loginusersid value=$usersid>
<input type=hidden name=loginusername value=$username>
</form>
</body>
</html>
bodyend

