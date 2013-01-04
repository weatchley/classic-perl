#!/usr/local/bin/newperl -w
# - !/usr/bin/perl

#
# Commitment Manager Due Date Change Screen
#
# $Source: /home/munroeb/do/RCS/DOECMgr_changeduedate.pl,v $
# $Revision: 1.19 $
# $Date: 2000/10/18 21:21:16 $
# $Author: munroeb $
# $Locker:  $
# $Log: DOECMgr_changeduedate.pl,v $
# Revision 1.19  2000/10/18 21:21:16  munroeb
# modified activity log message
#
# Revision 1.18  2000/10/17 15:51:59  munroeb
# removed log_history perm
#
# Revision 1.17  2000/10/16 16:50:46  munroeb
# removed log_history functionality
#
# Revision 1.16  2000/10/11 16:08:05  naydenoa
# Interface update
#
# Revision 1.15  2000/10/06 19:44:36  munroeb
# added log_activity feature to script
#
# Revision 1.14  2000/10/06 18:19:24  naydenoa
# Interface update
#
# Revision 1.13  2000/09/29 16:36:40  atchleyb
# fixed javascript validation for netscape
# fixed form submit for netscape
#
# Revision 1.12  2000/09/21 22:12:13  atchleyb
# updated title
#
# Revision 1.11  2000/09/20 17:49:06  atchleyb
# changed commitment_module_main.pl ref to home.pl
#
# Revision 1.10  2000/08/25 16:12:10  atchleyb
# changed Technical Lead to Discipline Lead
#
# Revision 1.9  2000/07/17 21:35:35  atchleyb
# got rid of redundent initialization code and removed misc use of uninitialized value error
#
# Revision 1.8  2000/07/17 16:25:42  atchleyb
# changed text image label
# placed form in a table of width 750
#
# Revision 1.7  2000/07/11 14:58:41  munroeb
# finished modifying html formatting
#
# Revision 1.6  2000/07/06 23:19:13  munroeb
# finished mods to html and javascripts
#
# Revision 1.5  2000/07/05 22:33:12  munroeb
# made minor tweaks to javascripts and html
#
# Revision 1.4  2000/06/14 18:47:32  zepedaj
# Changed Functional To Technical per DOE request
#
# Revision 1.3  2000/06/13 21:59:09  zepedaj
# Added "C" prior to commitment id on edit page
#
# Revision 1.2  2000/06/13 15:33:21  johnsonc
# Editted commitments select object to a fixed width.
#
# Revision 1.1  2000/06/05 18:21:30  zepedaj
# Initial revision
#
#
#

use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use Tie::IxHash;
use strict;

my $cirscgi = new CGI;

# print content type header
print $cirscgi->header('text/html');

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $pagetitle = "Change Due Dates";
my $pageheader = $pagetitle;
my $cgiaction = ((defined($cirscgi->param('cgiaction'))) ? $cirscgi->param('cgiaction') : "");
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $schema = ((defined($cirscgi->param("schema"))) ? $cirscgi->param("schema") : $SCHEMA);
my $submitonly = 0;
my $usersid = $cirscgi->param('loginusersid');
my $username = $cirscgi->param('loginusername');
my $updatetable = "issue";
tie my %lookup_values, "Tie::IxHash";
my $commitmentid = ((defined($cirscgi->param("commitmentid"))) ? $cirscgi->param("commitmentid") : "");
my $message = '';

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq "")) {
    print <<openloginpage;
    <script type="text/javascript">
    <!--
    parent.location='/cgi-bin/oncs/login.pl';
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
#print "<meta http-equiv=\"expires\" content=\"Fri, 12 May 1996 14:35:02 EST\">\n";
print "<title>$pagetitle</title>\n";

print <<testlabel1;
<!-- include external javascript code -->
<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>

<script language="JavaScript" type="text/javascript">
<!--
    doSetTextImageLabel('Change Due Dates');
//-->
</script>

<script type="text/javascript">
    <!--

    var dosubmit = true;
    if (parent == self)  {  // not in frames
    location = '/cgi-bin/oncs/login.pl'
    }

    function submitForm(script, command) {
    document.$form.cgiaction.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'workspace';
    document.$form.submit();
    }
    function submitFormCGIResults(script, command) {
    document.$form.cgiaction.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'control';
    document.$form.submit();
    }
    function submitFormWorkspace(script, command) {
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
        submitForm('$form','enterExtension');
    }
    }
    //-->
    </script>
  </head>
  <body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
  <table border=0 align=center width=750><tr><td>
  <!-- <center><h2>$pageheader</h2></center> -->
  <CENTER>
  <form name=$form enctype="multipart/form-data" method=post target="control">
  <input name=cgiaction type=hidden value="query">
  <input name=loginusersid type=hidden value=$usersid>
  <input name=loginusername type=hidden value=$username>
  <input name=commitmentid type=hidden value=$commitmentid>
  <input type=hidden name=schema value=$SCHEMA>
testlabel1

# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 1000;

#read the old due date.
my $oldduedate = ($commitmentid) ? lookup_single_value($dbh, "commitment", "TO_CHAR(duedate, 'MM/DD/YYYY')", $commitmentid) : "";


if ($cgiaction eq "query") {
    eval {
        print "<b>Active Commitments</b><br>\n";
        print "<select size=10 name=selectedcommitmentid onDblClick=\"processQuery();\">\n";
        my %status_items = get_lookup_values ($dbh, "status", "description", "statusid");
        my $status_list = '';
        foreach my $key ('Commitment Letter','M&O Fulfillment','DOE Fulfillment Review','M&O Fulfillment Rework', 'DOE Fulfillment Rework', 'Commitment Manager Closure Review','Commitment Maker Closure Review') {
            $status_list .= "$status_items{$key}, ";
        }
        chop ($status_list);
        chop ($status_list);
        %lookup_values = get_lookup_values($dbh, "commitment com, $schema.commitmentrole cr", 'com.commitmentid', "com.text", "((com.commitmentid = cr.commitmentid) AND (cr.roleid = 3) AND (cr.usersid = $usersid) AND (com.statusid IN ($status_list))) ORDER BY com.commitmentid");
        foreach my $key (keys %lookup_values) {
            print "<option value=$key>C" . lpadzero($key,5) . " - " . getDisplayString($lookup_values{$key},60) . "</option>\n";
        }
        print "<option value=blank>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; \n";
        print "</select><br>\n";
        print "<input type=button name=querysubmit value='Change Due Date' onClick=\"processQuery();\">\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$usersid,'','',"enter response - query page.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "    alert('$message');\n";
        print "//--></script>\n";
    }
} elsif ($cgiaction eq "enterExtension") {
    my $textareawidth = 80;
    eval {
        print <<END_OF_BLOCK;

<script language=javascript><!--
    function validateResponse() {
        var msg = '';
        var tmp = '';

        msg += ((tmp = validate_date(document.$form.newduedate_year.value, document.$form.newduedate_month[document.$form.newduedate_month.selectedIndex].value, document.$form.newduedate_day[document.$form.newduedate_day.selectedIndex].value, 0, 0, 0, 0, false, true, false)) == "") ? "" : "New Due Date - " + tmp + "\\n";
        msg += ((tmp = validate_accession_number(document.$form.approvalletteraccession.value)) == "") ? "" : "Approval Letter Accession Number - " + tmp + "\\n";
        msg += (document.$form.reason.value == "") ? "You must enter a reason for the due date change.\\n" : "";
        msg += (document.$form.approver.value == '0') ? "You must select the approver for the due date change.\\n" : "";
        if (msg != '') {
            alert (msg);
        }
        else {
            submitFormCGIResults('$form', 'processExtension')
        }
    }


//--></script>

END_OF_BLOCK

        print "<b>Due Date Extension for Commitment C" . lpadzero($commitmentid,5) . "</b><br>\n";
        print "<b>" . getDisplayString(get_value($dbh,$schema,'commitment','text',"commitmentid = $commitmentid"),80) . "</b>\n";
        print "<input type=hidden value=$commitmentid name=commitmentid><input type=hidden value=$oldduedate name=oldduedate><br><br>\n";
        print "<table border=0 width=100%><tr><td align=center><b>Due Date Extension</b></td></tr>\n";
        print "<tr><td><b><li>Current Due Date:</b>&nbsp;&nbsp;\n";
        print "<b>$oldduedate</b>";
        print "</td></tr>\n";
        print "<tr><td><b><li>New Due Date:</b>&nbsp;&nbsp;\n";
        print build_date_selection('newduedate',$form, 'today');
        print "</td></tr>\n";
        print "<tr><td><b><li>Approval Letter Accession Number:</b>&nbsp;&nbsp;<input name=approvalletteraccession type=text width=17 maxlength=17></td></tr>\n";
        print "<tr><td><b><li>Extension Reason / Justification:</b><br><textarea name=reason cols=$textareawidth rows=5></textarea></td></tr>\n";
        %lookup_values = ('0' => ' Select the Approver of the Extension', get_lookup_values($dbh, 'users','usersid',"firstname || ' ' || lastname","isactive='T' ORDER BY lastname,firstname"));
        print "<tr><td><b><li>Extension Approver:</b>&nbsp;&nbsp;" . build_drop_box('approver', \%lookup_values, '0','InitialBlank') . "</td></tr>\n";
        print "</table><br>\n";
        print "<br><center><input type=button name=responseSubmit value='Submit' onClick=\"validateResponse();\"></center>\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$usersid,'','',"enter response - entry page.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "    alert('$message');\n";
        print "//--></script>\n";
    }

} elsif ($cgiaction eq "processExtension") {
    my $commitmentid = $cirscgi->param('commitmentid');
    my $oldduedate = $cirscgi->param('oldduedate');
    my $newduedate = $cirscgi->param('newduedate');
    my $reason = $cirscgi->param('reason');
    my $reasonsql = ($reason) ? ":reasonclob" : "NULL";
    my $approvalletteraccession = $cirscgi->param('approvalletteraccession');
    my $approver = $cirscgi->param('approver');

    my $duedatehistupdatesql = "INSERT INTO $SCHEMA.duedatehistory (oldduedate, newduedate, commitmentid, approvalletteraccession, reason, approver)
                                VALUES (TO_DATE('$oldduedate', 'MM/DD/YYYY'), TO_DATE('$newduedate', 'MM/DD/YYYY'), $commitmentid, '$approvalletteraccession',
                                $reasonsql, $approver)";
    my $commitmentupdatesql = "UPDATE $SCHEMA.commitment
                               SET duedate = TO_DATE('$newduedate', 'MM/DD/YYYY'),
                               updatedby = $usersid
                               WHERE commitmentid = $commitmentid";
    my $activity = '';
    my $csr;
    eval
      {
      $activity = "Change Due Date in Commitment: $commitmentid.";
      print "<!-- $commitmentupdatesql -->\n";
      $csr = $dbh->prepare($commitmentupdatesql);
      $csr->execute;

      $activity = "Add due date history change record";
      print "<!-- $duedatehistupdatesql -->\n";
      $csr = $dbh->prepare($duedatehistupdatesql);
      if ($reason)
        {
        $csr->bind_param(':reasonclob', $reason, {ora_type => ORA_CLOB, ora_field => "reason" });
        }
      $csr->execute;
      };
    if ($@)
      {
      $dbh->rollback;
      my $alertstring = errorMessage($dbh,$username,$usersid,'commitment','$commitmentid',$activity,$@);
      $alertstring =~ s/"/'/g;
      print <<pageerror;
    <script language="JavaScript" type="text/javascript">
      <!--
      alert("$alertstring");
      //parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
      //-->
    </script>
pageerror
      }
    else
      {
      &log_activity($dbh, 'F', $usersid, "Commitment ".&formatID2($commitmentid, 'C')." due date changed");
      print <<pageresults;
    <script language="JavaScript" type="text/javascript">
      <!--
      parent.workspace.location="$ONCSCGIDir/home.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
      //parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
      //-->
    </script>
pageresults
      $dbh->commit;
      }
} else {
    print "Invalid command - $cgiaction\n";
}

#disconnect from the database
&oncs_disconnect($dbh);

# print html footers.
print "<br>\n";
print "</form>\n";

print "</CENTER>\n";
print "</td></tr></table>\n";
print "</body>\n";
print "</html>\n";
