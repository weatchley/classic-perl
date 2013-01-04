#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/crd/perl/RCS/bins.pl,v $
#
# $Revision: 1.43 $
#
# $Date: 2002/02/20 16:32:53 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: bins.pl,v $
# Revision 1.43  2002/02/20 16:32:53  atchleyb
# removed depricated function use named parameters and changed the html header
#
# Revision 1.42  2001/11/07 19:07:23  atchleyb
# fixed bug that alowed a bin to be updated as its own parent
#
# Revision 1.41  2001/11/02 23:59:23  atchleyb
# changed alert box code to handle single quotes
#
# Revision 1.40  2001/10/11 22:32:39  atchleyb
# added submitFormDummy and a form 'dummy' now used by many links
#
# Revision 1.39  2001/09/14 17:31:42  atchleyb
# added code to support bin/crd section mapping
#
# Revision 1.38  2001/06/15 23:44:25  atchleyb
# changed log for update bin
# fixed bug in add bin that did not allow adding response writers and tech reviewers
#
# Revision 1.37  2001/05/19 01:05:23  mccartym
# temporary remove changes from previous thre mods (1.34, 1.35, 1.36)
# add document specific review names
#
# Revision 1.33  2000/06/05 22:33:50  atchleyb
# changed setting of command hidden variable to use javascript
# changed hidden variable for binid to only show up for 'browsetable'
# changed getTitle to use correct titles for update operations
#
# Revision 1.32  2000/05/31 16:12:19  mccartym
# add bin browse table
#
# Revision 1.31  2000/05/19 00:10:20  mccartym
# add getTitle subroutine, call writeTitleBar at beginning of script
#
# Revision 1.30  2000/05/16 18:25:25  mccartym
# enable summary comment browse links
#
# Revision 1.29  2000/05/10 18:44:28  mccartym
# add count of summarized comments to browse
#
# Revision 1.28  2000/03/24 18:32:04  atchleyb
# added feature to change response writer when response is in
# bin coordinator assign and the bin coordinator is changed.
#
# Revision 1.27  2000/02/10 17:18:41  atchleyb
# removed form_verify.js
#
# Revision 1.26  2000/02/10 01:03:38  atchleyb
# changed the way that browse would display sub bins
#
# Revision 1.25  2000/02/09 23:22:01  atchleyb
# fixed bug with activity log message when new bin is added
#
# Revision 1.24  2000/02/09 22:33:10  atchleyb
# updated to alow browse to include sub bins
#
# Revision 1.23  2000/01/14 23:30:20  atchleyb
# replaced all references to EIS with $crdtype
#
# Revision 1.22  1999/12/15 22:18:55  mccartym
# change summary comment link in comments table
#
# Revision 1.21  1999/11/29 21:31:02  atchleyb
# changed expires to use '31 Dec 1997'
# added log_activity calls
#
# Revision 1.20  1999/11/10 02:12:20  mccartym
# more browse format changes
#
# Revision 1.19  1999/11/10 01:37:27  mccartym
# modify browse bin tables
#
# Revision 1.18  1999/11/05 18:04:24  mccartym
# change summary_comment comment text column name from text to commenttext on SELECT statement
#
# Revision 1.17  1999/11/04 15:46:30  mccartym
# title changes
#
# Revision 1.16  1999/10/27 18:37:13  atchleyb
# updated to use new title bar
#
# Revision 1.15  1999/10/25 22:49:45  atchleyb
# changed format of tables used to display comments and summary comments.
# added response status to comments screen
#
# Revision 1.14  1999/10/04 16:02:23  atchleyb
# fixed an error in a select statement that kept out the default reviewers from the update screen.
#
# Revision 1.13  1999/09/30 18:29:48  atchleyb
# changed labels for response writesr/technical reviewers
# changed browse so that comments and summary comments sections only display a message if they would be empty
#
# Revision 1.12  1999/09/15 17:05:50  mccartym
# display reviewers in alphabetical order
# remove raise error calls, put commits inside evals
#
# Revision 1.11  1999/09/14 20:08:55  atchleyb
# updated to exclude developers from pic lists
#
# Revision 1.10  1999/08/18 16:01:38  atchleyb
# got rid of blank options for bin coordinator and nepa reviewer in add screen
# used tie to sort drop down menus
#
# Revision 1.9  1999/08/13 22:32:43  atchleyb
# inserted routines to add a new bin
#
# Revision 1.8  1999/08/10 23:29:20  atchleyb
# inserted stub for add bin form
#
# Revision 1.7  1999/08/04 23:33:29  atchleyb
# added raiserror to eval blocks and added more eval blocks
# added commit to some eval blocks
#
# Revision 1.6  1999/08/02 22:34:19  atchleyb
# fixed newline prob with error messages
#
# Revision 1.5  1999/08/02 21:50:22  atchleyb
# updated error handling, now using errorMessage routine
#
# Revision 1.4  1999/08/02 02:38:03  mccartym
#  Reversed order of parameters on call to headerBar()
#
# Revision 1.3  1999/07/30 19:58:54  atchleyb
# removed hardcoded paths
# changed most links to form submits
#
# Revision 1.2  1999/07/19 19:52:06  atchleyb
# modified to use function getDisplayString
#
# Revision 1.1  1999/07/17 00:09:33  atchleyb
# Initial revision
#
#

use integer;
use strict;
use CRD_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use DocumentSpecific qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI qw(param);
use Tie::IxHash;

$| = 1;

my $crdcgi = new CGI;
my $userid = $crdcgi->param("userid");
my $username = $crdcgi->param("username");
my $schema = $crdcgi->param("schema");

&checkLogin ($username, $userid, $schema);

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $command = $crdcgi->param("command");
my $subbins = ((defined($crdcgi->param("subbins"))) ? $crdcgi->param("subbins") : "F");
my $dbh = db_connect();

$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 10000000;

my $firstReviewName = &FirstReviewName();


###################################################################################################################################
sub doAlertBox {
###################################################################################################################################
   my %args = (
      text => "",
      includeScriptTags => 'T',
      @_,
   );
   
   my $outputstring = '';
   $args{text} =~ s/\n/\\n/g;
   $args{text} =~ s/'/%27/g;
   if ($args{includeScriptTags} eq 'T') {$outputstring .= "<script language=javascript>\n<!--\n";}
   $outputstring .= "var mytext ='$args{text}';\nalert(unescape(mytext));\n";
   if ($args{includeScriptTags} eq 'T') {$outputstring .= "//-->\n</script>\n";}
   
   return ($outputstring);
   
}


###################################################################################################################################
sub writePrintCommentLink {                                                                                                       #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      addTableColumn => 1,
      useIcon => 1,
      icon => "$CRDImagePath/printer.gif",
      linkText => "print the comment and response text",
      @_,
   );
   my $out = ($args{addTableColumn}) ? &add_col() . "<center>" : "";
   if ($args{writeHeader}) {
      $out .= "<image src=$CRDImagePath/printer.gif border=0>";
   } elsif ($args{document} == 0) {
      $out .= "N/A";
   } else {
      my $formattedid = &formatID($CRDType, 6, $args{document}) . " / " . &formatID("", 4, $args{comment});
      my $version = ($args{version}) ? " version $args{version}" : "";
      my $prompt = "Click here for $formattedid comment and response$version text report";
      $version = ($args{version}) ? ",$args{version}" : "";
      $out .= "<a href=javascript:submitPrintCommentResponse($args{document},$args{comment}$version) title='$prompt'>";
      if ($args{useIcon}) {
         $out .= "<image src=$args{icon} border=0>";
      } else {
         $out .= "$args{linkText}";
      }
      $out .= "</a>";
   }
   $out .= "</center>" if ($args{addTableColumn});
   return ($out);
}

###################################################################################################################################
sub writeBinNumber {                                                                                                              #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      headerText => "Bin<br>Number",
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      my $prompt = "Click here to browse bin $args{number}";
      $out .= "<center><a href=javascript:displayBin($args{id}) title='$prompt'>$args{number}</a></center>";
   }
   return ($out);
}

###################################################################################################################################
sub getLookupValues {                                                                                                             #
###################################################################################################################################
   my %lookupHash = ();
   my $lookup = $_[0]->prepare("select id, name from $_[1].$_[2]");
   $lookup->execute;
   while (my @values = $lookup->fetchrow_array) {
      $lookupHash{$values[0]} = $values[1];
   }
   $lookup->finish;
   return (\%lookupHash);
}

###################################################################################################################################
sub getBinNumber {                                                                                                                #
###################################################################################################################################
   my %args = (
      @_,
   );
   $args{binName} =~ m/([0-9].*?)[ ](.*)/;
   return ($1, $2);
}

###################################################################################################################################
sub writeText {                                                                                                                   #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      center => 0,
      text => "",
      textWidth => 50,
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      $out .= "<center>" if ($args{center});
      $out .= &getDisplayString($args{text}, $args{textWidth});
      $out .= "</center>" if ($args{center});
   }
   return ($out);
}

###################################################################################################################################
sub writeUser {                                                                                                                    #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      center => 0,
      headerText => "Response<br>Writer",
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      my $displayedUserName = &get_fullname($dbh, $schema, $args{userID});
      my $prompt = "Click here to browse information about $displayedUserName";
      $out .= "<center>" if ($args{center});
      $out .= "<a href=javascript:display_user($args{userID}) title='$prompt'>$displayedUserName</a>";
      $out .= "</center>" if ($args{center});
   }
   return ($out);
}

###################################################################################################################################
sub browseBinTable {
###################################################################################################################################
   my %policyValues = %{&getLookupValues($dbh, $schema, 'technical_review_policy')};
   my $sql = "select b.id, b.name, nvl(b.parent,0), b.coordinator, b.techreviewpolicy from $schema.bin b order by b.name";
   my $csr = $dbh->prepare($sql);
   $csr->execute;
   my $output .= &start_table(7, 'center', 50, 320, 50, 130, 60, 60, 80);
   $output .= &title_row('#c0ffff', '#000099', "<font size=3>Bins (xxx)</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on bin number for detailed information</font></i>)");
   $output .= &add_header_row();
   $output .= &writeBinNumber(writeHeader => 1);
   $output .= &writeText(writeHeader => 1, headerText => "Name");
   $output .= &writeBinNumber(writeHeader => 1, headerText => "Parent<br>Bin");
   $output .= &writeUser(writeHeader => 1, headerText => "Coordinator");
   $output .= &writeText(writeHeader => 1, headerText => "Comments");
   $output .= &writeText(writeHeader => 1, headerText => "Summary<br>Comments");
   $output .= &writeText(writeHeader => 1, headerText => "Tech Review<br>Policy");
   my $rows = 0;
   while (my @values = $csr->fetchrow_array) {
      $rows++;
      my ($id, $name, $parent, $coordinator, $policy) = @values;
   my $sql = "select b.id, b.name, nvl(b.parent,0), b.coordinator, b.techreviewpolicy from $schema.bin b order by b.name";
   my $csr = $dbh->prepare($sql);
      my ($commentCount) = $dbh->selectrow_array ("select count(*) from $schema.comments where bin = $id");
      my ($summaryCount) = $dbh->selectrow_array ("select count(*) from $schema.summary_comment where bin = $id");
      $output .= &add_row();
      my ($binNumber, $binName) = &getBinNumber(binName => $name);
      $output .= &writeBinNumber(id => $id, number => $binNumber);
      $output .= &writeText(text => $binName, textWidth => 200);
      if (!$parent) {
         $output .= &writeText(text => "None", center => 1);
      } else {
         my ($parentName) = $dbh->selectrow_array ("select name from $schema.bin where id = $parent");
         ($binNumber, $binName) = &getBinNumber(binName => $parentName);
         $output .= &writeBinNumber(id => $parent, number => $binNumber);
      }
      $output .= &writeUser(userID => $coordinator);
      $output .= &writeText(text => $commentCount, center => 1);
      $output .= &writeText(text => $summaryCount, center => 1);
      $output .= &writeText(text => $policyValues{$policy}, center => 1);
   }
   $csr->finish;
   $output .= &end_table();
   $output =~ s/xxx/$rows/;
   $output .= "<tr><td height=15></td></tr>";
   return ($output);
}

###################################################################################################################################
sub getTitle {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $title = "";
   if (($args{command} eq "browse") || ($args{command} eq "browseform") || ($args{command} eq "browseTable")) {
      $title = "Browse Bin";
   #} elsif (($args{command} eq "updateform") || ($args{command} eq 'update2form')) {
   } elsif (($args{command} eq "update") || ($args{command} eq 'update1') || ($args{command} eq 'update2')) {
      $title = "Update Bin";
   } elsif ($args{command} eq "addbinform") {
      $title = "Add Bin";
   }
   return ($title);
}

###################################################################################################################################
sub writeBrowseCommentLink {                                                                                                      #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      headerText => "Doc ID /<br>Comment ID",
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      my $formattedID = &formatID($CRDType, 6, $args{document}) . " / " . &formatID("", 4, $args{comment});
      my $prompt = "Click here to browse comment information for $formattedID";
      $out .= "<center><a href=javascript:displayComment($args{document},$args{comment}) title='$prompt'>$formattedID</a></center>";
   }
   return ($out);
}

###################################################################################################################################
sub writeBrowseSummaryCommentLink {                                                                                               #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      headerText => "Summary<br>ID",
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      my $formattedID = &formatID('SCR', 4, $args{summary});
      my $prompt = "Click here to browse information for $formattedID";
      $out .= "<center><a href=javascript:displaySummaryComment($args{summary}) title='$prompt'>$formattedID</a></center>";
   }
   return ($out);
}

###################################################################################################################################
sub writeBrowseResponseLink {                                                                                                     #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      headerText => "Current<br>Response Status",
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      my ($prompt, $formattedID);
      if ($args{dupsimstatus} == 2) {
         $formattedID = &formatID($CRDType, 6, $args{dupdocument}) . " / " . &formatID("", 4, $args{dupcomment});
         $prompt = "Click here to browse information for $formattedID";
         $out .= "Duplicate of" . &nbspaces(2) . "<a href=javascript:displayComment($args{dupdocument},$args{dupcomment}) title='$prompt'>$formattedID</a>";
      } elsif ($args{summary}) {
         $formattedID = &formatID('SCR', 4, $args{summary});
         $prompt = "Click here to browse information for $formattedID";
         $out .= "Summarized by" . &nbspaces(2) . "<a href=javascript:displaySummaryComment($args{summary}) title='$prompt'>$formattedID</a>";
      } else {
         $formattedID = &formatID($CRDType, 6, $args{document}) . " / " . &formatID("", 4, $args{comment});
         $prompt = "Click here to browse response information for $formattedID";
         my $response_status = &get_value($dbh, $schema, "response_version", "status", "document=$args{document} AND commentnum=$args{comment} ORDER BY version DESC");
         $out .= "<a href=javascript:displayResponse($args{document},$args{comment}) title='$prompt'>" . &get_value($dbh, $schema, "response_status", "name", "id = $response_status") . "</a></font>";
      }
   }
   return ($out);
}

###################################################################################################################################
sub getBinTree { #  generate a list of bins that have 'root_bin' as a parent, the list is terminated with a 0
###################################################################################################################################
   my %args = (
      dbh => '',
       schema => '',
       root_bin => 0,
       @_,
   );
   my @binlist = ();
   my $binstring = '';
   my $sqlquery = "SELECT UNIQUE id FROM $args{'schema'}.bin START WITH id = $args{'root_bin'} CONNECT BY PRIOR id = parent";
   my $csr = $args{'dbh'}->prepare($sqlquery);
   my $status = $csr->execute;
   my @values;
   while (@values = $csr->fetchrow_array) {
      $binstring .= "$values[0], ";
   }
   $binstring = "0," . $binstring . "0";
   $sqlquery = "SELECT id FROM $args{'schema'}.bin WHERE id IN ($binstring) ORDER BY name";
   $csr = $args{'dbh'}->prepare($sqlquery);
   $status = $csr->execute;
   while (@values = $csr->fetchrow_array) {
      push @binlist, $values[0];
   }
   return (@binlist);
}

print $crdcgi->header('text/html');
print <<END_of_1;
<html>
<head>
<meta http-equiv=expires content='31 Dec 1997'>
   <script src=$CRDJavaScriptPath/utilities.js></script>
   <script src=$CRDJavaScriptPath/widgets.js></script>
   <script language=javascript><!--
   function process_$form (f) {
     var msg = "";
     if (f.command.value == 'update2' || f.command.value == 'add') {
       for (index=0; index < f.techreviewers.length-1;index++) {
           f.techreviewers.options[index].selected = true;
       }
     }
     if (msg != "") {
       alert (msg);
       return false;
     }
     return true;
   }

function submitForm(script, command) {
    document.$form.command.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'main';
    document.$form.submit();
}

function submitFormDummy(script, command) {
    document.dummy.command.value = command;
    document.dummy.action = '$path' + script + '.pl';
    document.dummy.target = 'main';
    document.dummy.submit();
}

function displayUser(id) {
    document.dummy.id.value = id;
    submitFormDummy ('user_functions', 'displayuser');
}

function displaySummaryComment(id) {
    dummy.summarycommentid.value = id;
    submitFormDummy ('summary_comments', 'browseSummaryComment');
}

function displayBin(id) {
   dummy.binid.value = id;
   submitFormDummy('bins', 'browse');
}

function display_user(id) {
   dummy.id.value = id;
   submitFormDummy('user_functions', 'displayuser');
}

function displayComment(documentid,commentid) {
    document.dummy.id.value = documentid;
    document.dummy.commentid.value = commentid;
    submitFormDummy("comments", "browse");
}

function displayResponse(documentid,commentid) {
    document.dummy.id.value = documentid;
    document.dummy.commentid.value = commentid;
    submitFormDummy("responses", "browse");
}



   //-->
   </script>
</head>

<body background=$CRDImagePath/background.gif text=$CRDFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
<center>
END_of_1
my $title = &getTitle(command => $command);
print  &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => $title);
tie my %binlookupvalues, "Tie::IxHash";
tie my %lookup_values, "Tie::IxHash";
tie my %auth_users, "Tie::IxHash";
tie my %selected_users, "Tie::IxHash";
my @binvalues;
my @values;
my $sqlquery;
my $csr;
my $status;
my $binid = $crdcgi->param('binid');
my $message;
my $urllocation;

my $id;
my $name;
my $coordinator;
my $nepareviewer;
my $parent;
my $crd_section;
my $techreviewpolicy;
my @techreviewers;

if ($command eq 'browseTable') {
   print &browseBinTable();
}

if ($command eq 'browse') {
    $command = 'browseform';
}

if ($command eq 'browse1') {
    # get data for browse ----------------------------------------------------------------------------------
    $urllocation = "$ENV{SCRIPT_NAME}?username=$username&userid=$userid&schema=$schema&command=browse&binid=$binid&subbins=$subbins";

}

if ($command eq 'update') {
    # get data for update -----------------------------------------------------------------------------------
    eval {
        if (!(defined($binid))) {
            $binid = 1;
            $command = "updateform";
        } else {
            $command = "update2form";
            $sqlquery = "SELECT id,name,coordinator,nepareviewer,parent,techreviewpolicy,crd_section FROM $schema.bin WHERE id = $binid";
            $csr = $dbh->prepare($sqlquery);
            $status = $csr->execute;
            @values=$csr->fetchrow_array;
            $csr->finish;
            if ($status) {
                $id = $values[0];
                $name = $values[1];
                $coordinator = $values[2];
                $nepareviewer = $values[3];
                $parent = (defined($values[4]) ? $values[4] : '');
                $crd_section = (defined($values[6]) ? $values[6] : '');
                $techreviewpolicy = $values[5];

                $selected_users{$coordinator} = get_fullname($dbh,$schema,$coordinator);
                $sqlquery = "SELECT u.id FROM $schema.default_tech_reviewer d, $schema.users u WHERE d.bin = $binid and d.reviewer = u.id order by u.lastname, u.firstname";
                $csr = $dbh->prepare($sqlquery);
                $status = $csr->execute;
                while (@values=$csr->fetchrow_array) {
                    $selected_users{$values[0]} = get_fullname($dbh,$schema,$values[0]);
                }
                $csr->finish;

            }

        }
        %binlookupvalues = get_lookup_values ($dbh, $schema, 'bin', 'id', 'name', 'id = id ORDER BY name');
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"load Bin $binid for update.",$@);
    }

}

if ($command eq 'update1') {
    # display update data in main screen -----------------------------------------------------------------------------------
    $urllocation = "$ENV{SCRIPT_NAME}?username=$username&userid=$userid&schema=$schema&command=update&binid=$binid";
}

if ($command eq 'update2') {
    # process update data -----------------------------------------------------------------------------------
    $name = $crdcgi->param('name');
    $name =~ s/'/''/g;
    $coordinator = $crdcgi->param('coordinator');
    $nepareviewer = $crdcgi->param('nepareviewer');
    $parent = $crdcgi->param('parent');
    $crd_section = $crdcgi->param('crd_section');
    $techreviewpolicy = $crdcgi->param('techreviewpolicy');
    @techreviewers = $crdcgi->param('techreviewers');
    my $old_coordinator = '';

    $sqlquery = "UPDATE $schema.bin SET name = '$name', coordinator = $coordinator, nepareviewer = $nepareviewer, ";
    if ($parent < 1 || $parent le ' ') {
        $sqlquery .= "parent = NULL, ";
    } else {
        $sqlquery .= "parent = $parent, ";
    }
    $sqlquery .= "crd_section = " . (($crd_section != 0) ? $crd_section : "NULL") . ", ";
    $sqlquery .= "techreviewpolicy = $techreviewpolicy WHERE id = $binid";
    eval {
        $old_coordinator = get_value($dbh, $schema, 'bin', 'coordinator', "id = $binid");

        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        $csr->finish;

        if ($coordinator != $old_coordinator) {
            $sqlquery = "UPDATE $schema.response_version SET responsewriter = $coordinator WHERE STATUS = 1 AND ";
            $sqlquery .= "(document || '-' || commentnum IN (SELECT document || '-' || commentnum FROM $schema.comments WHERE bin = $binid))";
            $csr = $dbh->prepare($sqlquery);
            $status = $csr->execute;
            $csr->finish;
        }

        $dbh->commit;
    };
    if ($status && !($@)) {
        $urllocation = "$ENV{SCRIPT_NAME}?username=$username&userid=$userid&schema=$schema&command=update";

        # update default tech reviewers
        $sqlquery = "DELETE FROM $schema.default_tech_reviewer WHERE bin = $binid";
        eval {
            $csr = $dbh->prepare($sqlquery);
            $status = $csr->execute;
            $csr->finish;
            $dbh->commit;
        };
        if ($status && !($@)) {
            eval {
                for (my $i=0; $i<=$#techreviewers; $i++) {
                    if ($techreviewers[$i] != $coordinator && $techreviewers[$i] != $old_coordinator) {
                        $sqlquery = "INSERT INTO $schema.default_tech_reviewer (reviewer, bin) VALUES ($techreviewers[$i], $binid)";
                        $csr = $dbh->prepare($sqlquery);
                        $status = $csr->execute;
                        $csr->finish;
                    }
                }
                log_activity($dbh, $schema, $userid, "Bin $binid - $name updated");
                $dbh->commit;
            };
            if (!($status) || $@) {
                $message = errorMessage($dbh,$username,$userid,$schema,"update default technical reviews for bin $binid - $name.",$@);
            }

        } else {
            $message = errorMessage($dbh,$username,$userid,$schema,"update default technical reviews for bin $binid - $name.",$@);
        }
    } else {
        $message = errorMessage($dbh,$username,$userid,$schema,"update Bin $binid - $name.",$@);
    }
}

if ($command eq 'add') {
    # get data from add bin form -----------------------------------------------------------------------------------
    $name = $crdcgi->param('name');
    $name =~ s/'/''/g;
    $coordinator = $crdcgi->param('coordinator');
    $nepareviewer = $crdcgi->param('nepareviewer');
    $parent = $crdcgi->param('parent');
    $crd_section = $crdcgi->param('crd_section');
    $techreviewpolicy = $crdcgi->param('techreviewpolicy');
    @techreviewers = $crdcgi->param('techreviewers');

    ($binid) = $dbh->selectrow_array("SELECT $schema.bin_id.NEXTVAL FROM $schema.bin");
    $sqlquery = "INSERT INTO $schema.bin (id, name,coordinator,nepareviewer,parent,crd_section,techreviewpolicy) VALUES ($binid,'$name', $coordinator, $nepareviewer, ";
    if (!(defined($parent)) || $parent < 1 || $parent le ' ') {
        $sqlquery .= "NULL, ";
    } else {
        $sqlquery .= "$parent, ";
    }
    if (!(defined($crd_section)) || $crd_section < 1 || $crd_section le ' ') {
        $sqlquery .= "NULL, ";
    } else {
        $sqlquery .= "$crd_section, ";
    }
    $sqlquery .= "$techreviewpolicy)";
    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        $csr->finish;
        $dbh->commit;
    };
    if ($status && !($@)) {
        eval {
print "\n\n<!-- $#techreviewers - $techreviewers[0] -->\n\n";
            for (my $i=0; $i<=$#techreviewers; $i++) {
                if ($techreviewers[$i] != $coordinator) {
                    $sqlquery = "INSERT INTO $schema.default_tech_reviewer (reviewer, bin) VALUES ($techreviewers[$i], $binid)";
print "\n\n<!-- $sqlquery -->\n\n";
                    $csr = $dbh->prepare($sqlquery);
                    $status = $csr->execute;
                    $csr->finish;
                }
            }
            log_activity($dbh, $schema, $userid, "Bin $name added");
            $dbh->commit;
        };
        if (!($status) || $@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"insert default technical reviews for bin $name.",$@);
        } else {
            $urllocation = $ENV{SCRIPT_NAME} . "?username=$username&userid=$userid&schema=$schema&command=addbinform";
        }

    } else {
        $message = errorMessage($dbh,$username,$userid,$schema,"insert new bin.",$@);
    }
}

#=============================================================================================================

# display any messages generated by the script
print "<script language=javascript><!--\n";
if (defined($message) && $message gt " ") {
    print doAlertBox( text => $message, includeScriptTags => 'F');
}

# send the main frame to the requested url
if (defined ($urllocation) && $urllocation gt ' ') {
    # close connection to the oracle database
    db_disconnect($dbh);

    print "   var newurl ='$urllocation';\n";
    print "   parent.main.location=newurl;\n";

    # reset the cgiresults fram to a blank page to help avoid reprocessing of scripts
    #print "   location='$path" . "blank.pl';\n";
}
print "//--></script>\n";

#=============================================================================================================

print "<form name=$form target=cgiresults onSubmit=\"return process_$form(this)\" action=$ENV{SCRIPT_NAME} method=post>\n";
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=id value=0>\n";
print "<input type=hidden name=summarycommentid value=0>\n";
print "<input type=hidden name=commentid value=0>\n";
if ($command eq 'browseTable') {
    print "<input type=hidden name=binid value=0>\n";
}
print "<input type=hidden name=command value=0>\n";
print "<table border=0 width=750><tr><td align=center>\n";

if ($command eq 'browseform') {
    # get data for browse ----------------------------------------------------------------------------------
    if (!(defined($binid))) {
        $binid = 1;
    }
    my @binlist = (($subbins eq 'T') ? getBinTree(dbh => $dbh, schema => $schema, root_bin => $binid) : ($binid));

    # generate initial browseform ----------------------------------------------------------------------------------
    print "<center>\n";
    $command = "browse1";
    print "<script language=javascript><!--\n";
    print "    document.$form.command.value='$command';\n";
    print "//--></script>\n";
    eval {
        %binlookupvalues = get_lookup_values ($dbh, $schema, 'bin', 'id', 'name', 'id = id ORDER BY name');
    };
    print build_drop_box ("binid", \%binlookupvalues,$binid) . " &nbsp; <input type=submit name=binsubmit value=Select><br>\n";
    print "<input type=checkbox name=subbins value=T" . (($subbins eq 'T') ? " checked" : "") . "> <b>Include All Subbins</b><br><br>\n";
    print "<hr><br>\n";
    foreach my $binid (@binlist) {
        eval {
            $sqlquery = "SELECT id,name,coordinator,nepareviewer,parent,techreviewpolicy,crd_section FROM $schema.bin WHERE id = $binid";
            $csr = $dbh->prepare($sqlquery);
            $status = $csr->execute;
            @values=$csr->fetchrow_array;
            $csr->finish;
        };
        if ($status && !($@)) {
            $binvalues[0][0] = $values[1];
            $binvalues[1][0] = "<b>Parent Bin:</b>";
            $binvalues[1][1] = "<b>" . (defined($values[4]) ? get_value($dbh,$schema,'bin','name',"id = $values[4]") : 'None') . "</b>";
            $binvalues[2][0] = "<b>CRD Section:</b>";
            $binvalues[2][1] = "<b>" . (defined($values[6]) ? get_value($dbh,$schema,'crd_sections',"section_number || ' ' || section_name","id = $values[6]") : 'None') . "</b>";
            $binvalues[3][0] = "<b>Technical Review Policy:</b>";
            $binvalues[3][1] = "<b>" . get_value($dbh,$schema,'technical_review_policy', 'name', "id = $values[5]") . "</b>";
            $binvalues[4][0] = "<b>Bin Coordinator:";
            $binvalues[4][1] = "<b><a href=javascript:displayUser($values[2])>" . get_fullname($dbh,$schema,$values[2]) . "</a></b>";
            $binvalues[5][0] = "<b>$firstReviewName Reviewer/Approver:</b>";
            $binvalues[5][1] = "<b><a href=javascript:displayUser($values[3])>" . get_fullname($dbh,$schema,$values[3]) . "</a></b>";
            $binvalues[6][0] = "<b>Response Writers and Tech Reviewers:</b>";
            $binvalues[6][1] = "<b><a href=javascript:displayUser($values[2])>" . get_fullname($dbh,$schema,$values[2]) . "</a>";
            $sqlquery = "SELECT reviewer FROM $schema.default_tech_reviewer WHERE bin = $binid";
            eval {
                $csr = $dbh->prepare($sqlquery);
                $status = $csr->execute;
                while (@values=$csr->fetchrow_array) {
                    $binvalues[6][1] .= "<br><a href=javascript:displayUser($values[0])>" . get_fullname($dbh,$schema,$values[0]) . "</a>";
                }
                $binvalues[6][1] .= "</b>";
                $csr->finish;
            };
            if ($@) {
                $message = errorMessage($dbh,$username,$userid,$schema,"select default response writers/reviewers for bin $binid",$@);
                 print doAlertBox( text => $message);
            }
        }
        print gen_table(\@binvalues) . "<br>\n";
        $dbh->{LongTruncOk} = 1;
        $sqlquery = "SELECT document, commentnum, text FROM $schema.comments WHERE bin = $binid ORDER BY document, commentnum";
        eval {
           $csr = $dbh->prepare($sqlquery);
           $csr->execute;
           print &start_table(4, 'center', 80, 20, 190, 460);
           my $output .= &add_header_row();
           $output .= &writeBrowseCommentLink(writeHeader => 1);
           $output .= &writePrintCommentLink(writeHeader => 1);
           $output .= &writeBrowseResponseLink(writeHeader => 1);
           $output .= &add_col() . "<center>Comment<br>Text</center>";
           my $rows = 0;
           while (my ($docid, $commentid, $text) = $csr->fetchrow_array) {
              $rows++;
              $output .= &add_row();
              $output .= &writeBrowseCommentLink(document => $docid, comment => $commentid);
              $output .= &writePrintCommentLink(document => $docid, comment => $commentid);
              my ($summary, $dupsimstatus, $dupsimdocumentid, $dupsimcommentid) = $dbh->selectrow_array ("SELECT nvl(summary,0), dupsimstatus, dupsimdocumentid, dupsimcommentid FROM $schema.comments WHERE document = $docid AND commentnum = $commentid");
              $output .= &writeBrowseResponseLink(document => $docid, comment => $commentid, summary => $summary, dupsimstatus => $dupsimstatus, dupdocument => $dupsimdocumentid, dupcomment => $dupsimcommentid);
              $output .= &add_col() . &getDisplayString($text, 150);
           }
           $csr->finish;
           my $title = ($rows == 0) ? "No Comments in Bin" : "Comments ($rows)" . &nbspaces(3) . "<font size=-1>(<i>Click on 'Doc ID/Comment ID' or 'Response Status' for detailed information</i>)</font>";
           print &title_row('#a0e0c0', '#000099', $title);
           print $output if ($rows > 0);
           print &end_table() . "<br>";
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"select documents in bin",$@);
            print doAlertBox( text => $message);
        }
        eval {
           $csr = $dbh->prepare("SELECT id, title, commenttext FROM $schema.summary_comment WHERE bin = $binid ORDER BY id");
           $csr->execute;
           print &start_table(4, 'center', 55, 70, 310, 315);
           my $output = &add_header_row();
           $output .= &writeBrowseSummaryCommentLink(writeHeader => 1);
           $output .= &add_col() . "<center>Comments<br>Summarized</center>";
           $output .= &add_col() . "<center>Summary Comment<br>Title</center>";
           $output .= &add_col() . "<center>Summary Comment<br>Text</center>";
           my $rows = 0;
           while (my ($id, $title, $text) = $csr->fetchrow_array) {
              $rows++;
              $output .= &add_row();
              $output .= &writeBrowseSummaryCommentLink(summary => $id);
              my ($count) = $dbh->selectrow_array ("select count(*) from $schema.comments where summary = $id");
              $output .= &add_col() . "<center>$count</center>";
              $output .= &add_col() . $title;
              $output .= &add_col() . &getDisplayString($text, 45);
           }
           $csr->finish;
           my $title = ($rows == 0) ? "No Summary Comments in Bin" : "Summary Comments ($rows)" . &nbspaces(3) . "<font size=-1>(<i>Click on 'ID' for detailed information</i>)</font>";
           print &title_row('#a0e0c0', '#000099', $title);
           print $output if ($rows > 0);
           print &end_table() . "<br>";
        };
        if ($@) {
           $message = errorMessage($dbh,$username,$userid,$schema,"select summary comments in bin",$@);
           print doAlertBox( text => $message);
        }
        print "<hr><br>\n";
    }
}

if ($command eq 'updateform') {
    # generate initial update form ----------------------------------------------------------------------------------
    print "<center>\n";
    $command = "update1";
    print "<script language=javascript><!--\n";
    print "    document.$form.command.value='$command';\n";
    print "//--></script>\n";
    print build_drop_box ("binid", \%binlookupvalues,$binid) . " &nbsp; <input type=submit name=binsubmit value=Retrieve> <br><br>\n";

}

if ($command eq 'update2form') {
    # generate initial update form ----------------------------------------------------------------------------------
    eval {
        print "<center>\n";
        $command = "update2";
        print "<script language=javascript><!--\n";
        print "    document.$form.command.value='$command';\n";
        print "//--></script>\n";
        print build_drop_box ("binid", \%binlookupvalues,$binid) . " &nbsp; <input type=submit name=binsubmit value=\"Retrieve Bin Information\" onClick=\"document.$form.command.value='update1'\"> <br><br>\n";
        print "<hr><br>\n";
        print "<table border=0>\n";
        print "<tr><td><b>Name:</b> </td><td><input type=text name=name size=80 maxlength=100 value=\"$name\"></td></tr>\n";
        print "<tr><td><b>Coordinator:</b> </td><td>";
        %lookup_values = get_authorized_users($dbh,$schema,8,-1);
        print build_drop_box ('coordinator', \%lookup_values, $coordinator) . "</td></tr>\n";
        print "<tr><td><b>$firstReviewName Reviewer:</b> </td><td>";
        %lookup_values = get_authorized_users($dbh,$schema,6,-1);
        print build_drop_box ('nepareviewer', \%lookup_values, $nepareviewer) . "</td></tr>\n";
        print "<tr><td><b>Parent Bin:</b> </td><td>";
        %binlookupvalues = get_lookup_values ($dbh, $schema, 'bin', 'id', 'name', "id <> $binid ORDER BY name");
        print build_drop_box ('parent', \%binlookupvalues, $parent, 'InitialBlank', '0') . "</td></tr>\n";
        %lookup_values = get_lookup_values ($dbh,$schema, 'crd_sections', 'id', "section_number || ' ' || section_name", "parent IS NOT NULL ORDER BY section_number");
        foreach my $key (keys %lookup_values) {
            $lookup_values{$key} = getDisplayString($lookup_values{$key}, 75);
        }
        print "<tr><td><b>CRD Section:</b> </td><td>";
        print build_drop_box ('crd_section', \%lookup_values, $crd_section, 'InitialBlank', '0') . "</td></tr>\n";
        
        print "<tr><td><b>Tech Review Policy:</b> </td><td>";
        %lookup_values = get_lookup_values ($dbh,$schema, 'technical_review_policy', 'id', 'name');
        print build_drop_box ('techreviewpolicy', \%lookup_values, $techreviewpolicy) . "</td></tr>\n";
        print "</table><br>\n";
        %auth_users = get_authorized_users($dbh,$schema,5,-1);
        print build_dual_select ('techreviewers', $form, \%auth_users, \%selected_users, '<b>Available<br>Response Writers/<br>Technical Reviewers</b>', '<b>Selected<br>Response Writers/<br>Technical Reviewers</b>', $coordinator);
        print "<br><input type=submit name=binsubmit value=Submit>\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate initial update form",$@);
        print doAlertBox( text => $message);
    }
}

if ($command eq 'addbinform') {
    # generate add form ----------------------------------------------------------------------------------
    eval {
        print "<center>\n";
        $command = "add";
        print "<script language=javascript><!--\n";
        print "    document.$form.command.value='$command';\n";
        print "//--></script>\n";
        print "<table border=0>\n";
        print "<tr><td><b>Name:</b> </td><td><input type=text name=name size=80 maxlength=100></td></tr>\n";
        print "<tr><td><b>Coordinator:</b> </td><td>";
        %lookup_values = get_authorized_users($dbh,$schema,8,-1);
        print build_drop_box ('coordinator', \%lookup_values, ' ') . "</td></tr>\n";
        print "<tr><td><b>$firstReviewName Reviewer:</b> </td><td>";
        %lookup_values = get_authorized_users($dbh,$schema,6,-1);
        print build_drop_box ('nepareviewer', \%lookup_values, ' ') . "</td></tr>\n";
        print "<tr><td><b>Parent Bin:</b> </td><td>";
        %binlookupvalues = get_lookup_values ($dbh, $schema, 'bin', 'id', 'name', 'id = id ORDER BY name');
        print build_drop_box ('parent', \%binlookupvalues, $parent, 'InitialBlank', '0') . "</td></tr>\n";
        %lookup_values = get_lookup_values ($dbh,$schema, 'crd_sections', 'id', "section_number || ' ' || section_name", "parent IS NOT NULL ORDER BY section_number");
        foreach my $key (keys %lookup_values) {
            $lookup_values{$key} = getDisplayString($lookup_values{$key}, 75);
        }
        print "<tr><td><b>CRD Section:</b> </td><td>";
        print build_drop_box ('crd_section', \%lookup_values, $crd_section, 'InitialBlank', '0') . "</td></tr>\n";
        print "<tr><td><b>Tech Review Policy:</b> </td><td>";
        %lookup_values = get_lookup_values ($dbh,$schema, 'technical_review_policy', 'id', 'name');
        print build_drop_box ('techreviewpolicy', \%lookup_values, 2) . "</td></tr>\n";
        print "</table><br>\n";
        %auth_users = get_authorized_users($dbh,$schema,5,-1);
        print build_dual_select ('techreviewers', $form, \%auth_users, \%selected_users, '<b>Available<br>Response Writers/<br>Technical Reviewers</b>', '<b>Selected<br>Response Writers/<br>Technical Reviewers</b>', 0);
        print "<br><input type=submit name=binsubmit value=Submit>\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate add bin form",$@);
        print doAlertBox( text => $message);
    }
}

db_disconnect($dbh);
print "</td></tr></table>\n";
print "</form>\n";
print "<form name=dummy>\n";
print "<input type=hidden name=command value=0>\n";
print "<input type=hidden name=binid value=0>\n";
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=id value=0>\n";
print "<input type=hidden name=summarycommentid value=0>\n";
print "<input type=hidden name=commentid value=0>\n";
print "</form>\n";
print &BuildPrintCommentResponse($username, $userid, $schema, $path);
print "</center></font></body>\n</html>\n";
