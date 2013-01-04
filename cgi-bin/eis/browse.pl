#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/crd/perl/RCS/browse.pl,v $
#
# $Revision: 1.24 $
#
# $Date: 2002/02/20 16:35:10 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: browse.pl,v $
# Revision 1.24  2002/02/20 16:35:10  atchleyb
# removed depricated function use named parameters and changed the html header
#
# Revision 1.23  2001/11/06 21:47:07  atchleyb
# fixed am pm problem with 12 in browse CRD
#
# Revision 1.22  2001/11/02 22:39:39  atchleyb
# changed alert box code to handle single quotes
#
# Revision 1.21  2001/07/27 19:29:44  mccartym
# fix javascript error in which wrong command was passed after back button was pressed
#
# Revision 1.20  2001/06/28 18:27:57  mccartym
# remove preapproved responses, message points from initial baseline version
#
# Revision 1.19  2001/06/21 20:25:25  atchleyb
# removed doFinalCRD from browse CRD
#
# Revision 1.18  2001/05/24 22:41:01  atchleyb
# changed command comment_response_document to browse_comment_response_document
#
# Revision 1.17  2001/05/09 21:47:45  atchleyb
# changed browse CRD display to have all runs together with a discription
#
# Revision 1.16  2001/05/08 21:53:25  atchleyb
# added code in browse CRD to check dir for a title file to append to name for more information
#
# Revision 1.15  2001/05/07 19:57:48  mccartym
# removed 'browse addressee', added conditional display of Final CRD (if it exists, display it)
#
# Revision 1.14  2001/03/30 17:44:00  atchleyb
# changed text for browse addressee to addressee
#
# Revision 1.13  2001/03/29 15:55:10  atchleyb
# added browse addressee
#
# Revision 1.12  2001/02/15 17:49:22  atchleyb
# changed label for SCR CRD column
#
# Revision 1.11  2001/02/14 19:01:13  atchleyb
# modified to have crd intermediate pages combined into one
#
# Revision 1.10  2001/02/14 01:55:29  atchleyb
# added connection to db
#
# Revision 1.9  2001/02/14 01:05:10  atchleyb
# added code to generate a list of folders in the CRD run areas for users to select from
#
# Revision 1.8  2001/02/12 18:49:37  atchleyb
# updated the way the final crd is browsed, there is now an intermediate page that lists different report runs
#
# Revision 1.7  2001/02/02 19:42:22  atchleyb
# The SCR option has been added to the browse crd section
#
# Revision 1.6  2001/01/11 17:04:15  atchleyb
# updated the way the crd is browsed
#
# Revision 1.5  2001/01/11 01:41:38  atchleyb
# updated text on final crd links
#
# Revision 1.4  2001/01/11 01:31:58  mccartym
# add final crd links
#
# Revision 1.3  2000/05/31 16:12:02  mccartym
# change command for bin browse
#
# Revision 1.2  1999/11/04 16:27:58  mccartym
# title changes
#
# Revision 1.1  1999/08/02 03:04:19  mccartym
# Initial revision
#
#

use integer;
use strict;
use CRD_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DocumentSpecific qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use CGI qw(param);

my $crdcgi = new CGI;
my $userid = $crdcgi->param("userid");
my $username = $crdcgi->param("username");
my $schema = $crdcgi->param("schema");
my $dbh = db_connect();
&checkLogin ($username, $userid, $schema);
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $command = defined($crdcgi->param("command")) ? $crdcgi->param("command") : "browse";
my $crdreporttype = defined($crdcgi->param("crdreporttype")) ? $crdcgi->param("crdreporttype") : "";
my $crdreportpath = defined($crdcgi->param("crdreportpath")) ? $crdcgi->param("crdreportpath") : "";
my $crdfullreportpath = defined($crdcgi->param("crdfullreportpath")) ? $crdcgi->param("crdfullreportpath") : "";


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


print $crdcgi->header('text/html');

print <<end;
<html>
<head>
   <meta http-equiv=expires content=now>
   <script src=$CRDJavaScriptPath/utilities.js></script>
   <script language=javascript><!--
      function doBrowse(script) {
         if (script == 'bins') {
            $form.command.value = 'browseTable';
         } else if (script == 'browse') {
            $form.command.value = 'browse_comment_response_document';
         } else {
            $form.command.value = 'browse';
         }
         $form.action = '$path' + script + '.pl';
         $form.submit();
      }
      //-->
   </script>
</head>
end

print "<body background=$CRDImagePath/background.gif text=$CRDFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n";
print "<font face=$CRDFontFace color=$CRDFontColor>\n";
print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => $command);
print "<form name=$form method=post>\n";
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=command value=$command>\n";
print "<input type=hidden name=crdreporttype value=$crdreporttype>\n";
print "<input type=hidden name=crdreportpath value=$crdreportpath>\n";
print "<input type=hidden name=crdfullreportpath value=$crdfullreportpath>\n";
print "</form>\n";
print "<table border=0>\n";
if ($command eq 'browse_comment_response_document') {
    eval {
        my %CRDReportHash;
        #print "<tr><td align=center colspan=3><font size=4>CRD Report Runs</font></td></tr>\n";
        print "<tr>\n";
        foreach $crdreporttype ('all','approved','scr') {
            $crdfullreportpath = "$CRDFullReportPath/final_crd/$crdreporttype";
            $crdreportpath = "$CRDReportPath/final_crd/$crdreporttype";
            my $crdTypeTitle = '';
            if ($crdreporttype eq 'all') {
                $crdTypeTitle = "All Comments & Responses";
            } elsif ($crdreporttype eq 'approved') {
                $crdTypeTitle = "Approved Comments & Responses";
            } elsif ($crdreporttype eq 'scr') {
                $crdTypeTitle = "Summary Comments & Responses";
            }
            opendir DIR1, "$crdfullreportpath";
            my @allfiles = readdir DIR1;
            my @sortedfiles = (sort @allfiles);
            for (my $i=0; $i<=$#allfiles; $i++) {
                my $filename = $allfiles[$i];
                if ($filename ne "index.htm" && substr($filename,0,1) ne ".") {
                    $CRDReportHash{$filename}{path} = $crdreportpath;
                    $CRDReportHash{$filename}{fullpath} = $crdfullreportpath;
                    $CRDReportHash{$filename}{title} = $crdTypeTitle;
                }
            }
        }
        my @sortedfiles = (sort keys %CRDReportHash);
        print "<td align=center valign=top>\n";
        print "<table border=1 cellpadding=4 cellspacing=0 align=center width =100%>\n";
        #print "<tr><td align=center><font size=4>$crdTypeTitle</font></td></tr>\n";
        #print "<tr><td><font size=4><br><ul>\n";
        print "<tr bgcolor=#f0f0f0><td align=center><font size=4>Run Date and Time</font></td><td align=center><font size=4>Contents</font></td></tr>\n";
        for (my $i=$#sortedfiles; $i>=0; $i--) {
            my $filename = $sortedfiles[$i];
            my $ampm = "AM";
            my $hour = (substr($filename,11,2)) + 1 - 1;
            if ($hour > 12) {
                $ampm = "PM";
                $hour = lpadzero(($hour-12),2);
            } elsif ($hour == 12) {
                $ampm = "PM";
            }
            print "<tr bgcolor=#ffffff><td><font size=3><a href=$CRDReportHash{$filename}{path}/$filename/toc.htm>" . uc(get_date(substr($filename,5,2) . "/" . substr($filename,8,2) . "/" . substr($filename,0,4))) . " " . $hour . ":" . substr($filename,14,2) . ":" . substr($filename,17,2) . " $ampm</a>";
            print "</font></td><td><font size=3>";
            if (open (FH0, "$CRDReportHash{$filename}{fullpath}/$filename/title.htm")) {
                print <FH0>;
                close (FH0);
            } else {
                print "$CRDReportHash{$filename}{title}";
            }
            print "</font></td></tr>\n";
            #print "</li>\n";
        }
        #print "</ul></font></td></tr>\n";
        print "</table></td>\n";


    };
    if ($@) {
       my $message = errorMessage($dbh,$username,$userid,$schema,"generate list of CRD runs.",$@);
       print doAlertBox( text => $message);
    }
    print "</tr>\n";
    print "</table>\n";
} else {
   print "<tr><td><font size=4><br><ul>\n";
   print "<li><a href=javascript:doBrowse('comment_documents')>Comment Documents</a><br><br>\n";
   print "<li><a href=javascript:doBrowse('commentors')>Commentors</a><br><br>\n";
   print "<li><a href=javascript:doBrowse('comments')>Comments</a><br><br>\n";
   print "<li><a href=javascript:doBrowse('responses')>Responses</a><br><br>\n";
   print "<li><a href=javascript:doBrowse('summary_comments')>Summary Comments/Responses</a><br><br>\n";
   # print "<li><a href=javascript:doBrowse('preapproved_text')>Preapproved Text</a><br><br>\n";
   print "<li><a href=javascript:doBrowse('bins')>Bins</a><br><br>\n";
   print "<li><a href=javascript:doBrowse('user_functions')>Users</a>\n";
   print "<br><br>\n";
   print "<li><a href=javascript:doBrowse('browse')>Comment Response Document</a><br><br>\n";
   print "</ul></font>\n";
   print "</td></tr></table>\n";
}
print "</font></center></body></html>\n";
db_disconnect($dbh);
exit();
