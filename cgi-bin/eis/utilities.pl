#!/usr/local/bin/newperl -w

# Utilities page for the CRD
#
# $Source: /data/dev/rcs/crd/perl/RCS/utilities.pl,v $
#
# $Revision: 1.67 $
#
# $Date: 2001/12/27 22:28:57 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: utilities.pl,v $
# Revision 1.67  2001/12/27 22:28:57  atchleyb
# made display of search log a developer only function
#
# Revision 1.66  2001/12/04 19:05:42  mccartym
# fix activity log display of 'proxy enter response'
#
# Revision 1.65  2001/11/08 21:49:58  naydenoa
# Added activity filter "Renumber document" to Activity/Error Log display
#
# Revision 1.64  2001/11/07 02:06:08  mccartym
# add link for renumber document utility
#
# Revision 1.63  2001/11/02 19:36:50  atchleyb
# changed javascript submit functions to not reset values after submition
# changed alert box code to handle single quotes
#
# Revision 1.62  2001/10/24 23:06:42  atchleyb
# updated log message for reload all and range of images
# updated to display what document reload images is working on
# updated so that there is only one option for checking image reload in the activity log
#
# Revision 1.61  2001/10/24 20:14:06  atchleyb
# added new option to reload image to load a range of images
#
# Revision 1.60  2001/10/02 22:26:47  atchleyb
# changed priv required to run find dups from -1 to 10
#
# Revision 1.59  2001/09/13 16:48:22  atchleyb
# updated to allow sys admins to do crd mapping
#
# Revision 1.58  2001/08/20 19:28:39  atchleyb
# added textbox resizer to find duplicates results box.
# fixed bug in find duplicates introduced with the lastSubmittedText function inclusion
#
# Revision 1.57  2001/08/16 16:43:33  naydenoa
# Updated search string for activity log message
#
# Revision 1.56  2001/08/15 23:22:19  naydenoa
# Added new activity to log
#
# Revision 1.55  2001/07/30 20:44:06  naydenoa
# Checkpoint
#
# Revision 1.54  2001/06/28 21:40:10  mccartym
# remove 'Delete Comments' command
#
# Revision 1.53  2001/06/15 23:18:40  naydenoa
# Changed Software Request formatting on main utilities screen
#
# Revision 1.52  2001/06/14 22:41:31  naydenoa
# Fixed main screen formatting
# Added SCCB options
#
# Revision 1.51  2001/06/08 22:32:36  atchleyb
# added commands for CRD Mapping (currently must be developer to use)
#
# Revision 1.50  2001/06/01 16:20:32  naydenoa
# Added error display to activity log - color-coded error text in red
#
# Revision 1.49  2001/05/24 23:23:20  naydenoa
# Some more minor interface tweaks
#
# Revision 1.48  2001/05/24 22:49:20  naydenoa
# Minor interface tweaks...
#
# Revision 1.47  2001/05/24 22:27:47  naydenoa
# Rearranged main utilities screen, added DOE/Final review to activity filter
#
# Revision 1.46  2001/05/17 16:21:19  atchleyb
# modified to use &FirstReviewName from DocumentSpecific.pm instead of NEPA
#
# Revision 1.45  2001/05/17 15:43:36  naydenoa
# Added new activity message
#
# Revision 1.44  2001/05/17 00:23:56  mccartym
# add link for Update Response Writer utility
#
# Revision 1.43  2001/05/16 20:52:59  atchleyb
# added function lastSubmittedText to check for duplicate responses
#
# Revision 1.42  2001/05/01 16:42:56  naydenoa
# Corrected activity log options.
#
# Revision 1.41  2001/04/30 17:28:57  naydenoa
# Added 2 activities to the activity display
#
# Revision 1.40  2001/04/30 04:32:29  mccartym
# add 'Do Response Workflow Step' command
#
# Revision 1.39  2001/04/06 21:03:26  naydenoa
# Added last 10 display, changed activity to error for error log,
# added "Update document" to activity list
#
# Revision 1.38  2001/04/06 20:17:36  naydenoa
# Added activity and error log filters (by user and by activity)
#
# Revision 1.37  2001/03/29 16:58:15  mccartym
# addressee changes
#
# Revision 1.36  2000/10/18 18:07:44  atchleyb
# updated the method of searching for duplicates to run in memory for most searches (much faster)
#
# Revision 1.35  2000/07/26 23:11:47  atchleyb
# changed algorithm for finding duplicate documents
# it no longer loads it all into memory at once to process
#
# Revision 1.34  2000/07/13 17:05:02  munroeb
# added duplicate document search utility
#
# Revision 1.33  2000/05/17 16:28:30  mccartym
# add Find Duplicate Comments utility
#
# Revision 1.32  2000/05/03 15:35:25  atchleyb
# fixed misspelling...
#
# Revision 1.31  2000/04/27 17:48:52  atchleyb
# added document id to error message for load all images
#
# Revision 1.30  2000/04/26 21:17:38  atchleyb
# changed load one image and load all images to be on the same screen
# changed format to status page for load all images
# changed page title for load images
#
# Revision 1.29  2000/04/25 23:59:25  atchleyb
# corrected type in error message
#
# Revision 1.28  2000/04/25 22:03:27  atchleyb
# modified message for image reload when image not changed
#
# Revision 1.27  2000/04/25 21:26:13  atchleyb
# changed messages for reload of one image
#
# Revision 1.26  2000/04/25 17:20:15  atchleyb
# now testing status for reload of one image before logging the activity
#
# Revision 1.25  2000/04/24 23:42:26  atchleyb
# added test to image reload to see if image was different
# added test to see if image > 10 MB, do not reload when reload all images run.
#
# Revision 1.24  2000/04/19 23:35:10  atchleyb
# added new user screens for reloading all bracketed images
#
# Revision 1.23  2000/04/14 22:17:39  atchleyb
# added utility to reload a bracketed image
# added utility to reload all bracketed images
#
# Revision 1.22  2000/03/14 19:34:58  atchleyb
# changed code for testing if there are dependent similar documents
#
# Revision 1.21  2000/03/14 19:23:18  atchleyb
# changed Summarize Comments link to debug only
#
# Revision 1.20  2000/03/14 18:13:25  atchleyb
# added function to reopen a document for comment entry
#
# Revision 1.19  2000/03/13 18:24:57  atchleyb
# added summarize comments link
# put links in table to fit on one screen
#
# Revision 1.18  2000/02/12 22:35:56  mccartym
# add link for rebin comment
#
# Revision 1.17  1999/12/08 18:03:25  mccartym
# add system privilege check on update summary comment link
#
# Revision 1.16  1999/12/07 19:50:58  mccartym
# add link for update summary comment
#
# Revision 1.15  1999/11/17 23:49:49  mccartym
# change default log size to 100
#
# Revision 1.14  1999/11/04 15:47:12  mccartym
# title changes
#
# Revision 1.13  1999/10/19 15:20:25  atchleyb
# added function to delete a comment (Mark)
#
# Revision 1.12  1999/09/10 01:37:19  mccartym
# modify view log
#
# Revision 1.11  1999/09/03 20:50:35  atchleyb
# placed db functions inside of eval blocks
#
# Revision 1.10  1999/09/02 23:47:32  atchleyb
# added evals and errorchecking to db accesses
#
# Revision 1.9  1999/08/25 18:23:53  atchleyb
# removed a hard coded path
#
# Revision 1.8  1999/08/11 23:24:15  atchleyb
# commented out the re-login option
#
# Revision 1.7  1999/08/10 23:23:44  atchleyb
# inserted command 'Add Bin'
#
# Revision 1.6  1999/08/09 20:35:28  atchleyb
# changed location of check_login function
#
# Revision 1.5  1999/08/02 02:38:19  mccartym
#  Reversed order of parameters on call to headerBar()
#
# Revision 1.4  1999/07/28 22:18:43  atchleyb
# changed links to use form submit
#
# Revision 1.3  1999/07/26 20:46:59  atchleyb
# fixed the sort order on log mesages
#
# Revision 1.2  1999/07/21 22:33:20  atchleyb
# change the path for the update commentor to commentors.pl
#
# Revision 1.1  1999/07/17 00:07:37  atchleyb
# Initial revision
#
#

$| = 1;

use strict;
use integer;
use CRD_Header qw(:Constants);
use CGI;
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use DocumentSpecific qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);

my $crdcgi = new CGI;
my $username = $crdcgi->param("username");
my $userid = $crdcgi->param("userid");
my $schema = $crdcgi->param("schema");
&checkLogin($username,$userid,$schema);

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $dbh;
my $command = defined($crdcgi->param("command")) ? $crdcgi->param("command") : "";
my $message = '';
my $instructionsColor = $CRDFontColor;
my $title = "Utilities";
if ($command eq "view_errors") {
   $title = "Error Log";
} elsif ($command eq "view_activity") {
   $title = "Activity Log";
} elsif ($command eq "reset_commentsentered") {
   $title = "Reopen Document for Comment Entry";
} elsif ($command eq "reload_image") {
   $title = "Reload Document Images";
} elsif ($command eq "reload_all_images_page" || $command eq "reload_all_images") {
   $title = "Reload Document Images";
} elsif ($command eq "find_duplicate_comments") {
   $title = "Find Duplicate Comments";
} elsif ($command eq "find_duplicate_comments_m") {
   $title = "Find Duplicate Comments";
}


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
sub drawFindDuplicateCommentsInterface {
###################################################################################################################################
    my $outputstring =
          "<table border=0 cellspacing=0 cellpadding=3 width=400 align=center>\n".
          "<tr><td align=center><table border=0 cellspacing=0 cellpadding=3 width=100%>\n".
          #"<tr><td bgcolor=#eeeeee colspan=2><font size=4><b>1. Please Pick an Option</b></font></td></tr>\n".
          "<tr><td align=center><input type=radio name=rdoSelection1 value=UNMARKEDDUPS checked>\n".
          "</td><td><b>Find Unmarked Duplicates</b></td></tr>\n".
          "<tr><td align=center><input type=radio name=rdoSelection1 value=ALLDUPS>".
          "</td><td><b>Find All Duplicates</b></td></tr>\n".
          "<tr><td align=center><input type=radio name=rdoSelection1 value=MARKEDDUPS>".
          "</td><td><b>Find Marked Duplicates with Differing Text</b></td></tr>\n".
          "<tr><td align=center><input type=radio name=rdoSelection1 value=DUPRESPONSES><br><br>\n".
          "</td><td><b>Find Duplicate Responses</b><br><br></td></tr>\n".
          "<tr><td colspan=2><b>Document Range - From:&nbsp;</b><input type=text name=startid size=6 maxlen=6 value=" . ((defined($crdcgi->param('startid'))) ? $crdcgi->param('startid') : "1") . ">\n" .
          "<b>To:&nbsp;</b><input type=text name=endid size=6 maxlen=6 value=" . ((defined($crdcgi->param('startid'))) ? $crdcgi->param('endid') : "999999") . "></td></tr>\n" .
          "</table>\n</td></tr><tr><td align=center>\n".
          "<input type=button name=dodupsearch value=Submit onClick=\" submitForm('utilities','find_duplicate_comments_display');\">".
          "</td></tr></table>\n";
    return ($outputstring);
}

###################################################################################################################################
sub drawFindDuplicateCommentsDisplay {
###################################################################################################################################
    my $searchType = "";
    my $selection = $crdcgi->param('rdoSelection1');
    if ($selection eq "UNMARKEDDUPS") {
        $searchType = "Unmarked Duplicates";
    } elsif ($selection eq "ALLDUPS") {
        $searchType = "All Duplicates";
    } elsif ($selection eq "MARKEDDUPS") {
        $searchType = "Marked Duplicates with Differing Text";
    } elsif ($selection eq "DUPRESPONSES") {
        $searchType = "Duplicate Responses";
    }
    my $outputstring = '';

    $outputstring .= "<table border=0 cellspacing=0 cellpadding=3 width=750 align=center>\n";
    #$outputstring .= "<tr><td align=center>" . drawFindDuplicateCommentsInterface;
    $outputstring .=
          "</td></tr>\n<tr><td align=center><hr width=90%></td></tr>\n" .
          "<tr><td align=center><table border=0 align=center>\n" .
          "<tr><td align=center>Elapsed Time:</td><td>" . nbspaces(20) . "</td><td align=center>Status:</td></tr>\n" .
          "<tr><td align=center><input type=text size=8 name=clock readonly onClick=\"this.blur();\"></td><td> </td>\n" .
          "<td align=center><input type=text size=8 name=status readonly value='Working' onClick=\"this.blur();\"></td></tr>\n" .
          "</td></tr></table></td></tr>\n" .
          "<tr><td align=center><hr width=75%></td></tr>\n" .
          "<tr><td align=center><table border=0 align=center>\n" .
          "<tr><td align=center>Document / Comment</td><td>" . nbspaces(10) . "</td><td align=center>$searchType" . nbspaces(65) . "<a href=\"javascript:expandTextBox(document.$form.foundlist,document.foundlist_button,'force',5);\"><img name=foundlist_button border=0 src=/eis/images/expand_button.gif></a></td></tr>\n" .
          "<tr><td align=center valign=top><table border=0 align=center>\n" .
          "<tr><td align=center><input type=text size=8 name=itemcount readonly value='0' onClick=\"this.blur();\"></td></tr>\n" .
          "<tr><td align=center><select size=1 name=itemlist onChange=\"updateFoundList(this);expandTextBox(document.$form.foundlist,document.foundlist_button,'dynamic',0);\">\n<option value=0>" . nbspaces(25) . "</option>\n</select></td></tr>\n" .
          "</table></td><td>&nbsp;</td>\n" .
          "<td align=center><textarea rows=5 name=foundlist cols=50></textarea>\n" .
          "</td></tr>" .
          "<tr><td align=center colspan=3>" .
          #"<input type=checkbox name=displaytext value='T'>Display Text &nbsp; " .
          "<input type=button name=builddupreportbutton value=Report onClick=\"processBuildDupReportButton();\">" .
          "</td></tr>\n" .
          "</table></td></tr>\n" .
          "</table>\n";

    $outputstring .=
       "<input type=hidden name=rdoSelection value=" . $crdcgi->param('rdoSelection1') . ">\n" .
       "<input type=hidden name=fulldocumentcommentlist value=''>\n" .
       "<input type=hidden name=idstart value=" . ((defined($crdcgi->param('startid'))) ? $crdcgi->param('startid') : "1") . ">\n" .
       "<input type=hidden name=idend value=" . ((defined($crdcgi->param('endid'))) ? $crdcgi->param('endid') : "999999") . ">\n";

    $outputstring .=
       "<script language=javascript><!--\n" .
       "\n" .
       "        var seconds = 0;\n" .
       "        var minutes = 0;\n" .
       "        var hours = 0;\n" .
       "        var timerID;\n" .
       "        var timerRunning = true;\n" .
       "        \n" .
       "        function lpadzero(instring, width) {\n" .
       "            var result = '';\n" .
       "            var index;\n" .
       "            for (index = 1; index <= (width - instring.length); index++) {\n" .
       "                result += \"0\";\n" .
       "            }\n" .
       "            return (result + instring);\n" .
       "        }\n" .
       "        function updateFoundList(what) {\n" .
       "            var a1 = new Array();\n" .
       "            var a2 = new Array();\n" .
       "            var a3 = new Array();\n" .
       "            var outstring = '';\n" .
       "            if (what[what.selectedIndex].value != '0') {\n" .
       "                a1 = what[what.selectedIndex].value.split('=>');\n" .
       "                a2 = a1[1].split(',');\n" .
       "                for (var i = 0; i < a2.length; i++) {\n" .
       "                    a3 = a2[i].split('-');\n" .
       "                    outstring += '$CRDType' + lpadzero(a3[0],6) + '/' + lpadzero(a3[1],4) + '  ';\n" .
       "                }\n" .
       "            } else {\n" .
       "                outstring = ' ';\n" .
       "            }\n" .
       "            document.$form.foundlist.value=outstring;\n" .
       "        }\n" .
       "        function processBuildDupReportButton() {\n" .
       "            var outputstring = '';\n" .
       "            if (document.$form.status.value != 'Finished') {\n" .
       "                alert('Search not finished yet');\n" .
       "            } else {\n" .
       "                for (var index=0; index<document.$form.itemlist.length; index++) {\n" .
       "                    if (document.$form.itemlist[index].value != '0') {\n" .
       "                        outputstring += document.$form.itemlist[index].value + ';';\n" .
       "                    }\n" .
       "                }\n" .
       "                if (outputstring != '') {\n" .
       "                    document.$form.fulldocumentcommentlist.value = outputstring;\n" .
       "                    submitFormNewWindow('$form','print_duplicate_comments_report');\n" .
       "                    //alert('Report not available yet');\n" .
       "                } else {\n" .
       "                    alert('Did not find any $searchType\\nNo report generated');\n " .
       "                }\n" .
       "            }\n" .
       "        }\n" .
       "        function displayTime() {\n" .
       "            var temp;\n" .
       "            if (seconds >= 59) {\n" .
       "                seconds = 0;\n" .
       "                if (minutes >= 59) {\n" .
       "                    minutes = 0;\n" .
       "                    hours++;\n" .
       "                } else {\n" .
       "                    minutes++;\n" .
       "                }\n" .
       "            } else {\n" .
       "                seconds++;\n" .
       "            }\n" .
       "            if (seconds < 10) {var ss = '0'} else {var ss = ''}\n" .
       "            if (minutes < 10) {var ms = '0'} else {var ms = ''}\n" .
       "            if (hours < 10) {var hs = '0'} else {var hs = ''}\n" .
       "            temp = hs + hours + ':' + ms + minutes + ':' + ss + seconds;\n" .
       "            document.$form.clock.value = temp;\n" .
       "            if (timerRunning) {\n" .
       "                timerID = setTimeout(\"displayTime()\", 1000);\n" .
       "            }\n" .
       "        }\n" .
       "\n" .
       "        displayTime();\n" .
       "\n" .
       "   //document.$form.builddupreportbutton.disabled = true;\n" .
       "   submitFormCGIResults('utilities','find_duplicate_comments');\n" .
       "//--></script>\n";

    return ($outputstring);
}


###################################################################################################################################
sub getReportDateTime {
###################################################################################################################################
    my @timedata = localtime(time);
    return(uc(get_date()) . " " . lpadzero($timedata[2],2) . ":" . lpadzero($timedata[1],2) . ":" . lpadzero($timedata[0],2));
}


###################################################################################################################################
sub buildDuplicateCommentsReport {
###################################################################################################################################
    my $searchType = "";
    my $selection = $crdcgi->param('rdoSelection');
    #my $displayText = ((defined($crdcgi->param('displaytext'))) ? $crdcgi->param('displaytext') : "F");
    my $message;
    my $inputData = ';';
    my @originals;
    my $originalID;
    my $IDList;
    my @matchList;
    my $fetchTable = 'comments';
    my $fetchWhere = '';
    my $fetchColumn = 'text';
    my $fetchValue;

    sub FormatIDs {
        my $inputID = $_[0];
        my ($document, $commentnum) = split /-/, $inputID;
        return ($CRDType . lpadzero($document,6) . "&nbsp;/&nbsp;" . lpadzero($commentnum,4));
    }

    sub getBinName {
        my $inputID = $_[0];
        my ($document, $commentnum) = split /-/, $inputID;
        my $bin = get_value($dbh,$schema,'comments','bin',"document=$document AND commentnum=$commentnum");
        my $outputstring = get_value($dbh,$schema,'bin','name',"id=$bin");
        return ($outputstring);
    }

    if ($selection eq "UNMARKEDDUPS") {
        $searchType = "Unmarked Duplicates";
    } elsif ($selection eq "ALLDUPS") {
        $searchType = "All Duplicates";
    } elsif ($selection eq "MARKEDDUPS") {
        $searchType = "Marked Duplicates with Differing Text";
    } elsif ($selection eq "DUPRESPONSES") {
        $searchType = "Duplicate Responses";
        $fetchTable = 'response_version';
        $fetchColumn = 'lastsubmittedtext';
        $fetchWhere = ' AND status < 10';
    }
    my $outputstring = '';
    eval {
        $inputData = ((defined($crdcgi->param('fulldocumentcommentlist'))) ? $crdcgi->param('fulldocumentcommentlist') : ";");
        chop($inputData);
        $outputstring .= "\n<!-- $inputData -->\n\n";
        @originals = split /;/, $inputData;
        $outputstring .= "<script language=javascript><!--\n";
        $outputstring .= "    document.title='$CRDType $searchType Report'\n";
        $outputstring .= "//--></script>\n";
        $outputstring .= "<table border=0 align=center width=650>\n";
        $outputstring .= "<tr><td align=center><h2>$searchType</h2>\n";
        $outputstring .= "<h3>Documents From: $CRDType" . lpadzero($crdcgi->param('idstart'),6) . " To: $CRDType" . lpadzero($crdcgi->param('idend'),6) . "</h3>\n";
        $outputstring .= "<font size=-1>" . getReportDateTime . "<br>&nbsp;</font></td></tr>\n";
        #$outputstring .= "<tr><td align=center>&nbsp;</td></tr>\n";
        foreach my $i (0 .. ($#originals)) {
            ($originalID, $IDList) = split /=>/, $originals[$i];
            $outputstring .= "<tr><td><b>Original: <u>" . FormatIDs($originalID) . "</u></b> - Bin: " . getDisplayString(getBinName($originalID),60) . "<br></td></tr>\n";
            @matchList = split /,/, $IDList;
            if ($selection ne "MARKEDDUPS") {
                $outputstring .= "<tr><td><b>" . (($selection eq "MARKEDDUPS") ? "Mis-" : "") . "Matches:</b><br>\n";
                foreach my $j (0 .. $#matchList) {
                    $outputstring .= FormatIDs($matchList[$j]) . " - Bin: " . getDisplayString(getBinName($matchList[$j]),60) . "<br>\n";
                }
                $outputstring .= "\n&nbsp;</td></tr>\n";
            }
            #if ($displayText eq 'T') {
                if ($selection ne 'MARKEDDUPS') {
                    if ($fetchColumn ne 'lastsubmittedtext') {
                        $fetchValue = get_value($dbh,$schema, $fetchTable, $fetchColumn, "document || '-' || commentnum = '$originalID'" . $fetchWhere);
                    } else {
                        my ($documentID, $commentNum) = split /-/, $originalID;
                        $fetchValue = lastSubmittedText(dbh => $dbh, schema => $schema, documentID => $documentID, commentID => $commentNum);
                    }
                    $fetchValue =~ s/\n/<br>/g;
                    $fetchValue =~ s/  /&nbsp;&nbsp;/g;
                    $outputstring .= "<tr><td>$fetchValue</td></tr>\n";
                } else {
                    if ($fetchColumn ne 'lastsubmittedtext') {
                        $fetchValue = get_value($dbh,$schema, $fetchTable, $fetchColumn, "document || '-' || commentnum = '$originalID'" . $fetchWhere);
                    } else {
                        my ($documentID, $commentNum) = split /-/, $originalID;
                        $fetchValue = lastSubmittedText(dbh => $dbh, schema => $schema, documentID => $documentID, commentID => $commentNum);
                    }
                    $fetchValue =~ s/\n/<br>/g;
                    $fetchValue =~ s/  /&nbsp;&nbsp;/g;
                    #$outputstring .= "<tr><td><u>Original Text</u></td></tr>\n";
                    $outputstring .= "<tr><td>$fetchValue</td></tr>\n";
                    foreach my $j (0 .. $#matchList) {
                        $outputstring .= "<tr><td><br><b>Duplicate: <u>" . FormatIDs($matchList[$j]) . "</u><b> - Bin: " . getDisplayString(getBinName($matchList[$j]),60) . "</td></tr>\n";
                        $fetchValue = get_value($dbh,$schema, $fetchTable, $fetchColumn, "document || '-' || commentnum = '$matchList[$j]'" . $fetchWhere);
                        $fetchValue =~ s/\n/<br>/g;
                        $fetchValue =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<tr><td>$fetchValue</td></tr>\n";
                    }
                }
            #}
            $outputstring .= "<tr><td align=center><br><hr width=50%><br></td></tr>\n";
        }
        $outputstring .= "</table>\n";

    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"print duplicates report.",$@);
        print doAlertBox( text => $message);
    }
    return ($outputstring);
}

###################################################################################################################################
sub findDuplicateComments {
###################################################################################################################################
    my ($selection, $regex, $titlePage);
    my $DocumentCommentID = '';
    my $testDocumentCommentID = '';
    my %MatchesFound = ();
    my %DupList = ();
    my $itemCounter = 0;
    my $sqlquery = '';
    my $csr;
    my @values;
    my $status;
    my $sqlquery2 = '';
    my $csr2;
    my @values2;
    my $message = '';
    my @CRDData;
    my $datacount;

    my $crdcgi = new CGI;

    eval {
        $selection = $crdcgi->param('rdoSelection');
        #$chkPrint = $crdcgi->param('chkPrint'); #prints 'on' if checked.

        if ($selection eq 'UNMARKEDDUPS') {
            $sqlquery = "SELECT document, commentnum, text FROM $schema.comments WHERE dupsimstatus = 1 ";
            $sqlquery .= "AND (document BETWEEN " . $crdcgi->param('idstart') . " AND " . $crdcgi->param('idend') . ") ";
            $sqlquery .= "ORDER BY document, commentnum";
            $sqlquery2 = "SELECT document, commentnum, text FROM $schema.comments WHERE dupsimstatus = 1 ";
            $sqlquery2 .= "AND ((document * 10000 + commentnum) > ?) ORDER BY document, commentnum";
            $regex = 'eq';
            $titlePage = "Find Unmarked Duplicates";
        } elsif ($selection eq 'ALLDUPS') {
            $sqlquery = "SELECT document, commentnum, text FROM $schema.comments ";
            $sqlquery .= "WHERE (document BETWEEN " . $crdcgi->param('idstart') . " AND " . $crdcgi->param('idend') . ") ";
            $sqlquery .= "ORDER BY document, commentnum";
            $sqlquery2 = "SELECT document, commentnum, text FROM $schema.comments WHERE ((document * 10000 + commentnum) > ?) ";
            $sqlquery2 .= "ORDER BY document, commentnum";
            $regex = 'eq';
            $titlePage = "Find All Duplicates";
        } elsif ($selection eq 'MARKEDDUPS') {
            $sqlquery = "SELECT document, commentnum, text FROM $schema.comments ";
            $sqlquery .= "WHERE ((document,commentnum) IN (SELECT dupsimdocumentid, dupsimcommentid FROM $schema.comments WHERE dupsimstatus = 2)) ";
            $sqlquery .= "AND (document BETWEEN " . $crdcgi->param('idstart') . " AND " . $crdcgi->param('idend') . ") ";
            $sqlquery .= "ORDER BY document, commentnum";
            $sqlquery2 = "SELECT document, commentnum, text FROM $schema.comments ";
            $sqlquery2 .= "WHERE dupsimdocumentid=? AND dupsimcommentid=? ";
            $sqlquery2 .= "ORDER BY document, commentnum";
            $regex = 'ne';
            $titlePage = "Find Marked Duplicates with Differing Text";
        } elsif ($selection eq 'DUPRESPONSES') {
            $sqlquery = "SELECT document, commentnum, lastsubmittedtext FROM $schema.response_version ";
            $sqlquery .= "WHERE lastsubmittedtext IS NOT NULL AND status < 10 ";
            $sqlquery .= "AND (document BETWEEN " . $crdcgi->param('idstart') . " AND " . $crdcgi->param('idend') . ") ";
            $sqlquery .= "ORDER BY document, commentnum";
            $sqlquery2 = "SELECT document, commentnum, lastsubmittedtext FROM $schema.response_version ";
            $sqlquery2 .= "WHERE lastsubmittedtext IS NOT NULL AND status < 10 AND ((document * 10000 + commentnum) > ?) ";
            $sqlquery2 .= "ORDER BY document, commentnum, version";
            $regex = 'eq';
            $titlePage = "Find Duplicate Responses";
        }

        print "\n<!-- $sqlquery -->\n\n";
        print "<!-- $sqlquery2 -->\n\n";

        # load data into array

        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        $datacount = -1;
        while (@values = $csr->fetchrow_array) {
            $datacount++;
            $CRDData[$datacount][0] = $values[0];
            $CRDData[$datacount][1] = $values[1];
            $CRDData[$datacount][2] = $values[0] . '-' . $values[1];
            #$CRDData[$datacount][3] = $values[2];
            $CRDData[$datacount][3] = (($selection ne 'DUPRESPONSES') ? $values[2] : lastSubmittedText(dbh => $dbh, schema => $schema, documentID => $values[0], commentID => $values[1]));
            $CRDData[$datacount][3] =~ s/[.,':;\n\s“”’"`?!\-)(]+//gs;
            $CRDData[$datacount][3] = lc($CRDData[$datacount][3]);
        }
        $csr->finish;

        ## beginning of 'eq' matches
        #

        if ($regex eq "eq") {

            # load data into array

            $csr = $dbh->prepare($sqlquery);
            $status = $csr->execute;
            $datacount = -1;
            while (@values = $csr->fetchrow_array) {
                $datacount++;
                $CRDData[$datacount][0] = $values[0];
                $CRDData[$datacount][1] = $values[1];
                $CRDData[$datacount][2] = $values[0] . '-' . $values[1];
                #$CRDData[$datacount][3] = $values[2];
                $CRDData[$datacount][3] = (($selection ne 'DUPRESPONSES') ? $values[2] : lastSubmittedText(dbh => $dbh, schema => $schema, documentID => $values[0], commentID => $values[1]));
                $CRDData[$datacount][3] =~ s/[.,':;\n\s“”’"`?!\-)(]+//gs;
                $CRDData[$datacount][3] = lc($CRDData[$datacount][3]);
            }
            $csr->finish;

#            $csr = $dbh->prepare($sqlquery);
#            $status = $csr->execute;
#            $csr2 = $dbh->prepare($sqlquery2);
#            while (@values = $csr->fetchrow_array) {
            for (my $i = 0; $i < $datacount; $i++) {
#                $DocumentCommentID = "$values[0]-$values[1]";
                $DocumentCommentID = $CRDData[$i][2];
                if (!(defined($DupList{$DocumentCommentID}))) {
                    $MatchesFound{$DocumentCommentID} = '';
#                    $values[2] =~ s/[.,':;\n\s“”’"`?!\-)(]+//gs;
#                    $values[2] = lc($values[2]);
#                    $status = $csr2->execute($values[0]*10000+$values[1]);
#                    while (@values2 = $csr2->fetchrow_array) {
                    for (my $j = $i + 1; $j <= $datacount; $j++) {
#                        if (!(defined($DupList{$values2[0]-$values2[1]}))) {
                        if (!(defined($DupList{$CRDData[$j][2]}))) {
#                            $values2[2] =~ s/[.,':;\n\s“”’"`?!\-)(]+//gs;
#                            $values2[2] = lc($values2[2]);
#                            if ($values[2] eq $values2[2]) {
                            if ($CRDData[$i][3] eq $CRDData[$j][3]) {
#                                $MatchesFound{$DocumentCommentID} .= "$values2[0]-$values2[1],";
                                $MatchesFound{$DocumentCommentID} .= "$CRDData[$j][2],";
#                                $DupList{$values2[0]-$values2[1]} = 'T';
                                $DupList{$CRDData[$j][2]} = 'T';
                            }
                        }
                    }
#                    $csr2->finish;

                    if ($MatchesFound{$DocumentCommentID} ne '') {
                        chop($MatchesFound{$DocumentCommentID});
                        $itemCounter++;
                        print "<script language=JavaScript>\n";
                        print "    parent.main.$form.itemcount.value=$itemCounter;\n";
#                        print "    append_option(parent.main.$form.itemlist, '$DocumentCommentID=>$MatchesFound{$DocumentCommentID}', '$CRDType" . lpadzero($values[0],6) . " / " . lpadzero ($values[1],4) . "');\n";
                        print "    append_option(parent.main.$form.itemlist, '$DocumentCommentID=>$MatchesFound{$DocumentCommentID}', '$CRDType" . lpadzero($CRDData[$i][0],6) . " / " . lpadzero ($CRDData[$i][1],4) . "');\n";
                        if ($itemCounter == 1) {print "    parent.main.updateFoundList(parent.main.$form.itemlist);\n";}
                        print "</script>\n";
                    } else {
                        print "<!-- Keep alive $DocumentCommentID -->\n";
                    }
                }

            }
#            $csr->finish;
            ## end of 'eq' matches
            #
        } else {
            $csr = $dbh->prepare($sqlquery);
            $status = $csr->execute;
            $csr2 = $dbh->prepare($sqlquery2);
            while (@values = $csr->fetchrow_array) {
#            for (my $i = 0; $i < $datacount; $i++) {
                $DocumentCommentID = "$values[0]-$values[1]";
#                $DocumentCommentID = $CRDData[$i][2];
                $MatchesFound{$DocumentCommentID} = '';
                $values[2] = (($selection ne 'DUPRESPONSES') ? $values[2] : lastSubmittedText(dbh => $dbh, schema => $schema, documentID => $values[0], commentID => $values[1]));
                $values[2] =~ s/[.,':;\n\s“”’"`?!\-)(]+//gs;
                $values[2] = lc($values[2]);
                $status = $csr2->execute($values[0],$values[1]);
#print "\n<!-- Original: $values[2] -->\n";
                while (@values2 = $csr2->fetchrow_array) {
#                for (my $j = $i + 1; $j <= $datacount; $j++) {
                    $values2[2] = (($selection ne 'DUPRESPONSES') ? $values2[2] : lastSubmittedText(dbh => $dbh, schema => $schema, documentID => $values2[0], commentID => $values2[1]));
                    $values2[2] =~ s/[.,':;\n\s“”’"`?!\-)(]+//gs;
                    $values2[2] = lc($values2[2]);
#print "\n<!-- Dup-----: $values2[2] -->\n";
                    if ($values[2] ne $values2[2]) {
#                    if ($CRDData[$i][3] ne $CRDData[$j][3]) {
                        $MatchesFound{$DocumentCommentID} .= "$values2[0]-$values2[1],";
#                        $MatchesFound{$DocumentCommentID} .= "$CRDData[$j][2],";
                    }
                }
                $csr2->finish;
                if ($MatchesFound{$DocumentCommentID} ne '') {
                    chop($MatchesFound{$DocumentCommentID});
                    $itemCounter++;
                    print "<script language=JavaScript>\n";
                    print "    parent.main.$form.itemcount.value=$itemCounter;\n";
                    print "    append_option(parent.main.$form.itemlist, '$DocumentCommentID=>$MatchesFound{$DocumentCommentID}', '$CRDType" . lpadzero($values[0],6) . " / " . lpadzero ($values[1],4) . "');\n";
#                    print "    append_option(parent.main.$form.itemlist, '$DocumentCommentID=>$MatchesFound{$DocumentCommentID}', '$CRDType" . lpadzero($CRDData[$i][0],6) . " / " . lpadzero ($CRDData[$i][1],4) . "');\n";
                    if ($itemCounter == 1) {print "    parent.main.updateFoundList(parent.main.$form.itemlist);\n";}
                    print "</script>\n";
                } else {
                    print "<!-- Keep alive $DocumentCommentID -->\n";
                }
            }
            $csr->finish;


            #} ## end of 'ne' matches
              #
        } # end of ifelse
        print "<script language=JavaScript>\n";
        print "    parent.main.timerRunning=false;\n";
        print "    parent.main.$form.status.value='Finished';\n";
        print "    //parent.main.$form.builddupreportbutton.disabled = false;\n" .
        print "</script>\n";

    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"find duplicates - option: $selection",$@);
        print doAlertBox( text => $message);
    }

}

###################################################################################################################################
sub reloadImage {
###################################################################################################################################
    my %args = (
        document => "",
        dbh => '',
        schema => '',
        userid => 0,
        imageType => 'Bracketed',
        processType => 'Auto',
        @_,
    );

    my $status = 1;
    my $filename = "$CRDType" . lpadzero($args{document},6) . ".pdf";
    my $localfilename = "$CRDType" . lpadzero($args{document},6) . ".pdf";
    my $remote_path ='';
    my $message = '';
    my $sqlcode = '';
    my @values;

#    if ($CRDProductionStatus == 0 && $CRDUser ne $schema) {
    if (uc($CRDUser) ne uc($schema)) {
        $remote_path = $CRDType . "_CD_Images\\\\Dev" . $args{imageType};
    } else {
        $remote_path = $CRDType . "_CD_Images\\\\" . $args{imageType};
    }

    # delete image file from web server
    my @status = stat("$CRDFullDocPath/$filename");
    if ($#status >= 0) {
        if (open (FH2, "./File_Utilities.pl --command=deleteFile --fullFilePath=$CRDFullDocPath/$filename |")) {
            $status = <FH2>;
            close FH2;
        } else {
            $status = 0;
        }
    }

    if ($status == 1) {
        # get image from file server
        if (open (FH2, "./File_Utilities.pl --command=sambaCopy --localPath=$CRDFullDocPath --remotePath=$remote_path --imageFile=$filename --localFile=$localfilename --protection=0777 |")) {
            $status = <FH2>;
            close FH2;
        }
        if ($status == 1) {
            my @fileStats = stat "$CRDFullDocPath/$localfilename";
            # only load image less than 10 MB
            if ($fileStats[7] < 10485760 || $args{processType} eq 'Manual') {
                # get new image from disk
                open FH1, "<$CRDFullDocPath/$filename";
                my $val = "";
                my $rc = read(FH1, $val, 100000000);
                close FH1;

                # get old image from db
                $args{'dbh'}->{LongReadLen} = 100000000;
                $sqlcode = "SELECT image FROM $args{schema}.document WHERE id = $args{document} AND image IS NOT NULL";
                @values = $args{'dbh'}->selectrow_array($sqlcode);

                if (!(defined($values[0])) ||$val ne $values[0]) {
                    # delete image from database
                    undef $values[0];
                    $sqlcode = "UPDATE $args{schema}.document SET image = NULL WHERE id = $args{document}";
                    $status = $args{dbh}->do($sqlcode);

                    # load new image into database
                    $sqlcode = "UPDATE $args{schema}.document SET image = ? where id = $args{document}";
                    my $csr = $args{dbh}->prepare($sqlcode);
                    $csr->bind_param(1, $val, { ora_type=>ORA_BLOB, ora_field=>'image'});
                    $status=$csr->execute;
                    $args{dbh}->commit;
                    $csr->finish;
                    undef $val;

                    $status = 1;
                } else {
                    $status = 2;
                }
            } else {
                $status = 3;
            }

        } elsif ($status == 0) {
            #
        } else {
            #$status = -2;
        }
    } else {
        $status = -1;
    }
    return ($status);
}

################
sub matchFound {
################
   my %args = (
      @_,
   );
   my $out;
   $out = ($args{text} =~ m/$args{searchString}/i) ? 1 : 0;
   return ($out);
}


$dbh = db_connect();
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 10000000;
print $crdcgi->header('text/html');
print <<end;
<html>
<head>
   <meta http-equiv=expires content=now>
   <script src=$CRDJavaScriptPath/utilities.js></script>
   <script src=$CRDJavaScriptPath/widgets.js></script>
   <script language=javascript><!--
      function submitForm(script, command) {
         document.$form.command.value = command;
         document.$form.action = '$path' + script + '.pl';
         document.$form.submit();
      }

        function submitFormMain(script, command) {
        document.$form.target = 'main';
        document.$form.command.value = command;
        document.$form.action = '$path' + script + '.pl';
        document.$form.submit();
      }

      function submitForm2(script, command, id) {
          document.$form.command.value = command;
          document.$form.id.value = id;
          document.$form.action = '$path' + script + '.pl';
          document.$form.target = 'main';
          document.$form.submit();
      }

     function submitFormNewWindow(script, command) {
          var myDate = new Date();
          var winName = myDate.getTime();
          document.$form.command.value = command;
          document.$form.action = '$path' + script + '.pl';
          document.$form.target = winName;
          var newwin = window.open("",winName);
          newwin.creator = self;
          document.$form.submit();
          //newwin.focus();
      }

      function submitFormCGIResults(script, command) {
          document.$form.command.value = command;
          document.$form.action = '$path' + script + '.pl';
          document.$form.target = 'cgiresults';
          document.$form.submit();
      }


      function display_user(id) {
         document.$form.id.value = id;
         submitForm('user_functions', 'displayuser');
      }
//-->
</script>
end
print "\n</head>\n";
print "<body background=$CRDImagePath/background.gif text=$CRDFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n";
if ($command ne 'print_duplicate_comments_report') {
    print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => $title);
}
print "<font face=$CRDFontFace color=$CRDFontColor>\n";
print "<br>\n";
if ($command ne 'print_duplicate_comments_report') {
    print "<table border=0 width=750><tr><td>\n";
} else {
    print "<table border=0 width=650><tr><td>\n";
}
print "<form name=$form method=post onSubmit=false>\n";
print "<input type=hidden name=command value=$command>\n";
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=id value=0>\n";
print "<center>\n";

my @months = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
my $dd = sprintf("%02d", $mday);
$year += 1900;
my $today = uc("$dd-$months[$mon]-$year");

# get the first day of last month
my $lastmonth = ($mon == 0) ? 12 : $mon;
my $mm = sprintf("%02d", $lastmonth);
my $yr = ($mon == 0) ? $year - 1 : $year;
my $startLastMonth = "01-$mm-$yr";

tie my %options, "Tie::IxHash";
%options = (
   "today"     => { 'index' => 0, 'title' => "Today",             'where' => "to_date(datelogged) = to_date('$today')" },
   "yesterday" => { 'index' => 1, 'title' => "Yesterday",         'where' => "to_date(datelogged) = to_date('$today') - 1" },
   "thisweek"  => { 'index' => 2, 'title' => "This Week",         'where' => "to_date(datelogged) between to_date('$today') - ($wday - 1) and to_date('$today')" },
   "lastweek"  => { 'index' => 3, 'title' => "Last Week",         'where' => "to_date(datelogged) between to_date('$today') - ($wday + 6) and to_date('$today') - $wday" },
   "thismonth" => { 'index' => 4, 'title' => "This Month",        'where' => "to_date(datelogged) between to_date('$today') - ($mday - 1) and to_date('$today')" },
   "lastmonth" => { 'index' => 5, 'title' => "Last Month",        'where' => "to_date(datelogged) between to_date('$startLastMonth', 'DD-MM-YYYY') and to_date('$today') - $mday" },
   "pastweek"  => { 'index' => 6, 'title' => "Past 7 Days",       'where' => "to_date(datelogged) between to_date('$today') - 6 and to_date('$today')" },
   "pastmonth" => { 'index' => 7, 'title' => "Past 30 Days",      'where' => "to_date(datelogged) between to_date('$today') - 29 and to_date('$today')" },
   "last10"   => { 'index' => 8, 'title' => "Last 10 Entries",  'where' => "1 = 1" },
   "last100"   => { 'index' => 9, 'title' => "Last 100 Entries",  'where' => "1 = 1" },
   "last1000"  => { 'index' => 10, 'title' => "Last 1000 Entries", 'where' => "1 = 1" }
);

tie my %logacts, "Tie::IxHash";
%logacts = (
    "all" => {'index' => 0, 'title' => "All Activities"},
    "bin.+added" => {'index' => 1, 'title' => "Add bin"},
    "assign user.+tech editor" => {'index' => 2, 'title' => "Assign technical editor"},
    "coordinator accept scr" => {'index' => 3, 'title' => "Bin coordinator accept summary comment"},
    "browsecomment.+existence" => {'index' => 4, 'title' => "Browse - check existence"},
    "browse comment" => {'index' => 5, 'title' => "Browse comment"},
    "browse range" => {'index' => 6, 'title' => "Browse range of comments"},
    "password changed?" => {'index' => 7, 'title' => "Change password"},
    "check if image loaded" => {'index' => 8, 'title' => "Check image load"},
    "commentor.+created" => {'index' => 9, 'title' => "Create commentor"},
    "document.+created" => {'index' => 10, 'title' => "Create document"},
    "created set.+duplicate" => {'index' => 11, 'title' => "Create set of duplicate comments"},
    "summary comment.+created" => {'index' => 12, 'title' => "Create summary comment"},
    "was created" => {'index' => 13, 'title' => "Create user"},
    "delete comments" => {'index' => 14, 'title' => "Delete comment"},
    "delete received message" => {'index' => 15, 'title' => "Delete received message"},
    "delete sent message" => {'index' => 16, 'title' => "Delete sent message"},
    "enter comment" => {'index' => 17, 'title' => "Enter comment"},
    "^(enter|update).+concurrence.+[0-9]\$" => {'index' => 62, 'title' => "Enter/update concurrence"},
    "manage approvals for scr" => {'index' => 18, 'title' => "Manage approvals for summary comments"},
    "mark.+duplicate" => {'index' => 19, 'title' => "Mark as duplicate"},
    "process bin coordinator assign response" => {'index' => 20, 'title' => "Process bin coordinator assignment"},
    "process entry of comment" => {'index' => 21, 'title' => "Process entry of comment"},
    "process proofread of summary comment entry" => {'index' => 22, 'title' => "Process proofread - summary comment"},
    "process response - accept" => {'index' => 23, 'title' => "Process response - accept"},
    "process response - assign" => {'index' => 24, 'title' => "Process response - assign"},
    "process response - edit" => {'index' => 25, 'title' => "Process response - edit"},
    "process response - modify" => {'index' => 26, 'title' => "Process response - modify"},
    "process response - ". FirstReviewName  ."review" => {'index' => 27, 'title' => "Process response - " . &FirstReviewName . " review"},
    "process response - ". SecondReviewName  ."review" => {'index' => 62, 'title' => "Process response - " . &SecondReviewName . " review"},
    "process response - update approved" => {'index' => 28, 'title' => "Process response - update approved response"},
    "process response - write" => {'index' => 29, 'title' => "Process response - write"},
    "process summary.+- data entry" => {'index' => 30, 'title' => "Process summary comment - data entry"},
    "process summary.+- response" => {'index' => 31, 'title' => "Process summary comment - response writer"},
    "process technical review" => {'index' => 32, 'title' => "Process technical review"},
    "proofread comment" => {'index' => 33, 'title' => "Proofread comment"},
    "proofread response version" => {'index' => 34, 'title' => "Proofread response version"},
    "proxy enter" => {'index' => 35, 'title' => "Proxy enter response"},
    "rebin" => {'index' => 36, 'title' => "Rebin comment"},
    "images? reloaded" => {'index' => 37, 'title' => "Reload Document Images"},
    "renumber" => {'index' => 61, 'title' => "Renumber document"},
    "document.+reopened" => {'index' => 38, 'title' => "Reopen document for comment entry"},
    "password.+reset" => {'index' => 39, 'title' => "Reset password"},
    "resummarize" => {'index' => 40, 'title' => "Resummarize"},
    "getting image" => {'index' => 41, 'title' => "Retrieve image for document"},
    "remark" => {'index' => 42, 'title' => "Save remark"},
    "search" => {'index' => 43, 'title' => "Search"},
    "send message" => {'index' => 44, 'title' => "Send message"},
    "set commentsentered" => {'index' => 45, 'title' => "Set comment entry complete"},
    "user preference" => {'index' => 46, 'title' => "Set user preference for bin filter"},
    "modified response" => {'index' => 47, 'title' => "Submit modified response"},
    "original response" => {'index' => 48, 'title' => "Submit original response"},
    "tech edited response" => {'index' => 49, 'title' => "Submit tech edited response"},
    "submit technical review" => {'index' => 50, 'title' => "Submit technical review"},
    "summarize multiple" => {'index' => 51, 'title' => "Summarize multiple comments"},
    "bin.+updated" => {'index' => 52, 'title' => "Update bin"},
    "update comment" => {'index' => 53, 'title' => "Update comment"},
    "commentor.+updated" => {'index' => 54, 'title' => "Update commentor"},
    "document.+updated" => {'index' => 55, 'title' => "Update document"},
    "updated document capture" => {'index' => 56, 'title' => "Update document capture"},
    "update response writer" => {'index' => 57, 'title' => "Update response writer"},
    "update summary comment" => {'index' => 58, 'title' => "Update summary comment"},
    "user.+updated" => {'index' => 59, 'title' => "Update user"},
    "logged" => {'index' => 60, 'title' => "User login"}
       );

tie my %logerr, "Tie::IxHash";
%logerr = (
    "all" => {'index' => 0, 'title' => "All Errors"},
    "browse addressee" => {'index' => 1, 'title' => "Browse addressee"},
    "check if.+duplicate" => {'index' => 2, 'title' => "Check if duplicate or similar"},
    "checking if.+exists" => {'index' => 3, 'title' => "Check for existence"},
    "if image loaded" => {'index' => 4, 'title' => "Check image load"},
    "copy.+for duplicate" => {'index' => 5, 'title' => "Copy comments for duplicate document"},
    "ad hoc selection" => {'index' => 6, 'title' => "Create ad hoc selection page"},
    "final crd report" => {'index' => 7, 'title' => "Create final CRD report"},
    "delete comments" => {'index' => 8, 'title' => "Delete comments"},
    "^display documents?" => {'index' => 9, 'title' => "Display documents for commentor"},
    "entry of approved response" => {'index' => 10, 'title' => "Display entry of approved response"},
    "response information section" => {'index' => 11, 'title' => "Display response information section"},
    "response proofread section" => {'index' => 12, 'title' => "Display response proofread section"},
    "response write section" => {'index' => 13, 'title' => "Display response write section"},
    "user info" => {'index' => 14, 'title' => "Display user information"},
    "draw summary comment page" => {'index' => 15, 'title' => "Draw summary comment page"},
    "ent.+ comment" => {'index' => 16, 'title' => "Enter comment"},
    "adhocreport" => {'index' => 17, 'title' => "Generate ad hoc report"},
    "adhoctest" => {'index' => 18, 'title' => "Generate ad hoc test"},
    "report by bin" => {'index' => 19, 'title' => "Generate report by bin"},
    "report for summary" => {'index' => 20, 'title' => "Generate report for summary comment/response"},
    "adressee list" => {'index' => 21, 'title' => "Get addressee list"},
    "default addressee" => {'index' => 22, 'title' => "Get default addressee"},
    "problem getting scanned" => {'index' => 23, 'title' => "Get scanned image"},
    "display image.+not found" => {'index' => 24, 'title' => "Image not found in database"},
    "insert document data" => {'index' => 25, 'title' => "Insert document data"},
    "loading bracketed" => {'index' => 26, 'title' => "Load bracketed image"},
    "load scanned image" => {'index' => 27, 'title' => "Load scanned image"},
    "bin coordinator assign" => {'index' => 28, 'title' => "Process bin coordinator assignment for response"},
    "- accept" => {'index' => 29, 'title' => "Process response - accept"},
    "- assign" => {'index' => 30, 'title' => "Process response - assign"},
    "- modify" => {'index' => 31, 'title' => "Process response - modify"},
    "- .+review" => {'index' => 32, 'title' => "Process response - " . &FirstReviewName . " review"},
    "- update approved" => {'index' => 33, 'title' => "Process response - update approved response"},
    "- write" => {'index' => 34, 'title' => "Process response - write"},
    "summary comment entry" => {'index' => 35, 'title' => "Process summary comment entry - response writer"},
    "technical review" => {'index' => 36, 'title' => "Process technical review"},
    "proofread comment" => {'index' => 37, 'title' => "Proofread comment"},
    "proofread response version" => {'index' => 38, 'title' => "Proofread response version"},
    "^proxy enter" => {'index' => 39, 'title' => "Proxy enter response"},
    "^read log" => {'index' => 40, 'title' => "Read log data"},
    "renumber" => {'index' => 60, 'title' => "Renumber document"},
    "^save proofread" => {'index' => 41, 'title' => "Save proofread"},
    "remark" => {'index' => 42, 'title' => "Save remarks"},
    "scanned image not found" => {'index' => 43, 'title' => "Scanned image not found"},
    "search" => {'index' => 44, 'title' => "Search"},
    "select commentor" => {'index' => 45, 'title' => "Select commentor"},
    "select.+eis0" => {'index' => 46, 'title' => "Select document"},
    "commentsentered" => {'index' => 47, 'title' => "Set comment entry complete"},
    "setup comments sections" => {'index' => 48, 'title' => "Set up comments sections"},
    "response sections" => {'index' => 49, 'title' => "Set up/configure response sections"},
    "setup report sections" => {'index' => 50, 'title' => "Set up report sections"},
    "setup sections" => {'index' => 51, 'title' => "Set up sections"},
    "test for comment report" => {'index' => 52, 'title' => "Test for comment report"},
    "test for commentor" => {'index' => 53, 'title' => "Test for commentor in database"},
    "update comment " => {'index' => 54, 'title' => "Update comment"},
    "update commentor" => {'index' => 55, 'title' => "Update commentor"},
    "update .+ eis" => {'index' => 56, 'title' => "Update document"},
    "update summary comment" => {'index' => 57, 'title' => "Update summary comment"},
    "write display image" => {'index' => 58, 'title' => "Write display image to server"},
    "activity log" => {'index' => 59, 'title' => "Write to activity log"}
      );


if ($command eq 'view_errors' || $command eq 'view_activity') {
    # generate activity and error log reports ---------------------------------------------------------------------------------------------
    my %userhash;
    my $key;
    eval {
        %userhash = get_lookup_values($dbh, $schema, 'users', "lastname || ', ' || firstname || ';' || id", 'id', "id > 0");
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"get available users.",$@);
        print doAlertBox( text => $message);
    }
    my $logOption = (defined($crdcgi->param("logOption"))) ? $crdcgi->param("logOption") : "today";
    my $logactivity = (defined($crdcgi->param("logactivity"))) ? $crdcgi->param("logactivity") : "all";
    my $selecteduser = (defined($crdcgi->param("selecteduser"))) ? $crdcgi -> param ("selecteduser") : -1;
    my $selectedusername = ($selecteduser == -1) ? "all users" : get_fullname($dbh, $schema, $selecteduser);
    my $userwhere = ($selecteduser == -1) ? "" : "userid = $selecteduser and";
    my $iserror = (($command eq 'view_errors') ? "iserror = 'T' and" : "");
    my $where = "$userwhere $iserror ${$options{$logOption}}{'where'}";
    my $sqlquery = "SELECT userid, TO_CHAR(datelogged,'DD-MON-YY HH24:MI:SS'), description, iserror FROM $schema.activity_log WHERE $where ORDER BY datelogged DESC";
    eval {
        my $csr = $dbh->prepare($sqlquery);
        $csr->execute;
        my $rows = 0;
        my $output .= &start_table(3, 'center', 130, 140, 480);
        my $logtype = ($command eq 'view_errors') ? 'Error' : 'Activity';
        my $selectedactivity = ($command eq 'view_activity') ? ${$logacts{$logactivity}}{'title'} : ${$logerr{$logactivity}}{'title'};
        my $title = "$logtype Log - ${$options{$logOption}}{'title'} for $selectedusername - $selectedactivity (xxx Entries)&nbsp;&nbsp; (<i><font size=2>Most&nbsp;recent&nbsp;at&nbsp;top</font></i>)";
        $output .= &title_row('#cdecff', '#000099', $title);
        $output .= &add_header_row();
        $output .= &add_col() . 'Date/Time';
        $output .= &add_col() . 'User';
        $logtype = "Activity/<font color=#cc0000>Error</font>" if ($logtype eq 'Activity');
        $output .= &add_col() . "$logtype Text";
        while (my @values = $csr->fetchrow_array) {
            my ($user, $date, $text, $err) = @values;
            if ($logactivity eq "all" || matchFound (text => $text, searchString => $logactivity)) {
              if (&does_user_have_priv($dbh, $schema, $userid, -1) || !(matchFound (text=>$text, searchString => 'search'))) {
                $rows++;
                $output .= &add_row();
                $output .= &add_col() . $date;
                $output .= ($user == 0) ? &add_col() . '<b>None</b>' : &add_col_link("javascript:display_user($user)") . &get_fullname($dbh, $schema, $user);
                if ($err eq 'T' && $command eq 'view_activity') {
                    $output .= &add_col() . "<font color=#cc0000>$text</font>";
                }
                else {
                    $output .= &add_col() . $text;
                }
                last if ((($rows >= 10) and ($logOption eq "last10")) ||(($rows >= 100) and ($logOption eq "last100")) || (($rows >= 1000) and ($logOption eq "last1000")));
              }
            }
       }
       $csr->finish;
       $output .= &end_table();
       if ((($rows >= 10) and ($logOption eq "last10")) ||(($rows >= 100) and ($logOption eq "last100")) || (($rows >= 1000) and ($logOption eq "last1000")) || (($rows >= 10) and ($logOption eq "last10"))) {
           $output =~ s/ \(xxx Entries\)//;
       }
       else {
           $output =~ s/xxx/$rows/;
       }
       print "<table width=700 cellpadding=0 calspacing=0 align=center>\n";
       print "<tr><td><b>View: </b></td><td><b>User: </b></td>\n";
       my $whichone = ($command eq 'view_activity') ? "Activity:" : "Error:";
       print "<td><b>$whichone</b></td>\n";
       print "<td>&nbsp;</td></tr>";
       print "<tr><td><select name=logOption size=1>\n";
       foreach my $option (keys (%options)) {
           print "<option value=\"$option\">${$options{$option}}{'title'}\n";
       }
       print "</select></td>\n";
       print "<td><select name=selecteduser>\n";
       print "<option value=-1 selected>All Users\n";
       foreach $key (sort keys %userhash) {
           my $usernamestring = $key;
           $usernamestring =~ s/;$userhash{$key}//g;
           if ($userhash{$key} == $selecteduser){
               print "<option value=\"$userhash{$key}\" selected>$usernamestring\n";
           }
           else {
               print "<option value=\"$userhash{$key}\">$usernamestring\n";
           }
       }
       print "</select></td>\n";
       if ($command eq 'view_activity') {
           print "<td><select name=logactivity>";
           foreach my $acts (keys (%logacts)) {
             if (&does_user_have_priv($dbh, $schema, $userid, -1) || $acts ne 'search') {
               my $selected = ($logactivity eq $acts) ? " selected" : "";
               print "<option value=\"$acts\"$selected>${$logacts{$acts}}{'title'}\n";
             }
           }
           print "</select></td>";
       }
       else {
           print "<td><select name=logactivity>";
           foreach my $acts (keys (%logerr)) {
               my $selected = ($logactivity eq $acts) ? " selected" : "";
               print "<option value=\"$acts\"$selected>${$logerr{$acts}}{'title'}\n";
           }
           print "</select></td>";
       }
       print "<td align=center><input type=button name=displaylog value=Display onClick=document.$form.submit()></td></tr></table><br>";
       print $output;
       print "<script language=javascript><!--\ndocument.$form.logOption.selectedIndex = ${$options{$logOption}}{'index'};\n//--></script>\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"read log data",$@);
        print doAlertBox( text => $message);
    }
}
elsif ($command eq 'find_duplicate_comments') {
    &findDuplicateComments();
}
elsif ($command eq 'find_duplicate_comments_m') {
    print &drawFindDuplicateCommentsInterface();
}
elsif ($command eq 'find_duplicate_comments_display') {
    print &drawFindDuplicateCommentsInterface();
    print &drawFindDuplicateCommentsDisplay();
}
elsif ($command eq 'print_duplicate_comments_report') {
    print &buildDuplicateCommentsReport();
}
elsif ($command eq 'reload_all_images' || $command eq 'reload_range_images') {
    # reload all images -----------------------------------------------------------------------------
    my $sqlquery;
    my $csr;
    my @values;
    my $status;
    $message = '';
    my $count=0;
    my $scanCount=0;
    my $skippedCount=0;
    my $errorCount=0;
    my $toLargeCount=0;
    my $nullCount=0;
    eval {
        my $extraWhereInfo ='';
        my ($startID, $endID);
        if ($command eq 'reload_range_images') {
            $startID = ((defined($crdcgi->param('documentidstart'))) ? $crdcgi->param('documentidstart') : "0");
            $endID = ((defined($crdcgi->param('documentidend'))) ? $crdcgi->param('documentidend') : "0");
            $extraWhereInfo = "AND id >= $startID AND id <= $endID";
        }
        $sqlquery = "SELECT id FROM $schema.document WHERE image IS NOT NULL $extraWhereInfo ORDER BY id";
print "\n\n<!-- $sqlquery -->\n\n";
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        print "\n";
        $| = 1;
        while (@values = $csr->fetchrow_array) {
            my $dbh2 = db_connect();
            my $source = 'Bracketed';
            $status = reloadImage(dbh => $dbh2, schema => $schema, userid => $userid, document => $values[0]);
            &db_disconnect($dbh2);
            if ($status != 1 && $status != 2 && $status != 3) {
                $status = reloadImage(dbh => $dbh, schema => $schema, userid => $userid, document => $values[0], imageType => 'Scanned');
                if ($status != 1 && $status != 2) {
                    $message .= "Error loading image for $CRDType" . lpadzero($values[0],6) . "\\n";
                    $source = 'Error';
                    $errorCount++;
                } elsif ($status == 1) {
                    $source = 'Scanned';
                    $scanCount++;
                } elsif ($status == 2) {
                    $source = 'Scanned - not changed';
                    $skippedCount++;
                } elsif ($status == 3) {
                    $source = 'Scanned - to large';
                    $toLargeCount++;
                }
            } elsif ($status == 1) {
                $count++;
            } elsif ($status == 2) {
                $source = 'Bracketed - not changed';
                $skippedCount++;
            } elsif ($status == 3) {
                $source = 'Bracketed - to large';
                $toLargeCount++;
            }
            print "$CRDType" . lpadzero($values[0],6) . " - $source\n";
            print "<script language=javascript><!--\n";
            print "   parent.main.$form.bracketed.value=$count;\n";
            print "   parent.main.$form.scanned.value=$scanCount;\n";
            print "   parent.main.$form.tolargecount.value=$toLargeCount;\n";
            print "   parent.main.$form.skippedcount.value=$skippedCount;\n";
            print "   parent.main.$form.errors.value=$errorCount;\n";
            if ($source eq 'Bracketed') {
                print "   append_option(parent.main.$form.changedbracketed, 0, '$CRDType" . lpadzero($values[0],6) . "');\n";
            } elsif ($source eq 'Scanned') {
                print "   append_option(parent.main.$form.changedscanned, 0, '$CRDType" . lpadzero($values[0],6) . "');\n";
            } elsif ($status == 2) {
                print "   append_option(parent.main.$form.skipped, 0, '$CRDType" . lpadzero($values[0],6) . "');\n";
            } elsif ($status == 3) {
                print "   append_option(parent.main.$form.tolarge, 0, '$CRDType" . lpadzero($values[0],6) . "');\n";
            } else {
                print "   append_option(parent.main.$form.loaderror, 0, '$CRDType" . lpadzero($values[0],6) . "');\n";
            }
            print "   parent.main.$form.status.value = 'Testing $CRDType" . lpadzero($values[0],6) . "';\n";
            print "//--></script>\n";
        }
        $csr->finish;
        $sqlquery = "SELECT id FROM $schema.document WHERE image IS NULL $extraWhereInfo ORDER BY id";
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        while (@values = $csr->fetchrow_array) {
            $nullCount++;
            print "$CRDType" . lpadzero($values[0],6) . " - NULL Image\n";
            print "<script language=javascript><!--\n";
            print "   parent.main.$form.status.value = 'No Load $CRDType" . lpadzero($values[0],6) . "';\n";
            print "   parent.main.$form.nullcount.value=$nullCount;\n";
            print "   append_option(parent.main.$form.nullimage, 0, '$CRDType" . lpadzero($values[0],6) . "');\n";
            print "//--></script>\n";
        }
        $csr->finish;

        my $reloadType = '';
        if ($command eq 'reload_all_images') {
            $reloadType = "(All Images)"
        } else {
            $reloadType = "($CRDType" . lpadzero($startID,6) . " through $CRDType" . lpadzero($endID,6) . ")";
        }

        $message = ($count + $scanCount) . " Image" . (($count != 1) ? "s have" : " has") . " been Reloaded $reloadType.\\n" . $message;
        log_activity ($dbh,$schema,$userid,($count + $scanCount) . " Bracketed Image" . (($count != 1) ? "s" : "") . " Reloaded $reloadType");
        print "<script language=javascript><!--\n";
        print "   parent.main.$form.status.value = 'Finished';\n";
        print "   parent.main.timerRunning = false;\n";
        print "   alert('$message');\n";
        print "   //submitFormMain('utilities', '');\n";
        print "//--></script>\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"reload all bracketed images - last documentprocessed was $CRDType" . lpadzero($values[0],6) ,$@);
        print "<script language=javascript><!--\n";
        print "   parent.main.$form.status.value = 'Error';\n";
        print "   parent.main.timerRunning = false;\n";
        print doAlertBox( text => $message, includeScriptTags => 'F');
        print "   //submitFormMain('utilities', '');\n";
        print "//--></script>\n";
    }

} elsif ($command eq 'reload_all_images_page' || $command eq 'reload_range_images_page') {
    # reload all images -----------------------------------------------------------------------------
    print "<center><table border=0>\n";
    print "<tr><td align=center>Elapsed Time:</td><td>" . nbspaces(20) . "</td><td align=center>Status:</td></tr>\n";
    print "<tr><td align=center><input type=text size=8 name=clock readonly onClick=\"this.blur();\"></center></td><td> </td>\n";
    print "<td align=center><input type=text size=18 name=status readonly value='Working' onClick=\"this.blur();\"></td></tr>\n";
    print "</table>\n";
    my ($startID,$endID);
    if ($command eq 'reload_range_images_page') {
        $startID = ((defined($crdcgi->param('documentidstart'))) ? $crdcgi->param('documentidstart') : "0");
        $endID = ((defined($crdcgi->param('documentidend'))) ? $crdcgi->param('documentidend') : "0");
        print "<input type=hidden name=documentidstart value=$startID>\n";
        print "<input type=hidden name=documentidend value=$endID>\n";
        print "Reloading images $CRDType" . lpadzero($startID,6) . " through $CRDType" . lpadzero($endID,6) . "\n";
    }
    print "<br><hr width=75%><br>\n";
    print "<table border=0>\n";

    print "<tr><td align=center valign=bottom>Bracketed</td><td>" . nbspaces(3) . "</td><td align=center valign=bottom>Scanned</td><td>" . nbspaces(3) . "</td><td align=center valign=bottom>Unchanged</td><td>" . nbspaces(3) . "</td>\n";
    print "<td align=center valign=bottom>Not Yet<br>Loaded</td><td>" . nbspaces(3) . "</td><td align=center valign=bottom>Skipped<br>(> 10MB)</td><td>" . nbspaces(3) . "</td><td align=center valign=bottom>Not Found</td></tr>\n";
    print "<tr><td align=center><input type=text size=8 name=bracketed readonly value=0 onClick=\"this.blur();\"></td><td> </td>\n";
    print "<td align=center><input type=text size=8 name=scanned readonly value=0 onClick=\"this.blur();\"></td><td> </td>\n";
    print "<td align=center><input type=text size=8 name=skippedcount readonly value=0 onClick=\"this.blur();\"></td><td> </td>\n";
    print "<td align=center><input type=text size=8 name=nullcount readonly value=0 onClick=\"this.blur();\"></td><td> </td>\n";
    print "<td align=center><input type=text size=8 name=tolargecount readonly value=0 onClick=\"this.blur();\"></td><td> </td>\n";
    print "<td align=center><input type=text size=8 name=errors readonly value=0 onClick=\"this.blur();\"></td></tr>\n";
    print "<tr><td align=center><select size=1 name=changedbracketed>\n<option value=0>" . nbspaces(25) . "</option>\n</select></td>\n";
    print "<td> </td><td align=center><select size=1 name=changedscanned>\n<option value=0>" . nbspaces(25) . "</option>\n</select></td>\n";
    print "<td> </td><td align=center><select size=1 name=skipped>\n<option value=0>" . nbspaces(25) . "</option>\n</select></td>\n";
    print "<td> </td><td align=center><select size=1 name=nullimage>\n<option value=0>" . nbspaces(25) . "</option>\n</select></td>\n";
    print "<td> </td><td align=center><select size=1 name=tolarge>\n<option value=0>" . nbspaces(25) . "</option>\n</select></td>\n";
    print "<td> </td><td align=center><select size=1 name=loaderror>\n<option value=0>" . nbspaces(25) . "</option>\n</select></td><tr>\n";

    print "</table>\n";
    print "</center>\n";
    print "<script language=javascript><!--\n";
    print "\n";
    print "        var seconds = 0;\n";
    print "        var minutes = 0;\n";
    print "        var hours = 0;\n";
    print "        var timerID;\n";
    print "        var timerRunning = true;\n";
    print "        \n";
    print "        function displayTime() {\n";
    print "            var temp;\n";
    print "            if (seconds >= 59) {\n";
    print "                seconds = 0;\n";
    print "                if (minutes >= 59) {\n";
    print "                    minutes = 0;\n";
    print "                    hours++;\n";
    print "                } else {\n";
    print "                    minutes++;\n";
    print "                }\n";
    print "            } else {\n";
    print "                seconds++;\n";
    print "            }\n";
    print "            if (seconds < 10) {var ss = '0'} else {var ss = ''}\n";
    print "            if (minutes < 10) {var ms = '0'} else {var ms = ''}\n";
    print "            if (hours < 10) {var hs = '0'} else {var hs = ''}\n";
    print "            temp = hs + hours + ':' + ms + minutes + ':' + ss + seconds;\n";
    print "            document.$form.clock.value = temp;\n";
    print "            if (timerRunning) {\n";
    print "                timerID = setTimeout(\"displayTime()\", 1000);\n";
    print "            }\n";
    print "        }\n";
    print "\n";
    print "        displayTime();\n";
    print "\n";
    if ($command eq 'reload_all_images_page') {
        print "   submitFormCGIResults('utilities','reload_all_images');\n";
    } else {
        print "   submitFormCGIResults('utilities','reload_range_images');\n";
    }
    print "//--></script>\n";

} elsif ($command eq 'reset_commentsentered' || $command eq 'reload_image') {
    # Reset commentssentered field or reload images -----------------------------------------------------------------------------
    eval {
        my $document = ((defined($crdcgi->param('documentid'))) ? $crdcgi->param('documentid') : '');
        my $id = ((defined($crdcgi->param('id'))) ? $crdcgi->param('id') : -1);

        if ($document eq '' || !($document =~ /\S/)) {
            $document = '';
        } elsif ($document gt '' && $document =~ /\D/) {
            print "<script language=javascript><!--\n";
            print "   alert('Only positive numbers may be entered.');\n";
            print "//--></script>\n";
            $document = '';
        } elsif ($document gt '' && $document > 0) {
            my $sqlcode = '';
            my $csr;
            my @values;
            my $status;

            print "\n\n<!-- $command - Document ID $document -->\n\n";

            $sqlcode = "SELECT count(*) FROM $schema.document WHERE id = $document";
            @values = $dbh->selectrow_array($sqlcode);
            if ($values[0] > 0) {
                $sqlcode = "SELECT id,dupsimstatus,commentsentered,dupsimid FROM $schema.document WHERE id = $document";
                @values = $dbh->selectrow_array($sqlcode);
                if ($command eq 'reset_commentsentered') {
                    if ($values[1] != 1) {
                        print "<script language=javascript><!--\n";
                        print "   alert('Can not change Document $CRDType" . lpadzero($document,6) . ", it is not an original document.');\n";
                        print "//--></script>\n";

                    } elsif ($values[2] eq 'T') {
                        if ($command eq 'reset_commentsentered') {
                            $sqlcode = "SELECT count(*) FROM $schema.document WHERE dupsimstatus = 3 AND dupsimid = $document";
                            @values = $dbh->selectrow_array($sqlcode);
                        } else {
                            $values[0] = 0;
                        }
                        if ($values[0] >= 1) {
                            print "<script language=javascript><!--\n";
                            print "   alert('Can not change Document $CRDType" . lpadzero($document,6) . ", it has dependent similar documents.');\n";
                            print "//--></script>\n";
                        } else {
                            $sqlcode = "UPDATE $schema.document SET commentsentered = 'F' WHERE id = $document";
                            $csr = $dbh->prepare($sqlcode);
                            $status = $csr->execute;
                            $dbh->commit;
                            $csr->finish;

                            log_activity ($dbh,$schema,$userid,"Document $CRDType" . lpadzero($document,6) . " reopened for comment entry");
                            print "<script language=javascript><!--\n";
                            print "   alert('Document $CRDType" . lpadzero($document,6) . " is now open for Comment Entry.');\n";
                            print "   javascript:submitFormMain('utilities','reset_commentsentered');\n";
                            print "//--></script>\n";
                        }

                    } else {
                        print "<script language=javascript><!--\n";
                        print "   alert('Document $CRDType" . lpadzero($document,6) . " is still open for Comment Entry.');\n";
                        print "//--></script>\n";
                    }
                } elsif ($command eq 'reload_image') {
# commented out to allow reloading of duplicate images.
#                    if ($values[1] != 1) {
                    if (1 != 1) {
                        print "<script language=javascript><!--\n";
                        print "   alert('Can not reload image for Document $CRDType" . lpadzero($document,6) . ", it is not an original document.');\n";
                        print "//--></script>\n";

                    } else {

                        $status = reloadImage(dbh => $dbh, schema => $schema, userid => $userid, document => $document, processType => 'Manual');
                        if ($status ==1) {
                            log_activity ($dbh,$schema,$userid,"Image reloaded for $CRDType" . lpadzero($document,6));
                            print "<script language=javascript><!--\n";
                            print "   alert('New image for $CRDType" . lpadzero($document,6) . " loaded.');\n";
                            print "   parent.main.$form.documentid.value='';\n";
                            print "//--></script>\n";
                        } elsif ($status == 2) {
                            print "<script language=javascript><!--\n";
                            print "   alert('New image for $CRDType" . lpadzero($document,6) . " identical to image in database.');\n";
                            print "   parent.main.$form.documentid.value='';\n";
                            print "//--></script>\n";
                        } else {
                            $message = "Error, Problem loading Bracketed image for $CRDType" . lpadzero($document,6) . ", Status = $status.";
                            log_error ($dbh,$schema,$userid,$message);
                            print "<script language=javascript><!--\n";
                            print "   alert('$message');\n";
                            print "   parent.main.$form.documentid.value='';\n";
                            print "//--></script>\n";
                        }


                    }
                }
            } else {
                print "<script language=javascript><!--\n";
                print "   alert('Document $CRDType" . lpadzero($document,6) . " not in database.');\n";
                print "//--></script>\n";
            }
        }
        if ($document eq '' || $id == 0) {
            if ($command eq 'reset_commentsentered') {
                print "<b>$CRDType</b><input type=text size=6 maxlength=6 name=documentid>&nbsp;&nbsp;\n";
            }
            print "<script language=javascript><!--\n";
            print "   function validateDocumentID (id) {\n";
            print "       var msg = '';\n";
            print "       if (isblank(id.value)) {\n";
            print "           msg += 'ID number must be input\\n';\n";
            print "       } else if (!(isnumeric(id.value))) {\n";
            print "           msg += 'Only positive numbers may be entered\\n';\n";
            print "       }\n";
            print "       if (msg == '') {\n";
            if ($command eq 'reset_commentsentered') {
                print "           javascript:submitFormCGIResults('utilities','reset_commentsentered');\n";
            } else {
                print "           javascript:submitFormCGIResults('utilities','reload_image');\n";
            }
            print "       } else {\n";
            print "           alert (msg);\n";
            print "       }\n";
            print "   }\n";
            print "   function validateDocumentIDRange (idstart, idend) {\n";
            print "       var msg = '';\n";
            print "       if (isblank(idstart.value) || isblank(idend.value)) {\n";
            print "           msg += 'ID numbers must be input\\n';\n";
            print "       } else if (!(isnumeric(idstart.value)) || !(isnumeric(idend.value))) {\n";
            print "           msg += 'Only positive numbers may be entered\\n';\n";
            print "       } else if ((idstart.value - 0) > (idend.value - 0)) {\n";
            print "           msg += 'End ID must be greater than or equal to start ID\\n';\n";
            print "       }\n";
            print "       if (msg == '') {\n";
            print "           javascript:submitForm('utilities','reload_range_images_page');\n";
            print "       } else {\n";
            print "           alert (msg);\n";
            print "       }\n";
            print "   }\n";
            print "//--></script>\n";
            if ($command eq 'reset_commentsentered') {
                print "<input type=button name=doc_reset value=Submit onClick=\"javascript:validateDocumentID(document.$form.documentid);\">\n";
            }

            if ($command eq 'reload_image') {
                # reload one image -----------------------------------------------------------------------------
                print "<table border=0>\n";
                print "<tr><td><input type=radio name=reloadradio value=one checked onClick=\"enableReload();\"> &nbsp; </td><td><b>Reload $CRDType<input type=text size=6 maxlength=6 name=documentid></b></td></tr>\n";
                print "<tr><td colspan=2> &nbsp; </td></tr>\n";
                print "<tr><td><input type=radio name=reloadradio value=range onClick=\"enableReload();\"> &nbsp; </td>";
                print "<td><b>Reload From $CRDType<input type=text size=6 maxlength=6 name=documentidstart> to $CRDType<input type=text size=6 maxlength=6 name=documentidend></b></td></tr>\n";
                print "<tr><td colspan=2> &nbsp; </td></tr>\n";
                # reload all images -----------------------------------------------------------------------------
                print "<tr><td><input type=radio name=reloadradio value=all onClick=\"enableReload();\"> &nbsp; </td><td><b>Reload All Images (Takes 30 - 60 minutes)</b></td></tr>\n";
                print "</table>\n";
                print "<br><input type=button name=reloadimagesbutton value='Submit' onClick=\"processImageReload();\">\n";
                print "<script language=javascript><!--\n";
                print "    function processImageReload () {\n";
                print "        if (document.$form.reloadradio[0].checked) {\n";
                print "            validateDocumentID(document.$form.documentid);\n";
                print "        } else if (document.$form.reloadradio[1].checked) {\n";
                print "            validateDocumentIDRange(document.$form.documentidstart,document.$form.documentidend);\n";
                print "        } else {\n";
                print "            submitForm('utilities','reload_all_images_page');\n";
                print "        }\n";
                print "    }\n";
                print "    function enableReload () {\n";
                print "        var enabled = eval(!document.$form.reloadradio[0].checked);\n";
                print "        document.$form.documentid.disabled = (enabled);\n";
                print "        var enabled = eval(!document.$form.reloadradio[1].checked);\n";
                print "        document.$form.documentidstart.disabled = (enabled);\n";
                print "        document.$form.documentidend.disabled = (enabled);\n";
                print "    }\n";
                print "    enableReload();\n";
                print "//--></script>\n";
                #print "<input type=button name=reloadimagesbutton value='Reload All Bracketed Images' onClick=\"submitForm('utilities','reload_all_images_page');\"></center>\n";

            }

            print "<script language=javascript><!--\ndocument.$form.action = '';\ndocument.$form.documentid.focus();\n//--></script>\n";
        }
    };
    if ($@) {
        if ($command eq 'reset_commentsentered') {
            $message = errorMessage($dbh,$username,$userid,$schema,"reset comments entered flag.",$@);
        } else {
            $message = errorMessage($dbh,$username,$userid,$schema,"reload CRD image.",$@);
        }
        print doAlertBox( text => $message);
    }
}
else {
    # display utilities menu -----------------------------------------------------------------------------
    print "<table width=100% align=center><tr><td>\n";
    eval {
        print "<table border=0 cellspacing=0 cellpadding=0 align=center>\n";
        print "<tr><td valign=top width=250>\n";
        print "<font size=3><b>General Utilities</b>\n";
        print "<li><a href=javascript:submitForm('user_functions','changepasswordform')>Change&nbsp;Password</a>\n";
        if (&does_user_have_priv($dbh, $schema, $userid, 10)) {
            print "<li><b>View&nbsp;Logs:</b>&nbsp;&nbsp;<a href=javascript:submitForm('utilities','view_activity')>Activity</a>&nbsp;&nbsp;<a href=javascript:submitForm('utilities','view_errors')>Error</a>\n";
        }
        my ($sccb) = $dbh -> selectrow_array ("select sccbid from $schema.sccbuser where userid=$userid");
        if ($sccb) {
            print "<li><b>Software Change Request:</b><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href=javascript:submitForm('scrhome','write_request')>Submit</a>\n";
####  <a href=$SCMPath/scrhome.pl?command=write_request&userid=$sccb&schema=SCM&origschema=$schema>Submit</a>&nbsp;\n";
####  print "<a href=$SCMPath/scrbrowse.pl?userid=$sccb&schema=SCM>Browse</a>\n";
            print "<a href=javascript:submitForm('scrbrowse','')>Browse</a>\n";
        }
        if (&does_user_have_priv($dbh, $schema, $userid, -1)) {
            print "<li><a href=javascript:submitForm('user_functions','becomeusernameform')>Become Another User</a>\n";
        }
        print "</font>\n</td>";
        if (&does_user_have_priv($dbh, $schema, $userid, 10)) {
            print "<td valign=top width=250>\n<font size=3><b>Bins and Users</b><br>\n";
            print "<li><b>Bins:&nbsp;&nbsp;</b><a href=javascript:submitForm('bins','addbinform')>Add</a>&nbsp;&nbsp;<a href=javascript:submitForm('bins','update')>Update</a>\n";
            print "<li><b>Users:</b>&nbsp;&nbsp;<a href=javascript:submitForm('user_functions','adduserform')>Add</a>&nbsp;&nbsp;<a href=javascript:submitForm('user_functions','updateuserform')>Update</a>\n";
            print "<li><b>CRD&nbsp;Sections:</b>&nbsp;&nbsp;<a href=javascript:submitForm('crd_sections','add')>Add</a>&nbsp;&nbsp;<a href=javascript:submitForm('crd_sections','update')>Update</a>\n";
            print "</font></td>\n";
        }
        if (&does_user_have_priv($dbh, $schema, $userid, 4) || &does_user_have_priv($dbh, $schema, $userid, 6) || &does_user_have_priv($dbh, $schema, $userid, 8) || &does_user_have_priv($dbh, $schema, $userid, 10)) {
            print "<td valign=top width=250><font size=3><b>Summary Comments/Responses</b>";
            print "<li><a href=javascript:submitForm('summary_comments','update')>Update</a>\n";
            print "</td>";
        }
        print "</tr>\n<tr><td colspan=3>&nbsp;</td></tr>\n<tr>\n";
        if (&does_user_have_priv($dbh, $schema, $userid, 10)) {
            print "<td valign=top width=250>\n<font size=3><b>Comment Documents</b>\n";
            print "<li><a href=javascript:submitForm('comment_documents','update')>Update Document</a>\n";
            print "<li><a href=javascript:submitForm('commentors','update')>Update Commentor</a>\n";
            print "<li><a href=javascript:submitForm('utilities','reset_commentsentered')>Reopen&nbsp;for&nbsp;Comment&nbsp;Entry</a>\n";
            print "<li><a href=javascript:submitForm('utilities','reload_image')>Reload Images</a>\n";
            print "<li><a href=javascript:submitForm('renumber_document','renumber_document')>Renumber Document</a>\n";
            print "<li><b>Addressee:</b>&nbsp;&nbsp;<a href=javascript:submitForm('addressee','add')>Add</a>&nbsp;&nbsp;<a href=javascript:submitForm('addressee','update')>Update</a>\n";
            print "</font></td>\n";
}
        if (&does_user_have_priv($dbh, $schema, $userid, 6) || &does_user_have_priv($dbh, $schema, $userid, 8) || &does_user_have_priv($dbh, $schema, $userid, 10)) {
            print "<td valign=top width=250><font size=3><b>Comments</b><br>\n";
            if (&does_user_have_priv($dbh, $schema, $userid, 10)) {
                print "<li><a href=javascript:submitForm('comments','update')>Update</a>\n";
                print "<li><a href=javascript:submitForm('comments','markduplicate')>Mark as Duplicate</a>\n";
            }
            print "<li><a href=javascript:submitForm('comments','rebin')>Rebin/Resummarize</a>\n";
            if (&does_user_have_priv($dbh, $schema, $userid, 10)) {
                print "<li><a href=javascript:submitForm('utilities','find_duplicate_comments_m')>Find Duplicates</a>\n";
            }
            print "</td>";
        }
        if (&does_user_have_priv($dbh, $schema, $userid, 6) || &does_user_have_priv($dbh, $schema, $userid, 10)) {
            print "<td valign=top width=250><font size=3><b>Responses</b>";
            print "<li><b>Update&nbsp;Status:</b>&nbsp;&nbsp;ID&nbsp;Entry&nbsp;&nbsp;<a href=javascript:submitForm('responses','update_status')>Table&nbsp;Select</a>\n";
            if (&does_user_have_priv($dbh, $schema, $userid, 10)) {
                print "<li><b>Update&nbsp;Approved:</b>&nbsp;&nbsp;<a href=javascript:submitForm('responses','select_update_approved_enter_ID')>ID&nbsp;Entry</a>&nbsp;&nbsp;<a href=javascript:submitForm('responses','select_update_approved_table')>Table&nbsp;Select</a>\n";
                print "<li><a href=javascript:submitForm('responses','update_response_writer_enter_ID')>Update Writer</a>\n";
                print "<li><a href=javascript:submitForm('responses','do_workflow_step_enter_ID')>Do Workflow Step</a>\n";
            }
            print "</font>\n</td>";
        }
        print "</tr>\n</table>\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"test user privileges",$@);
        print doAlertBox( text => $message);
    }
    print "</td></tr></table>\n";
}
print "</center>\n</form>\n</td></tr></table></center>\n</font>\n";
print $crdcgi->end_html;
&db_disconnect($dbh);
exit();

