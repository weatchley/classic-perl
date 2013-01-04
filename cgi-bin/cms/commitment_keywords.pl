#!/usr/local/bin/newperl -w
# - !/usr/bin/perl

#
# Commitment Maker commitment keyword edit screen.
#
# $Source: /data/dev/cirs/perl/RCS/commitment_keywords.pl,v $
# $Revision: 1.13 $
# $Date: 2000/09/21 22:32:39 $
# $Author: atchleyb $
# $Locker: naydenoa $
# $Log: commitment_keywords.pl,v $
# Revision 1.13  2000/09/21 22:32:39  atchleyb
# changed page layout
#
# Revision 1.12  2000/09/21 22:13:43  atchleyb
# updated title
#
# Revision 1.11  2000/07/24 15:22:07  johnsonc
# Inserted GIF file for display.
#
# Revision 1.10  2000/07/17 21:32:15  atchleyb
# got rid of misc use of uninitialized value error
#
# Revision 1.9  2000/07/17 21:29:24  atchleyb
# removed redundent initialization code
#
# Revision 1.8  2000/07/17 17:02:55  atchleyb
# placed form in a table of width 750
#
# Revision 1.7  2000/07/11 14:56:47  munroeb
# finished modifying html formatting
#
# Revision 1.6  2000/07/06 23:34:36  munroeb
# finished mods to html and javascripts
#
# Revision 1.5  2000/07/05 23:03:18  munroeb
# made minor changes to html and javascripts
#
# Revision 1.4  2000/06/13 21:59:19  zepedaj
# Added "C" prior to commitment id on edit page
#
# Revision 1.3  2000/06/13 15:32:07  johnsonc
# Editted commitments select object to a fixed width.
#
# Revision 1.2  2000/05/31 19:46:46  atchleyb
# changed status lookup to lookup by name instead of number
#
# Revision 1.1  2000/05/19 23:04:43  atchleyb
# Initial revision
#
#
#

use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);
#use UI_Widgets qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use Tie::IxHash;
use strict;

my $cirscgi = new CGI;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

# print content type header
print $cirscgi->header('text/html');

my $pagetitle = "Edit Commitment Keywords";
my $pageheader = $pagetitle;
my $cgiaction = ((defined($cirscgi->param('cgiaction'))) ? $cirscgi->param('cgiaction') : "");
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $schema = ((defined($cirscgi->param("schema"))) ? $cirscgi->param("schema") : $SCHEMA);
my $submitonly = 0;
my $usersid = $cirscgi->param('loginusersid');
my $username = $cirscgi->param('loginusername');
my $updatetable = "issue";
tie my %lookup_values, "Tie::IxHash";
tie my %lookup_values2, "Tie::IxHash";
my $commitmentid = ((defined($cirscgi->param("commitmentid"))) ? $cirscgi->param("commitmentid") : "");
my $message = '';

sub doProcessKeywords {
    my %args = (
        dbh => '',
        schema => '',
        @_,
    );
    my $message = '';
    my $sqlcode = '';
    my $csr;
    my $status;
    my @values;
    my %keywords;
    my $key;
    my $keywordref = $args{keywords};
    my @keywordlist = @$keywordref;

    $sqlcode = "SELECT keywordid FROM $args{schema}.keyword";
    $csr = $args{dbh}->prepare($sqlcode);
    $status = $csr->execute;
    while (@values = $csr->fetchrow_array) {
        $keywords{$values[0]} = 'avail';
    }
    $csr->finish;
    $sqlcode = "SELECT keywordid FROM $args{schema}.commitmentkeyword WHERE commitmentid = $args{commitmentID}";
    $csr = $args{dbh}->prepare($sqlcode);
    $status = $csr->execute;
    while (@values = $csr->fetchrow_array) {
        $keywords{$values[0]} = 'cur';
    }
    $csr->finish;

    for $key (0 .. ($#keywordlist)) {
        if ($keywords{$keywordlist[$key]} eq 'avail') {
            $keywords{$keywordlist[$key]} = 'add';
        } else {
            $keywords{$keywordlist[$key]} = 'keep';
        }
        print "<!-- $keywordlist[$key] -->\n";
    }

    my $dellist = "";
    my $addcount = 0;

    foreach $key (sort keys %keywords) {
        if ($keywords{$key} eq 'cur') {
            $dellist .= "$key,";
        }
        if ($keywords{$key} eq 'add') {
            $addcount++;
        }
        print "<!-- $key - $keywords{$key} -->\n";
    }

    if ($dellist gt '') {
        chop($dellist);
        $sqlcode = "DELETE FROM $args{schema}.commitmentkeyword WHERE commitmentid = $args{commitmentID} AND keywordid IN ($dellist)";
        print "\n<!-- $sqlcode -->\n\n";
        $args{dbh}->do($sqlcode);
    }
    if ($addcount > 0) {
        foreach $key (keys %keywords) {
            if ($keywords{$key} eq 'add') {
                $sqlcode = "INSERT INTO $args{schema}.commitmentkeyword (commitmentid,keywordid) VALUES ($args{commitmentID}, $key)";
                print "\n<!-- $sqlcode -->\n\n";
                $args{dbh}->do($sqlcode);
            }
        }
    }
    if ($dellist eq '' && $addcount == 0) {
        $message = 'No changes made';
    }

    #$args{dbh}->commit;


    return ($message);
}


if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq ""))
  {
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
#print "<title>$pagetitle</title>\n";

print <<testlabel1;
<!-- include external javascript code -->
<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>

<script type="text/javascript">
    <!--

    var dosubmit = true;
    if (parent == self)  // not in frames
      {
      location = '/cgi-bin/oncs/login.pl'
      }

      function submitForm(script, command) {
          var old_cgiaction = document.$form.cgiaction.value;
          var old_action = document.$form.action;
          var old_target = document.$form.target;
          document.$form.cgiaction.value = command;
          document.$form.action = '$path' + script + '.pl';
          document.$form.target = 'workspace';
          document.$form.submit();
          document.$form.cgiaction.value = old_cgiaction;
          document.$form.action = old_action;
          document.$form.target = old_target;
      }
      function submitFormCGIResults(script, command) {
          var old_cgiaction = document.$form.cgiaction.value;
          var old_action = document.$form.action;
          var old_target = document.$form.target;
          document.$form.cgiaction.value = command;
          document.$form.action = '$path' + script + '.pl';
          document.$form.target = 'control';
          document.$form.submit();
          document.$form.cgiaction.value = old_cgiaction;
          document.$form.action = old_action;
          document.$form.target = old_target;
      }
      function submitFormWorkspace(script, command) {
          var old_cgiaction = document.$form.cgiaction.value;
          var old_action = document.$form.action;
          var old_target = document.$form.target;
          document.$form.cgiaction.value = command;
          document.$form.action = '$path' + script + '.pl';
          document.$form.target = 'workspace';
          document.$form.submit();
          document.$form.cgiaction.value = old_cgiaction;
          document.$form.action = old_action;
          document.$form.target = old_target;
      }
      function processQuery() {

          if ((document.$form.closedcommitmentid.options[document.$form.closedcommitmentid.options.length - 1].selected == 1) || (document.$form.opencommitmentid.options[document.$form.opencommitmentid.options.length - 1].selected == 1)) {
              alert ('You must first select a commitment');
          } else if (document.$form.opencommitmentid.selectedIndex >= 0) {
              document.$form.commitmentid.value = document.$form.opencommitmentid[document.$form.opencommitmentid.selectedIndex].value;
              submitForm('$form','editKeywords');
          } else if (document.$form.closedcommitmentid.selectedIndex >= 0) {
              document.$form.commitmentid.value = document.$form.closedcommitmentid[document.$form.closedcommitmentid.selectedIndex].value;
              submitForm('$form','editKeywords');
          } else  {
              alert ('You must first select a commitment');

          }
      }
    //-->
</script>

<script language="JavaScript" type="text/javascript">
<!--
    doSetTextImageLabel('Edit Commitment Keywords');
//-->
</script>

  </head>
  <body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
  <table border=0 align=center width=750><tr><td>
testlabel1
  #<center><h2>$pageheader</h2></center>
  print <<testlabel2;
  <CENTER>
  <form name=$form enctype="multipart/form-data" method=post target="control">
  <input name=cgiaction type=hidden value="query">
  <input name=loginusersid type=hidden value=$usersid>
  <input name=loginusername type=hidden value=$username>
  <input name=commitmentid type=hidden value=$commitmentid>
  <input type=hidden name=schema value=$SCHEMA>
testlabel2

# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();
$dbh->{RaiseError} = 1;
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 1000;

if ($cgiaction eq "query") {
    eval {
        print "<b>Open Commitments</b><br>\n";
        print "<select size=10 name=opencommitmentid onDblClick=\"processQuery();\">\n";
        my %status_items = get_lookup_values ($dbh, "status", "description", "statusid");
        my $status_list = '';
        foreach my $key ('Closed','Closure Letter','Rejected') {
            $status_list .= "$status_items{$key}, ";
        }
        chop ($status_list);
        chop ($status_list);
        %lookup_values = get_lookup_values($dbh, "commitment", 'commitmentid', "text", "(statusid NOT IN ($status_list)) AND (commitmentid IN (SELECT commitmentid FROM $schema.commitmentrole WHERE usersid = $usersid)) ORDER BY commitmentid");
        foreach my $key (keys %lookup_values) {
            print "<option value=$key>C" . lpadzero($key,5) . " - " . getDisplayString($lookup_values{$key},60) . "</option>\n";
        }
        print "<option value=blank>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; \n";
        print "</select><br><br>\n";
        print "<b>Closed Commitments</b><br>\n";
        print "<select size=10 name=closedcommitmentid onDblClick=\"processQuery();\">\n";
        %lookup_values = get_lookup_values($dbh, "commitment", 'commitmentid', "text", "(statusid IN ($status_list)) AND (commitmentid IN (SELECT commitmentid FROM $schema.commitmentrole WHERE usersid = $usersid)) ORDER BY commitmentid");
        foreach my $key (keys %lookup_values) {
            print "<option value=$key>C" . lpadzero($key,5) . " - " . getDisplayString($lookup_values{$key},60) . "</option>\n";
        }
        print "<option value=blank>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; \n";
        print "</select><br>\n";
        print "<input type=button name=querysubmit value='Edit Keywords'' onClick=\"processQuery();\">\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$usersid,'','',"edit keywords - query page.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "    alert('$message');\n";
        print "//--></script>\n";
    }
} elsif ($cgiaction eq "editKeywords") {
    eval {
        print <<END_OF_BLOCK;

<script language=javascript><!--
    function validateKeywords() {
        var msg = '';
        var tmp = '';

        if (msg > '') {
            alert (msg);
        } else {
            selectemall(document.$form.keywords);
            submitFormCGIResults('$form', 'processKeywords');
        }
    }


//--></script>

END_OF_BLOCK

        print "<table border=0 align=center>\n";
        print "<tr><td align=center><b>Commitment C" . lpadzero($commitmentid,5) . "</b></td></tr>\n";
        print "<tr><td align=center><b>" . getDisplayString(get_value($dbh,$schema,'commitment','text',"commitmentid = $commitmentid"),80) . "</b></td></tr>\n";
        print "<tr><td align=center><table border=0 width=100%>\n";
        %lookup_values = get_lookup_values($dbh, 'keyword','keywordid','description',"isactive = 'T' ORDER BY description");
        %lookup_values2 = get_lookup_values($dbh, 'keyword','keywordid','description',"(keywordid IN (SELECT keywordid FROM $schema.commitmentkeyword WHERE commitmentid = $commitmentid)) ORDER BY description");
        print "<tr><td>" . build_dual_select('keywords', "$form", \%lookup_values, \%lookup_values2, 'Avaliable Keywords', 'Selected Keywords') . "</td></tr>\n";

        print "</table></td></tr>\n";
        print "<tr><td><center><input type=button name=keywordSubmit value='Submit' onClick=\"validateKeywords();\"></center></td></tr></table>\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$usersid,'','',"edit keywords - edit page.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "    alert('$message');\n";
        print "//--></script>\n";
    }

} elsif ($cgiaction eq "processKeywords") {
    eval {
        my @keywords =  $cirscgi->param('keywords');
        #print "\n\n<!-- $keywords[0], $keywords[1], $keywords[2], -->\n\n";
        $message = doProcessKeywords('dbh' => $dbh, 'schema' => $schema,'commitmentID' => $cirscgi->param('commitmentid'),
                        'keywords' => \@keywords);
        if ($message gt ' ') {
            print "<script language=javascript><!--\n";
            print "    alert('$message');\n";
            print "//--></script>\n";
        } else {
            print "<script language=javascript><!--\n";
            print "    submitFormWorkspace('$form', 'query');\n";
            print "//--></script>\n";
        }
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$usersid,'','',"edit keywords - process page.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "    alert('$message');\n";
        print "//--></script>\n";
    }
} else {
    print "Invalid command\n";
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
