#!/usr/local/bin/newperl -w
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/crd/perl/RCS/reports.pl,v $
#
# $Revision: 1.140 $
#
# $Date: 2009/05/18 16:22:52 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: reports.pl,v $
# Revision 1.140  2009/05/18 16:22:52  atchleyb
# ACR0905_002 - Fixed Final CRD index issue
#
# Revision 1.139  2002/02/06 00:00:44  atchleyb
# updated evaluation factor report with smaller fonts to allow more evaluation factors
#
# Revision 1.138  2001/12/19 00:37:23  atchleyb
# updated javascript form verification for standard comments report paste in list
#
# Revision 1.137  2001/12/04 21:32:57  atchleyb
# updated to have the FinalCRDIndex4 only show when the function showFinalCRDIndex4 returns a 1
#
# Revision 1.136  2001/11/20 16:43:01  atchleyb
# added new report to display create index 4 from fianl crd
#
# Revision 1.135  2001/11/02 18:24:11  atchleyb
# changed javascript submit functions to not reset values after submition
# changed alert box code to handle single quotes
#
# Revision 1.134  2001/10/31 00:55:42  atchleyb
# added report form object
# changed menus to use the Text_Menus object
#
# Revision 1.133  2001/10/24 15:44:10  atchleyb
# replaced hard coded Nepa with firstReviewName function
#
# Revision 1.132  2001/10/23 22:38:09  atchleyb
# added option to display commentor id on standard comment reports that include commentor
#
# Revision 1.131  2001/10/22 23:59:09  atchleyb
# modified evaluation factor report to have percentages and two subtotal lines based on dates
#
# Revision 1.130  2001/10/05 23:29:14  atchleyb
# changed the evaluation factor report to use zeros instead of blanks and added the prints landscape message
#
# Revision 1.129  2001/10/05 22:35:00  atchleyb
# added CRD Type to the title of the print summary comment response report
#
# Revision 1.128  2001/10/05 21:45:13  atchleyb
# added new report for evaluation factor
# This fullfills SCR31 along with code in Documentspecific.
#
# Revision 1.127  2001/10/05 21:13:39  atchleyb
# Added function to generate a report for one provided SCR
# This with code changes in UI_Widgets.pm fullfils SCREQ 11
#
# Revision 1.126  2001/10/05 18:54:20  atchleyb
# updated SCR display strings to only display 75 characters of the tilte
#
# Revision 1.125  2001/09/20 23:17:03  atchleyb
# mapped three new document types in the weekly status report for SR
#
# Revision 1.124  2001/09/19 20:45:02  atchleyb
# fixed javascript bug for bin section mapping report that only showed up in production
#
# Revision 1.123  2001/09/18 22:29:58  atchleyb
# added new weekly status report for SR
#
# Revision 1.122  2001/09/14 17:41:48  atchleyb
# updates bin/crd section mapping report to be by bin or by section
#
# Revision 1.121  2001/09/13 17:08:48  atchleyb
# alows users to run the crd bin mapping report
#
# Revision 1.120  2001/09/13 16:40:16  atchleyb
# enables the bin section mapping report
#
# Revision 1.119  2001/09/04 15:46:27  atchleyb
# fixed bug in search strings report that would case an error if too many "hits" were found.
#
# Revision 1.118  2001/08/20 19:08:28  atchleyb
# added the textbox resizer to report menus
#
# Revision 1.117  2001/08/14 23:48:42  atchleyb
# added document range to header of response status report
#
# Revision 1.116  2001/08/14 22:06:00  atchleyb
# changed misspelled begining to Starting in javascript verification script
#
# Revision 1.115  2001/08/14 20:11:54  atchleyb
# fixed problem in javascript validation for summary repsonse report, leading zeros were not treated right.
#
# Revision 1.114  2001/08/09 17:02:54  atchleyb
# changed the format of the default numbers for response status report
#
# Revision 1.113  2001/08/06 22:24:02  atchleyb
# added ending document id option to reponse status report
#
# Revision 1.112  2001/08/03 21:25:36  atchleyb
# changed concurrence report to only print columns requested
# added concurrence totals specific to individual and scr
# changed concurence lables on report selection screen
#
# Revision 1.111  2001/08/02 23:09:00  atchleyb
# reenabled changes made for SCR's #10, #13, and #16
#
# Revision 1.110  2001/07/31 23:29:00  atchleyb
# disabled changes made for SCR's #10, #13, and #16
#
# Revision 1.109  2001/07/31 21:28:08  atchleyb
# updated concurrence report to include bin name in title when a bin is selected
# updated concurrence report to test for an empty report first
#
# Revision 1.108  2001/07/30 21:51:46  atchleyb
# updated concurrence reports to only use SCR's with dateapproved set
# modified summary concurrence report to even out the widths of the count columns
#
# Revision 1.107  2001/07/27 00:05:31  atchleyb
# added more javascript form verification for the concurrece report
#
# Revision 1.106  2001/07/26 23:48:58  atchleyb
# changed table name and field names for concurrence reports
#
# Revision 1.105  2001/07/26 22:02:04  atchleyb
# added more options to the concurrence report
#
# Revision 1.104  2001/07/24 22:51:47  atchleyb
# updated javascript in scr report selection to correctly handle the closing/opening of another section
#
# Revision 1.103  2001/07/24 19:15:42  atchleyb
# changed column title in concurence summary report
# updated javascript form validation code for paste a list of SCR's
#
# Revision 1.102  2001/07/23 15:29:06  atchleyb
# added option to reponse status report to only report on responses after a given document number
#
# Revision 1.101  2001/07/20 20:01:40  atchleyb
# added option to SCR report to paste in a list of numbers to report on
# fixed minor bug in standard comment report dealing with anonymous commentors
#
# Revision 1.100  2001/07/18 23:09:50  atchleyb
# added option for summary comment report to sort by SCR number
#
# Revision 1.99  2001/07/18 22:09:19  atchleyb
# added option to concurrence report to select individual or scr or both
#
# Revision 1.98  2001/07/18 21:07:26  atchleyb
# fixed bug in concurrence summary report
# added SCR's to concurrence report
#
# Revision 1.97  2001/07/18 18:28:07  atchleyb
# added concurrence report
# changed summary concurrence report to use FirstReviewName and SecondReviewName
#
# Revision 1.96  2001/07/18 16:35:54  atchleyb
# added concurrence summary report
#
# Revision 1.95  2001/06/21 22:00:35  atchleyb
# fixed included comment count with show organization is selected in summary comment report
#
# Revision 1.94  2001/06/21 21:21:28  atchleyb
# removed debug code
#
# Revision 1.93  2001/06/21 20:54:14  atchleyb
# fixes typo in get_value function call
# adds new bin/section mapping report (disabled and only selectable by developers)
# fulfills SCREQ0007 by adding comment count to summay comment/response report with included summarized comments option
#
# Revision 1.92  2001/05/17 16:36:17  atchleyb
# modified to use &FirstReviewName and &SecondReviewName from DocumentSpecific.pm
#
# Revision 1.91  2001/05/16 21:08:27  atchleyb
# updated to use lastSubmittedText function
# fixed bug in search strings report by commentor where no strings found message did not come up
#
# Revision 1.90  2001/04/20 16:35:39  atchleyb
# added new comment and summary comment counts by organization report
#
# Revision 1.89  2001/04/20 15:15:15  atchleyb
# added option to summary comment report to display commentor organization
#
# Revision 1.88  2001/03/28 15:44:17  atchleyb
# fixed 'use of uninitialized variable' error
#
# Revision 1.87  2001/03/16 07:00:00  mccartym
# change name on Comment/Bin Counts Report
#
# Revision 1.86  2001/03/16 01:07:23  atchleyb
# added Bin/Comments report
#
# Revision 1.85  2001/03/14 01:56:58  atchleyb
# modified standard comment report to not display responses when reponse status is > 9
#
# Revision 1.84  2001/02/21 23:17:19  atchleyb
# added option to standard comment reports to display commentor information
#
# Revision 1.83  2001/02/16 16:48:11  atchleyb
# changed labels for document/comment counts by type report
#
# Revision 1.82  2001/02/16 16:09:18  atchleyb
# added report 'document and comment count by document  type'
#
# Revision 1.81  2001/02/12 16:08:26  atchleyb
# added option on search strings report to display detailed commentor information
#
# Revision 1.80  2001/02/08 16:24:00  atchleyb
# added bin selection to search strings report.
#
# Revision 1.79  2001/01/10 17:48:45  atchleyb
# changed option for final CRD report to only diplayed for developers, rather than only on the dev server
#
# Revision 1.78  2000/12/08 00:04:44  atchleyb
# added code to handle multiple oracle servers
#
# Revision 1.77  2000/11/09 23:55:40  atchleyb
# added option to standard comments report to paste in a list of document/comment ids
#
# Revision 1.76  2000/11/06 22:30:30  atchleyb
# added comments to the text string search report
# added options for what to search in to the text string search
# fixed bug on text string search to made a string with a blank line after it not get searched for
#
# Revision 1.75  2000/11/02 20:56:22  atchleyb
# fixed a problem when calls were made to ad_hoc_reports.pl
#
# Revision 1.74  2000/10/26 19:06:15  atchleyb
# added bin name to search strings report
#
# Revision 1.73  2000/10/20 16:15:25  atchleyb
# added the search strings reprot
#
# Revision 1.72  2000/09/19 16:10:09  atchleyb
# fixed bug that displayed the wrong status in the standard comment reports
#
# Revision 1.71  2000/09/18 23:56:06  atchleyb
# fixed bug that displyed a status on the standard comment report when a commentwas summarized after response dev was started
#
# Revision 1.70  2000/09/08 23:40:53  atchleyb
# fixed bug in standard comment reports, display by comment id
#
# Revision 1.69  2000/09/08 22:40:18  atchleyb
# added option to standard comment reports to sort by bin
#
# Revision 1.68  2000/08/29 21:30:59  atchleyb
# fixed javascript bug that made the last bin not display in the SCR list
#
# Revision 1.67  2000/08/29 18:15:32  atchleyb
# added a dev only option under summary reports for final comment response document
# updated selection option for summary comment/repose report to select on change impact
#
# Revision 1.66  2000/08/11 16:17:07  atchleyb
# fixed bug in user workload report that was not reporting DOE Review properly
#
# Revision 1.65  2000/08/09 23:28:04  atchleyb
# minor update to sql in response status report
#
# Revision 1.64  2000/08/09 16:57:44  atchleyb
# fixed bug in response status report that caused some duplicates to be listed in the summary column
#
# Revision 1.63  2000/08/08 19:20:16  atchleyb
# Fixed bug in Response Status Report that had columns mixed up
#
# Revision 1.62  2000/08/04 20:30:38  atchleyb
# Fixed nepa count in user workload report
# added keep alive lines for longer running reports
# fixed bug in SCR selection display
#
# Revision 1.61  2000/07/26 22:23:49  atchleyb
# updated way printCommentResponse displays responses
# changed summary comment report to have an option to not print summarized comments
#
# Revision 1.60  2000/07/25 19:55:36  atchleyb
# updated printCommentResponse to print all versions of a response by default and to handle duplicates and summaries.
# returned version branch back to main tree
#
# Revision 1.57.1.8  2000/07/17 19:28:11  atchleyb
# moved output of version down to response section
#
# Revision 1.57.1.7  2000/07/17 18:58:17  atchleyb
# added option for response version on function for printCommentResponse
#
# Revision 1.57.1.6  2000/07/14 17:55:41  atchleyb
# changed code for printing a comment/response pair to use function and form from modual
#
# Revision 1.57.1.5  2000/07/13 20:58:28  atchleyb
# added doc id & comm id to window title
#
# Revision 1.57.1.4  2000/07/13 16:12:10  atchleyb
# added function to print a single comment/response
#
# Revision 1.57.1.3  2000/07/10 18:50:01  atchleyb
# swaped the tech edit and review columns
#
# Revision 1.57.1.2  2000/07/10 18:39:18  atchleyb
# added tech edit column
#
# Revision 1.57.1.1  2000/07/10 18:04:22  atchleyb
# added two new columns to the response status report
#
# Revision 1.57  2000/06/20 19:35:22  atchleyb
# removed use of technical_review_view
#
# Revision 1.56  2000/06/20 17:55:36  atchleyb
# added pending comments to the summary comment report
#
# Revision 1.55  2000/05/23 16:03:23  atchleyb
# added duplicates and summarized comments to percentages list in bin statistics report
#
# Revision 1.54  2000/05/18 17:12:34  atchleyb
# changed format of lables on technical reviewer/status
# changed label of technical reviewer list to assigned technical reviewer
#
# Revision 1.53  2000/05/17 20:43:05  atchleyb
# fixed problem with technical reviewer text only getting first one
# added technical review to status line
#
# Revision 1.52  2000/05/16 20:07:50  atchleyb
# Added the option to display tech review text and status to the bin status report
#
# Revision 1.51  2000/05/01 18:12:02  atchleyb
# added options to standard comment reports to select several non sequential documents or individual comments.
#
# Revision 1.50  2000/04/25 22:25:45  atchleyb
# fixed bug in workload report, wrong counts for tech edit, nepa review, and accept response
#
# Revision 1.49  2000/04/21 23:07:29  atchleyb
# fixed bug in workload reports that reported status on duplicates
# fixed bug in workload, tech edit was not reported right.
#
# Revision 1.48  2000/04/13 19:28:13  atchleyb
# added include remarks option for summary comment report
#
# Revision 1.47  2000/04/13 16:39:33  atchleyb
# modified javascript to have each report come up in its own window
#
# Revision 1.46  2000/04/07 17:17:43  atchleyb
# added option to bin status report to exclude duplicates
#
# Revision 1.45  2000/04/03 17:42:51  atchleyb
# changed summary comment report selection to allow selection by bin or by SCR in a pulldown.
# set fully customizable report options to call ad_hoc_reports with parameters
# to generate a section specific screen.
# created standard commentor reports using calls to ad_hoc_reports.pl
# created standard document reports using calls to ad_hoc_reports.pl
# cleaned up misc error log entries
#
# Revision 1.43  2000/03/16 18:04:50  atchleyb
# added option to generate a bin workload report for all bins
#
# Revision 1.42  2000/03/10 01:53:28  atchleyb
# added new duplicate comments report
#
# Revision 1.41  2000/03/08 00:55:10  atchleyb
# added new Response Status report
#
# Revision 1.40  2000/03/06 21:32:47  atchleyb
# fixed strange error in display of standard comment selection page.
# Fixed by creating a new hash - my be a perl bug
#
# Revision 1.39  2000/03/06 17:07:48  atchleyb
# fixed bug in javascript code that verifies standard comment report selection data
#
# Revision 1.38  2000/02/29 18:22:28  atchleyb
# made the display of organizations and affiliations on the bin statistics report optional
# created a new report to output the number of documents captured each week
#
# Revision 1.37  2000/02/24 22:41:35  atchleyb
# fixed bug where comment reports stoped one some cases when there was no response_version entry
#
# Revision 1.36  2000/02/22 23:15:52  atchleyb
# fixed bug in standard comment reports introduced when work started on using ad_hoc_reports.pl for canned reports
#
# Revision 1.35  2000/02/12 01:23:18  mccartym
# clean up positioning of 'in development' messages
#
# Revision 1.34  2000/02/12 00:27:59  atchleyb
# changed under development flags to reflec that the custom reports option is now working
#
# Revision 1.33  2000/02/11 17:10:36  atchleyb
# modified help text for printing
# set up custome report links to call ad_hoc_reports.pl
#
# Revision 1.32  2000/02/10 20:55:26  atchleyb
# added display message to help users set thier page headers for printing
#
# Revision 1.31  2000/02/10 17:47:42  atchleyb
# removed form-verify.js
#
# Revision 1.30  2000/02/07 17:59:49  atchleyb
# Check point
# Started work on using adhocreport to generate canned reports
#
# Revision 1.29  2000/01/14 23:41:15  atchleyb
# replaced all references to EIS with $crdtype
#
# Revision 1.28  2000/01/07 00:14:22  atchleyb
# Updated standard commet report code
# changed standard comment reports to use one common intermedeate page with all on the screen at one time
# rather than just one report at a time selected by a drop down
#
# Revision 1.27  1999/12/23 00:48:54  atchleyb
# added several reports types to the standard comment report
#
# Revision 1.26  1999/12/17 23:54:24  atchleyb
# added comment report with two initial types of commitments and EIS Change Impacts
#
# Revision 1.25  1999/12/17 17:39:51  atchleyb
# fixed bug with javascript and closed sections
#
# Revision 1.24  1999/12/16 21:49:21  atchleyb
# modified all reports to use 'getReportDateTime' function
# replaced some print statements with appends to the output string
# got rid of potential, but unlikley bug of showing a bins status report for a single user accross all bins when there are no comments assigned to them.
#
# Revision 1.23  1999/12/16 21:14:07  atchleyb
# modified summary comment/response report test to check for a blank scr number
#
# Revision 1.22  1999/12/16 19:08:45  atchleyb
# added summary comment/response report
# added function 'getReportDateTime'
#
# Revision 1.21  1999/12/14 18:55:55  atchleyb
# changed formatting on bins status report to have bin titles left justified, with an indented no comments in bin message
# changed user selection on bin status report to only print bins that the user has assignments in
#
# Revision 1.20  1999/12/13 19:23:34  atchleyb
# added a select user option to the bin status report
#
# Revision 1.19  1999/12/09 23:07:06  atchleyb
# added due date (when set) and bin number to each comment in bin status report
#
# Revision 1.18  1999/12/09 16:39:28  atchleyb
# minor formatting change, when bin count = 1 print bin not bins
#
# Revision 1.17  1999/12/09 00:14:50  atchleyb
# reformatted all workload reports
# fixed code to disable form fields so it will work with sections
#
# Revision 1.16  1999/12/08 18:12:44  atchleyb
# added javascript functions to disable form field that are not currently in use
#
# Revision 1.15  1999/12/07 23:17:48  atchleyb
# added new report - user work load report
#
# Revision 1.14  1999/12/06 23:11:24  atchleyb
# Changed way number of assignments in technical review is calculated in bin and system workload reports
# combined code for bin and system workload reports with passed in options
#
# Revision 1.13  1999/12/04 00:55:39  atchleyb
# added system workload report
# fixed problem with doe and nepa reviews in workload reports
#
# Revision 1.12  1999/12/02 23:50:13  atchleyb
# added bin workload report
#
# Revision 1.11  1999/11/30 00:31:48  atchleyb
# updated binstatusreport test to also check summary comments correctly
# added report title with selected dates for bin status report
#
# Revision 1.10  1999/11/29 23:40:28  atchleyb
# added optional date range for bin status report
#
# Revision 1.9  1999/11/23 19:04:00  atchleyb
# added Bin Statistics Report
# added System Users Report
# added first cut on a commentor mailing list report
#
# Revision 1.8  1999/11/12 23:43:08  atchleyb
# added code to print summary comment information on bin status report
#
# Revision 1.7  1999/11/08 17:08:37  mccartym
# add button for detailed status report
#
# Revision 1.6  1999/11/08 15:32:41  mccartym
# create section for summary reports
#
# Revision 1.5  1999/11/06 01:13:08  atchleyb
# format changes to reports
# added function to check number of comments before opening new window
#
# Revision 1.4  1999/11/02 20:49:12  atchleyb
# commented out sections code
# updated summary Status Report
# updated Comment Report - By Bin (with printable pagination)
#
# Revision 1.3  1999/10/29 23:55:45  atchleyb
# added functions to create two reports: 'Status Report - Summary' and  'Comment Report - By Bin'
#
# Revision 1.2  1999/10/28 15:13:07  mccartym
# change headerBar() to writeTitleBar()
#
# Revision 1.1  1999/08/02 03:04:46  mccartym
# Initial revision
#
#
use integer;
use strict;
use CRD_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use DocumentSpecific qw(:Functions);
use Tie::IxHash;
use Text_Menus;
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI qw(param);
use Time::Local;

my $crdcgi = new CGI;
my $username = $crdcgi->param("username");
my $userid = $crdcgi->param("userid");
my $schema = $crdcgi->param("schema");
# Set server parameter
my $Server = $crdcgi->param("server");
if (!(defined($Server))) {$Server=$CRDServer;}

my $documentid = $crdcgi->param("id");
if (!(defined($documentid))) {$documentid='';}
my $command = $crdcgi->param("command");
if (!(defined($command))) {$command='';}
&checkLogin ($username, $userid, $schema);
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $pageNum = 1;
my $dbh;
my $errorstr = "";
my $underDevelopment = &nbspaces(3) . "<b><font size=2 color=#ff0000>(in development)</font></b>";
my $enableAllFunction = "setEnabled('all'); setEnabledComments('all')";
my $printHeaderHelp = "<table border=1 width=75% align=center><tr><td><font size=-1><b><i>To set report page headers and footers for printing, select Page Setup... from the File menu, remove the text from the Footer box and replace the text in the Header box with the following:</i> <br><center>&d &t &b&bPage &p of &P</center><i>Then click on OK.</i></b></font></td></tr></table>\n";

tie my %commentDocumentsOptions, "Tie::IxHash"; 
tie my %commentsOptions, "Tie::IxHash"; 
tie my %commentorsOptions, "Tie::IxHash"; 

$| =1;

%commentDocumentsOptions = (
   'id'   => 'ID Number', 
   'type' => 'Document Type',
   'date' => 'Date Received',
   'name' => 'Commentor Name'
);

%commentsOptions = (
   'docid'           => 'Source Document ID Number',
   'doctype'         => 'Source Document Type',
   'commentid'       => 'Comment ID Number', 
   'bin'             => 'Bin',
   'date'            => 'Date Received',
   'name'            => 'Commentor Name',
   'organization'    => 'Commentor Organization',
   'affiliation'     => 'Commentor Affiliation',
   'city'            => 'Commentor City',
   'state'           => 'Commentor State',
   'postal_code'     => 'Commentor Postal Code'
);

%commentorsOptions = (
   'name'         => 'Commentor Name',
   'organization' => 'Organization',
   'affiliation'  => 'Affiliation',
   'city'         => 'City',
   'state'        => 'State',
   'country'      => 'Country',
   'postal_code'  => 'Postal Code',
   'area_code'    => 'Area Code'
);


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
sub matchFound {                                                                                                                  #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out;
   if (defined($args{text})) {
       if (defined($crdcgi->param("case"))) {
          $out = ($args{text} =~ m/$args{searchString}/) ? 1 : 0;
       } else {
          $out = ($args{text} =~ m/$args{searchString}/i) ? 1 : 0;
       }
   } else {
       $out = 0;
   }
   return ($out);
}

###################################################################################################################################
sub writeRadioBox {
###################################################################################################################################
   my %args = (
      default => "",
      name => 'radioBox',
      height => 30,
      useForm => defined($crdcgi->param("useFormValues")) ? 1 : 0,
      onClick => "",
      @_,
   );
   tie my %buttons, "Tie::IxHash"; 
   %buttons = %{$args{buttons}}; 
   my $saved = $crdcgi->param($args{name});
   my $checked;
   my $output = "";
   while (my ($button, $values) = each %buttons) {
      if ($button eq $args{default}) {
         $checked = (!$args{useForm} || ($saved eq $button)) ? 'checked' : '';
      } else {
         $checked = ($args{useForm} && ($saved eq $button)) ? 'checked' : '';
      }
      $output .= "<tr><td height=$args{height} valign=bottom><input type=radio name=$args{name} value=$button " . (($args{'onClick'} gt "") ? "onClick=$args{'onClick'} " : "") . "$checked>" . &nbspaces(2) . "<b>$$values{label}</b></td></tr>\n";
      if (defined($$values{content})) {
         $output .= "<tr><td align=right><table width=96% border=2 bordercolorlight=#ccddee bordercolordark=#2f4f4f cellpadding=8 cellspacing=0>$$values{content}</table></td></tr>\n";
      }
   }
   return ($output);
}

###################################################################################################################################
sub processError {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $error = &errorMessage($dbh, $username, $userid, $schema, $args{activity}, $@);
   $error =  ('_' x 100) . "\n\n" . $error if ($errorstr ne "");
   $error =~ s/\n/\\n/g;
   $error =~ s/'/%27/g;
   $errorstr .= $error;
}



###################################################################################################################################
sub doMainMenu {
###################################################################################################################################
    my $message = '';
    my $outputstring = '';
  eval {
    my $menu1 = new Text_Menus;

# Summary section
      tie my %binlookupvalues, "Tie::IxHash";
      tie my %userlookupvalues, "Tie::IxHash";
      my $DocumentCommentCountByTypeInput .= "<table border=0><tr><td><b><input type=checkbox name=displayhearings value=T>Show Submission and Transcript Counts for Individual Hearings</b></td></tr></table><input type=button value=Submit align=center onClick=\"submitFormNewWindow('$form', 'report','DocumentCommentCountByType');\">\n";
      my $DocumentCommentCountByType = new Report_Forms;
      $DocumentCommentCountByType->label("Document/Comment Counts by Document Type");
      $DocumentCommentCountByType->contents($DocumentCommentCountByTypeInput);
      
      %binlookupvalues = ('0' => "All Bins", get_lookup_values ($dbh, $schema, 'bin', 'id', 'name', 'parent is NULL ORDER BY name'));
      my $BinStatisticsReportInput = "<table border=0><tr><td><b>Select Bin:</b>" . &nbspaces(3) . &build_drop_box ('bin1', \%binlookupvalues, '0') . "</td></tr>\n";
      $BinStatisticsReportInput .= "<tr><td><b><input type=checkbox name=includeorgs value=T>Include Commentor Organizations and Affiliations</b></td></tr></table><input type=button value=Submit align=center onClick=\"submitFormNewWindow('$form', 'report','BinStatisticsReport');\">\n";
      my $BinStatisticsReport = new Report_Forms;
      $BinStatisticsReport->label("Bin Statistics Report");
      $BinStatisticsReport->contents($BinStatisticsReportInput);
      
      %binlookupvalues = ('0' => "All Bins",get_lookup_values ($dbh, $schema, 'bin', 'id', 'name', 'parent is NULL ORDER BY name'));
      my $BinWorkLoadReportInput = "<table border=0><tr><td><b>Select Bin:</b>" . &nbspaces(3) . &build_drop_box ('bin2', \%binlookupvalues, '0') . "</td></tr></table><input type=button value=Submit align=center onClick=\"submitFormNewWindow('$form', 'report','BinWorkLoadReport');\">\n";
      my $BinWorkLoadReport = new Report_Forms;
      $BinWorkLoadReport->label("Bin Workload Report");
      $BinWorkLoadReport->contents($BinWorkLoadReportInput);
      
      %binlookupvalues = ('0' => "All Bins", get_lookup_values ($dbh, $schema, 'bin', 'id', 'name', 'id = id ORDER BY name'));
      %userlookupvalues = ('0' => "All Users", get_lookup_values ($dbh, $schema, 'users', 'id', "firstname || ' ' || lastname", "(id > 0) AND (id < 1000) AND (id IN (SELECT userid FROM $schema.user_privilege WHERE privilege>3)) ORDER BY username"));
      my $BinStatusReportInput = "<table border=0><tr><td><b>Select Bin:</b>" . &nbspaces(3) . &build_drop_box ('bin', \%binlookupvalues, '0') . "</td></tr>\n";
      $BinStatusReportInput .= "<tr><td><b>Select User:</b>" . &nbspaces(3) . &build_drop_box ('user2', \%userlookupvalues, "0") . "</td></tr>\n";
      $BinStatusReportInput .= "<tr><td><b>Include:</b>" . &nbspaces(5) . "<input type=checkbox name=displaycomments value=T><b>Comment Text</b>\n";
      $BinStatusReportInput .= &nbspaces(5) . "<input type=checkbox name=displayresponses value=T><b>Response Text</b>\n";
      $BinStatusReportInput .= &nbspaces(5) . "<input type=checkbox name=displayduplicates value=T checked><b>Duplicates</b>\n";
      $BinStatusReportInput .= &nbspaces(5) . "<input type=checkbox name=displaytechreview value=T><b>Technical Review</b></td></tr>\n";
      $BinStatusReportInput .= "<tr><td><input type=checkbox name=binstatusselectdates value=T onClick=\"enableSetBinStatusReportDates(!(this.checked));\"><b>Select Date Range - ";
      $BinStatusReportInput .= "From: " . build_date_selection("binstatusbegindate", "$form", "today") . " &nbsp; ";
      $BinStatusReportInput .= "To: " . build_date_selection("binstatusenddate", "$form", "today");
      $BinStatusReportInput .= "<script language=javascript><!--\n";
      $BinStatusReportInput .= "function enableSetBinStatusReportDates (status) {\n";
      $BinStatusReportInput .= "    document.$form.binstatusbegindate_month.disabled = (status);\n";
      $BinStatusReportInput .= "    document.$form.binstatusbegindate_day.disabled = (status);\n";
      $BinStatusReportInput .= "    document.$form.binstatusbegindate_year.disabled = (status);\n";
      $BinStatusReportInput .= "    document.$form.binstatusenddate_month.disabled = (status);\n";
      $BinStatusReportInput .= "    document.$form.binstatusenddate_day.disabled = (status);\n";
      $BinStatusReportInput .= "    document.$form.binstatusenddate_year.disabled = (status);\n";
      $BinStatusReportInput .= "}\n";
      $BinStatusReportInput .= "    //alert (show_props(document.$form.binstatusselectdates,'date'));\n";
      $BinStatusReportInput .= "    enableSetBinStatusReportDates(!(document.$form.binstatusselectdates.checked));\n";
      $BinStatusReportInput .= "//--></script>\n";
      $BinStatusReportInput .= "</table><input type=button value=Submit align=center onClick=\"submitFormCGIResults('$form', 'report','BinStatusReportTest');\">\n";
      my $BinStatusReport = new Report_Forms;
      $BinStatusReport->label("Bin Status Report");
      $BinStatusReport->contents($BinStatusReportInput);
      
      %userlookupvalues = get_lookup_values ($dbh, $schema, 'users', 'id', "firstname || ' ' || lastname", "(id > 0) AND (id < 1000) AND (id IN (SELECT userid FROM $schema.user_privilege WHERE privilege>3)) ORDER BY username");
      my $UserWorkLoadReportInput = "<table border=0><tr><td><b>Select User:</b>". &nbspaces(3) . &build_drop_box ('user', \%userlookupvalues, "0") . "</td></tr></table><input type=button value=Submit align=center onClick=\"submitFormNewWindow('$form', 'report','UserWorkLoadReport');\">\n";
      my $UserWorkLoadReport = new Report_Forms;
      $UserWorkLoadReport->label("User Workload Report");
      $UserWorkLoadReport->contents($UserWorkLoadReportInput);
      
      my $ResponseStatusInput .= "<table border=0><tr><td><b>Report on Documents Starting with ID # $CRDType <input type=text size=6 maxlength=6 name=rsstartid value=000001>";
      #my $maxDocID = 999999;
      my ($maxDocID) = lpadzero($dbh->selectrow_array("SELECT MAX(id) FROM $schema.document"),6);
      $ResponseStatusInput .= " and Ending with ID # $CRDType <input type=text size=6 maxlength=6 name=rsendid value=$maxDocID></b></td></tr></table><b><font size=-1><i>(Prints Landscape - select File/Page Setup... and Landscape option)</i></font></b><br><input type=button value=Submit align=center onClick=\"checkResponseStatusReport();\">\n";
      my $ResponseStatus = new Report_Forms;
      $ResponseStatus->label("Response Status Report");
      $ResponseStatus->contents($ResponseStatusInput);
      my $secInDay = 60*60*24;
      my @now = localtime;
      my @startDay = localtime(time - ($secInDay * (8,9,10,11,12,13,14)[$now[6]]));
      my @endDay = localtime(time - ($secInDay * (2,3,4,5,6,7,8)[$now[6]]));
      #my $WeeklyStatusReportInput = "<table border=0><tr><td><b>From: " . build_date_selection("weeklystatusbegindate", "$form", lpadzero(($startDay[4]+1),2) . "/" . lpadzero($startDay[3],2) . "/" . ($startDay[5] + 1900)) . " &nbsp; ";
      #$WeeklyStatusReportInput .= "<b>To:</b> " . build_date_selection("weeklystatusenddate", "$form", lpadzero(($endDay[4]+1),2) . "/" . lpadzero($endDay[3],2) . "/" . ($endDay[5] + 1900)) . "</td></tr></table><input type=button value=Submit align=center onClick=\"checkWeeklyStatusReport();\">\n";
      my $WeeklyStatusReportInput = "<table border=0><tr><td><b>From: " . build_date_selection("weeklystatusbegindate", "$form", lpadzero(($startDay[4]+1),2) . "/" . lpadzero($startDay[3],2) . "/" . ($startDay[5] + 1900)) . " &nbsp; ";
      $WeeklyStatusReportInput .= "<b>To:</b> " . build_date_selection("weeklystatusenddate", "$form", lpadzero(($endDay[4]+1),2) . "/" . lpadzero($endDay[3],2) . "/" . ($endDay[5] + 1900)) . "</td></tr></table><input type=button value=Submit align=center onClick=\"checkWeeklyStatusReport();\">\n";
      my $WeeklyStatus = new Report_Forms;
      $WeeklyStatus->label("Weekly Status Report");
      $WeeklyStatus->contents($WeeklyStatusReportInput);
      my $evaluationFactorReportInput = "<table border=0><tr><td><b>From: " . build_date_selection("evaluationFactorbegindate", "$form", lpadzero(($startDay[4]+1),2) . "/" . lpadzero($startDay[3],2) . "/" . ($startDay[5] + 1900)) . " &nbsp; ";
      $evaluationFactorReportInput .= "<b>To:</b> " . build_date_selection("evaluationFactorenddate", "$form", lpadzero(($endDay[4]+1),2) . "/" . lpadzero($endDay[3],2) . "/" . ($endDay[5] + 1900)) . "</td></tr></table><b><font size=-1><i>(Prints Landscape - select File/Page Setup... and Landscape option)</i></font></b><br><input type=button value=Submit align=center onClick=\"checkEvaluationFactorReport();\">\n";
      my $evaluationFactorReport = new Report_Forms;
      $evaluationFactorReport->label("Evaluation Factor Report");
      $evaluationFactorReport->contents($evaluationFactorReportInput);
      my $BinSectionMappingReportInput = "<table border=0><tr><td><b><input type=radio name=binsectionmaptype value='byBin' checked> By Bin &nbsp; &nbsp; &nbsp; <input type=radio name=binsectionmaptype value='bySection'> By CRD Section</b></td></tr></table><input type=button value=Submit align=center onClick=\"checkBinSectionMappingReport();\">\n";
      my $BinSectionMappingReport = new Report_Forms;
      $BinSectionMappingReport->label("Bin/Section Mapping Report");
      $BinSectionMappingReport->contents($BinSectionMappingReportInput);
      

    my $summaryMenu = new Text_Menus;
    
    $summaryMenu->addMenu(name => "summary1", label => "Summary Status Report", contents => "javascript:submitFormNewWindow('$form', 'report','SummaryStatusReport');");
    $summaryMenu->addMenu(name => "summary2", label => $DocumentCommentCountByType->label(), contents => $DocumentCommentCountByType->contents(), title => $DocumentCommentCountByType->label());
    $summaryMenu->addMenu(name => "summary3", label => $BinStatisticsReport->label(), contents => $BinStatisticsReport->contents(), title => $BinStatisticsReport->label());
    $summaryMenu->addMenu(name => "summary4", label => $BinStatusReport->label(), contents => $BinStatusReport->contents(), title => $BinStatusReport->label());
    $summaryMenu->addMenu(name => "summary5", label => $BinWorkLoadReport->label(), contents => $BinWorkLoadReport->contents(), title => $BinWorkLoadReport->label());
    $summaryMenu->addMenu(name => "summary6", label => "System Workload Report", contents => "javascript:submitFormNewWindow('$form', 'report','SystemWorkLoadReport');");
    $summaryMenu->addMenu(name => "summary7", label => $UserWorkLoadReport->label(), contents => $UserWorkLoadReport->contents(), title => $UserWorkLoadReport->label());
    $summaryMenu->addMenu(name => "summary8", label => "System Users Report", contents => "javascript:submitFormNewWindow('$form', 'report','UsersReport');");
    $summaryMenu->addMenu(name => "summary9", label => $ResponseStatus->label(), contents => $ResponseStatus->contents(), title => $ResponseStatus->label());
    $summaryMenu->addMenu(name => "summary10", label => "Comment and Summary Comment Counts by Bin", contents => "javascript:submitFormNewWindow('$form', 'report','BinCountsReport');");
    $summaryMenu->addMenu(name => "summary11", label => "Comment and Summary Comment Counts by Organization", contents => "javascript:submitFormNewWindow('$form', 'report','OrgCountsReport');");
    $summaryMenu->addMenu(name => "summary12", label => "Concurrence Overview Report", contents => "javascript:submitFormNewWindow('$form', 'report','ConcurrenceSummaryReport');");
    if (&doWeeklyStatus == 1) {
        $summaryMenu->addMenu(name => "summary15", label => $WeeklyStatus->label(), contents => $WeeklyStatus->contents(), title => $WeeklyStatus->label());
    }
    $summaryMenu->addMenu(name => "summary13", label => $BinSectionMappingReport->label(), contents => $BinSectionMappingReport->contents(), title => $BinSectionMappingReport->label());
    $summaryMenu->addMenu(name => "summary16", label => $evaluationFactorReport->label(), contents => $evaluationFactorReport->contents(), title => $evaluationFactorReport->label());
    if (&showFinalCRDIndex4 == 1) {
        $summaryMenu->addMenu(name => "summary17", label => "Final CRD Index 4", contents => "javascript:submitFormNewWindow('$form', 'report','FinalCRDIndex4Report');");
    }
    if (&does_user_have_priv($dbh, $schema, $userid, -1)) {
        $summaryMenu->addMenu(name => "summary14", label => "Final Comment Response Document", contents => "javascript:submitForm('final_crd', 'menu',0);");
    }
    
# Comment Documents Section
    
    my $commentDocumentMenu = new Text_Menus;

    $commentDocumentMenu->addMenu(name => "documents1", label => "Fully customizable documents report", contents => "javascript:submitForm('ad_hoc_reports','adhocsetup','document');");
    $commentDocumentMenu->addMenu(name => "documents2", label => "Standard document report", contents => "javascript:submitForm('$form', 'reportselect', 'StandardDocumentReport');");
    
# Commentors Section
    
    #my $commentorsMenu = new Text_Menus;

    $commentDocumentMenu->addMenu(name => "commentors1", label => "Fully customizable commentors report", contents => "javascript:submitForm('ad_hoc_reports','adhocsetup','commentor');");
    $commentDocumentMenu->addMenu(menu => "commentors", name => "commentors2", label => "Standard commentor report", contents => "javascript:submitForm('$form', 'reportselect', 'StandardCommentorReport');");
    
# Comments Section

      #tie my %binlookupvalues, "Tie::IxHash";
      tie my %lookupvalues, "Tie::IxHash";
      %binlookupvalues = ( );
      %binlookupvalues = ('0' => "All Bins", get_lookup_values ($dbh, $schema, 'bin', 'id', 'name', 'id = id ORDER BY name'));
      %lookupvalues = ('0' => "All Summary Comments" . nbspaces(130), get_lookup_values ($dbh, $schema, 'summary_comment', 'id', "id || ' - ' || title", 'id = id ORDER BY id'));
      foreach my $key (keys %lookupvalues) {
          if ($key ne '0') {
              $lookupvalues{$key} = &getDisplayString($lookupvalues{$key}, 85);
          }
      }
      my $SummaryCommentReportInput = "<table border=0 align=center><tr><td><b>Bin:</b>" . &build_drop_box('binforscrs', \%binlookupvalues, '0') . "</td></tr>\n";
      $SummaryCommentReportInput =~ s/"binforscrs">/"binforscrs" onChange=\"buildSCRList(this.options,document.$form.scrid.options);\">/;
      $SummaryCommentReportInput .= "<tr><td><b><i>Include Summarized Comments:</i></b><input type=checkbox name=includescrcomments checked value='T'>\n";
      $SummaryCommentReportInput .= nbspaces(10) . "<b><i>Include Sub-Bins:</i></b><input type=checkbox name=scrusesubbins checked value='T' onClick=\"buildSCRList(document.$form.binforscrs.options,document.$form.scrid.options);\">\n";
      $SummaryCommentReportInput .= nbspaces(10) . "<b><i>Include Remarks:</i></b><input type=checkbox name=scruseremarks value='T'>\n";
      $SummaryCommentReportInput .= "<br><b><i>Include Commentor Organizations of Summarized Comments:</i></b><input type=checkbox name=scruseorganizations value='T'>\n";
      $SummaryCommentReportInput .= "<br><b><i>Include Only Summary Comments With Potential or Confirmed Document Change Impact:</i></b><input type=checkbox name=scrhaschangeimpact value='T' onClick=\"buildSCRList(document.$form.binforscrs.options,document.$form.scrid.options);\"></td></tr>\n";
      $SummaryCommentReportInput .= "<tr><td><b>Sort by SCR:</b><input type=checkbox name=scrsortbyscr value='T' ></td></tr>\n";
      $SummaryCommentReportInput .= "<tr><td>";
      $SummaryCommentReportInput .= "<input type=radio name=scridtype value=select onClick=\"setSCRIDTypeDisabled()\" checked>";
      $SummaryCommentReportInput .= "<b>SCR:</b>" . &build_drop_box('scrid', \%lookupvalues, '0') . "</td></tr>\n";
      $SummaryCommentReportInput .= "<tr><td><table border=0 cellpadding=0 cellspacing=0><tr><td valign=center><input type=radio name=scridtype value=paste onClick=\"setSCRIDTypeDisabled()\">\n";
      $SummaryCommentReportInput .= "</td><td valign=center><b>Paste in list of SCR numbers<br>use format of 'SCR0000':</b>";
      $SummaryCommentReportInput .= "</td><td>" . nbspaces(30) . "<a href=\"javascript:expandTextBox(document.$form.scridpastelist,document.scridpastelist_button,'force',5);\"><img name=scridpastelist_button border=0 src=/eis/images/expand_button.gif></a><br>\n";
      $SummaryCommentReportInput .= nbspaces(10) . "<textarea name=scridpastelist rows=6 cols=10 onKeyPress=\"expandTextBox(this,document.scridpastelist_button,'dynamic');\"></textarea></td></tr></table></td></tr></table><input type=button value=Submit align=center onClick=\"checkSCRReport();\">\n";
      $SummaryCommentReportInput .= "<script language=javascript><!--\n";
      $SummaryCommentReportInput .= "setSCRIDTypeDisabled();\n";
      $SummaryCommentReportInput .= "//--></script>\n";
      my $SummaryCommentReport = new Report_Forms;
      $SummaryCommentReport->label("Report on a Summary Comment/Response");
      $SummaryCommentReport->contents($SummaryCommentReportInput);
      #
      print "<script language=javascript><!--\n";
      print "function setSCRIDTypeDisabled(object) {\n";
      print "    if (object != 'all') {\n";
      print "        if ($form.scridtype[0].checked) {\n";
      print "            $form.binforscrs.disabled = false;\n";
      print "            $form.scrid.disabled = false;\n";
      print "            $form.scridpastelist.disabled = true;\n";
      print "        } else {\n";
      print "            $form.binforscrs.disabled = true;\n";
      print "            $form.scrid.disabled = true;\n";
      print "            $form.scridpastelist.disabled = false;\n";
      print "        }\n";
      print "    }\n";
      print "    //;\n";
      print "}\n";
      #print "setSCRIDTypeDisabled();\n";
      print "    var scrs = new Array();\n";
      my $sqlquery = "SELECT id, title, changeimpact FROM $schema.summary_comment WHERE bin = ?";
      my $csr = $dbh->prepare($sqlquery);
      foreach my $key (sort keys %binlookupvalues) {
          if ($key > 0) {
              print "    scrs[$key] = [0," . get_value($dbh,$schema,'bin','NVL(parent,0)', "id = $key") . ",0";
              $csr->execute($key);
              my $count=0;
              while (my @values = $csr->fetchrow_array) {
                  $values[1] =~ s/'//g;
                  $binlookupvalues{$key} =~ m/([0-9].*?)[ ]/;
                  my $binnumber = $1;
                  print ",[$values[0],'" . getDisplayString("$binnumber - SCR" . lpadzero($values[0],4) ." - $values[1]", 85) . "',$values[2]]";
                  $count++
              }
              print "];\n";
              print "    scrs[$key][2] = $count;\n";
              $csr->finish;
          }
      }
      print "    function isBinMember(binID,rootBin) {\n";
      print "        var parent = binID;\n";
      print "        while (parent != rootBin && parent != 0) {\n";
      print "            parent = scrs[parent][1];\n";
      print "        }\n";
      print "        if (parent == rootBin) {\n";
      print "            return true;\n";
      print "        } else {\n";
      print "            return false;\n";
      print "        }\n";
      print "    }\n";
      print "    function buildSCRList(binobj,scrobj) {\n";
      print "        var bin = binobj[binobj.selectedIndex].value;\n";
      print "        var last = 0;\n";
      print "        var scrlist = new Array();\n";
      print "        for (var i=(scrobj.length-1); i > 0; i--) {\n";
      print "            scrobj[i].value = 0;\n";
      print "            scrobj[i].text = '';\n";
      print "        }\n";
      print "        scrobj.length = 1;\n";
      print "        scrobj.selectedIndex = 0;\n";
      print "        if (bin == '0') {\n";
      print "            for (var i=1; i < scrs.length; i++) {\n";
      print "                if (scrs[i]) {\n";
      print "                    if (scrs[i][2] != 0) {\n";
      print "                        for (var j=3; j <= scrs[i][2]+2; j++) {\n";
      print "                            if ((!document.$form.scrhaschangeimpact.checked) || (document.$form.scrhaschangeimpact.checked && scrs[i][j][2] > 1)) {\n";
      print "                                scrlist[scrs[i][j][0]] = scrs[i][j][1];\n";
      print "                            }\n";
      print "                        }\n";
      print "                    }\n";
      print "                }\n";
      print "            }\n";
      print "        } else {\n";
      print "            if (document.$form.scrusesubbins.checked) {\n";
      print "                for (var i=1; i < scrs.length; i++) {\n";
      print "                    if (scrs[i]) {\n";
      print "                        if (scrs[i][2] != 0) {\n";
      print "                            if (isBinMember(i, bin)) {\n";
      print "                                for (var j=3; j <= scrs[i][2]+2; j++) {\n";
      print "                                    if ((!document.$form.scrhaschangeimpact.checked) || (document.$form.scrhaschangeimpact.checked && scrs[i][j][2] > 1)) {\n";
      print "                                        scrlist[scrs[i][j][0]] = scrs[i][j][1];\n";
      print "                                    }\n";
      print "                                }\n";
      print "                            }\n";
      print "                        }\n";
      print "                    }\n";
      print "                }\n";
      print "            } else {\n";
      print "                if (scrs[bin][2] != 0) {\n";
      print "                    for (var j=3; j <= scrs[bin][2]+2; j++) {\n";
      print "                        if ((!document.$form.scrhaschangeimpact.checked) || (document.$form.scrhaschangeimpact.checked && scrs[i][j][2] > 1)) {\n";
      print "                            scrlist[scrs[bin][j][0]] = scrs[bin][j][1];\n";
      print "                        }\n";
      print "                    }\n";
      print "                }\n";
      print "            }\n";
      print "        }\n";
      print "        for (var i=1; i < scrlist.length; i++) {\n";
      print "            if (scrlist[i]) {\n";
      print "                last++\n";
      print "                scrobj.length++;\n";
      print "                scrobj[last].value = i;\n";
      print "                scrobj[last].text = scrlist[i];\n";
      print "            }\n";
      print "        }\n";
      print "    }\n";
      print "//-->\n";
      print "</script>\n";
      my $DuplicateReportInput = "<table border=0 align=center><tr><td><b>Select Bin:</b>" . &nbspaces(3) . &build_drop_box ('binfordups', \%binlookupvalues, '0') . "</td></tr></table><input type=button value=Submit align=center onClick=\"submitFormCGIResults('$form', 'report', 'DuplicateCommentsReportTest');\">\n";
      my $DuplicateReport = new Report_Forms;
      $DuplicateReport->label("Report on Duplicate Comments");
      $DuplicateReport->contents($DuplicateReportInput);
      
      my $CommentsWithStringInput = "<table border=0 align=center><tr><td><b>Text Strings:</b>" . nbspaces(135) . "<a href=\"javascript:expandTextBox(document.$form.commentsearchstrings,document.commentsearchstrings_button,'force',5);\"><img name=commentsearchstrings_button border=0 src=/eis/images/expand_button.gif></a><br>\n";
      $CommentsWithStringInput .= "<textarea name=commentsearchstrings wrap=virtual rows=6 cols=80 onKeyPress=\"expandTextBox(this,document.commentsearchstrings_button,'dynamic');\"></textarea>\n";
      $CommentsWithStringInput .= "</tr></td><tr><td><b>Select Bin:</b>" . &nbspaces(3) . &build_drop_box ('cwsbin', \%binlookupvalues, '0') . "</tr></td><tr><td>\n";
      $CommentsWithStringInput .= "<b>Search: \n";
      $CommentsWithStringInput .= "<input type=checkbox name=cwscomments value='T' checked>Comments &nbsp; \n";
      $CommentsWithStringInput .= "<input type=checkbox name=cwsresponses value='T' checked>Responses &nbsp; \n";
      $CommentsWithStringInput .= "<input type=checkbox name=cwsscr value='T' checked>SCR's \n";
      $CommentsWithStringInput .= nbspaces(20) . "<b><i>(End each string with an 'Enter')</i></b></b></td></tr>\n";
      $CommentsWithStringInput .= "<tr><td><b><input type=checkbox name=cwscommentors value='T'>Display Detailed Commentor Information</b></td></tr></table><input type=button value=Submit align=center onClick=\"checkSearchStringsReport();\">\n";
      my $CommentsWithString = new Report_Forms;
      $CommentsWithString->label("Search Strings Report");
      $CommentsWithString->contents($CommentsWithStringInput);
      
      %binlookupvalues = ('0' => "All Bins", get_lookup_values ($dbh, $schema, 'bin', 'id', 'name', 'parent is NULL ORDER BY name'));
      my $ConcurrenceReportInput = "<table border=0 align=center><tr><td><b>Select Bin:</b>" . &nbspaces(3) . &build_drop_box ('concurbin', \%binlookupvalues, '0') . "</td></tr>\n";
      $ConcurrenceReportInput .= "<tr><td><table border=0 width=100%><tr><td valign=top>\n";
      $ConcurrenceReportInput .= "<b>" . get_value($dbh,$schema,'concurrence_type','name',"id=1") . " Concurrence Entered:</b>\n";
      $ConcurrenceReportInput .= "<br><b><input type=checkbox name=includefirstnonecon value=T checked>None</b>\n";
      $ConcurrenceReportInput .= "<br><b><input type=checkbox name=includefirstpositivecon value=T checked>Positive</b>\n";
      $ConcurrenceReportInput .= "<br><b><input type=checkbox name=includefirstnegativecon value=T checked>Negative</b>\n";
      $ConcurrenceReportInput .= "<br><b>" . get_value($dbh,$schema,'concurrence_type','name',"id=2") . " Concurrence Entered:</b>\n";
      $ConcurrenceReportInput .= "<br><b><input type=checkbox name=includesecondnonecon value=T checked>None</b>\n";
      $ConcurrenceReportInput .= "<br><b><input type=checkbox name=includesecondpositivecon value=T checked>Positive</b>\n";
      $ConcurrenceReportInput .= "<br><b><input type=checkbox name=includesecondnegativecon value=T checked>Negative</b>\n";
      $ConcurrenceReportInput .= "</td><td valign=top>\n";
      $ConcurrenceReportInput .= "<b>Include:</b>\n";
      $ConcurrenceReportInput .= "<br><b><input type=checkbox name=includeindividualcon value=T checked onClick=\"setIndividualConcurrenceReportDisabled('');\">Individual Responses</b>\n";
      $ConcurrenceReportInput .= "<br>" . nbspaces(5) . "<b><input type=checkbox name=includefirstreviewcon value=T checked>" . &FirstReviewName . " Review/Approval</b>\n";
      $ConcurrenceReportInput .= "<br>" . nbspaces(5) . "<b><input type=checkbox name=includesecondreviewcon value=T checked>" . &SecondReviewName . " Review/Approval</b>\n";
      $ConcurrenceReportInput .= "<br>" . nbspaces(5) . "<b><input type=checkbox name=includeapprovedcon value=T checked>Approved</b>\n";
      $ConcurrenceReportInput .= "<br><b><input type=checkbox name=includescrcon value=T checked>Summary Comment/Responses</b>\n";
      $ConcurrenceReportInput .= "</td></tr></table></td></tr></table><input type=button value=Submit align=center onClick=\"checkConcurrenceReport();\">\n";
      my $ConcurrenceReport = new Report_Forms;
      $ConcurrenceReport->label("Concurrence Report");
      $ConcurrenceReport->contents($ConcurrenceReportInput);
      
    
    my $commentsMenu = new Text_Menus;

    $commentsMenu->addMenu(name => "comments1", label => "Fully customizable comments report", contents => "javascript:submitForm('ad_hoc_reports','adhocsetup','comment');");
    $commentsMenu->addMenu(name => "comments2", label => "Standard comment report", contents => "javascript:submitForm('$form', 'reportselect', 'StandardCommentReport');");
    $commentsMenu->addMenu(name => "comments3", label => "Report on all comments related to DOE commitments", contents => "javascript:submitFormCGIResults('$form', 'report', 'DOECommitmentsReportTest');");
    $commentsMenu->addMenu(name => "comments4", label => "Report on all comments related to<br>potential or confirmed $CRDType changes", contents => "javascript:submitFormCGIResults('$form', 'report', 'CRDChangesReportTest');");
    $commentsMenu->addMenu(name => "comments5", label => $SummaryCommentReport->label(), contents => $SummaryCommentReport->contents(), title => $SummaryCommentReport->label());
    $commentsMenu->addMenu(name => "comments6", label => $DuplicateReport->label(), contents => $DuplicateReport->contents(), title => $DuplicateReport->label());
    $commentsMenu->addMenu(name => "comments7", label => $CommentsWithString->label(), contents => $CommentsWithString->contents(), title => $CommentsWithString->label());
    $commentsMenu->addMenu(name => "comments8", label => $ConcurrenceReport->label(), contents => $ConcurrenceReport->contents(), title => $ConcurrenceReport->label());

# Top menu
    $menu1->addMenu(name => "summary", label => "Overview Reports", status => 'open', contents => $summaryMenu->buildMenus(name=>'summaryMenu', type => 'bullets'), title => 'Overview Reports');
    $menu1->addMenu(name => "documents", label => "Documents/Commentors", contents => $commentDocumentMenu->buildMenus(name=>'commentDocumentMenu', type => 'bullets'), title => 'Documents/Commentors');
    $menu1->addMenu(name => "comments", label => "Comments/SCRs", contents => $commentsMenu->buildMenus(name=>'commentsMenu', type => 'bullets'), title => 'Comments/SCRs');
    #$menu1->addMenu(name => "commentors", label => "Commentors", contents => $commentorsMenu->buildMenus(name=>'commentorsMenu', type => 'bullets'), title => 'Commentors');

    my $menutype = ((defined($crdcgi->param('menutype'))) ? $crdcgi->param('menutype') : "table");
    $menu1->imageSource("$CRDImagePath/");
    print $menu1->buildMenus(name => 'ReportMenu1', type => $menutype);
    #print $menu1->buildMenus(name => 'ReportMenu1', type => 'tabs');
    #print $menu1->buildMenus(name => 'ReportMenu1', type => 'buttons');
    #print $menu1->buildMenus(name => 'ReportMenu1', type => 'bullets');
    
    #print "<input type=hidden name=menutype value=>\n";
    #print "<br><i>Use Menu Type <a href=\"javascript:document.$form.menutype.value='table';submitForm('$form','',0);\">Table</a>,"; 
    #print "<a href=\"javascript:document.$form.menutype.value='tabs';submitForm('$form','',0);\">Tabs</a>, ";
    #print "<a href=\"javascript:document.$form.menutype.value='buttons';submitForm('$form','',0);\">Buttons</a>, or ";
    #print "<a href=\"javascript:document.$form.menutype.value='bullets';submitForm('$form','',0);\">Bullets</a></i>\n";
  };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate a Status Report - Summary.",$@);
        print doAlertBox( text => $message);
    }
    
    return ($outputstring);
}



###################################################################################################################################
sub getReportDateTime {
###################################################################################################################################
    my @timedata = localtime(time);
    return(uc(get_date()) . " " . lpadzero($timedata[2],2) . ":" . lpadzero($timedata[1],2) . ":" . lpadzero($timedata[0],2));
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
# routine to generate a hash of lookup/values from a table
sub get_unique_values {
###################################################################################################################################
    my $dbh = $_[0];
    my $schema = $_[1];
    my $table = $_[2];
    my $lookups = $_[3];
    my $wherestatement='';      # optional
    if (defined($_[4])) {$wherestatement = $_[4];} # optional
    tie my %lookup_list, "Tie::IxHash";
    my @values;
    my $csr;
    my $sqlquery = "select UNIQUE $lookups from $schema.$table";
    if ($wherestatement gt " ") {
        $sqlquery .= " where $wherestatement";
    }
    $csr = $dbh->prepare($sqlquery);
    $csr->execute;
    while (@values = $csr->fetchrow_array) {
        $lookup_list{$values[0]} = $values[0];
    }
    $csr->finish;
    return (%lookup_list);
}


###################################################################################################################################
# routine to generate a hash of lookup/values from a table
sub get_unique_commentor_values {
###################################################################################################################################
    my $dbh = $_[0];
    my $schema = $_[1];
    my $lookup = $_[2];
    my $wherestatement='';      # optional
    if (defined($_[3])) {$wherestatement = $_[3];} # optional
    tie my %lookup_list, "Tie::IxHash";
    my @values;
    my $csr;
    my $sqlquery = "SELECT UNIQUE cmtr.$lookup FROM $schema.commentor cmtr, $schema.document doc, $schema.comments com ";
    $sqlquery .= "WHERE cmtr.id=doc.commentor AND doc.id=com.document ";
    if ($wherestatement gt " ") {
        $sqlquery .= " AND $wherestatement";
    }
    $csr = $dbh->prepare($sqlquery);
    $csr->execute;
    while (@values = $csr->fetchrow_array) {
        $lookup_list{$values[0]} = $values[0];
    }
    $csr->finish;
    return (%lookup_list);
}


###################################################################################################################################
sub doSummaryStatusReport {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        @_,
    );
    my $outputstring ='';
    my $sqlquery = '';
    my $csr;
    my @values;
    my $status;
    my $count;
    my @counts;
    my $message;
    
    $outputstring .= "<script language=javascript><!--\n";
    $outputstring .= "    document.title='$CRDType Comment/Response Database - Summary Status Report'\n";
    $outputstring .= "//--></script>\n";
    
    eval {
        $outputstring .= "<font size=-1>\n";
        $outputstring .= "<table border=0 width=670 cellpadding=0 cellspacing=0><tr><td>\n";
        $outputstring .= "<center><h2>$CRDType Comment/Response Database<br>Summary Status Report</h2>\n";
        $outputstring .= "<b>$args{'run_date'}</b></center><hr>\n";
        #
        $outputstring .= "<table border=0 width=100%><tr><td align=center valign=top>\n";
        #
        $outputstring .= "<table border=1><tr><td colspan=2 align=center><font size=-1><b>Documents</b></font></td></tr>\n";
        #
        @values = $dbh->selectrow_array("SELECT count(*) FROM $schema.document WHERE dupsimstatus = 1");
        $outputstring .= "<tr><td><font size=-1>Originals &nbsp; &nbsp; </font></td><td align=right><font size=-1> &nbsp; &nbsp; $values[0]</font></td></tr>\n";
        $count = $values[0];
        #
        @values = $dbh->selectrow_array("SELECT count(*) FROM $schema.document WHERE dupsimstatus = 2");
        $outputstring .= "<tr><td><font size=-1>Duplicates</font></td><td align=right><font size=-1> &nbsp; &nbsp; $values[0]</font></td></tr>\n";
        $count += $values[0];
        #
        @values = $dbh->selectrow_array("SELECT count(*) FROM $schema.document WHERE dupsimstatus = 3");
        $outputstring .= "<tr><td><font size=-1>Similar</font></td><td align=right><font size=-1> &nbsp; &nbsp; $values[0]</font></td></tr>\n";
        $count += $values[0];
        #
        @values = $dbh->selectrow_array("SELECT count(*) FROM $schema.document_entry");
        $outputstring .= "<tr><td colspan=2></td></tr>\n";
        $outputstring .= "<tr><td><font size=-1>Entry in progress &nbsp; &nbsp; </font></td><td align=right><font size=-1> &nbsp; &nbsp; $values[0]</font></td></tr>\n";
        #
        $outputstring .= "<tr><td colspan=2></td></tr>\n";
        $outputstring .= "<tr><td><font size=-1><b>Total</b></font></td><td align=right><font size=-1> &nbsp; &nbsp; <b>" . ($count + $values[0]) . "</b></font></td></tr>\n";
        #
        $outputstring .= "</table>\n";
        #
        $outputstring .= "</td><td align=center valign=top>\n";

        #
        $outputstring .= "<table border=1><tr><td colspan=2 align=center><font size=-1><b>Comments</b></font></td></tr>\n";
        #
        @values = $dbh->selectrow_array("SELECT count(*) FROM $schema.comments WHERE dupsimstatus = 1");
        $outputstring .= "<tr><td><font size=-1><font size=-1>Originals &nbsp; &nbsp; </font></td><td align=right><font size=-1> &nbsp; &nbsp; $values[0]</font></td></tr>\n";
        $count = $values[0];
        #
        @values = $dbh->selectrow_array("SELECT count(*) FROM $schema.comments WHERE dupsimstatus = 2");
        $outputstring .= "<tr><td><font size=-1>Duplicates</font></td><td align=right><font size=-1> &nbsp; &nbsp; $values[0]</font></td></tr>\n";
        $count += $values[0];
        #
        @values = $dbh->selectrow_array("SELECT count(*) FROM $schema.comments_entry");
        $outputstring .= "<tr><td colspan=2></td></tr>\n";
        $outputstring .= "<tr><td><font size=-1>Entry in progress &nbsp; &nbsp; </font></td><td align=right><font size=-1> &nbsp; &nbsp; $values[0]</font></td></tr>\n";
        #
        $outputstring .= "<tr><td colspan=2></td></tr>\n";
        $outputstring .= "<tr><td><font size=-1><b>Total</b></font></td><td align=right><font size=-1> &nbsp; &nbsp; <b>" . ($count + $values[0]) . "</b></font></td></tr>\n";
        #
        $outputstring .= "</table>\n";
        #
        $outputstring .= "</td></tr></table>\n";
        
        #
        $outputstring .= "<br><table border=1 width=75% align=center><tr><td colspan=3 align=center><font size=-1><b>Comments in Bins</b></font></td></tr>\n";
        #
        $sqlquery = "SELECT id,name,NVL(parent,0) FROM $schema.bin";
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        while (@values = $csr->fetchrow_array) {
            $counts[$values[0]][0] = 0;
            $counts[$values[0]][1] = $values[2];
        }
        $csr->finish;
        
        $sqlquery = "SELECT bin FROM $schema.comments";
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        while (@values = $csr->fetchrow_array) {
            my $binid = $values[0];
            while ($counts[$binid][1] != 0) {
                $binid = $counts[$binid][1];
            }
            ++$counts[$binid][0];
        }
        $csr->finish;
        $sqlquery = "SELECT id,name,coordinator FROM $schema.bin WHERE NVL(parent,0) = 0 ORDER BY name";
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        while (@values = $csr->fetchrow_array) {
            $outputstring .= "<tr><td align=right><font size=-1>$counts[$values[0]][0]</font></td><td><font size=-1> &nbsp; &nbsp; $values[1]</font></td>\n";
            $outputstring .= "<td><font size=-1>" . get_fullname($dbh,$schema, $values[2]) . "</font></td></tr>\n";
        }
        $csr->finish;
        @values = $dbh->selectrow_array("SELECT count(*) FROM $schema.comments");
        $outputstring .= "<tr><td align=right><font size=-1><B>$values[0]</B></font></td><td colspan=2><font size=-1> &nbsp; &nbsp; <B>Total</B></font></td></tr>\n";
        
        $outputstring .= "</table></font>\n";
        $outputstring .= "</td></tr></table></font>\n";
        
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate a Status Report - Summary.",$@);
        print doAlertBox( text => $message);
    }
    
    return ($outputstring);
}


###################################################################################################################################
sub doDocumentCommentCountByTypeReport {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        combineHearings => "T",
        @_,
    );
    my $outputstring ='';
    my $sqlquery = '';
    my @values;
    my $typeCount = 0;
    my $documentCount = 0;
    my $commentCount = 0;
    my $message;
    my %DocumentTypes;
    
    $outputstring .= "<script language=javascript><!--\n";
    $outputstring .= "    document.title='$CRDType Comment/Response Database - Document Comment Count By Type Report'\n";
    $outputstring .= "//--></script>\n";
    
    eval {
        if ($args{combineHearings} eq 'T') {
            $typeCount = 7;
        } else {
            @values = $dbh->selectrow_array("SELECT count(*) FROM $schema.document_type");
            $typeCount = $values[0];
        }
        %DocumentTypes = get_lookup_values($args{dbh}, $args{schema}, 'document_type', 'id', 'name', "id <= $typeCount");
        
        #$outputstring .= "<font size=-1>\n";
        $outputstring .= "<table border=0 width=670 cellpadding=0 cellspacing=0><tr><td>\n";
        $outputstring .= "<center><h2>$CRDType Comment/Response Database<br>Document and Comment Count by Document Type</h2>\n";
        $outputstring .= "<b>$args{'run_date'}</b></center><hr>\n";
        
        $outputstring .= "<table border=0 align=center>\n";
        $outputstring .= "<tr><td><u>Document Type</u></td><td>" . nbspaces(5) . "</td><td colspan=3><u>Documents</u></td><td>" . nbspaces(5) . "</td><td colspan=3><u>Comments</u></td></tr>\n";
        
        foreach my $i (1..$typeCount) {
        
            $DocumentTypes{$i} =~ s/(\w+)/\u\L$1/g;
            $DocumentTypes{$i} =~ s/Am$/AM/g;
            $DocumentTypes{$i} =~ s/Pm$/PM/g;
        
            $outputstring .= "<tr><td>" . $DocumentTypes{$i} . "</td><td>&nbsp;</td>";
            @values = $dbh->selectrow_array("SELECT count(*) FROM $schema.document doc WHERE doc.documenttype = $i");
            $outputstring .= "<td>&nbsp;</td><td align=right>" . ((defined($values[0])) ? $values[0] : 0) . "</td><td>" . nbspaces(2) . "</td><td>&nbsp;</td>";
            $documentCount += $values[0];
            @values = $dbh->selectrow_array("SELECT count(*) FROM $schema.document doc, $schema.comments com WHERE (doc.id = com.document) AND doc.documenttype = $i");
            $outputstring .= "<td>&nbsp;</td><td align=right>" . ((defined($values[0])) ? $values[0] : 0) . "</td><td>" . nbspaces(2) . "</td></tr>\n";
            $commentCount += $values[0];
        }
        
        if ($args{combineHearings} eq 'T') {
            $outputstring .= "<tr><td>Hearing Transcript (All)</td><td>&nbsp;</td>";
            @values = $dbh->selectrow_array("SELECT count(*) FROM $schema.document doc, $schema.document_type dt WHERE doc.documenttype=dt.id AND dt.name LIKE '%TRANSCRIPT%'");
            $outputstring .= "<td>&nbsp;</td><td align=right>" . ((defined($values[0])) ? $values[0] : 0) . "</td><td>&nbsp;</td><td>&nbsp;</td>";
            $documentCount += $values[0];
            @values = $dbh->selectrow_array("SELECT count(*) FROM $schema.document doc, $schema.document_type dt, $schema.comments com WHERE (doc.id = com.document) AND (doc.documenttype=dt.id) AND dt.name LIKE '%TRANSCRIPT%'");
            $outputstring .= "<td>&nbsp;</td><td align=right>" . ((defined($values[0])) ? $values[0] : 0) . "</td><td>&nbsp;</td></tr>\n";
            $commentCount += $values[0];
            
            $outputstring .= "<tr><td>Hearing Submission (All)</td><td>&nbsp;</td>";
            @values = $dbh->selectrow_array("SELECT count(*) FROM $schema.document doc, $schema.document_type dt WHERE doc.documenttype=dt.id AND dt.name LIKE '%SUBMISSION%'");
            $outputstring .= "<td>&nbsp;</td><td align=right>" . ((defined($values[0])) ? $values[0] : 0) . "</td><td>&nbsp;</td><td>&nbsp;</td>";
            $documentCount += $values[0];
            @values = $dbh->selectrow_array("SELECT count(*) FROM $schema.document doc, $schema.document_type dt, $schema.comments com WHERE (doc.id = com.document) AND (doc.documenttype=dt.id) AND dt.name LIKE '%SUBMISSION%'");
            $outputstring .= "<td>&nbsp;</td><td align=right>" . ((defined($values[0])) ? $values[0] : 0) . "</td><td>" . nbspaces(1) . "</td></tr>\n";
            $commentCount += $values[0];
        }
        
        $outputstring .= "<tr><td colspan=9>&nbsp;</td></tr>\n";
        $outputstring .= "<tr><td>Total</td><td>&nbsp;</td><td>&nbsp;</td><td align=right>$documentCount</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td align=right>$commentCount</td><td>&nbsp;</td></tr>\n";
        $outputstring .= "</table>\n";

        $outputstring .= "</td></tr></table>\n";
        #$outputstring .= "</font>\n";
        
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate a Document Comment Count By Type report.",$@);
        print doAlertBox( text => $message);
    }
    
    return ($outputstring);
}

###################################################################################################################################
sub getBinTree {
###################################################################################################################################
    # generate a list of bins that have 'root_bin' as a parent, the list is terminated with a 0
    my $hashref = $_[0];
    my %args = %$hashref;
    my $outputstring = '';
    
    my $sqlquery = "SELECT UNIQUE id FROM $args{'schema'}.bin START WITH id = $args{'root_bin'} CONNECT BY PRIOR id = parent";
    my $csr = $args{'dbh'}->prepare($sqlquery);
    my $status = $csr->execute;
    my @values;
    while (@values = $csr->fetchrow_array) {
        $outputstring .= "$values[0],";
    }
    $outputstring = "0," . $outputstring . "0";
    return ($outputstring);
    
}


###################################################################################################################################
sub getBinRoot {
###################################################################################################################################
    # get the top level bin for a given bin
    my %args = (
        dbh => '',
        schema => '',
        bin => 0,
        @_,
    );
    my $outputstring = '';
    
    my $sqlquery = "SELECT id, name FROM $args{'schema'}.bin WHERE parent IS NULL AND id IN (SELECT UNIQUE id FROM $args{'schema'}.bin START WITH id = $args{'bin'} CONNECT BY PRIOR parent = id)";
    my $csr = $args{'dbh'}->prepare($sqlquery);
    my $status = $csr->execute;
    my ($id, $name) = $csr->fetchrow_array;
    return ($id, $name);
    
}


###################################################################################################################################
sub isBinMember {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        testUser => 0,
        binList => '0',
        @_,
    );
    my @row;
    my @values;
    my $bincount = 0;

    @row = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.bin WHERE (coordinator=$args{'testUser'} OR nepareviewer=$args{'testUser'}) AND (id IN ($args{'binList'}))");
    @values = $args{'dbh'}->selectrow_array("SELECT UNIQUE count(*) FROM $args{'schema'}.default_tech_reviewer WHERE (reviewer = $args{'testUser'}) AND (bin IN ($args{'binList'})) AND (bin NOT IN (SELECT id FROM $args{'schema'}.bin WHERE coordinator=$args{'testUser'} OR nepareviewer=$args{'testUser'}))");

    $bincount = $row[0] + $values[0];
    
    return ((($bincount >= 1) ? 1 : 0));
}



###################################################################################################################################
sub doBinStatusReportTest {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        crdcgi => '',
        @_,
    );
        
    my $outputstring ='';
    my $message;
    my @values;
    my $count = 0;
    my $binlist = '';
    my $isuserinbin = 0;
    my $checkuser = "";
    my $checkuser2 = "";
    
    eval {
        my $dateTest = '';
        my $checkbins = '';
        my $checkbins2 = '';
        my $duptest = '';
        if ($args{'root_bin'} != 0) {
            $checkbins = "bin IN (" . getBinTree(\%args) . ")";
            $checkbins2 = "com.bin IN (" . getBinTree(\%args) . ")";
        } else {
            $checkbins = "1 = 1";
            $checkbins2 = "1 = 1";
        }
    
        $checkuser = "";
        if ($args{'displayUser'} != 0) {
            if ($args{'root_bin'} != 0) {
                $binlist = getBinTree(\%args);
                $isuserinbin = isBinMember (dbh => $args{'dbh'}, schema => $args{'schema'}, testUser => $args{'displayUser'}, binList => $binlist);
            } else {
                $isuserinbin = 1;
            }
            $checkuser = " AND (com.document = rs.document) AND (com.commentnum = rs.commentnum) AND (";
            $checkuser .= "((rs.responsewriter = $args{'displayUser'}) AND (rs.status IN (2,4,5))) OR ";
            $checkuser .= "(($args{'displayUser'} = bin.coordinator) AND (rs.status IN (1,6))) OR ";
            $checkuser .= "(($args{'displayUser'} = bin.nepareviewer) AND (rs.status = 7)) OR ";
            $checkuser .= "((rs.status = 3) AND ($args{'displayUser'} IN (SELECT rvw.reviewer FROM $args{'schema'}.technical_review rvw WHERE (rvw.document = com.document) AND (rvw.commentnum = com.commentnum))))";
            $checkuser .= ")";

            $checkuser2 = ",$args{'schema'}.response_version rs";
                
        } else {
            $isuserinbin = 1;
        }
    
        if ($args{'selectDates'} eq 'T') {
            $dateTest = " AND (TO_CHAR(com.proofreaddate,'YYYYMMDD') BETWEEN '$args{'beginDate'}' AND '$args{'endDate'}') ";
        } else {
            $dateTest = ' ';
        }
        if ($args{'displayDuplicates'} eq 'F') {
            $duptest = " AND com.dupsimstatus = 1";
        }
        @values = $dbh->selectrow_array("SELECT count(*) FROM $args{'schema'}.comments com, $args{'schema'}.bin bin $checkuser2 WHERE (com.bin=bin.id) AND ($checkbins2)" . $dateTest . $checkuser . $duptest);
        $count = $values[0];
        if ($args{'selectDates'} eq 'T') {
            $dateTest = " AND (TO_CHAR(dateapproved,'YYYYMMDD') BETWEEN '$args{'beginDate'}' AND '$args{'endDate'}') ";
        } else {
            $dateTest = ' ';
        }
        @values = $dbh->selectrow_array("SELECT count(*) FROM $args{'schema'}.summary_comment WHERE ($checkbins)" . $dateTest);
        $count += $values[0];
        if ($count == 0 || $isuserinbin != 1) {
            if ($args{'selectDates'} eq 'T') {
                $dateTest = " For Selected Dates";
            }
            $outputstring .= "<script language=javascript><!--\n";
            if ($isuserinbin != 1) {
                $outputstring .= "    alert('" . get_fullname($args{'dbh'},$args{'schema'},$args{'displayUser'}) . " is not assigned in Bin:\\n" . get_value($dbh,$schema,'bin','name', "id=$args{'root_bin'}") . "')\n";
            } else {
                $outputstring .= "    alert('No Comments Were Found" . $dateTest . " in Bin:\\n" . (($args{'root_bin'}>0) ? get_value($dbh,$schema,'bin','name', "id=$args{'root_bin'}") : "All Bins") . "')\n";
            }
            $outputstring .= "//--></script>\n";
            
        } else {
            $outputstring .= "<input type=hidden name=bin value=$args{'root_bin'}>\n";
            $outputstring .= "<input type=hidden name=user2 value=$args{'displayUser'}>\n";
            $outputstring .= "<input type=hidden name=displaycomments value=$args{'displayComments'}>\n";
            $outputstring .= "<input type=hidden name=displayresponses value=$args{'displayResponses'}>\n";
            $outputstring .= "<input type=hidden name=displayduplicates value=$args{'displayDuplicates'}>\n";
            $outputstring .= "<input type=hidden name=displaytechreview value=$args{'displayTechReview'}>\n";
            $outputstring .= "<input type=hidden name=binstatusselectdates value=$args{'selectDates'}>\n";
            $outputstring .= "<input type=hidden name=binstatusbegindate value=$args{'beginDate'}>\n";
            $outputstring .= "<input type=hidden name=binstatusenddate value=$args{'endDate'}>\n";
            $outputstring .= "<script language=javascript><!--\n";
            $outputstring .= "    submitFormNewWindow('$form', 'report','BinStatusReport');\n";
            $outputstring .= "//--></script>\n";
        }
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"check comment count before generating a Comment Report by Bin.",$@);
        print doAlertBox( text => $message);
    }
    
    return($outputstring);
}

###################################################################################################################################
sub doBinStatusReport {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        crdcgi => '',
        displayEmptyBins => 'T',
        @_,
    );
        
    my $outputstring ='';
    my $binsqlquery = '';
    my $sqlquery = '';
    my $sqlquery2 = '';
    my $bincsr;
    my $csr;
    my $csr2;
    my @binvalues;
    my @values;
    my @values2;
    my @values3;
    my @row;
    my $status;
    my $binid='';
    my $rootbin=0;
    my $lastrootbin=0;
    my $count=0;
    my $counts=0;
    my $commentcount=0;
    my $summarycommentcount=0;
    my $message;
    my $binlist;
    my $bincount;
    my $binnumber='';
    my $parentbin;
    my $dateTest = '';
    
    my $currLine=0;
    
    $outputstring .= "<script language=javascript><!--\n";
    $outputstring .= "    document.title='$CRDType Comment/Response Database - Summary Status Report'\n";
    $outputstring .= "//--></script>\n";
    
    eval {
    
        my $checkbins = '';
        my $checkuser = '';
        my $checkresponse = '';
        my $duptest = '';
        if ($args{'root_bin'} != 0) {
            $checkbins = "bin IN (" . getBinTree(\%args) . ")";
        } else {
            $checkbins = "1 = 1";
        }

        $outputstring .= "<table border=0 width=670 cellpadding=0 cellspacing=0><tr><td>\n";
        $outputstring .= "<center><font size=+2>$CRDType Comment/Response Database<br>Bin Status Report</font><font size=-1><br><br></font>";
        if ($args{'displayUser'} > 0) {
            $outputstring .= "<font size=+1>User: " . get_fullname($args{'dbh'},$args{'schema'},$args{'displayUser'}) . "</font><br><br>\n";
        }
        if ($args{'root_bin'} > 0) {
            $outputstring .= "<font size=+1>Bin: " . get_value($args{'dbh'},$args{'schema'},'bin', 'name', "id = $args{'root_bin'}");
            $outputstring .= "</font><br>\n";
            $outputstring .= "<font size=+1>Bin Coordinator: " . get_fullname($args{'dbh'},$args{'schema'},(get_value($args{'dbh'},$args{'schema'},'bin','coordinator',"id=$args{'root_bin'}"))) . "</font><font size=-1><br><br></font>\n";
        } else {
            $outputstring .= "<font size=+1>All Bins</font><br>\n";
        }
        if ($args{'selectDates'} eq 'T') {
            $outputstring .= "Selected Dates - ";
            $outputstring .= "From: " . uc(get_date(substr($args{'beginDate'},4,2) . "/" . substr($args{'beginDate'},6,2) . "/" . substr($args{'beginDate'},0,4))) . " ";
            $outputstring .= "To: " . uc(get_date(substr($args{'endDate'},4,2) . "/" . substr($args{'endDate'},6,2) . "/" . substr($args{'endDate'},0,4))) . "<br><br>";
        }
        $outputstring .= "<font size=-1>$args{'run_date'}</font></center>\n";

        #
        if ($args{'root_bin'} != 0) {
            $checkbins = "id IN (" . getBinTree(\%args) . ")";
        } else {
            $checkbins = "1 = 1";
        }
        $binsqlquery = "SELECT id,name FROM $schema.bin WHERE ($checkbins) ORDER BY name";
        $bincsr = $args{'dbh'}->prepare($binsqlquery);
        $status = $bincsr->execute;
        while (@binvalues = $bincsr->fetchrow_array) {
            if ($args{'displayUser'} == 0 || ($args{'displayUser'} != 0 && isBinMember(dbh => $args{'dbh'}, schema => $args{'schema'}, testUser => $args{'displayUser'}, binList => "$binvalues[0]"))) {
                $binid = $binvalues[0];
                $binnumber = substr($binvalues[1],0,index($binvalues[1],' ',1));
                
                # process comments
                if ($args{'displayUser'} != 0) {
                    $checkuser = ", $args{'schema'}.response_version rs";
                } else {
                    $checkuser = "";
                }
                $sqlquery = "SELECT com.document,com.commentnum,com.text,com.bin,bin.name,bin.coordinator,NVL(bin.parent,0),com.dupsimstatus,com.dupsimdocumentid,com.dupsimcommentid,NVL(com.summary,0),NVL(TO_CHAR(com.datedue,'DD-MON-YYYY'),' ') FROM $args{'schema'}.comments com, $args{'schema'}.bin bin $checkuser WHERE (com.bin=bin.id) AND (bin.id = $binid)";
                $sqlquery2 = "SELECT count(*) FROM $args{'schema'}.comments com, $args{'schema'}.bin bin $checkuser WHERE (com.bin=bin.id) AND (bin.id = $binid)";
                if ($args{'selectDates'} eq 'T') {
                    $dateTest = " AND (TO_CHAR(com.proofreaddate,'YYYYMMDD') BETWEEN '$args{'beginDate'}' AND '$args{'endDate'}') ";
                } else {
                    $dateTest = ' ';
                }
                $checkuser = "";
                if ($args{'displayUser'} != 0) {
                    $checkuser = " AND (com.document = rs.document) AND (com.commentnum = rs.commentnum) AND (";
                    $checkuser .= "((rs.responsewriter = $args{'displayUser'}) AND (rs.status IN (2,4,5))) OR ";
                    $checkuser .= "(($args{'displayUser'} = bin.coordinator) AND (rs.status IN (1,6))) OR ";
                    $checkuser .= "(($args{'displayUser'} = bin.nepareviewer) AND (rs.status = 7)) OR ";
                    $checkuser .= "((rs.status = 3) AND ($args{'displayUser'} IN (SELECT rvw.reviewer FROM $args{'schema'}.technical_review rvw WHERE (rvw.document = com.document) AND (rvw.commentnum = com.commentnum))))";
                    $checkuser .= ")";
                }
                if ($args{'commentsWithResponses'} eq 'T') {
                    $checkresponse = " AND ((TO_CHAR(com.document,'099999') || '/' || TO_CHAR(com.commentnum,'0999')) IN ";
                    $checkresponse .= "(SELECT TO_CHAR(document,'099999') || '/' || TO_CHAR(commentnum,'0999') FROM $args{'schema'}.response_version WHERE ";
                    $checkresponse .= "originaltext is not null AND dupsimstatus = 1))";
                }
                if ($args{'displayDuplicates'} eq 'F') {
                    $duptest = " AND com.dupsimstatus = 1";
                }
                $sqlquery .= "$checkuser $dateTest $duptest $checkresponse ORDER BY bin.name,com.document,com.commentnum";
                $sqlquery2 .= "$checkuser $dateTest $duptest $checkresponse ORDER BY bin.name,com.document,com.commentnum";
                if ($args{'displayEmptyBins'} eq 'T') {
                    $outputstring .= "<hr><font size=+1>$binvalues[1]<font>\n";
                } else {
                    @row = $dbh->selectrow_array($sqlquery2);
                    if ($row[0] >0) {
                        $outputstring .= "<hr><font size=+1>$binvalues[1]<font>\n";
                    }
                }
                $csr = $args{'dbh'}->prepare($sqlquery);
                $status = $csr->execute;
                $commentcount=0;
                
                while (@values = $csr->fetchrow_array) {
                    $commentcount++;
                    print "<!-- Keep alive, bin $binvalues[0], count $commentcount -->\n";
                    $outputstring .= "<hr><table border=0 width=670><tr><td>\n";
                    @values2 = $dbh->selectrow_array("SELECT version,status,originaltext,lastsubmittedtext,responsewriter,TO_CHAR(dateupdated,'DD-MON-YYYY HH24:MI:SS') FROM $schema.response_version WHERE document=$values[0] AND commentnum=$values[1] ORDER BY version DESC");
                    $outputstring .= "<font size=-1>$CRDType" . lpadzero($values[0],6) . " / " . lpadzero($values[1],4) . " - Bin: $binnumber</font>";
                    $counts++;
                    if ($values[7] == 1 && $values[10] == 0 && $#values2 >1) {
                        $outputstring .= "<font size=-1> - Status: " . get_value ($dbh, $schema, 'response_status','name',"id=$values2[1]") . "</font>\n";
                        if ($values2[1] != 1) {
                            $outputstring .= "<font size=-1><br>Response Writer: " . get_fullname($dbh,$schema,$values2[4]) . " &nbsp; &nbsp; Last Updated: $values2[5]</font>\n";
                            @values3 = $dbh->selectrow_array("SELECT count(*) FROM $schema.technical_reviewer WHERE document=$values[0] AND commentnum=$values[1]");
                            $count = $values3[0];
                            $outputstring .= "<font size=-1><br>Assigned Technical Reviewer" . (($count != 1) ? "s" : "") . ": ";
                            $sqlquery2 = "SELECT reviewer FROM $schema.technical_reviewer WHERE document=$values[0] AND commentnum=$values[1]";
                            $csr2 = $dbh->prepare($sqlquery2);
                            $status = $csr2->execute;
                            while (@values3 = $csr2->fetchrow_array) {
                                $outputstring .= " " . get_fullname($dbh,$schema, $values3[0]) . ",";
                            }
                            chop($outputstring);
                            if ($values[11] gt " ") {
                                $outputstring .= "<br>Due: $values[11]\n";
                            }
                            $outputstring .= "</font>\n";
                            $csr2->finish;
                        }
                    }
                    if ($values[10] != 0) {
                        $outputstring .= "<font size=-1><br><i>(Summarized by SCR" . lpadzero($values[10],4) . ")</i></font>";
                    } elsif ($values[7] == 2) {
                        $outputstring .= "<font size=-1><br><i>(Duplicate of $CRDType" . lpadzero($values[8],6) . " / " . lpadzero($values[9],4) . ")</i></font>";
                    }
                    $outputstring .= "</td></tr></table>\n";
                    if ($args{'displayComments'} eq 'T') {
                        $values[2] =~ s/\n/<br>/g;
                        $values[2] =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<table border=0 width=670><tr><td><font size=-1><u>Comment:</u><br>$values[2]</font></td></tr></table>\n";
                    }
                    if ($args{'displayResponses'} eq 'T' && $values[7] == 1) {
                        my $responseText = lastSubmittedText(dbh => $dbh, schema => $schema, documentID => $values[0], commentID => $values[1]);
                        if (defined($responseText) && $responseText gt '') {
                            $responseText =~ s/\n/<br>/g;
                            $responseText =~ s/  /&nbsp;&nbsp;/g;
                            $outputstring .= "<table border=0 width=670><tr><td><font size=-1><u>Response:</u><br>$responseText</font></td></tr></table>\n";
                        }
                        #if (defined($values2[3]) && $values2[3] gt '') {
                        #    $values2[3] =~ s/\n/<br>/g;
                        #    $values2[3] =~ s/  /&nbsp;&nbsp;/g;
                        #    $outputstring .= "<table border=0 width=670><tr><td><font size=-1><u>Response:</u><br>$values2[3]</font></td></tr></table>\n";
                        #} elsif (defined($values2[2]) && $values2[2] gt '') {
                        #    $values2[2] =~ s/\n/<br>/g;
                        #    $values2[2] =~ s/  /&nbsp;&nbsp;/g;
                        #    $outputstring .= "<table border=0 width=670><tr><td><font size=-1><u>Response:</u><br>$values2[2]</font></td></tr></table>\n";
                        #}
                    }
                    if ($args{'displayTechReview'} eq 'T') {
                        my $trcsr = $args{dbh}->prepare("SELECT tr.document,tr.commentnum,tr.reviewer,tr.version,tr.status,tr.text,TO_CHAR(tr.dateupdated,'DD-MON-YYYY HH24:MI:SS'),u.firstname,u.lastname FROM $schema.technical_review tr, $schema.users u WHERE tr.reviewer = u.id AND tr.document=$values[0] AND tr.commentnum=$values[1] AND tr.status <> 4 ORDER BY u.username");
                        $status = $trcsr->execute;
                        while (@values3 = $trcsr->fetchrow_array) {
                            $outputstring .= "<table border=0 width=670>\n";
                            $outputstring .= "<tr><td><font size=-1>Technical Reviewer: $values3[7] $values3[8]" . nbspaces(5) . "Status: &nbsp;" . get_value($args{dbh},$args{schema},'technical_review_status','name',"id = $values3[4]") . "</font></td></tr>\n";
                            if (defined($values3[5]) && $values[5] gt ' ') {
                                $values3[5] =~ s/\n/<br>/g;
                                $values3[5] =~ s/  /&nbsp;&nbsp;/g;
                                $outputstring .= "<tr><td><font size=-1><u>Technical Review Text:</u><br>$values3[5]</font></td></tr>\n";
                            }
                            $outputstring .= "</table><br>\n";
                        }
                        $trcsr->finish;
                    }


                }
                $csr->finish;
                
                # process summary comments
                if ($args{'displayUser'} == 0) {
                    if ($args{'selectDates'} eq 'T') {
                        $dateTest = " AND (TO_CHAR(dateapproved,'YYYYMMDD') BETWEEN '$args{'beginDate'}' AND '$args{'endDate'}') ";
                    } else {
                        $dateTest = ' ';
                    }
                    $sqlquery = "SELECT id,title,commenttext,responsetext,TO_CHAR(dateapproved,'DD-MON-YYYY HH24:MI:SS'),hascommitments,changeimpact,changecontrolnum,createdby,datecreated,proofreadby,proofreaddate,bin,responsewriter FROM $args{'schema'}.summary_comment WHERE (bin = $binid) $dateTest ORDER BY id";
                    $csr = $args{'dbh'}->prepare($sqlquery);
                    $status = $csr->execute;
                    $summarycommentcount=0;
                    
                    while (@values = $csr->fetchrow_array) {
                        $summarycommentcount++;
                        $outputstring .= "<hr><table border=0 width=670><tr><td>\n";
                        $outputstring .= "<font size=-1>SCR" . lpadzero($values[0],4) . nbspaces(3) . "Bin: $binnumber" . nbspaces(3) . "Title: $values[1]</font>";
                        $outputstring .= "<font size=-1><br>Summary Writer: " . get_fullname($dbh,$schema,$values[13]) . ((defined($values[4]) && $values[4] gt " ") ? " &nbsp; &nbsp; Date Approved: $values[4]" : "") . "</font>\n";
                        $counts++;
                        $outputstring .= "</td></tr></table>\n";
                        if ($args{'displayComments'} eq 'T') {
                            $values[2] =~ s/\n/<br>/g;
                            $values[2] =~ s/  /&nbsp;&nbsp;/g;
                            $outputstring .= "<table border=0 width=670><tr><td><font size=-1><u>Comment:</u><br>$values[2]</font></td></tr></table>\n";
                        }
                        if ($args{'displayResponses'} eq 'T') {
                            if (defined($values[3]) && $values[3] gt '') {
                                $values[3] =~ s/\n/<br>/g;
                                $values[3] =~ s/  /&nbsp;&nbsp;/g;
                                $outputstring .= "<table border=0 width=670><tr><td><font size=-1><u>Response:</u><br>$values[3]</font></td></tr></table>\n";
                            }
                        }
                    }
                    $csr->finish;
                }
            
                #
                if ($commentcount == 0 && $summarycommentcount == 0 && $args{'displayEmptyBins'} eq 'T') {
                    $outputstring .= "<br>" . nbspaces(10) . "<i>No comments " . (($args{'displayUser'} == 0) ? "or summary comments " : "") . "in bin</i>\n";
                }
            }
        }
        
        $outputstring .= "<hr><font size=-1><b>$counts comment" . (($counts != 1) ? "s were" : " was") . " printed.</b></font>\n";
        $outputstring .= "</td></tr></table>\n";
    
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate a Comment Report by Bin.",$@);
        print doAlertBox( text => $message);
    }
    
    return ($outputstring);
}


###################################################################################################################################
sub doBinStatisticsReport {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        @_,
    );
    
    no integer;
    
    my $outputstring ='';
    my $binsqlquery = '';
    my $sqlquery = '';
    my $bincsr;
    my $csr;
    my $csr2;
    my @binvalues;
    my @values;
    my @row;
    my $status;
    my @counts;
    my $key;
    my $message;
    my $binlist;
    tie my %response_status, "Tie::IxHash";

    $outputstring .= "<script language=javascript><!--\n";
    $outputstring .= "    document.title='$CRDType Comment/Response Database - Bin Statistics Report'\n";
    $outputstring .= "//--></script>\n";
    
    eval {
    
        $outputstring .= "<table border=0 width=670 cellpadding=0 cellspacing=0><tr><td>\n";
        $outputstring .= "<center><font size=+2>$CRDType Comment/Response Database<br>Bin Statistics Report</font><font size=-1><br><br></font>";
        $outputstring .= "<font size=-1>$args{'run_date'}</font>\n";
        %response_status = get_lookup_values($args{'dbh'},$args{'schema'},'response_status','id','name','1=1 ORDER BY name');
        if ($args{'root_bin'} eq '0') {
           $binsqlquery = "SELECT id,name,coordinator FROM $args{'schema'}.bin WHERE NVL(parent,0) = 0 ORDER BY name";
        } else {
           $binsqlquery = "SELECT id,name,coordinator FROM $args{'schema'}.bin WHERE (NVL(parent,0) = 0) AND (bin.id IN (" . getBinTree(\%args) . ")) ORDER BY name";
        }
        $bincsr = $args{'dbh'}->prepare($binsqlquery);
        $status = $bincsr->execute;
        while (@binvalues = $bincsr->fetchrow_array) {
            foreach $key (keys %response_status) {
                $counts[$key] =0;
            }
            $counts[0] =0;
            
            $outputstring .= "<hr><table border=0 width=100%><tr><td>\n";
            $outputstring .= "<font size=+1><b>$binvalues[1]</b></font><br>\n";
            $outputstring .= "Bin Coordinator: " . get_fullname($args{'dbh'},$args{'schema'},$binvalues[2]) . "<br><br>\n";
            $args{'root_bin'} = $binvalues[0];
            $binlist = getBinTree(\%args);
            $sqlquery = "SELECT document,commentnum FROM $args{'schema'}.comments WHERE (dupsimstatus =1) AND (NVL(summary,0) = 0) AND (bin IN ( $binlist ))";
            $csr = $args{'dbh'}->prepare($sqlquery);
            $status = $csr->execute;
            while (@values = $csr->fetchrow_array) {
                $counts[get_value($args{'dbh'},$args{'schema'},'response_version','status', "document=$values[0] AND commentnum=$values[1] ORDER BY version DESC")] ++;
                $counts[0]++;
            }
            $csr->finish;
            
            @row = $dbh->selectrow_array("SELECT count(*) FROM $args{'schema'}.comments WHERE dupsimstatus = 2 AND (bin IN ( $binlist ))");
            $counts[14] = $row[0];
            @row = $dbh->selectrow_array("SELECT count(*) FROM $args{'schema'}.comments WHERE (NVL(summary,0) != 0) AND (bin IN ( $binlist ))");
            $counts[15] = $row[0];
            ##$outputstring .= ($counts[0] + $counts[15]) . " original comment" . (($counts[0] != 1) ? "s" : "") . " and $counts[14] duplicate comment" . (($counts[14]!=1)? "s" : "") . " for a total of " . ($counts[14] + $counts[15] + $counts[0]) . "<br><br>\n";
            $outputstring .= "<table border=0>\n";
            
            $counts[0] = $counts[14] + $counts[15] + $counts[0];
            
            $outputstring .= "<tr><td align=right>" . sprintf("%5.2f",(($counts[14]/(($counts[0]!=0)? $counts[0] : 1))*100.0)) . "% &nbsp; &nbsp; </td><td>Duplicate</td></tr>\n";
            $outputstring .= "<tr><td align=right>" . sprintf("%5.2f",(($counts[15]/(($counts[0]!=0)? $counts[0] : 1))*100.0)) . "% &nbsp; &nbsp; </td><td>Summarized</td></tr>\n";
            $outputstring .= "<tr><td align=right>" . sprintf("%5.2f",(($counts[9]/(($counts[0]!=0)? $counts[0] : 1))*100.0)) . "% &nbsp; &nbsp; </td><td>Approved</td></tr>\n";
            $outputstring .= "<tr><td align=right>" . sprintf("%5.2f",(($counts[8]/(($counts[0]!=0)? $counts[0] : 1))*100.0)) . "% &nbsp; &nbsp; </td><td>" . &SecondReviewName . " Review</td></tr>\n";
            $outputstring .= "<tr><td align=right>" . sprintf("%5.2f",(($counts[7]/(($counts[0]!=0)? $counts[0] : 1))*100.0)) . "% &nbsp; &nbsp; </td><td>" . &FirstReviewName . " Review</td></tr>\n";
            $outputstring .= "<tr><td align=right>" . sprintf("%5.2f",(($counts[6]/(($counts[0]!=0)? $counts[0] : 1))*100.0)) . "% &nbsp; &nbsp; </td><td>Awaiting Bin Coordinator Acceptance</td></tr>\n";
            $outputstring .= "<tr><td align=right>" . sprintf("%5.2f",((($counts[2]+$counts[3]+$counts[4]+$counts[5])/(($counts[0]!=0)? $counts[0] : 1))*100.0)) . "% &nbsp; &nbsp; </td><td>Response Development in progress</td></tr>\n";
            $outputstring .= "<tr><td align=right>" . sprintf("%5.2f",(($counts[1]/(($counts[0]!=0)? $counts[0] : 1))*100.0)) . "% &nbsp; &nbsp; </td><td>Awaiting Assignment</td></tr>\n";
            $outputstring .= "<tr><td colspan=2>&nbsp;<br></td></tr>\n";
            
            $outputstring .= "<tr><td colspan=2>Count of comments in each status:</td></tr>\n";
            
            foreach $key (14,15,9,8,7,6,5,4,3,2,1) {
                if ($key < 10 || $key >13) {
                    $outputstring .= "<tr><td align=right>$counts[$key] &nbsp; &nbsp; </td><td>$response_status{$key}</td></tr>\n";
                }
            }
            #$outputstring .= "<tr><td align=right><hr width=75%></td><td></td></tr><tr><td align=right>" . ($counts[14] + $counts[15] + $counts[0]) . " &nbsp; &nbsp; </td><td>Total</td></tr>\n";
            $outputstring .= "<tr><td align=right><hr width=75%></td><td></td></tr><tr><td align=right>" . ($counts[0]) . " &nbsp; &nbsp; </td><td>Total</td></tr>\n";
            
            if ($args{includeOrgs} eq 'T') {
                $sqlquery = "SELECT com.document,com.commentnum,doc.namestatus,cmtr.organization,affil.name FROM $args{'schema'}.comments com, $args{'schema'}.document doc, $args{'schema'}.commentor cmtr, $args{'schema'}.commentor_affiliation affil WHERE (com.document=doc.id) AND (doc.commentor=cmtr.id(+)) AND (cmtr.affiliation=affil.id) AND (bin IN ( $binlist ))";
                $csr = $args{'dbh'}->prepare($sqlquery);
                $status = $csr->execute;
                my %orglist;
                my %afflist;
                while (@values = $csr->fetchrow_array) {
                    if ($values[2] == 1) {
                        if (defined($values[3]) && $values[3] gt ' ') {
                            if (!(defined($orglist{$values[3]}))) {
                                $orglist{$values[3]}[0] = 0;
                            }
                            $orglist{$values[3]}[0]++;
                        }
                        if (!(defined($afflist{$values[4]}))) {
                            $afflist{$values[4]}[0] = 0;
                        }
                        $afflist{$values[4]}[0]++;
                    }
                }
                $csr->finish;
                
                $outputstring .="<tr><td colspan=2><br>Count of commentor organizations:</td></tr>\n";
                foreach $key (sort keys %orglist) {
                    $outputstring .= "<tr><td align=right>$orglist{$key}[0] &nbsp; &nbsp; </td><td>$key</td></tr>\n";
                }
                
                $outputstring .="<tr><td colspan=2><br>Count of commentor affiliations:</td></tr>\n";
                foreach $key (sort keys %afflist) {
                    $outputstring .= "<tr><td align=right>$afflist{$key}[0] &nbsp; &nbsp; </td><td>$key</td></tr>\n";
                }
            }
            
            
            $outputstring .= "</table>\n";
            
            
            $outputstring .= "</td></tr></table>\n";
        }
        $bincsr->finish;
        $outputstring .= "</td></tr></table>\n";


    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate a Detailed Comment Report by Bin.",$@);
        print doAlertBox( text => $message);
    }

    return ($outputstring);
}


###################################################################################################################################
sub doCommentorReport {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        @_,
    );
    
    no integer;
    
    my $outputstring ='';
    my $sqlquery = '';
    my $csr;
    my @values;
    my @row;
    my $status;
    my $line;
    my $message;

    $outputstring .= "<script language=javascript><!--\n";
    $outputstring .= "    document.title='$CRDType Comment/Response Database - Commentor Report'\n";
    $outputstring .= "//--></script>\n";
    
    eval {
        $outputstring .= "<table border=0 width=670 cellpadding=0 cellspacing=0><tr><td>\n";
        $outputstring .= "<center><font size=+2>$CRDType Comment/Response Database<br>Commentor Report</font><font size=-1><br><br></font>";
        $outputstring .= "<font size=-1>$args{'run_date'}</font>\n";
        $sqlquery = "SELECT id,lastname,firstname,middlename,title,suffix,address,city,state,country,postalcode,areacode,phonenumber,phoneextension,faxareacode,faxnumber,faxextension,email,organization,position,affiliation FROM $args{'schema'}.commentor ORDER BY $args{'orderBy'}";
        $csr = $args{'dbh'}->prepare($sqlquery);
        $status = $csr->execute;
        
        $outputstring .= "<table border=0 width=100%><tr><td>\n";
        while (@values = $csr->fetchrow_array) {
            $outputstring .= "<hr>\n";
            $outputstring .= ((defined($values[4])) ? "$values[4] " : '') . ((defined($values[2])) ? "$values[2] " : '') . ((defined($values[3])) ? "$values[3] " : '') . ((defined($values[1])) ? "$values[1] " : '') . ((defined($values[5])) ? "$values[5] " : '') . "<br>\n";
            $outputstring .= ((defined($values[6]) && $values[6] gt " ") ? "$values[6]<br>\n" : "");
            $line = ((defined($values[7]) && $values[7] gt " ") ? "$values[7], " : "");
            $line .= ((defined($values[8]) && $values[8] gt " ") ? "$values[8] " : "");
            $line .= ((defined($values[10]) && $values[10] gt " ") ? "$values[10] " : "");
            $line .= ((defined($values[9]) && $values[9] gt " ") ? "$values[9]" : "");
            $outputstring .= ((defined($line) && $line gt " ") ? "$line<br>\n" : "");
            $outputstring .= ((defined($values[17]) && $values[17] gt " ") ? "$values[17]<br>\n" : "");
            @row = $dbh->selectrow_array("SELECT count(*) FROM $args{'schema'}.document WHERE commentor=$values[0]");
            $outputstring .= "Comment Documents submited: $row[0]<br>\n";
        }
        $csr->finish;
        $outputstring .= "</td></tr></table>\n";
    
    
    };

    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate a Commentor Report.",$@);
        print doAlertBox( text => $message);
    }

    return ($outputstring);
}


###################################################################################################################################
sub doUsersReport {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        @_,
    );
    
    no integer;
    
    my $outputstring ='';
    my $sqlquery = '';
    my $sqlquery2 = '';
    my $csr;
    my $csr2;
    my @values;
    my @values2;
    my @row;
    my $status;
    my $message;
    my $seperator;

    $outputstring .= "<script language=javascript><!--\n";
    $outputstring .= "    document.title='$CRDType Comment/Response Database - System Users Report'\n";
    $outputstring .= "//--></script>\n";
    
    eval {
        $outputstring .= "<table border=0 width=670 cellpadding=0 cellspacing=0><tr><td>\n";
        $outputstring .= "<center><font size=+2>$CRDType Comment/Response Database<br>System Users Report</font><font size=-1><br><br></font>";
        $outputstring .= "<font size=-1>$args{'run_date'}</font></center>\n";
        $sqlquery = "SELECT id,location,username,firstname,lastname,organization,areacode,phonenumber,extension,email,isactive,accesstype FROM $args{'schema'}.users WHERE id<>0 ORDER BY lastname,firstname";
        $csr = $args{'dbh'}->prepare($sqlquery);
        $status = $csr->execute;
        while (@values = $csr->fetchrow_array) {
            $outputstring .= "<hr>\n";
            $outputstring .= "$values[3] $values[4] - $values[5] - \n";
            $outputstring .= "$values[1] \n";
            $outputstring .= " - ($values[6]) " . substr($values[7],0,3) . "-" . substr($values[7],3,4) . ((defined($values[8])) ? " $values[8]\n" : "\n");
            #$outputstring .= "E-Mail: $values[9]<br>\n";
            #$outputstring .= "Access Type: " . get_value($args{'dbh'},$args{'schema'},'system_access_type','name', "id=$values[11]") . nbspaces(8) . "User is marked as " . (($values[10] eq 'F') ? "Not " : "") . "Active<br>\n";
            $outputstring .= "<table border=0 width=100% cellpaddeing=0 cellspacing=0>\n";
            $outputstring .= "<tr><td valign=top width=5%>Permissions:" . nbspaces(4) ."</td>\n";
            $outputstring .= "<td>\n";
            if ($values[0] < 1000) {
                $sqlquery2 = "SELECT sp.name FROM $args{'schema'}.user_privilege userp, $args{'schema'}.system_privilege sp WHERE (userp.privilege = sp.id) AND (userp.userid = $values[0]) ORDER BY sp.name";
                $csr2 = $args{'dbh'}->prepare($sqlquery2);
                $status = $csr2->execute;
                $seperator = "";
                while (@values2 = $csr2->fetchrow_array) {
                    $outputstring .= $seperator . $values2[0];
                    $seperator = "<br>";
                }
                $csr2->finish;
            } else {
                $outputstring .= "DEVELOPER\n";
            }
            $outputstring .= "</td></tr>\n";
            $outputstring .= "<tr><td valign=top>Assignments:" . nbspaces(4) ."</td>\n";
            $outputstring .= "<td>\n";
            $sqlquery2 = "SELECT name FROM $args{'schema'}.bin WHERE coordinator=$values[0] AND NVL(parent,0)=0 ORDER BY name";
            $csr2 = $args{'dbh'}->prepare($sqlquery2);
            $status = $csr2->execute;
            $seperator = "Coordinator:<br>";
            while (@values2 = $csr2->fetchrow_array) {
                $outputstring .= $seperator . nbspaces(4) . $values2[0];
                $seperator = "<br>";
            }
            $csr2->finish;
            
            $sqlquery2 = "SELECT name FROM $args{'schema'}.bin WHERE nepareviewer=$values[0] AND NVL(parent,0)=0 ORDER BY name";
            $csr2 = $args{'dbh'}->prepare($sqlquery2);
            $status = $csr2->execute;
            if ($seperator eq "<br>") {
                $seperator = "<br><br>" . &FirstReviewName . " Reviewer:<br>";
            } else {
                $seperator = &FirstReviewName . " Reviewer:<br>";
            }
            while (@values2 = $csr2->fetchrow_array) {
                $outputstring .= $seperator . nbspaces(4) . $values2[0];
                $seperator = "<br>";
            }
            $csr2->finish;
            
            $sqlquery2 = "SELECT bin.name FROM $args{'schema'}.default_tech_reviewer dtr, $args{'schema'}.bin bin WHERE (dtr.reviewer=$values[0]) AND (dtr.bin=bin.id) AND (NVL(parent,0)=0) ORDER BY bin.name";
            $csr2 = $args{'dbh'}->prepare($sqlquery2);
            $status = $csr2->execute;
            if ($seperator eq "<br>") {
                $seperator = "<br><br>Response Writer/Technical Reviewer:<br>";
            } else {
                $seperator = "Response Writer/Technical Reviewer:<br>";
            }
            while (@values2 = $csr2->fetchrow_array) {
                $outputstring .= $seperator . nbspaces(4) . $values2[0];
                $seperator = "<br>";
            }
            $csr2->finish;
            
            $outputstring .= "</td></tr></table>\n";
        }
        $csr->finish;
        $outputstring .= "</td></tr></table>\n";
    
    };

    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate a Users Report.",$@);
        print doAlertBox( text => $message);
    }

    return ($outputstring);
}


###################################################################################################################################
sub doEntryCountsReport {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        beginDate => '19990101',
        endDate => '30001232',
        dbh => '',
        type => '',
        @_,
    );
    
    no integer;
    
    my $outputstring ='';
    my $sqlquery = '';
    my $csr;
    my @row;
    my @row2;
    my @values;
    my $status;
    my $message;
    my $lastdate = '';
    my $lastweek = 0;
    my $count = 0;
    my $total = 0;
    
    foreach my $key (sort keys %args) {
        $outputstring .= "<!-- $key - $args{$key} -->\n";
    }

    $outputstring .= "<script language=javascript><!--\n";
    $outputstring .= "    document.title='$CRDType Comment/Response Database - Entry Counts Report'\n";
    $outputstring .= "//--></script>\n";
    
    eval {
        if ($args{'type'} eq 'test') {
            if ($args{countBy} eq 'day') {
                @row = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.document_entry WHERE (TO_CHAR(entrydate1,'YYYYMMDD') BETWEEN '$args{beginDate}' AND '$args{endDate}')");
                @row2 = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.document WHERE (TO_CHAR(entrydate1,'YYYYMMDD') BETWEEN '$args{beginDate}' AND '$args{endDate}')");
            } else {
                @row = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{schema}.document_entry WHERE (TO_CHAR(entrydate1,'YYYYMMDD') BETWEEN TO_CHAR(TO_DATE(TO_CHAR(TO_DATE('$args{beginDate}','YYYYMMDD'),'J')-7,'J'),'YYYYMMDD') AND TO_CHAR(TO_DATE(TO_CHAR(TO_DATE('$args{endDate}','YYYYMMDD'),'J')+6,'J'),'YYYYMMDD'))");
                @row2 = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{schema}.document WHERE (TO_CHAR(entrydate1,'YYYYMMDD') BETWEEN TO_CHAR(TO_DATE(TO_CHAR(TO_DATE('$args{beginDate}','YYYYMMDD'),'J')-7,'J'),'YYYYMMDD') AND TO_CHAR(TO_DATE(TO_CHAR(TO_DATE('$args{endDate}','YYYYMMDD'),'J')+6,'J'),'YYYYMMDD'))");
            }
            if ($row[0] >0 || $row2[0] >0) {
                $outputstring .= "<input type=hidden name=entrycountsbegindate value='$args{beginDate}'>\n";
                $outputstring .= "<input type=hidden name=entrycountsenddate value='$args{endDate}'>\n";
                $outputstring .= "<input type=hidden name=entrycountscounttype value='$args{countBy}'>\n";
                $outputstring .= "<script language=javascript><!--\n";
                $outputstring .= "    submitFormNewWindow('$form', 'report','EntryCountsReport');\n";
                $outputstring .= "//--></script>\n";
            } else {
                $outputstring .= "<script language=javascript><!--\n";
                $outputstring .= "    alert('No report generated with selected dates.')\n";
                $outputstring .= "//--></script>\n";
            }
        } else {
            if ($args{countBy} eq 'day') {
                $sqlquery = "SELECT UPPER(TO_CHAR(entrydate1,'DD-MON-YYYY')), UPPER(TO_CHAR(NEXT_DAY(TO_DATE(TO_CHAR(entrydate1,'J')-7,'J'),'MON'),'DD-MON-YYYY')), id, TO_CHAR(entrydate1,'YYYYMMDD') datesort FROM $args{schema}.document_entry WHERE (TO_CHAR(entrydate1,'YYYYMMDD') BETWEEN '$args{beginDate}' AND '$args{endDate}') ";
                $sqlquery .= "UNION ";
                $sqlquery .= "SELECT UPPER(TO_CHAR(entrydate1,'DD-MON-YYYY')), UPPER(TO_CHAR(NEXT_DAY(TO_DATE(TO_CHAR(entrydate1,'J')-7,'J'),'MON'),'DD-MON-YYYY')), id, TO_CHAR(entrydate1,'YYYYMMDD') datesort FROM $args{schema}.document WHERE (TO_CHAR(entrydate1,'YYYYMMDD') BETWEEN '$args{beginDate}' AND '$args{endDate}') ";
                $sqlquery .= "ORDER BY datesort";
            } else {
                $sqlquery = "SELECT UPPER(TO_CHAR(entrydate1,'DD-MON-YYYY')), UPPER(TO_CHAR(NEXT_DAY(TO_DATE(TO_CHAR(entrydate1,'J')-7,'J'),'MON'),'DD-MON-YYYY')), TO_CHAR(NEXT_DAY(TO_DATE(TO_CHAR(entrydate1,'J')-7,'J'),'MON'),'J'), id, TO_CHAR(entrydate1,'YYYYMMDD') datesort FROM $args{schema}.document_entry WHERE (TO_CHAR(entrydate1,'YYYYMMDD') BETWEEN TO_CHAR(TO_DATE(TO_CHAR(TO_DATE('$args{beginDate}','YYYYMMDD'),'J')-7,'J'),'YYYYMMDD') AND TO_CHAR(TO_DATE(TO_CHAR(TO_DATE('$args{endDate}','YYYYMMDD'),'J')+6,'J'),'YYYYMMDD'))";
                $sqlquery .= "UNION ";
                $sqlquery .= "SELECT UPPER(TO_CHAR(entrydate1,'DD-MON-YYYY')), UPPER(TO_CHAR(NEXT_DAY(TO_DATE(TO_CHAR(entrydate1,'J')-7,'J'),'MON'),'DD-MON-YYYY')), TO_CHAR(NEXT_DAY(TO_DATE(TO_CHAR(entrydate1,'J')-7,'J'),'MON'),'J'), id, TO_CHAR(entrydate1,'YYYYMMDD') datesort FROM $args{schema}.document WHERE (TO_CHAR(entrydate1,'YYYYMMDD') BETWEEN TO_CHAR(TO_DATE(TO_CHAR(TO_DATE('$args{beginDate}','YYYYMMDD'),'J')-7,'J'),'YYYYMMDD') AND TO_CHAR(TO_DATE(TO_CHAR(TO_DATE('$args{endDate}','YYYYMMDD'),'J')+6,'J'),'YYYYMMDD'))";
                $sqlquery .= "ORDER BY datesort";
            }
            $csr = $args{'dbh'}->prepare($sqlquery);
            $status = $csr->execute;
    
            $outputstring .= "<table border=0 width=670 cellpadding=0 cellspacing=0><tr><td>\n";
            $outputstring .= "<center><font size=+2>$CRDType Comment/Response Database<br>Document Capture - Documents Processed Report</font><font size=-1><br><br></font>";
            $outputstring .= "<font size=-1>$args{'run_date'}</font></center>\n";
            
            $outputstring .= "<br><table border=0 align=center>\n";
            $outputstring .= "<tr><td align=center>" . (($args{countBy} eq 'day') ? "Date" . nbspaces(9) : "Week Of" . nbspaces(6)) . "</td><td align=center>Documents<br>Processed</td></tr>\n";
            
            while (@values=$csr->fetchrow_array) {
                if ($args{countBy} eq 'day' && $values[0] ne $lastdate || $args{countBy} eq 'week' && $values[1] ne $lastdate) {
                    if ($lastdate ne '') {
                        $outputstring .= "<tr><td>$lastdate &nbsp; </td><td align=right>$count" . nbspaces(5) . "</td></tr>\n";
                        if ($args{countBy} eq 'week') {
                            while (($lastweek + 7) < $values[2]) {
                                $lastweek = $lastweek + 7;
                                @row = $args{'dbh'}->selectrow_array("SELECT UPPER(TO_CHAR(TO_DATE('$lastweek','J'),'DD-MON-YYYY')) FROM dual");
                                $outputstring .= "<tr><td>$row[0] &nbsp; </td><td align=right>0" . nbspaces(5) . "</td></tr>\n";
                            }
                        }
                    }
                    $lastdate = (($args{countBy} eq 'day') ? $values[0] : $values[1]);
                    $lastweek = (($args{countBy} eq 'week') ? $values[2] : 0);
                    $count = 0;
                }
                $count++;
                $total++;
            }
            $outputstring .= "<tr><td>$lastdate &nbsp; </td><td align=right>$count" . nbspaces(5) . "</td></tr>\n";
            if ($args{countBy} eq 'week') {
                @row = $args{'dbh'}->selectrow_array("SELECT UPPER(TO_CHAR(TO_DATE('$lastweek','J'),'DD-MON-YYYY')), TO_CHAR(NEXT_DAY(TO_DATE(TO_CHAR(TO_DATE('" . get_date() . "','DD-MON-YYYY'),'J')-7,'J'),'MON'),'J'), TO_CHAR(NEXT_DAY(TO_DATE(TO_CHAR(TO_DATE('$args{endDate}','YYYYMMDD'),'J')-7,'J'),'MON'),'J') FROM dual");
                while (($lastweek + 7) <= $row[1] && ($lastweek + 7) <= $row[2]) {
                    $lastweek = $lastweek + 7;
                    @row = $args{'dbh'}->selectrow_array("SELECT UPPER(TO_CHAR(TO_DATE('$lastweek','J'),'DD-MON-YYYY')), TO_CHAR(NEXT_DAY(TO_DATE(TO_CHAR(TO_DATE('" . get_date() . "','DD-MON-YYYY'),'J')-7,'J'),'MON'),'J'), TO_CHAR(NEXT_DAY(TO_DATE(TO_CHAR(TO_DATE('$args{endDate}','YYYYMMDD'),'J')-7,'J'),'MON'),'J') FROM dual");
                    $outputstring .= "<tr><td>$row[0] &nbsp; </td><td align=right>0" . nbspaces(5) . "</td></tr>\n";
                }
            }
            $outputstring .= "<tr><td><hr></td><td align=right><hr></td></tr>\n";
            $outputstring .= "<tr><td>Total &nbsp; </td><td align=right>$total" . nbspaces(5) . "</td></tr>\n";
            
            $outputstring .= "</table>\n";
            $outputstring .= "</td></tr></table>\n";
            
        }
    };
    
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate a Entry Count Report.",$@);
        print doAlertBox( text => $message);
    }
    
    return $outputstring
    
}


###################################################################################################################################
sub doWorkLoadReportAllBins {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        type => 'Bin',
        @_,
    );
    
    no integer;
    
    my $outputstring ='';
    my $binsqlquery = '';
    my $bincsr;
    my $usrcsr;
    my @binvalues;
    my $status;
    my $message;

    eval {
        $binsqlquery = "SELECT id FROM $args{schema}.bin WHERE NVL(parent,0) = 0 ORDER BY name";
        $bincsr = $args{dbh}->prepare($binsqlquery);
        $status = $bincsr->execute;
        
        while (@binvalues = $bincsr->fetchrow_array) {
            $outputstring .= doWorkLoadReport(dbh => $args{dbh}, schema => $args{schema}, userId => $args{userId}, root_bin => $binvalues[0], type => $args{type});
            $outputstring .= "\n<br><br> <hr> <br><br>\n";
            print "<!-- Keep Alive $binvalues[0] -->\n";
        }
    };
    
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate a Workload Report for all Bins.",$@);
        print doAlertBox( text => $message);
    }
    
    return $outputstring
    
}


###################################################################################################################################
sub doWorkLoadReport {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        type => 'Bin',
        @_,
    );
    
    no integer;
    
    my $outputstring ='';
    my $binsqlquery = '';
    my $usrsqlquery = '';
    my $sqlquery = '';
    my $bincsr;
    my $usrcsr;
    my $csr;
    my $csr2;
    my @binvalues;
    my @usrvalues;
    my @values;
    my @row;
    my $status;
    my @counts;
    my @usrBinCounts;
    my @totals;
    my $key;
    my $key2;
    my $message;
    my $binlist = "0";
    my $usrBinList = "0";
    my @binlist = (0);
    my $bincount = 0;
    my %binmember;
    my $testbin = "(1=1)";
    my $lastid = 0;

    $outputstring .= "<script language=javascript><!--\n";
    $outputstring .= "    document.title='$CRDType Comment/Response Database - $args{'type'} Workload Report'\n";
    $outputstring .= "//--></script>\n";
    
    eval {
        $outputstring .= "<table border=0 width=670 cellpadding=0 cellspacing=0><tr><td>\n";
        $outputstring .= "<center><font size=+2>$CRDType Comment/Response Database<br>$args{'type'} Workload Report</font><font size=-1><br><br></font>";
        if ($args{'type'} eq 'Bin') {
            $binsqlquery = "SELECT id,name,coordinator FROM $args{'schema'}.bin WHERE (NVL(parent,0) = 0) AND (bin.id = $args{'root_bin'})";
            $bincsr = $args{'dbh'}->prepare($binsqlquery);
            $status = $bincsr->execute;
            @binvalues = $bincsr->fetchrow_array;
            $bincsr->finish;
            $outputstring .= "<font size=+1><b>$binvalues[1]</b></font><br>\n";
            $outputstring .= "Coordinator: " . get_fullname($args{'dbh'},$args{'schema'},$binvalues[2]) . "<br>\n";
            $outputstring .= "<br>\n";
            $binlist = getBinTree(\%args);
            @binlist = (eval "$binlist");
        }
        if ($args{'type'} eq 'User') {
            @row = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.bin WHERE coordinator=$args{'displayUser'} OR nepareviewer=$args{'displayUser'} OR id IN (SELECT bin FROM $args{'schema'}.comments WHERE doereviewer=$args{'displayUser'})");
            @values = $args{'dbh'}->selectrow_array("SELECT UNIQUE count(*) FROM $args{'schema'}.default_tech_reviewer WHERE (reviewer = $args{'displayUser'}) AND (bin NOT IN (SELECT id FROM $args{'schema'}.bin WHERE coordinator=$args{'displayUser'} OR nepareviewer=$args{'displayUser'} OR id IN (SELECT bin FROM $args{'schema'}.comments WHERE doereviewer=$args{'displayUser'})))");

            $bincount = $row[0] + $values[0];

            $outputstring .= "<font size=+1><b>" . get_fullname($args{'dbh'},$args{'schema'},$args{'displayUser'}) . " - \n";
            $outputstring .= "$bincount bin" . (($bincount != 1) ? "s" : "") . "</b></font><br><br>\n";
        }
        $outputstring .= "<font size=-1>$args{'run_date'}</font><br>\n";
        $outputstring .= "<table border=0><tr><td><table border=0>\n";
        
        if ($args{'type'} eq "User") {
            $sqlquery = "SELECT id FROM $args{'schema'}.bin WHERE coordinator=$args{'displayUser'} OR nepareviewer=$args{'displayUser'}";
            $csr = $args{'dbh'}->prepare($sqlquery);
            $status = $csr->execute;
            while (@values = $csr->fetchrow_array) {
                $binmember{$values[0]} = 1;
            }
            $csr->finish;
            $sqlquery = "SELECT bin FROM $args{'schema'}.default_tech_reviewer WHERE reviewer=$args{'displayUser'}";
            $csr = $args{'dbh'}->prepare($sqlquery);
            $status = $csr->execute;
            while (@values = $csr->fetchrow_array) {
                $binmember{$values[0]} = 1;
            }
            $csr->finish;
            $sqlquery = "SELECT bin FROM $args{'schema'}.comments WHERE doereviewer=$args{'displayUser'}";
            $csr = $args{'dbh'}->prepare($sqlquery);
            $status = $csr->execute;
            while (@values = $csr->fetchrow_array) {
                $binmember{$values[0]} = 1;
            }
            $csr->finish;
            $usrBinList = "";
            foreach $key (keys %binmember) {
                $usrBinList .= "$key,";
                for ($key2=0; $key2 <= 8; $key2++) {
                    $usrBinCounts[$key][$key2] = 0;
                }
            }
            $usrBinList .= "0";
        }
        
        $usrsqlquery = "SELECT id,firstname,lastname FROM $args{'schema'}.users WHERE ";
        if ($args{'type'} eq 'User') {
            $usrsqlquery .= "id = $args{'displayUser'} ";
        } else {
            if ($args{'type'} eq 'Bin') {$testbin = "(id IN ($binlist))";}
            $usrsqlquery .= "(id IN (SELECT UNIQUE coordinator FROM $args{'schema'}.bin WHERE $testbin )) OR ";
            $usrsqlquery .= "(id IN (SELECT UNIQUE nepareviewer FROM $args{'schema'}.bin WHERE $testbin )) OR ";
            if ($args{'type'} eq 'Bin') {$testbin = "(bin IN ($binlist))";}
            $usrsqlquery .= "(id IN (SELECT UNIQUE reviewer FROM $args{'schema'}.default_tech_reviewer WHERE $testbin )) OR ";
            $usrsqlquery .= "(id IN (SELECT UNIQUE doereviewer FROM $args{'schema'}.comments WHERE $testbin AND (doereviewer IS NOT NULL) )) ";
        }
        $usrsqlquery .= "ORDER BY username";
        
        $usrcsr = $args{'dbh'}->prepare($usrsqlquery);
        $status = $usrcsr->execute;
        
        if ($args{'type'} eq "Bin") {
            $outputstring .= "<tr><td>Name &nbsp; &nbsp; </td><td width=250>Response Assignment Status</td><td width=70 align=right>This Bin</td><td width=70 align=right>All Bins</td></tr>\n";
        } elsif ($args{'type'} eq "System") {
            $outputstring .= "<tr><td>User &nbsp; &nbsp; </td><td># Bins</td><td width=250>Response Activity</td><td width=70 align=right>Assignments</td></tr>\n";
        } elsif ($args{'type'} eq "User") {
            $outputstring .= "<tr><td> &nbsp; &nbsp; </td><td width=250>Response Activity</td><td width=70 align=right>Assignments</td></tr>\n";
        }
        
        for ($key=0; $key <= 8; $key++) {
            $totals[$key] = 0;
            $totals[$key] = 0;
        }
        while (@usrvalues = $usrcsr->fetchrow_array) {
            
            for ($key=0; $key <= 8; $key++) {
                $counts[0][$key] = 0;
                $counts[1][$key] = 0;
            }
            print "<!-- keep alive $usrvalues[1] $usrvalues[2] -->\n";

            $sqlquery = "SELECT rsv.status,rsv.responsewriter,com.bin ";
            $sqlquery .= "FROM $args{'schema'}.response_version rsv, $args{'schema'}.comments com ";
            $sqlquery .= "WHERE (rsv.document=com.document) AND (rsv.commentnum=com.commentnum) AND (rsv.responsewriter=$usrvalues[0]) ";
            $sqlquery .= "AND (com.dupsimstatus = 1) ";
            $sqlquery .= "AND (com.summary IS NULL) ";
            $sqlquery .= "AND (rsv.status IN (1, 2, 3, 4, 5, 6, 7, 8)) ";
            $sqlquery .= "ORDER BY rsv.status";
            $csr = $args{'dbh'}->prepare($sqlquery);
            $status = $csr->execute;
            $lastid = 0;
            
            while (@values = $csr->fetchrow_array) {
                if ($values[0] < 6 && $values[0] != 3 && $values[0] != 5) {
                    foreach $key (@binlist) {
                        if ($key eq $values[2]) {
                            $counts[0][$values[0]]++;
                            $counts[0][0]++;
                            if ($args{'type'} eq 'Bin') {
                                $totals[$values[0]]++;
                                $totals[0]++;
                            }
                            last;
                        }
                    }
                    $counts[1][$values[0]]++;
                    $counts[1][0]++;
                    if ($args{'type'} ne 'Bin') {
                        $totals[$values[0]]++;
                        $totals[0]++;
                    }
                    if ($args{'type'} eq "User") {
                        if ($usrvalues[0] = $args{'displayUser'}) {
                            $usrBinCounts[$values[2]][$values[0]]++;
                            $usrBinCounts[$values[2]][0]++;
                        }
                    }
                }
                #print "<!-- keep alive rsv $values[0], $values[1], $values[2] -->\n";
            }
            $csr->finish;
            if ($args{'type'} eq 'Bin') {
                if ($usrvalues[0] == get_value($args{'dbh'}, $args{'schema'}, 'bin', 'nepareviewer', "id = $args{'root_bin'}") ) {
                    @row = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.response_version rs,$args{'schema'}.comments com WHERE (rs.document = com.document) AND (rs.commentnum = com.commentnum) AND (com.bin in ($binlist)) AND (rs.status = 7) AND (com.dupsimstatus = 1) AND (com.summary IS NULL) AND (com.bin IN (SELECT id FROM $args{'schema'}.bin WHERE nepareviewer = $usrvalues[0]))");
                    $counts[0][7] = $counts[0][7] + $row[0];
                    $counts[0][0] = $counts[0][0] + $row[0];
                    $totals[7] = $totals[7] + $row[0];
                    $totals[0] = $totals[0] + $row[0];
                    @row = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.response_version rs,$args{'schema'}.comments com WHERE (rs.document = com.document) AND (rs.commentnum = com.commentnum) AND (rs.status = 7) AND (com.dupsimstatus = 1) AND (com.bin IN (SELECT id FROM $args{'schema'}.bin WHERE nepareviewer = $usrvalues[0]))");
                    $counts[1][7] = $counts[1][7] + $row[0];
                    $counts[1][0] = $counts[1][0] + $row[0];
                }
                if (0 < get_value($args{'dbh'}, $args{'schema'}, 'comments', 'count(*)', "doereviewer = $usrvalues[0]") ) {
                    @row = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.response_version rs,$args{'schema'}.comments com WHERE (rs.document = com.document) AND (rs.commentnum = com.commentnum) AND (com.bin in ($binlist)) AND (rs.status = 8) AND (com.dupsimstatus = 1) AND (com.summary IS NULL) AND (com.doereviewer = $usrvalues[0])");
                    $counts[0][8] = $counts[0][8] + $row[0];
                    $counts[0][0] = $counts[0][0] + $row[0];
                    $totals[8] = $totals[8] + $row[0];
                    $totals[0] = $totals[0] + $row[0];
                    @row = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.response_version rs,$args{'schema'}.comments com WHERE (rs.document = com.document) AND (rs.commentnum = com.commentnum) AND (rs.status = 8) AND (com.dupsimstatus = 1) AND (com.summary IS NULL)");
                    $counts[1][8] = $counts[1][8] + $row[0];
                    $counts[1][0] = $counts[1][0] + $row[0];
                }
            } else {
                if (0 < get_value($args{'dbh'}, $args{'schema'}, 'bin', 'count(*)', "nepareviewer = $usrvalues[0]") ) {
                    @row = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.response_version rs,$args{'schema'}.comments com WHERE (rs.document = com.document) AND (rs.commentnum = com.commentnum) AND (rs.status = 7) AND (com.dupsimstatus = 1) AND (com.summary IS NULL) AND (com.bin IN (SELECT id FROM $args{'schema'}.bin WHERE nepareviewer = $usrvalues[0]))");
                    $counts[1][7] = $counts[1][7] + $row[0];
                    $counts[1][0] = $counts[1][0] + $row[0];
                    $totals[7] = $totals[7] + $row[0];
                    $totals[0] = $totals[0] + $row[0];
                }
                if (0 < get_value($args{'dbh'}, $args{'schema'}, 'comments', 'count(*)', "doereviewer = $usrvalues[0]") ) {
                    @row = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.response_version rs,$args{'schema'}.comments com WHERE (rs.document = com.document) AND (rs.commentnum = com.commentnum) AND (rs.status = 8) AND (com.dupsimstatus = 1) AND (com.summary IS NULL) AND (com.doereviewer = $usrvalues[0])");
                    $counts[1][8] = $counts[1][8] + $row[0];
                    $counts[1][0] = $counts[1][0] + $row[0];
                    $totals[8] = $totals[8] + $row[0];
                    $totals[0] = $totals[0] + $row[0];
                }
            }
            
            @values = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.technical_review tr,$args{'schema'}.comments com WHERE (tr.document = com.document) AND (tr.commentnum = com.commentnum) AND (com.bin in ($binlist)) AND (tr.reviewer = $usrvalues[0]) AND (tr.status = 1) AND (com.dupsimstatus = 1) AND (com.summary IS NULL)");
            $counts[0][3] = $counts[0][3] + $values[0];
            $counts[0][0] = $counts[0][0] + $values[0];
            if ($args{'type'} eq "Bin"){
                $totals[3] = $totals[3] + $values[0];
                $totals[0] = $totals[0] + $values[0];
            }
            @values = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.technical_review tr,$args{'schema'}.comments com WHERE (tr.document = com.document) AND (tr.commentnum = com.commentnum) AND (tr.reviewer = $usrvalues[0]) AND (tr.status = 1) AND (com.dupsimstatus = 1) AND (com.summary IS NULL)");
            $counts[1][3] = $counts[1][3] + $values[0];
            $counts[1][0] = $counts[1][0] + $values[0];
            if ($args{'type'} ne "Bin"){
                $totals[3] = $totals[3] + $values[0];
                $totals[0] = $totals[0] + $values[0];
            }
            
            @values = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.response_version rs,$args{'schema'}.comments com WHERE (rs.document = com.document) AND (rs.commentnum = com.commentnum) AND (com.bin in ($binlist)) AND (rs.techeditor = $usrvalues[0]) AND (rs.status = 5) AND (com.dupsimstatus = 1) AND (com.summary IS NULL)");
            $counts[0][5] = $counts[0][5] + $values[0];
            $counts[0][0] = $counts[0][0] + $values[0];
            if ($args{'type'} eq "Bin"){
                $totals[5] = $totals[5] + $values[0];
                $totals[0] = $totals[0] + $values[0];
            }
            @values = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.response_version rs,$args{'schema'}.comments com WHERE (rs.document = com.document) AND (rs.commentnum = com.commentnum) AND (rs.techeditor = $usrvalues[0]) AND (rs.status = 5) AND (com.dupsimstatus = 1) AND (com.summary IS NULL)");
            $counts[1][5] = $counts[1][5] + $values[0];
            $counts[1][0] = $counts[1][0] + $values[0];
            if ($args{'type'} ne "Bin"){
                $totals[5] = $totals[5] + $values[0];
                $totals[0] = $totals[0] + $values[0];
            }
            
            @values = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.response_version rs,$args{'schema'}.comments com, $args{'schema'}.bin bin WHERE (rs.document = com.document) AND (rs.commentnum = com.commentnum) AND (com.bin = bin.id) AND (com.bin in ($binlist)) AND (bin.coordinator = $usrvalues[0]) AND (rs.status = 6) AND (com.dupsimstatus = 1) AND (com.summary IS NULL)");
            $counts[0][6] = $counts[0][6] + $values[0];
            $counts[0][0] = $counts[0][0] + $values[0];
            if ($args{'type'} eq "Bin"){
                $totals[6] = $totals[6] + $values[0];
                $totals[0] = $totals[0] + $values[0];
            }
            @values = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.response_version rs,$args{'schema'}.comments com, $args{'schema'}.bin bin WHERE (rs.document = com.document) AND (rs.commentnum = com.commentnum) AND (com.bin = bin.id) AND (bin.coordinator = $usrvalues[0]) AND (rs.status = 6) AND (com.dupsimstatus = 1) AND (com.summary IS NULL)");
            $counts[1][6] = $counts[1][6] + $values[0];
            $counts[1][0] = $counts[1][0] + $values[0];
            if ($args{'type'} ne "Bin"){
                $totals[6] = $totals[6] + $values[0];
                $totals[0] = $totals[0] + $values[0];
            }
            
            @row = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.bin WHERE coordinator=$usrvalues[0] OR nepareviewer=$usrvalues[0] OR id IN (SELECT bin FROM $args{'schema'}.comments WHERE doereviewer=$usrvalues[0])");
            @values = $args{'dbh'}->selectrow_array("SELECT UNIQUE count(*) FROM $args{'schema'}.default_tech_reviewer WHERE (reviewer = $usrvalues[0]) AND (bin NOT IN (SELECT id FROM $args{'schema'}.bin WHERE coordinator=$usrvalues[0] OR nepareviewer=$usrvalues[0] OR id IN (SELECT bin FROM $args{'schema'}.comments WHERE doereviewer=$usrvalues[0])))");

            $bincount = $row[0] + $values[0];

            if ($args{'type'} ne "User") {
                $outputstring .= "<tr><td colspan=4><hr></td></tr>\n";
                if ($args{'type'} eq "Bin") {
                    $outputstring .= "<tr><td valign=top>$usrvalues[1] $usrvalues[2] &nbsp; &nbsp; </td><td colspan=3><table border=0 width=100% cellpadding=0 cellspacing=0>\n";
                } elsif ($args{'type'} eq "System") {
                    $outputstring .= "<tr><td valign=top>$usrvalues[1] $usrvalues[2] &nbsp; &nbsp; </td><td align=right valign=top>$bincount &nbsp; &nbsp; </td><td colspan=2><table border=0 width=100% cellpadding=0 cellspacing=0>\n";
                #} elsif ($args{'type'} eq "User") {
                #    $outputstring .= "<tr><td colspan=3>Summary - $bincount Bins</td></tr>\n";
                #    $outputstring .= "<tr><td align=right valign=top> &nbsp; &nbsp; </td><td colspan=2><table border=0 width=100% cellpadding=0 cellspacing=0>\n";
                }
                if ($counts[1][8] > 0) {
                $outputstring .= "<tr><td>" . &SecondReviewName . " Review</td>" . (($args{'type'} eq "Bin") ? ("<td align=right>$counts[0][8]" . nbspaces(3) . "</td>") : "") . "<td align=right>$counts[1][8]" . nbspaces(3) . "</td></tr>\n";}
                if ($counts[1][7] > 0) {
                $outputstring .= "<tr><td>" . &FirstReviewName . " Review</td>" . (($args{'type'} eq "Bin") ? ("<td align=right>$counts[0][7]" . nbspaces(3) . "</td>") : "") . "<td align=right>$counts[1][7]" . nbspaces(3) . "</td></tr>\n";}
                if ($counts[1][6] > 0) {
                $outputstring .= "<tr><td>Accept Response</td>" . (($args{'type'} eq "Bin") ? ("<td align=right>$counts[0][6]" . nbspaces(3) . "</td>") : "") . "<td align=right>$counts[1][6]" . nbspaces(3) . "</td></tr>\n";}
                if ($counts[1][5] > 0) {
                $outputstring .= "<tr><td>Technical Edit</td>" . (($args{'type'} eq "Bin") ? ("<td align=right>$counts[0][5]" . nbspaces(3) . "</td>") : "") . "<td align=right>$counts[1][5]" . nbspaces(3) . "</td></tr>\n";}
                if ($counts[1][3] > 0) {
                $outputstring .= "<tr><td>Technical Review</td>" . (($args{'type'} eq "Bin") ? ("<td align=right>$counts[0][3]" . nbspaces(3) . "</td>") : "") . "<td align=right>$counts[1][3]" . nbspaces(3) . "</td></tr>\n";}
                if (($counts[1][2]+$counts[1][4]) > 0) {
                $outputstring .= "<tr><td>Write/Modify Response</td>" . (($args{'type'} eq "Bin") ? ("<td align=right>" . ($counts[0][2]+$counts[0][4]) . nbspaces(3) . "</td>") : "") . "<td align=right>" . ($counts[1][2]+$counts[1][4]) . nbspaces(3) . "</td></tr>\n";}
                if ($counts[1][1] > 0) {
                $outputstring .= "<tr><td>Assign Response</td>" . (($args{'type'} eq "Bin") ? ("<td align=right>$counts[0][1]" . nbspaces(3) . "</td>") : "") . "<td align=right>$counts[1][1]" . nbspaces(3) . "</td></tr>\n";}
                #if ($counts[1][0] > 0 || $args{'type'} eq "User") {
                    if ($counts[1][0]>0) {
                        $outputstring .= "<tr><td width=250></td>" . (($args{'type'} eq "Bin") ? ("<td width=70 align=right><hr width=75%></td>") : "") . "<td width=70 align=right><hr width=75%></td></tr>\n";
                    }
                    $outputstring .= "<tr><td>Total</td>" . (($args{'type'} eq "Bin") ? ("<td width=70 align=right>$counts[0][0]" . nbspaces(3) . "</td>") : "") . "<td width=70 align=right>$counts[1][0]" . nbspaces(3) . "</td></tr>\n";
                #} else {
                #    $outputstring .= "<tr><td width=250></td>" . (($args{'type'} eq "Bin") ? ("<td width=70 align=right>0" . nbspaces(3) . "</td>") : "") . "<td width=70 align=right>0" . nbspaces(3) . "</td></tr>\n";
                #}
            
                $outputstring .= "</table></td></tr>\n";
            }
                    
        }
        if ($args{'type'} eq "User") {
            
            $binsqlquery = "SELECT id, name FROM $args{'schema'}.bin WHERE id IN ($usrBinList) ORDER BY name";
            $bincsr = $args{'dbh'}->prepare($binsqlquery);
            $status = $bincsr->execute;
            
            while (@binvalues = $bincsr->fetchrow_array) {
                print "<!-- keep alive bin id: $binvalues[0] -->\n";
                if ($args{'displayUser'} == get_value($args{'dbh'}, $args{'schema'}, 'bin', 'nepareviewer', "id = $binvalues[0]") ) {
                    @row = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.response_version rs,$args{'schema'}.comments com WHERE (rs.document = com.document) AND (rs.commentnum = com.commentnum) AND (com.bin = $binvalues[0]) AND (rs.status = 7) AND (com.dupsimstatus = 1) AND (com.summary IS NULL)");
                    $usrBinCounts[$binvalues[0]][7] = $usrBinCounts[$binvalues[0]][7] + $row[0];
                    $usrBinCounts[$binvalues[0]][0] = $usrBinCounts[$binvalues[0]][0] + $row[0];
                }
                if (0 < get_value($args{'dbh'}, $args{'schema'}, 'comments', 'count(*)', "doereviewer = $args{'displayUser'} AND bin = $binvalues[0]") ) {
                    @row = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.response_version rs,$args{'schema'}.comments com WHERE (rs.document = com.document) AND (rs.commentnum = com.commentnum) AND (com.bin = $binvalues[0]) AND (rs.status = 8) AND (com.dupsimstatus = 1) AND (com.summary IS NULL)");
                    $usrBinCounts[$binvalues[0]][8] = $usrBinCounts[$binvalues[0]][8] + $row[0];
                    $usrBinCounts[$binvalues[0]][0] = $usrBinCounts[$binvalues[0]][0] + $row[0];
                }
                
                @values = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.technical_review tr,$args{'schema'}.comments com WHERE (tr.document = com.document) AND (tr.commentnum = com.commentnum) AND (com.bin = $binvalues[0]) AND (tr.reviewer = $args{'displayUser'}) AND (tr.status = 1) AND (com.dupsimstatus = 1) AND (com.summary IS NULL)");
                $usrBinCounts[$binvalues[0]][3] = $usrBinCounts[$binvalues[0]][3] + $values[0];
                $usrBinCounts[$binvalues[0]][0] = $usrBinCounts[$binvalues[0]][0] + $values[0];
                
                @values = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.response_version rs,$args{'schema'}.comments com WHERE (rs.document = com.document) AND (rs.commentnum = com.commentnum) AND (com.bin = $binvalues[0]) AND (rs.techeditor = $args{'displayUser'}) AND (rs.status = 5) AND (com.dupsimstatus = 1) AND (com.summary IS NULL)");
                $usrBinCounts[$binvalues[0]][5] = $usrBinCounts[$binvalues[0]][5] + $values[0];
                $usrBinCounts[$binvalues[0]][0] = $usrBinCounts[$binvalues[0]][0] + $values[0];

                $outputstring .= "<tr><td colspan=3><hr>$binvalues[1]</td></tr>\n";
                $outputstring .= "<tr><td align=right valign=top> &nbsp; &nbsp; </td><td colspan=2><table border=0 width=100% cellpadding=0 cellspacing=0>\n";
                if ($usrBinCounts[$binvalues[0]][8] > 0) {
                $outputstring .= "<tr><td>" . &SecondReviewName . " Review</td><td align=right>$usrBinCounts[$binvalues[0]][8]" . nbspaces(3) . "</td></tr>\n";}
                if ($usrBinCounts[$binvalues[0]][7] > 0) {
                $outputstring .= "<tr><td>" . &FirstReviewName . " Review</td><td align=right>$usrBinCounts[$binvalues[0]][7]" . nbspaces(3) . "</td></tr>\n";}
                if ($usrBinCounts[$binvalues[0]][6] > 0) {
                $outputstring .= "<tr><td>Accept Response</td><td align=right>$usrBinCounts[$binvalues[0]][6]" . nbspaces(3) . "</td></tr>\n";}
                if ($usrBinCounts[$binvalues[0]][5] > 0) {
                $outputstring .= "<tr><td>Technical Edit</td><td align=right>$usrBinCounts[$binvalues[0]][5]" . nbspaces(3) . "</td></tr>\n";}
                if ($usrBinCounts[$binvalues[0]][3] > 0) {
                $outputstring .= "<tr><td>Technical Review</td><td align=right>$usrBinCounts[$binvalues[0]][3]" . nbspaces(3) . "</td></tr>\n";}
                if (($usrBinCounts[$binvalues[0]][2]+$usrBinCounts[$binvalues[0]][4]) > 0) {
                $outputstring .= "<tr><td>Write/Modify Response</td></td><td align=right>" . ($usrBinCounts[$binvalues[0]][2]+$usrBinCounts[$binvalues[0]][4]) . nbspaces(3) . "</td></tr>\n";}
                if ($usrBinCounts[$binvalues[0]][1] > 0) {
                $outputstring .= "<tr><td>Assign Response</td><td align=right>$usrBinCounts[$binvalues[0]][1]" . nbspaces(3) . "</td></tr>\n";}
                #if ($usrBinCounts[$binvalues[0]][0] > 0) {
                    if ($usrBinCounts[$binvalues[0]][0] > 0) {
                        $outputstring .= "<tr><td width=250></td><td width=70 align=right><hr width=75%></td></tr>\n";
                    }
                    $outputstring .= "<tr><td>Total</td><td align=right>$usrBinCounts[$binvalues[0]][0]" . nbspaces(3) . "</td></tr>\n";
                #} else {
                #    $outputstring .= "<tr><td width=250></td><td width=70 align=right>0" . nbspaces(3) . "</td></tr>\n";
                #}
            
            $outputstring .= "</table></td></tr>\n";
                
            
            }
        }

        if ($args{'type'} eq "System" || $args{'type'} eq "User" || $args{'type'} eq "Bin") {
            $outputstring .= "<tr><td colspan=4><hr></td></tr>\n";
            $outputstring .= "<tr><td colspan=4><hr></td></tr>\n";
            if ($args{'type'} eq "System") {
                $outputstring .= "<tr><td valign=top>Grand Total &nbsp; &nbsp; </td><td valign=top align=right> &nbsp; &nbsp; </td><td colspan=2><table border=0 width=100% cellpadding=0 cellspacing=0>\n";
            }
            if ($args{'type'} eq "User") {
                $outputstring .= "<tr><td valign=top>Grand Total &nbsp; &nbsp; </td><td colspan=2><table border=0 width=100% cellpadding=0 cellspacing=0>\n";
            }
            if ($args{'type'} eq "Bin") {
                $outputstring .= "<tr><td valign=top>Grand Total &nbsp; &nbsp; </td><td colspan=2><table border=0 width=100% cellpadding=0 cellspacing=0>\n";
            }
            if ($totals[8] > 0) {
            $outputstring .= "<tr><td>" . &SecondReviewName . " Review</td><td align=right>$totals[8]" . nbspaces(3) . "</td></tr>\n";}
            if ($totals[7] > 0) {
            $outputstring .= "<tr><td>" . &FirstReviewName . " Review</td><td align=right>$totals[7]" . nbspaces(3) . "</td></tr>\n";}
            if ($totals[6] > 0) {
            $outputstring .= "<tr><td>Accept Response</td><td align=right>$totals[6]" . nbspaces(3) . "</td></tr>\n";}
            if ($totals[5] > 0) {
            $outputstring .= "<tr><td>Technical Edit</td><td align=right>$totals[5]" . nbspaces(3) . "</td></tr>\n";}
            if ($totals[3] > 0) {
            $outputstring .= "<tr><td>Technical Review</td><td align=right>$totals[3]" . nbspaces(3) . "</td></tr>\n";}
            if (($totals[2]+$totals[4]) > 0) {
            $outputstring .= "<tr><td>Write/Modify Response</td><td align=right>" . ($totals[2]+$totals[4]) . nbspaces(3) . "</td></tr>\n";}
            if ($totals[1] > 0) {
            $outputstring .= "<tr><td>Assign Response</td><td align=right>$totals[1]" . nbspaces(3) . "</td></tr>\n";}
            #if ($totals[0] > 0) {
                if ($totals[0] > 0) {
                    $outputstring .= "<tr><td width=250></td><td width=70 align=right><hr width=75%></td></tr>\n";
                }
                $outputstring .= "<tr><td>Total</td><td align=right>$totals[0]" . nbspaces(3) . "</td></tr>\n";
            #} else {
            #    $outputstring .= "<tr><td width=250></td><td width=70 align=right>0" . nbspaces(3) . "</td></tr>\n";
            #}
            
            $outputstring .= "</table></td></tr>\n";
        }
        
        $outputstring .= "</table></td></tr></table>\n";

    
        $outputstring .= "</td></tr></table>\n";
    };

    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate a Workload Report.",$@);
        print doAlertBox( text => $message);
    }

    return ($outputstring);
}


###################################################################################################################################
sub doSummaryCommentReportTest {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        SCR => '',
        @_,
    );
    
    my @row;
    my $sqlquery = '';
    my $message = '';
    my $outputstring = '';
    my $binlist = '';

    eval {
    
        if (defined($args{'SCR'})) {
            if ($args{'SCR'} > 0 && $args{'scrIDType'} eq 'select') {
                $sqlquery = "SELECT count(*) FROM $args{'schema'}.summary_comment WHERE (id=$args{'SCR'})";
            } else {
                if ($args{'bin'} == 0 && $args{'scrIDType'} eq 'select') {
                    $sqlquery = "SELECT count(*) FROM $args{'schema'}.summary_comment scr";
                    if ($args{'changeImpact'} eq 'T') {
                        $sqlquery .= " WHERE scr.changeimpact > 1";
                    }
                } else {
                    if ($args{'scrIDType'} eq 'select') {
                        if ($args{'useSubBins'} eq 'T') {
                            $args{'root_bin'} = $args{'bin'};
                            $binlist = getBinTree(\%args);
                        } else {
                            $binlist = $args{'bin'};
                        }
                        $sqlquery = "SELECT count(*) FROM $args{'schema'}.summary_comment WHERE (bin IN ($binlist))";
                    } else {
                        $sqlquery = "SELECT count(*) FROM $args{'schema'}.summary_comment WHERE (id IN (0,";
                        my $idList = $args{'pasteList'};
                        $idList = lc($idList);
                        $idList =~ s/scr//g;
                        $idList =~ s/ //g;
                        $idList =~ s/\r/\n/g;
                        $idList =~ s/\n\n/\n/g;
                        $idList =~ s/\n/,/g;
                        $idList =~ s/\s//g;
                        while ($idList =~ /,,/) {
                            $idList =~ s/,,/,/g;
                        }
                        if (substr($idList,(length($idList)-1),1) eq ',') {
                            chop($idList);
                        }
                        $sqlquery .= "$idList))";
                        $args{'pasteList'} = $idList;
                    }
                    if ($args{'changeImpact'} eq 'T') {
                        $sqlquery .= " AND changeimpact > 1";
                    }
                }
            }
            print "\n<!-- $sqlquery -->\n\n";
            @row = $args{'dbh'}->selectrow_array($sqlquery);
            $outputstring .= "\n\n<!-- $sqlquery -->\n\n";
            
            if ($row[0] == 0) {
                $outputstring .= "<script language=javascript><!--\n";
                $outputstring .= "    alert('Selections generated an empty report.')\n";
                $outputstring .= "//--></script>\n";
            } else {
                $outputstring .= "<input type=hidden name=scrid value=$args{'SCR'}>\n";
                $outputstring .= "<input type=hidden name=binforscrs value=$args{'bin'}>\n";
                $outputstring .= "<input type=hidden name=includescrcomments value=" . $args{'includeComments'} . ">\n";
                $outputstring .= "<input type=hidden name=scrusesubbins value=" . $args{'useSubBins'} . ">\n";
                $outputstring .= "<input type=hidden name=scruseremarks value=" . $args{'useRemarks'} . ">\n";
                $outputstring .= "<input type=hidden name=scruseorganizations value=" . $args{'useOrganizations'} . ">\n";
                $outputstring .= "<input type=hidden name=scrhaschangeimpact value=" . $args{'changeImpact'} . ">\n";
                $outputstring .= "<input type=hidden name=scrsortbyscr value=" . $args{'sortBySCR'} . ">\n";
                $outputstring .= "<input type=hidden name=scridtype value=" . $args{'scrIDType'} . ">\n";
                $outputstring .= "<input type=hidden name=scridpastelist value=" . $args{'pasteList'} . ">\n";
                $outputstring .= "<script language=javascript><!--\n";
                $outputstring .= "    submitFormNewWindow('$form', 'report','SummaryCommentReport');\n";
                $outputstring .= "//--></script>\n";
            }
        }
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"test for Summary Comment/Response SCR" . lpadzero($args{'SCR'},4) . " in database.",$@);
        print doAlertBox( text => $message);
    }
    return ($outputstring);
}


###################################################################################################################################
sub doSummaryCommentReport {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        SCR => '',
        sortBySCR => 'F',
        @_,
    );
    
    my $outputstring ='';
    my $binlist = '';
    my $sqlquery = '';
    my $scrsqlquery = '';
    my $csr;
    my $scrcsr;
    my @values;
    my @scrvalues;
    my @row;
    my $status;
    my $message='';
    my $count = 0;

    $outputstring .= "<script language=javascript><!--\n";
    $outputstring .= "    document.title='$CRDType Comment/Response Database - Summary Comment/Response Report'\n";
    $outputstring .= "//--></script>\n";
    
    eval {
        $outputstring .= "<table border=0 width=670 cellpadding=0 cellspacing=0><tr><td>\n";
        $outputstring .= "<center><font size=+2>$CRDType Comment/Response Database<br>Summary Comment/Response Report</font><font size=-1><br><br></font>";
        
        $scrsqlquery = "SELECT scr.id, scr.title,scr.commenttext,scr.responsetext,scr.dateapproved,scr.hascommitments,scr.changeimpact,scr.changecontrolnum,";
        $scrsqlquery .= "scr.createdby,scr.datecreated,scr.proofreadby,scr.proofreaddate,scr.bin,scr.responsewriter ";
        $scrsqlquery .= "FROM $args{'schema'}.summary_comment scr, $args{'schema'}.bin bin ";
        $outputstring .= "<font size=-1><br>$args{'run_date'}</font></center>\n";
        
        $scrsqlquery .= "WHERE (scr.bin = bin.id) AND ";
        if ($args{'SCR'} > 0 && $args{'scrIDType'} eq 'select') {
            $scrsqlquery .= "scr.id = $args{'SCR'}";
        } else {
            if ($args{'bin'} == 0 && $args{'scrIDType'} eq 'select') {
                $scrsqlquery .= "(1=1)";
            } else {
                if ($args{'scrIDType'} eq 'select') {
                    if ($args{'useSubBins'} eq 'T') {
                        $args{'root_bin'} = $args{'bin'};
                        $binlist = getBinTree(\%args);
                    } else {
                        $binlist = $args{'bin'};
                    }
                    $scrsqlquery .= "(scr.bin IN ($binlist))";
                } else {
                    $scrsqlquery .= "(scr.id IN (0,";
                    my $idList = $args{'pasteList'};
                    $scrsqlquery .= "$idList))";
                }
            }
        }
        if ($args{'changeImpact'} eq 'T') {
            $scrsqlquery .= " AND scr.changeimpact > 1";
        }
        
        $scrsqlquery .= " ORDER BY " . (($args{sortBySCR} eq 'F') ? "bin.name, " : "") ."scr.id";
        
        $outputstring .= "\n\n<!-- $scrsqlquery -->\n\n";
        
        $scrcsr = $args{'dbh'}->prepare($scrsqlquery);
        $status = $scrcsr->execute;
        
        while (@scrvalues = $scrcsr->fetchrow_array) {
            $count++;
            $outputstring .= "<hr width =75%><br>\n";
            print "<!-- Keep Alive SCR $scrvalues[0] -->\n";
            
            $outputstring .= "<font size=+1>SCR" . lpadzero($scrvalues[0],4) . " - $scrvalues[1]</font><br>\n";
            $outputstring .= "<font size=+1>Created By:" . nbspaces(3) . get_fullname($args{'dbh'}, $args{'schema'}, $scrvalues[13]) . "</font><br>\n";
            $outputstring .= "<font size=+1>Bin:". nbspaces(3) . get_value($args{'dbh'}, $args{'schema'}, 'bin', 'name', "id=$scrvalues[12]") . "</font><br>\n";
            $outputstring .= "<font size=+1>Coordinator:". nbspaces(3) . get_fullname($args{'dbh'}, $args{'schema'}, get_value($args{'dbh'}, $args{'schema'}, 'bin', 'coordinator', "id=$scrvalues[12]")) . "</font><br>\n";
            $outputstring .= "<font size=+1>$CRDType Change Impact:". nbspaces(3) . get_value($args{'dbh'}, $args{'schema'}, 'document_change_impact', 'name', "id=$scrvalues[6]");
            if ($scrvalues[6] != 1) {
                $outputstring .= nbspaces(3) . "Change Control Number:&nbsp; $scrvalues[7]";
            }
            $outputstring .= "</font><br>\n";
            if ($scrvalues[5] eq 'T') {
                $outputstring .= "<font size=+1><b>Has Commitments</b></font><br>\n";
            }
            print "<!-- Keep Alive " . lpadzero($scrvalues[0],4) . " -->\n";
            
            $outputstring .= "<table border=0 width=100%>\n";
            $scrvalues[2] =~ s/\n/<br>/g;
            $scrvalues[2] =~ s/  /&nbsp;&nbsp;/g;
            $outputstring .= "<tr><td><hr></td></tr>\n";
            $outputstring .= "<tr><td><b>Summary Comment:</b></td></tr>\n<tr><td>$scrvalues[2]</td></tr>\n";
            if (defined($scrvalues[3])) {
                if ($scrvalues[3] gt '') {
                    $scrvalues[3] =~ s/\n/<br>/g;
                    $scrvalues[3] =~ s/  /&nbsp;&nbsp;/g;
                    $outputstring .= "<tr><td><hr></td></tr>\n";
                    $outputstring .= "<tr><td><b>Summary Response:</b></td></tr>\n<tr><td>$scrvalues[3]</td></tr>\n";
                }
            }
            if ($args{includeComments} eq 'T' || $args{useOrganizations} eq 'T') {
                $outputstring .= "<tr><td><hr></td></tr>\n";
                if ($args{includeComments} eq 'T') {
                    $outputstring .= "<tr><td><b>Comments Summarized:</b></td></tr>\n";
                } else {
                    $outputstring .= "<tr><td><b>Commentor Organizations:</b></td></tr>\n";
                }
                
                $sqlquery = "SELECT com.document,com.commentnum,com.text,NVL(com.summary,0) ";
                if ($args{useOrganizations} eq 'T') {$sqlquery .= ", NVL(cmntr.organization,'') ";}
                $sqlquery .= "FROM $args{'schema'}.comments com, $args{'schema'}.response_version rv ";
                if ($args{useOrganizations} eq 'T') {$sqlquery .= ", $args{'schema'}.document doc, $args{'schema'}.commentor cmntr ";}
                $sqlquery .= "WHERE (com.document(+)=rv.document AND com.commentnum(+)=rv.commentnum) AND (rv.status NOT IN (10,11,12,13)) ";
                if ($args{useOrganizations} eq 'T') {$sqlquery .= "AND (com.document = doc.id AND doc.commentor = cmntr.id(+))";}
                $sqlquery .= "AND ((com.summary=$scrvalues[0]) OR ((com.summary IS NULL) AND rv.summary=$scrvalues[0])) ";
                if ($args{includeComments} eq 'T') {
                    $sqlquery .= "ORDER BY com.document,com.commentnum";
                } else {
                    $sqlquery .= "ORDER BY cmntr.organization";
                }
                $csr = $args{'dbh'}->prepare($sqlquery);
                $status = $csr->execute;
                my $lastorg = '';
                my $orgcount = 0;
                my $comcount = 0;
                while(@values = $csr->fetchrow_array) {
                    if ($args{includeComments} eq 'T') {
                        $outputstring .= "<tr><td><hr></td></tr>\n";
                        $outputstring .= "<tr><td>$CRDType" . lpadzero($values[0],6) . " / " . lpadzero($values[1],4);
                        if ($values[3] == 0) {$outputstring .= " - Pending";}
                        if ($args{useOrganizations} eq 'T') {$outputstring .= "<br>Commentor Organization: " . ((defined($values[4])) ? $values[4] : "None");}
                        $outputstring .= "</td></tr>\n";
                        $scrvalues[2] =~ s/\n/<br>/g;
                        $scrvalues[2] =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<tr><td>$values[2]</td></tr>\n";
                    } else {
                        if ($values[4] ne $lastorg && $values[4] gt '') {
                            $lastorg = $values[4];
                            $outputstring .= "<tr><td>$values[4]</td></tr>\n";
                            $orgcount++;
                        }
                    }
                    $comcount++;
                }
                if ($args{useOrganizations} eq 'T' && $orgcount == 0) {
                    $outputstring .= "<tr><td>None</td></tr>\n";
                }
                $csr->finish;
                $outputstring .= "<tr><td><br>$comcount comment" . (($comcount != 1) ? 's' : '') . " summarized";
            } else {
                $sqlquery = "SELECT count(*) FROM $args{'schema'}.comments com, $args{'schema'}.response_version rv ";
                $sqlquery .= "WHERE (com.document(+)=rv.document AND com.commentnum(+)=rv.commentnum) AND (rv.status NOT IN (10,11,12,13))";
                $sqlquery .= "AND ((com.summary=$scrvalues[0]) OR ((com.summary IS NULL) AND rv.summary=$scrvalues[0])) ORDER BY com.document,com.commentnum";
                @row = $args{dbh}->selectrow_array($sqlquery);
                $outputstring .= "<tr><td><hr></td></tr>\n";
                $outputstring .= "<tr><td>$row[0] comment" . (($row[0] != 1) ? 's' : '') . " summarized";
                $sqlquery = "SELECT count(*) FROM $args{'schema'}.comments com, $args{'schema'}.response_version rv ";
                $sqlquery .= "WHERE (com.document(+)=rv.document AND com.commentnum(+)=rv.commentnum) AND (rv.status NOT IN (10,11,12,13))";
                $sqlquery .= "AND ((com.summary=$scrvalues[0]) OR ((com.summary IS NULL) AND rv.summary=$scrvalues[0])) AND com.summary IS NULL ";
                $sqlquery .= "ORDER BY com.document,com.commentnum";
                @row = $args{dbh}->selectrow_array($sqlquery);
                if ($row[0] > 0) {
                    $outputstring .= ", $row[0] of which " . (($row[0] != 1) ? 'are' : 'is') . " pending.";
                }
                $outputstring .= "</td></tr>\n";
                
            }
            
            if ($args{useRemarks} eq 'T') {
                @row = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{'schema'}.summary_remark WHERE summarycomment = $scrvalues[0]");
                if ($row[0] > 0) {
                    $outputstring .= "<tr><td><hr></td></tr>\n";
                    $outputstring .= "<tr><td><b>Summary Comment Remarks:</b></td></tr>\n";
                    $outputstring .= "<tr><td><table border=0>\n";
            
                    $sqlquery = "SELECT summarycomment,remarker,TO_CHAR(dateentered, 'DD-MON-YYYY'),text FROM $args{'schema'}.summary_remark WHERE summarycomment = $scrvalues[0]";
                    $csr = $args{'dbh'}->prepare($sqlquery);
                    $status = $csr->execute;
                    while(@values = $csr->fetchrow_array) {
                        $outputstring .= "<tr><td valign=top>" . get_fullname($args{dbh}, $args{schema}, $values[1]) . nbspaces(5) . "<br>";
                        $outputstring .= $values[2] . nbspaces(5) . "</td>\n";
                        $values[3] =~ s/\n/<br>/g;
                        $values[3] =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<td valign=top>$values[3]</td></tr>\n";
                    }
                    $outputstring .= "</table></td></tr>\n";
                    $csr->finish;
                }
            }
            $outputstring .= "</table>\n";
            $outputstring .= "<br><br>\n";
        }
        $scrcsr->finish;
        $outputstring .= "$count Summary Comment" . (($count != 1) ? "s" : "") . " Printed."
        
        
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate a report for Summary Comment/Response SCR" . lpadzero($args{'SCR'},4) . ".",$@);
        print doAlertBox( text => $message);
    }
    
    return($outputstring);
}


###################################################################################################################################
sub doResponseStatusReport {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        startID => 0,
        endID => 999999,
        @_,
    );
    
    my $outputstring ='';
    my $sqlquery = '';
    my $csr;
    my @values;
    my $binsqlquery = '';
    my $bincsr;
    my @binvalues;
    my $binlist;
    my @row;
    my $status;
    my $message='';
    my @counts;
    my @bin_totals = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    my @totals = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

    $outputstring .= "<script language=javascript><!--\n";
    $outputstring .= "    document.title='$CRDType Comment/Response Database - Comment Response Status Report'\n";
    $outputstring .= "//--></script>\n";
    
    eval {
    
        $outputstring .= "<table border=0 width=800 cellpadding=0 cellspacing=0><tr><td>\n";
        $outputstring .= "<center><font size=+1>$CRDType Comment/Response Database<br>Response Status Report</font><br>\n";
        $outputstring .= "Documents $CRDType" . lpadzero($args{startID},6) . " Through $CRDType" . lpadzero($args{endID},6) . "\n";
        $outputstring .= "<font size=-2><br><br></font>";
        $outputstring .= "<font size=-1>$args{'run_date'}</font></center>\n";

        $outputstring .= "<table border=0 width=100% cellpadding=1 cellspacing=0>\n";
        $outputstring .= "<tr><td colspan=13><hr></td></tr>\n";
        $outputstring .= "<tr>\n";
        $outputstring .= "<td valign=bottom align=center><font size=-1>Bin</font></td>\n";
        $outputstring .= "<td valign=bottom align=center><font size=-1>Bin<br>Coord.</font></td>\n";
        $outputstring .= "<td valign=bottom align=center><font size=-1>Dup.<br>Comms.</font></td>\n";
        $outputstring .= "<td valign=bottom align=center><font size=-1>Sum<br>Comms.</font></td>\n";
        $outputstring .= "<td valign=bottom align=center><font size=-1>Bin<br>Coord.<br>Assign</font></td>\n";
        $outputstring .= "<td valign=bottom align=center><font size=-1>Write/<br>Modify<br>Response</font></td>\n";
        $outputstring .= "<td valign=bottom align=center><font size=-1>Tech<br>Review</font></td>\n";
        $outputstring .= "<td valign=bottom align=center><font size=-1>Tech<br>Edit</font></td>\n";
        $outputstring .= "<td valign=bottom align=center><font size=-1>Bin<br>Coord.<br>Accept</font></td>\n";
        $outputstring .= "<td valign=bottom align=center><font size=-1>" . &FirstReviewName . "<br>Review</font></td>\n";
        $outputstring .= "<td valign=bottom align=center><font size=-1>" . &SecondReviewName . "<br>Review</font></td>\n";
        $outputstring .= "<td valign=bottom align=center><font size=-1>Approved</font></td>\n";
        $outputstring .= "<td valign=bottom align=center><font size=-1>Total</font></td>\n";
        $outputstring .= "</tr>\n";
        $outputstring .= "<tr><td colspan=13><hr></td></tr>\n";
        
        $binsqlquery = "SELECT id,name,coordinator FROM $schema.bin WHERE NVL(parent,0) = 0 ORDER BY name";
        $bincsr = $args{'dbh'}->prepare($binsqlquery);
        $status = $bincsr->execute;
        while (@binvalues = $bincsr->fetchrow_array) {
            @bin_totals = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
            foreach my $key (0 .. 15) {
                $counts[$key] =0;
            }
            #$counts[0] =0;
            $args{'root_bin'} = $binvalues[0];
            $binlist = getBinTree(\%args);
            $sqlquery = "SELECT document,commentnum FROM $args{'schema'}.comments WHERE (dupsimstatus =1) AND (NVL(summary,0) = 0) AND (bin IN ( $binlist )) AND document >= $args{'startID'} AND document <= $args{'endID'}";
            $csr = $args{'dbh'}->prepare($sqlquery);
            $status = $csr->execute;
            while (@values = $csr->fetchrow_array) {
                #$counts[get_value($args{'dbh'},$args{'schema'},'response_version','status', "document=$values[0] AND commentnum=$values[1] AND document >= $args('startID') ORDER BY version DESC")] ++;
                $counts[get_value($args{'dbh'},$args{'schema'},'response_version','status', "document=$values[0] AND commentnum=$values[1] AND (status<10 OR status>13) AND document >= $args{'startID'} AND document <= $args{'endID'}")] ++;
                $counts[0]++;
            }
            $csr->finish;
            
            @row = $dbh->selectrow_array("SELECT count(*) FROM $args{'schema'}.comments WHERE dupsimstatus = 2 AND (bin IN ( $binlist )) AND document >= $args{'startID'} AND document <= $args{'endID'}");
            $counts[14] = $row[0];
            @row = $dbh->selectrow_array("SELECT count(*) FROM $args{'schema'}.comments WHERE (NVL(summary,0) != 0) AND dupsimstatus = 1 AND (bin IN ( $binlist )) AND document >= $args{'startID'} AND document <= $args{'endID'}");
            $counts[15] = $row[0];
            
            $bin_totals[0] = $counts[14];
            $bin_totals[1] = $counts[15];
            $bin_totals[2] = $counts[1];
            $bin_totals[3] = $counts[2] + $counts[4];
            $bin_totals[4] = $counts[3];
            $bin_totals[5] = $counts[5];
            $bin_totals[6] = $counts[6];
            $bin_totals[7] = $counts[7];
            $bin_totals[8] = $counts[8];
            $bin_totals[9] = $counts[9];
            $bin_totals[10] = $bin_totals[0] + $bin_totals[1] + $bin_totals[2] + $bin_totals[3] + $bin_totals[4] + $bin_totals[5] + $bin_totals[6] + $bin_totals[7] + $bin_totals[8] + $bin_totals[9];
            
            $totals[0] += $bin_totals[0];
            $totals[1] += $bin_totals[1];
            $totals[2] += $bin_totals[2];
            $totals[3] += $bin_totals[3];
            $totals[4] += $bin_totals[4];
            $totals[5] += $bin_totals[5];
            $totals[6] += $bin_totals[6];
            $totals[7] += $bin_totals[7];
            $totals[8] += $bin_totals[8];
            $totals[9] += $bin_totals[9];
            $totals[10] += $bin_totals[10];
            
            if ($binvalues[0] == 77) {
                $binvalues[1] = "15  EJ/NA";
            }
            
            if ($binvalues[0] == 112) {
                $binvalues[1] = "22  SNF/HLRW";
            }
            
            $outputstring .= "<tr><td><font size=-1>$binvalues[1]</font></td><td><font size=-1>" . get_fullname($args{dbh}, $args{schema}, $binvalues[2]) . "</font></td>\n";
            foreach my $key (0 .. 10) {
                $outputstring .= "<td align=center><font size=-1>$bin_totals[$key]</font></td>";
            }
            $outputstring .= "</tr>\n";
            
        }
        $outputstring .= "<tr><td> &nbsp; </td><td valign=bottom><font size=-1>Total</font></td>\n";
        foreach my $key (0 .. 10) {
            $outputstring .= "<td align=center><hr><font size=-1>$totals[$key]</font></td>";
        }
        $outputstring .= "</tr>\n";
        #$outputstring .= "<tr><td colspan=10><hr></td></tr>\n";
        $outputstring .= "</table>\n";
        $outputstring .= "</td></tr></table>\n";
        
        
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate a Response Status report.",$@);
        print doAlertBox( text => $message);
    }
    
    return($outputstring);
}


###################################################################################################################################
sub doBinCountsReport {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        @_,
    );
    
    my $outputstring ='';
    my $sqlquery = '';
    my $csr;
    my @values;
    my @row;
    my $status;
    my %bins;
    my $totalcomments = 0;
    my $totalsummaries = 0;
    my @binmap;
    my $message='';

    $outputstring .= "<script language=javascript><!--\n";
    $outputstring .= "    document.title='$CRDType Comment/Response Database - Comment and Summary Comment Counts by Bin'\n";
    $outputstring .= "//--></script>\n";
    
    eval {
    
        $outputstring .= "<table border=0 width=670 cellpadding=0 cellspacing=0><tr><td>\n";
        $outputstring .= "<center><font size=+1>$CRDType Comment/Response Database<br>Comment and Summary Comment Counts by Bin</font><font size=-2><br><br></font>";
        $outputstring .= "<font size=-1>$args{'run_date'}</font></center>\n";

        $outputstring .= "<table border=0 width=100% cellpadding=1 cellspacing=0>\n";
        $outputstring .= "<tr><td colspan=9><hr></td></tr>\n";
        $outputstring .= "<tr>\n";
        $outputstring .= "<td valign=bottom><font size=-1>Bin</font></td>\n";
        $outputstring .= "<td> &nbsp; </td>\n";
        $outputstring .= "<td valign=bottom align=center><font size=-1>Original<br>Comments</font></td>\n";
        $outputstring .= "<td> &nbsp; </td>\n";
        $outputstring .= "<td valign=bottom align=center><font size=-1>Summary<br>Comments</font></td>\n";
        $outputstring .= "<td> &nbsp; </td>\n";
        $outputstring .= "<td valign=bottom align=center><font size=-1>Total<br>Comments</font></td>\n";
        $outputstring .= "<td> &nbsp; </td>\n";
        $outputstring .= "<td valign=bottom align=center><font size=-1>Total<br>Summaries</font></td>\n";
        $outputstring .= "</tr>\n";
        $outputstring .= "<tr><td colspan=9><hr></td></tr>\n";
        
        $sqlquery = "SELECT id,name,parent FROM $schema.bin";
        $csr = $args{'dbh'}->prepare($sqlquery);
        $status = $csr->execute;
        while (@values = $csr->fetchrow_array) {
            my ($id,$name,$parent) = @values;
            $binmap[$id] = $name;
            $bins{$name}{parent} = ((defined($parent)) ? $parent : 0);
            $bins{$name}{comments} = 0;
            $bins{$name}{summaries} = 0;
            $bins{$name}{totalcomments} = 0;
            $bins{$name}{totalsummaries} = 0;
        }
        $sqlquery = "SELECT bin FROM $schema.comments WHERE dupsimstatus = 1 AND summary IS NULL";
        $csr = $args{'dbh'}->prepare($sqlquery);
        $status = $csr->execute;
        while (@values = $csr->fetchrow_array) {
            my ($bin) = @values;
            $bins{$binmap[$bin]}{comments}++;
            my $testbin = $bin;
            while ($bins{$binmap[$testbin]}{parent} > 0) {
                $testbin = $bins{$binmap[$testbin]}{parent};
            }
            $bins{$binmap[$testbin]}{totalcomments}++;
            $totalcomments++;
        }
        $csr->finish;
        
        $sqlquery = "SELECT bin FROM $schema.summary_comment";
        $csr = $args{'dbh'}->prepare($sqlquery);
        $status = $csr->execute;
        while (@values = $csr->fetchrow_array) {
            my ($bin) = @values;
            $bins{$binmap[$bin]}{summaries}++;
            my $testbin = $bin;
            while ($bins{$binmap[$testbin]}{parent} > 0) {
                $testbin = $bins{$binmap[$testbin]}{parent};
            }
            $bins{$binmap[$testbin]}{totalsummaries}++;
            $totalsummaries++;
        }
        $csr->finish;
        
        foreach my $key (sort keys %bins) {
            $outputstring .= "<tr><td valign=top><font size=-1>$key</font></td>";
            $outputstring .= "<td>&nbsp;</td>\n";
            $outputstring .= "<td valign=top align=center><font size=-1>$bins{$key}{comments}</font></td>";
            $outputstring .= "<td>&nbsp;</td>\n";
            $outputstring .= "<td valign=top align=center><font size=-1>$bins{$key}{summaries}</font></td>";
            $outputstring .= "<td>&nbsp;</td>\n";
            $outputstring .= "<td valign=top align=center><font size=-1>". (($bins{$key}{totalcomments} > 0) ? $bins{$key}{totalcomments} : "&nbsp;") . "</font></td>";
            $outputstring .= "<td>&nbsp;</td>\n";
            $outputstring .= "<td valign=top align=center><font size=-1>". (($bins{$key}{totalsummaries} > 0) ? $bins{$key}{totalsummaries} : "&nbsp;") . "</font></td>";
            $outputstring .= "</tr>\n";
        }
        
        $outputstring .= "<tr><td><font size=-1><hr><br>Total</td><td colspan=5>&nbsp;</td><td align=center><font size=-1><hr><br>$totalcomments</font></td><td>&nbsp;</td><td align=center><font size=-1><hr><br>$totalsummaries</font></td></tr>\n";
        
        $outputstring .= "</table>\n";
        $outputstring .= "</td></tr></table>\n";
        
        
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate a bin counts report.",$@);
        print doAlertBox( text => $message);
    }
    
    return($outputstring);
}


###################################################################################################################################
sub doOrgCountsReport {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        @_,
    );
    
    my $outputstring ='';
    my $sqlquery = '';
    my $csr;
    my @values;
    my @row;
    my $status;
    my %organizations;
    my $comemnts = 0;
    my $summaries = 0;
    my $totalcomments = 0;
    my $totalsummaries = 0;
    my $message='';

    $outputstring .= "<script language=javascript><!--\n";
    $outputstring .= "    document.title='$CRDType Comment/Response Database - Comment and Summary Comment Counts by Organization'\n";
    $outputstring .= "//--></script>\n";
    
    eval {
    
        $outputstring .= "<table border=0 width=670 cellpadding=0 cellspacing=0><tr><td>\n";
        $outputstring .= "<center><font size=+1>$CRDType Comment/Response Database<br>Comment and Summary Comment Counts by Organization</font><font size=-2><br><br></font>";
        $outputstring .= "<font size=-1>$args{'run_date'}</font></center>\n";

        $outputstring .= "<table border=0 width=100% cellpadding=1 cellspacing=0>\n";
        $outputstring .= "<tr><td colspan=5><hr></td></tr>\n";
        $outputstring .= "<tr>\n";
        $outputstring .= "<td valign=bottom><font size=-1>Organization</font></td>\n";
        $outputstring .= "<td> &nbsp; </td>\n";
        $outputstring .= "<td valign=bottom align=center><font size=-1>Total<br>Comments</font></td>\n";
        $outputstring .= "<td> &nbsp; </td>\n";
        $outputstring .= "<td valign=bottom align=center><font size=-1>#<br>Summarized</font></td>\n";
        $outputstring .= "</tr>\n";
        $outputstring .= "<tr><td colspan=5><hr></td></tr>\n";
        
        $sqlquery = "SELECT cmntr.organization,NVL(com.summary,0) FROM $args{schema}.commentor cmntr,$args{schema}.document doc,$args{schema}.comments com ";
        $sqlquery .= "WHERE (cmntr.id = doc.commentor AND doc.id = com.document) AND cmntr.organization IS NOT NULL ORDER BY cmntr.organization";
        $csr = $args{dbh}->prepare($sqlquery);
        $status = $csr->execute;
        while (@values = $csr->fetchrow_array) {
            my ($org,$summary) = @values;
            if (!defined($organizations{$org}{comments})) {
                $organizations{$org}{comments} = 0;
                $organizations{$org}{summaries} = 0;
            }
            $organizations{$org}{comments}++;
            $totalcomments++;
            if ($summary > 0) {
                $organizations{$org}{summaries}++;
                $totalsummaries++;
            }
        }
        
        foreach my $key (sort keys %organizations) {
            $outputstring .= "<tr><td valign=top><font size=-1>$key</font></td>";
            $outputstring .= "<td>&nbsp;</td>\n";
            $outputstring .= "<td valign=top align=center><font size=-1>$organizations{$key}{comments}</font></td>";
            $outputstring .= "<td>&nbsp;</td>\n";
            $outputstring .= "<td valign=top align=center><font size=-1>$organizations{$key}{summaries}</font></td>";
            $outputstring .= "</tr>\n";
        }
        
        $outputstring .= "<tr><td><font size=-1><hr><br>Total</td><td>&nbsp;</td><td align=center><font size=-1><hr><br>$totalcomments</font></td><td>&nbsp;</td><td align=center><font size=-1><hr><br>$totalsummaries</font></td></tr>\n";
        
        $outputstring .= "</table>\n";
        $outputstring .= "</td></tr></table>\n";
        
        
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate a organization counts report.",$@);
        print doAlertBox( text => $message);
    }
    
    return($outputstring);
}


###################################################################################################################################
sub doBinMappingReport {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        type => 'byBin',
        @_,
    );
    
    my $outputstring ='';
    my $sqlquery = "";
    my $csr;
    my @values;
    my $status;
    my $message='';
    my $comCount;
    my $scrCount;
    my $binID;
    my $binName;
    my $sectionID;
    my $section;
    my $sectionList = "0";

    $outputstring .= "<script language=javascript><!--\n";
    $outputstring .= "    document.title='$CRDType Comment/Response Database - " . (($args{type} eq 'byBin') ? "Bin/Section" : "Section/Bin") . " Mapping Report'\n";
    $outputstring .= "//--></script>\n";
    
    eval {
    
        $outputstring .= "<table border=0 width=670 cellpadding=0 cellspacing=0><tr><td>\n";
        $outputstring .= "<center><font size=+1>$CRDType Comment/Response Database<br>" . (($args{type} eq 'byBin') ? "Bin/Section" : "Section/Bin") . " Mapping Report</font><font size=-2><br><br></font>";
        $outputstring .= "<font size=-1>$args{'run_date'}</font></center>\n";
        
        $outputstring .= "<table border=0 width=100%>\n";
        $outputstring .= "<tr><td align=center valign=bottom><font size=-1>Comment Count</font></td><td align=center valign=bottom><font size=-1>SCR Count</font></td><td valign=bottom><font size=-1>" . (($args{type} eq 'byBin') ? "Bin/Mapped Section" : "Mapped Section/Bin") . "</font></td></tr>\n";
        $outputstring .= "<tr><td><hr></td><td><hr></td><td><hr></td></tr>\n";
        
# report by bin
        if ($args{type} eq 'byBin') {
            $sqlquery = "SELECT id,name,NVL(crd_section,0) FROM $args{schema}.bin ORDER BY name";
            $csr = $args{dbh}->prepare($sqlquery);
            $status = $csr->execute;
            
            while (@values = $csr->fetchrow_array) {
                ($binID, $binName, $sectionID) = @values;
                print "<!-- $binID, $binName, $sectionID -->\n";
                ($comCount) = $dbh->selectrow_array("SELECT count(*) FROM $args{schema}.comments WHERE bin=$binID");
                ($scrCount) = $dbh->selectrow_array("SELECT count(*) FROM $args{schema}.summary_comment WHERE bin=$binID");
                if ($sectionID !=0) {
                    ($section) = $dbh->selectrow_array("SELECT section_number || ' ' || section_name FROM $args{schema}.crd_sections WHERE id=$sectionID");
                    $sectionList .= ",$sectionID";
                } else {
                    $section = "Not Mapped";
                }
                my $doBold = (($sectionID ==0 && ($comCount+$scrCount) > 0) ? "<font color=#000000><b>" : "");
                my $unBold = (($sectionID ==0 && ($comCount+$scrCount) > 0) ? "</b></font>" : "");
                $outputstring .= "<tr><td align=center valign=top><font size=-1>$doBold$comCount$unBold</font></td><td align=center valign=top><font size=-1>$doBold$scrCount$unBold</font></td><td><font size=-1>$doBold$binName<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$section$unBold</font></td></tr>\n";
                $outputstring .= "<tr><td colspan=3 hight=3></td></tr>\n";
            }
            $csr->finish;
        } else {
# report by section
            $sqlquery = "SELECT cs.id, cs.section_number, cs.section_name, NVL(b.id,0), NVL(b.Name,'Not Mapped') FROM $args{schema}.crd_sections cs, $args{schema}.bin b WHERE b.crd_section(+) = cs.id ORDER BY cs.section_number,b.name";
            $csr = $args{dbh}->prepare($sqlquery);
            $status = $csr->execute;
            
            while (@values = $csr->fetchrow_array) {
                my ($sectionID,$sectionNumber,$sectionName, $binID, $binName) = @values;
                print "<!-- $sectionID, $sectionName, $sectionID -->\n";
                ($comCount) = $dbh->selectrow_array("SELECT count(*) FROM $args{schema}.comments WHERE bin=$binID");
                ($scrCount) = $dbh->selectrow_array("SELECT count(*) FROM $args{schema}.summary_comment WHERE bin=$binID");
                ($section) = $dbh->selectrow_array("SELECT section_number || ' ' || section_name FROM $args{schema}.crd_sections WHERE id=$sectionID");
                $sectionList .= ",$sectionID";
                if ($binID != 0) {
                    $sectionList .= ",$sectionID";
                }
                my $doBold = "";
                my $unBold = "";
                $outputstring .= "<tr><td align=center valign=top><font size=-1>$doBold$comCount$unBold</font></td><td align=center valign=top><font size=-1>$doBold$scrCount$unBold</font></td><td><font size=-1>$doBold$section<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$binName$unBold</font></td></tr>\n";
                $outputstring .= "<tr><td colspan=3 hight=3></td></tr>\n";
            }
            $csr->finish;
            $sqlquery = "SELECT id,name,NVL(crd_section,0) FROM $args{schema}.bin WHERE crd_section IS NULL ORDER BY name";
            $csr = $args{dbh}->prepare($sqlquery);
            $status = $csr->execute;
            while (@values = $csr->fetchrow_array) {
                ($binID, $binName, $sectionID) = @values;
                print "<!-- $binID, $binName, $sectionID -->\n";
                ($comCount) = $dbh->selectrow_array("SELECT count(*) FROM $args{schema}.comments WHERE bin=$binID");
                ($scrCount) = $dbh->selectrow_array("SELECT count(*) FROM $args{schema}.summary_comment WHERE bin=$binID");
                $section = "Not Mapped";
                my $doBold = (($sectionID ==0 && ($comCount+$scrCount) > 0) ? "<font color=#000000><b>" : "");
                my $unBold = (($sectionID ==0 && ($comCount+$scrCount) > 0) ? "</b></font>" : "");
                $outputstring .= "<tr><td align=center valign=top><font size=-1>$doBold$comCount$unBold</font></td><td align=center valign=top><font size=-1>$doBold$scrCount$unBold</font></td><td><font size=-1>$doBold$section<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$binName$unBold</font></td></tr>\n";
                $outputstring .= "<tr><td colspan=3 hight=3></td></tr>\n";
            }
            $csr->finish;
            
        }
        $outputstring .= "</table>\n";
        
# report unmapped sections
#        $sqlquery = "SELECT id,section_number,section_name FROM $args{schema}.crd_sections WHERE id NOT IN ($sectionList) AND parent IS NOT NULL ORDER BY section_number";
        $sqlquery = "SELECT id,section_number,section_name FROM $args{schema}.crd_sections WHERE id NOT IN (SELECT UNIQUE crd_section FROM $args{schema}.bin WHERE crd_section IS NOT NULL) AND parent IS NOT NULL ORDER BY section_number";
        $csr = $args{dbh}->prepare($sqlquery);
        $status = $csr->execute;
        
        $outputstring .= "<br>There <count sections> not have Bins mapped.<br><font size=-1>\n";
        my $count = 0;
        while (@values = $csr->fetchrow_array) {
            my ($crdID, $sectionNumber, $sectionName) = @values;
            $outputstring .= "<br>$sectionNumber $sectionName\n";
            $count++;
        }
        $csr->finish;
        my $tempString = (($count != 1) ? "are $count sections that do" : "is $count section that does");
        $outputstring =~ s/<count sections>/$tempString/;
        
        $outputstring .= "</font>\n";
        
# report unmapped bins
        $sqlquery = "SELECT id,name FROM $args{schema}.bin WHERE crd_section IS NULL ORDER BY name";
        $csr = $args{dbh}->prepare($sqlquery);
        $status = $csr->execute;
        
        $outputstring .= "<br><br>There <count bins> not have CRD Sections mapped.<br><font size=-1>\n";
        $count = 0;
        while (@values = $csr->fetchrow_array) {
            my ($ID, $Name) = @values;
            $outputstring .= "<br>$Name\n";
            $count++;
        }
        $csr->finish;
        $tempString = (($count != 1) ? "are $count bins that do" : "is $count bin that does");
        $outputstring =~ s/<count bins>/$tempString/;
        
        $outputstring .= "</font>\n";


        $outputstring .= "</td></tr></table>\n";
        
        
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate a bin/section mapping report.",$@);
        print doAlertBox( text => $message);
    }
    
    return($outputstring);
}


###################################################################################################################################
sub doEvaluationFactorReport {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        beginDate => '',
        endDate => '',
        @_,
    );
    
    my $outputstring ='';
    my $sqlquery = "";
    my $csr;
    my @values;
    my $status;
    my $message='';
    my @factorCounts;
    my @subTotalCounts;
    my $countOfFactors = 0;
    my $countOfAffiliations = 0;
    my @affiliationMap;
    my @factorMap;
    my $secInDay = 60*60*24;
    my $beginTime = timelocal(0,0,0,(substr($args{beginDate},6,2) - 0),(substr($args{beginDate},4,2) - 1),(substr($args{beginDate},0,4) - 1900));
    my @previousDay = localtime($beginTime - $secInDay);
    my $PreviousDay = lpadzero(($previousDay[4]+1),2) . "/" . lpadzero($previousDay[3],2) . "/" . ($previousDay[5] + 1900);
    my @now = localtime;
    my $today = lpadzero(($now[4]+1),2) . "/" . lpadzero($now[3],2) . "/" . ($now[5] + 1900);
    my $firstDocumentDate;
    
    $outputstring .= "<script language=javascript><!--\n";
    $outputstring .= "    document.title='$CRDType Comment/Response Database - Evaluation Factor Report'\n";
    $outputstring .= "//--></script>\n";
    
    eval {
    
        $firstDocumentDate = get_value($args{dbh},$args{schema},'document', "TO_CHAR(datereceived,'MM/DD/YYYY')", ' 1=1 ORDER BY datereceived');
        
        $outputstring .= "<table border=0 width=900 cellpadding=0 cellspacing=0><tr><td>\n";
        $outputstring .= "<center>$CRDType Comment/Response Database<br>Evaluation Factor Report<font size=-3><br></font>";
        $outputstring .= "<font size=-2>$args{'run_date'}</font></center>\n";
        
        $sqlquery = "SELECT id,name FROM $args{schema}.evaluation_factor ORDER BY id";
        $csr = $args{dbh}->prepare($sqlquery);
        $status = $csr->execute;
        
        while (my ($id, $name) = $csr->fetchrow_array) {
            $countOfFactors++;
            $factorCounts[0][$countOfFactors] = $name;
            $factorMap[$id] = $countOfFactors;
        }
        $csr->finish;
        $factorCounts[0][++$countOfFactors] = "TOTAL";
        
        $sqlquery = "SELECT id,name FROM $args{schema}.commentor_affiliation ORDER BY name";
        $csr = $args{dbh}->prepare($sqlquery);
        $status = $csr->execute;
        
        while (my ($id, $name) = $csr->fetchrow_array) {
            $countOfAffiliations++;
            $name =~ s/(\w+)/\u\L$1/g;
            $name =~ s/Nv/NV/g;
            $name =~ s/ /&nbsp;/g;
            $factorCounts[$countOfAffiliations][0] = $name;
            $affiliationMap[$id] = $countOfAffiliations;
        }
        $csr->finish;
        $factorCounts[++$countOfAffiliations][0] = "Grand Total";
        
        for (my $i=1; $i<=$countOfAffiliations; $i++) {
            for (my $j=1; $j<=$countOfFactors; $j++) {
                $factorCounts[$i][$j] = 0;
            }
        }
        for (my $j=1; $j<=$countOfFactors; $j++) {
            $subTotalCounts[0][$j] = 0;
            $subTotalCounts[1][$j] = 0;
        }
        
        $sqlquery = "SELECT d.id,d.evaluationfactor,c.id,NVL(c.affiliation,1),TO_CHAR(d.datereceived,'YYYYMMDD') FROM $args{schema}.document d, $args{schema}.commentor c WHERE (d.commentor = c.id(+)) AND d.evaluationfactor IS NOT NULL";
        $csr = $args{dbh}->prepare($sqlquery);
        $status = $csr->execute;
        while (my ($docID, $evaluationFactor, $comID, $affiliation,$dateReceived) = $csr->fetchrow_array) {
            $factorCounts[$affiliationMap[$affiliation]][$factorMap[$evaluationFactor]]++;
            $factorCounts[$affiliationMap[$affiliation]][$countOfFactors]++;
            $factorCounts[$countOfAffiliations][$factorMap[$evaluationFactor]]++;
            $factorCounts[$countOfAffiliations][$countOfFactors]++;
            if ($dateReceived lt $args{beginDate}) {
                $subTotalCounts[0][$factorMap[$evaluationFactor]]++;
                $subTotalCounts[0][$countOfFactors]++;
            } elsif ($dateReceived ge $args{beginDate} && $dateReceived le $args{endDate}) {
                $subTotalCounts[1][$factorMap[$evaluationFactor]]++;
                $subTotalCounts[1][$countOfFactors]++;
            }
        }
        $csr->finish;
        $outputstring .= "<table border=1 cellpadding=2 cellspacing=0 align=center>\n";
        $outputstring .= "<tr><td align=center><font size=-2>$firstDocumentDate - $today<br>This Table provides Qualitative Ratings of $factorCounts[$countOfAffiliations][$countOfFactors] Comment Documents by Category as provided below.</font></td>\n";
        for (my $j=1; $j<=$countOfFactors; $j++) {
            $outputstring .= "<td valign=bottom align=center><font size=-2>$factorCounts[0][$j]</font></td>\n";
        }
        $outputstring .= "</tr>\n";
        
        for (my $i=1; $i<$countOfAffiliations; $i++) {
            $outputstring .= "<tr><td valign=top><font size=-2>$factorCounts[$i][0]</font></td>";
            if ($i != $countOfAffiliations) {
                for (my $j=1; $j<=$countOfFactors; $j++) {
                    if ($j == $countOfFactors) {
                        no integer;
                        my $percent = sprintf "%1.1f",($factorCounts[$i][$j]/((($factorCounts[$countOfAffiliations][$j] != 0) ? $factorCounts[$countOfAffiliations][$j] : 1))*100.0);
                        $outputstring .= "<td valign=top align=center><table border=0 cellpadding=0 cellspacing=0><td width=50% valign=top align=center><font size=-2>$factorCounts[$i][$j]</font></td><td width=50% valign=top align=center><font size=-2>($percent%)</font></td></table></td>\n";
                    } else {
                        $outputstring .= "<td valign=top align=center><font size=-2>$factorCounts[$i][$j]</font></td>\n";
                    }
                }
            } else {
                for (my $j=1; $j<=$countOfFactors; $j++) {
                    if ($j != $countOfFactors) {
                        no integer;
                        my $percent = sprintf "%1.1f",($factorCounts[$i][$j]/((($factorCounts[$countOfAffiliations][$countOfFactors] != 0) ? $factorCounts[$countOfAffiliations][$countOfFactors] : 1))*100.0);
                        $outputstring .= "<td valign=top align=center><table border=0 cellpadding=0 cellspacing=0><td width=50% valign=top align=center><font size=-2>$factorCounts[$i][$j]</font></td><td width=50% valign=top align=center><font size=-2>($percent%)</font></td></table></td>\n";
                    } else {
                        $outputstring .= "<td valign=top align=center><font size=-2>$factorCounts[$i][$j]</font></td>\n";
                    }
                }
            }
            $outputstring .= "</tr>\n";
        }
        
        $outputstring .= "<tr><td colspan=" . ($countOfFactors + 1) . " height=5></td></tr>\n";
        
        $outputstring .= "<tr><td valign=top><font size=-2>Subtotal for $firstDocumentDate - $PreviousDay</font></td>";
        for (my $j=1; $j<=$countOfFactors; $j++) {
            if ($j != $countOfFactors) {
                no integer;
                my $percent = sprintf "%1.1f",($subTotalCounts[0][$j]/((($subTotalCounts[0][$countOfFactors] != 0) ? $subTotalCounts[0][$countOfFactors] : 1))*100.0);
                $outputstring .= "<td valign=top align=center><table border=0 cellpadding=0 cellspacing=0><td width=50% valign=top align=center><font size=-2>$subTotalCounts[0][$j]</font></td><td width=50% valign=top align=center><font size=-2>($percent%)</font></td></table></td>\n";
            } else {
                $outputstring .= "<td valign=top align=center><font size=-2>$subTotalCounts[0][$j]</font></td>\n";
            }
        }
        $outputstring .= "</tr>\n";
        
        $outputstring .= "<tr><td valign=top><font size=-2>Subtotal for " . substr($args{beginDate},4,2) . "/" . substr($args{beginDate},6,2) . "/" . substr($args{beginDate},0,4) . " - " . substr($args{endDate},4,2) . "/" . substr($args{endDate},6,2) . "/" . substr($args{endDate},0,4) . "</font></td>";
        for (my $j=1; $j<=$countOfFactors; $j++) {
            if ($j != $countOfFactors) {
                no integer;
                my $percent = sprintf "%1.1f",($subTotalCounts[1][$j]/((($subTotalCounts[1][$countOfFactors] != 0) ? $subTotalCounts[1][$countOfFactors] : 1))*100.0);
                $outputstring .= "<td valign=top align=center><table border=0 cellpadding=0 cellspacing=0><td width=50% valign=top align=center><font size=-2>$subTotalCounts[1][$j]</font></td><td width=50% valign=top align=center><font size=-2>($percent%)</font></td></table></td>\n";
            } else {
                $outputstring .= "<td valign=top align=center><font size=-2>$subTotalCounts[1][$j]</font></td>\n";
            }
        }
        $outputstring .= "</tr>\n";
        
        my $i = $countOfAffiliations;
        $outputstring .= "<tr><td valign=top><font size=-2>$factorCounts[$i][0]</font></td>";
        for (my $j=1; $j<=$countOfFactors; $j++) {
            if ($j != $countOfFactors) {
                no integer;
                my $percent = sprintf "%1.1f",($factorCounts[$i][$j]/((($factorCounts[$countOfAffiliations][$countOfFactors] != 0) ? $factorCounts[$countOfAffiliations][$countOfFactors] : 1))*100.0);
                $outputstring .= "<td valign=top align=center><table border=0 cellpadding=0 cellspacing=0><td width=50% valign=top align=center><font size=-2>$factorCounts[$i][$j]</font></td><td width=50% valign=top align=center><font size=-2>($percent%)</font></td></table></td>\n";
            } else {
                $outputstring .= "<td valign=top align=center><font size=-2>$factorCounts[$i][$j]</font></td>\n";
            }
        }
        $outputstring .= "</tr>\n";
        
        $outputstring .= "</table>\n";
        
        $outputstring .= &EvaluationFactorReportSubText;

        $outputstring .= "</td></tr></table>\n";
        
        
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate an evaluation factor report.",$@);
        print doAlertBox( text => $message);
    }
    
    return($outputstring);
}


###################################################################################################################################
sub doConcurrenceSummaryReport {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        @_,
    );
    
    my $outputstring ='';
    my $sqlquery;
    my $csr;
    my @values;
    my $bincsr;
    my @binvalues;
    my $status;
    my $message='';
    my $count;
    my $binID;
    my $binName;
    my $binList;
    my @concurrerList;
    my %cCounts;
    my %cTotals;

    $outputstring .= "<script language=javascript><!--\n";
    $outputstring .= "    document.title='$CRDType Comment/Response Database - Concurrence Summary Report'\n";
    $outputstring .= "//--></script>\n";
    
    eval {
    
        $outputstring .= "<table border=0 width=670 cellpadding=0 cellspacing=0><tr><td>\n";
        $outputstring .= "<center><font size=+1>$CRDType Comment/Response Database<br>Concurrence Summary Report</font><font size=-2><br><br></font>";
        $outputstring .= "<font size=-1>$args{'run_date'}<br>&nbsp;</font></center>\n";
        
        $outputstring .= "<table border=1 cellspacing=0 cellspacing=0 width=100%>\n";
        $outputstring .= "<tr><td align=center valign=center rowspan=3><font size=-1>Bin</font></td><td align=center valign=center rowspan=3><font size=-1>Concurring<br>Agency</font></td>\n";
        $outputstring .= "<td align=center valign=center rowspan=2 colspan=3><font size=-1>Summary<br>Comment/<br>Responses</font></td>\n";
        $outputstring .= "<td align=center valign=center colspan=9><font size=-1>Individual Comment/Responses</font></td></tr>\n";
        $outputstring .= "<tr><td align=center valign=center colspan=3><font size=-1>" . &FirstReviewName . "<br>Review</font></td>\n";
        $outputstring .= "<td align=center valign=center colspan=3><font size=-1>" . &SecondReviewName . "<br>Review</font></td>\n";
        $outputstring .= "<td align=center valign=center colspan=3><font size=-1>Approved</font></td></tr>\n";
        $outputstring .= "<tr>";
        my $colSize = 40;
        foreach my $i (1..4) {
            $outputstring .= "<td align=center valign=center width=$colSize><font size=-1>Y</font></td><td align=center valign=center width=$colSize><font size=-1>N</font></td><td align=center valign=center width=$colSize><font size=-1>Not<br>Entered</font></td>\n";
        }
        $outputstring .= "</tr>\n";
        $outputstring .= "</tr>\n";
        
        $sqlquery = "SELECT id, name FROM $args{schema}.concurrence_type ORDER BY name";
        $csr = $args{dbh}->prepare($sqlquery);
        $status = $csr->execute;
        my $count=0;
        while (@values = $csr->fetchrow_array) {
            my $concurrerID = $values[0];
            $concurrerList[$count][0] = $concurrerID;
            $concurrerList[$count][1] = $values[1];
            $cTotals{summary}[$concurrerID][0] = 0;
            $cTotals{summary}[$concurrerID][1] = 0;
            $cTotals{summary}[$concurrerID][2] = 0;
            $cTotals{first}[$concurrerID][0] = 0;
            $cTotals{first}[$concurrerID][1] = 0;
            $cTotals{first}[$concurrerID][2] = 0;
            $cTotals{second}[$concurrerID][0] = 0;
            $cTotals{second}[$concurrerID][1] = 0;
            $cTotals{second}[$concurrerID][2] = 0;
            $cTotals{approved}[$concurrerID][0] = 0;
            $cTotals{approved}[$concurrerID][1] = 0;
            $cTotals{approved}[$concurrerID][2] = 0;
            $count++;
        }
        $csr->finish;
        
        $sqlquery = "SELECT id,name FROM $args{schema}.bin WHERE parent IS NULL ORDER BY name";
        $bincsr = $args{dbh}->prepare($sqlquery);
        $status = $bincsr->execute;
        while (($binID, $binName) = $bincsr->fetchrow_array) {
            my ($binNumber, $binShortName) = getBinNumber ('binName' => $binName);
            $outputstring .= "<tr><td rowspan=2 align=center valiagn=center><font size=-1>$binNumber</font></td>\n";
            $args{root_bin} = $binID;
            $binList = getBinTree (\%args);
            
            for (my $i=0; $i<= $#concurrerList; $i++) {
                my $concurrerID = $concurrerList[$i][0];
                $outputstring .= (($i == 0) ? "" : "<tr>") . "<td align=center><font size=-1>" . $concurrerList[$i][1] . "</font></td>";
                $cCounts{summary}[0] = 0;
                $cCounts{summary}[1] = 0;
                $cCounts{summary}[2] = 0;
                $cCounts{first}[0] = 0;
                $cCounts{first}[1] = 0;
                $cCounts{first}[2] = 0;
                $cCounts{second}[0] = 0;
                $cCounts{second}[1] = 0;
                $cCounts{second}[2] = 0;
                $cCounts{approved}[0] = 0;
                $cCounts{approved}[1] = 0;
                $cCounts{approved}[2] = 0;
                ($count) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.summary_comment sc WHERE sc.bin IN ($binList) AND sc.dateapproved IS NOT NULL");
                ($cCounts{summary}[0]) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.summary_comment sc, $args{schema}.concurrence_summary c WHERE (sc.id = c.summarycomment) AND sc.dateapproved IS NOT NULL AND c.concurrencetype = $concurrerID AND c.concurs = 'T' AND sc.bin IN ($binList)");
                ($cCounts{summary}[1]) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.summary_comment sc, $args{schema}.concurrence_summary c WHERE (sc.id = c.summarycomment) AND sc.dateapproved IS NOT NULL AND c.concurrencetype = $concurrerID AND c.concurs = 'F' AND sc.bin IN ($binList)");
                $cCounts{summary}[2] = $count - ($cCounts{summary}[0] + $cCounts{summary}[1]);
                $cTotals{summary}[$concurrerID][0] += $cCounts{summary}[0];
                $cTotals{summary}[$concurrerID][1] += $cCounts{summary}[1];
                $cTotals{summary}[$concurrerID][2] += $cCounts{summary}[2];
                ($count) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.response_version rv, $args{schema}.comments com WHERE (rv.document=com.document AND rv.commentnum=com.commentnum) AND rv.status=7 AND com.bin IN ($binList)");
                ($cCounts{first}[0]) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.response_version rv, $args{schema}.comments com, $args{schema}.concurrence c WHERE (rv.document=com.document AND rv.commentnum=com.commentnum) AND (rv.document = c.document AND rv.commentnum = c.commentnum) AND rv.status=7 AND c.concurrencetype = $concurrerID AND c.concurs = 'T' AND com.bin IN ($binList)");
                ($cCounts{first}[1]) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.response_version rv, $args{schema}.comments com, $args{schema}.concurrence c WHERE (rv.document=com.document AND rv.commentnum=com.commentnum) AND (rv.document = c.document AND rv.commentnum = c.commentnum) AND rv.status=7 AND c.concurrencetype = $concurrerID AND c.concurs = 'F' AND com.bin IN ($binList)");
                $cCounts{first}[2] = $count - ($cCounts{first}[0] + $cCounts{first}[1]);
                $cTotals{first}[$concurrerID][0] += $cCounts{first}[0];
                $cTotals{first}[$concurrerID][1] += $cCounts{first}[1];
                $cTotals{first}[$concurrerID][2] += $cCounts{first}[2];
                ($count) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.response_version rv, $args{schema}.comments com WHERE (rv.document=com.document AND rv.commentnum=com.commentnum) AND rv.status=8 AND com.bin IN ($binList)");
                ($cCounts{second}[0]) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.response_version rv, $args{schema}.comments com, $args{schema}.concurrence c WHERE (rv.document=com.document AND rv.commentnum=com.commentnum) AND (rv.document = c.document AND rv.commentnum = c.commentnum) AND rv.status=8 AND c.concurrencetype = $concurrerID AND c.concurs = 'T' AND com.bin IN ($binList)");
                ($cCounts{second}[1]) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.response_version rv, $args{schema}.comments com, $args{schema}.concurrence c WHERE (rv.document=com.document AND rv.commentnum=com.commentnum) AND (rv.document = c.document AND rv.commentnum = c.commentnum) AND rv.status=8 AND c.concurrencetype = $concurrerID AND c.concurs = 'F' AND com.bin IN ($binList)");
                $cCounts{second}[2] = $count - ($cCounts{second}[0] + $cCounts{second}[1]);
                $cTotals{second}[$concurrerID][0] += $cCounts{second}[0];
                $cTotals{second}[$concurrerID][1] += $cCounts{second}[1];
                $cTotals{second}[$concurrerID][2] += $cCounts{second}[2];
                ($count) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.response_version rv, $args{schema}.comments com WHERE (rv.document=com.document AND rv.commentnum=com.commentnum) AND rv.status=9 AND com.bin IN ($binList)");
                ($cCounts{approved}[0]) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.response_version rv, $args{schema}.comments com, $args{schema}.concurrence c WHERE (rv.document=com.document AND rv.commentnum=com.commentnum) AND (rv.document = c.document AND rv.commentnum = c.commentnum) AND rv.status=9 AND c.concurrencetype = $concurrerID AND c.concurs = 'T' AND com.bin IN ($binList)");
                ($cCounts{approved}[1]) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.response_version rv, $args{schema}.comments com, $args{schema}.concurrence c WHERE (rv.document=com.document AND rv.commentnum=com.commentnum) AND (rv.document = c.document AND rv.commentnum = c.commentnum) AND rv.status=9 AND c.concurrencetype = $concurrerID AND c.concurs = 'F' AND com.bin IN ($binList)");
                $cCounts{approved}[2] = $count - ($cCounts{approved}[0] + $cCounts{approved}[1]);
                $cTotals{approved}[$concurrerID][0] += $cCounts{approved}[0];
                $cTotals{approved}[$concurrerID][1] += $cCounts{approved}[1];
                $cTotals{approved}[$concurrerID][2] += $cCounts{approved}[2];
                
                foreach my $key ('summary','first','second','approved') {
                    foreach my $j (0..2) {
                        $outputstring .= "<td align=center><font size=-1>$cCounts{$key}[$j]</font></td>";
                    }
                }
                
                $outputstring .= "</tr>\n";
            }
        
        }
        $bincsr->finish;
        
        $outputstring .= "<tr><td colspan=14 height=4></td></tr>\n";
        $outputstring .= "<tr><td rowspan=2 align=center><font size=-1>Totals</font></td>";
        for (my $i=0; $i<= $#concurrerList; $i++) {
            my $concurrerID = $concurrerList[$i][0];
            $outputstring .= (($i==0) ? "" : "<tr>") . "<td align=center><font size=-1>$concurrerList[$i][1]</font></td>";
            foreach my $key ('summary','first','second','approved') {
                foreach my $j (0..2) {
                    $outputstring .= "<td align=center><font size=-1>$cTotals{$key}[$concurrerID][$j]</font></td>";
                }
            }
            $outputstring .= "</tr>\n";
        }

        $outputstring .= "</table>\n";
        $outputstring .= "</td></tr></table>\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate a concurrence summary report.",$@);
        print doAlertBox( text => $message);
    }
    
    return($outputstring);
}


###################################################################################################################################
sub doFinalCRDIndex4Report {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        @_,
    );
    
    my $outputstring ='';
    my $sqlquery;
    my $csr;
    my $csr2;
    my $csr3;
    my @values;
    my $status;
    my $message='';
    my %indexLocation;

    $outputstring .= "<script language=javascript><!--\n";
    $outputstring .= "    document.title='$CRDType Comment/Response Database - Final CRD Index 4'\n";
    $outputstring .= "//--></script>\n";
    
    eval {
        $sqlquery = "SELECT b.id,c.section_number FROM $args{schema}.bin b, $args{schema}.crd_sections c WHERE b.crd_section=c.id ORDER BY c.section_number";
        $csr = $args{dbh}->prepare ($sqlquery);
        $status = $csr->execute;
        while (my ($binID, $crdSection) = $csr->fetchrow_array) {
            $sqlquery = "SELECT document, commentnum, uniqueid FROM $args{schema}.comments WHERE bin = $binID AND dupsimstatus = 1 AND summary IS NULL ORDER BY document, commentnum";
            $csr2 = $args{dbh}->prepare ($sqlquery);
            $status = $csr2->execute;
            while (my ($documentID, $commentID, $uniqueID) = $csr2->fetchrow_array) {
                $indexLocation{("$CRDType" . lpadzero($documentID,6) . " / " . lpadzero($commentID,4))} = "$crdSection ($uniqueID)";
            }
            $csr2->finish;

            $sqlquery = "SELECT id, uniqueid FROM $args{schema}.summary_comment WHERE bin = $binID AND uniqueid IS NOT NULL ORDER BY id";
            $csr2 = $args{dbh}->prepare ($sqlquery);
            $status = $csr2->execute;
            while (my ($scrID, $uniqueID) = $csr2->fetchrow_array) {
                $indexLocation{("SCR" . lpadzero($scrID,4))} = "$crdSection ($uniqueID)";
                $sqlquery = "SELECT document, commentnum, uniqueid FROM $args{schema}.comments WHERE summary=$scrID ORDER BY document, commentnum";
                $csr3 = $args{dbh}->prepare ($sqlquery);
                $status = $csr3->execute;
                while (my ($documentID, $commentID, $uniqueID) = $csr3->fetchrow_array) {
                    $indexLocation{("$CRDType" . lpadzero($documentID,6) . " / " . lpadzero($commentID,4))} = "$crdSection ($uniqueID) [SCR" . lpadzero($scrID,4) . "]";
                }
                $csr3->finish;
            }
            $csr2->finish;
            
        }
        $csr->finish;
        
        my $fontSize = 3;
        
        $outputstring .= "<center><font size=+1>$CRDType Comment/Response Database<br>Index To Final CRD Chapters By Comment Number Report</font><font size=-2><br><br></font>";
        $outputstring .= "<font size=-1>$args{'run_date'}<br>&nbsp;</font></center>\n";
        $outputstring .= "<table border=0 width=670 align=center>";
        $outputstring .= "<tr><td align=center valgin=bottom>&nbsp;</td>";
        $outputstring .= "<td align=center valgin=bottom width=45%><font size=$fontSize><b>Comment&nbsp;Document&nbsp;/<br>Comment&nbsp;No.</b></font></td><td valgin=bottom>&nbsp;</td>";
        $outputstring .= "<td align=center valgin=bottom width=45%><font size=$fontSize><b>Comment&nbsp;Location</b></font></td><td align=center valgin=bottom>&nbsp;</td>";
        $outputstring .= "</tr>\n";
        $outputstring .= "<tr><td colspan=5><hr width=100% align=center></td></tr>\n";
        
        foreach my $key (sort keys %indexLocation) {
            
            $outputstring .= "<tr>";
            $outputstring .= "<td>&nbsp;</td><td valign=top align=center><font size=$fontSize>$key</font></td>";
            $outputstring .= "<td>&nbsp;</td><td valign=top align=center><font size=$fontSize>$indexLocation{$key}</font></td>";
            $outputstring .= "<td>&nbsp;</td></tr>\n";
            #$outputstring .= .= "<br>$key - $indexLocation{$key}\n";
        }
        
        $outputstring .= "</table>\n";
    
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate a final CRD index 4 report.",$@);
        print doAlertBox( text => $message);
    }
    
    return($outputstring);
}


###################################################################################################################################
sub doConcurrenceReport {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        showIndividual => 'T',
        showSCR => 'T',
        firstReview => 'T',
        secondReview => 'T',
        approved => 'T',
        firstNone => 'T',
        firstPostitive => 'T',
        firstNegative => 'T',
        secondNone => 'T',
        secondPositive => 'T',
        secondNegative => 'T',
        root_bin => 0,
        test => 'F',
        @_,
    );
    
    my $outputstring ='';
    my $sqlquery;
    my $csr;
    my @values;
    my $bincsr;
    my @binvalues;
    my $status;
    my $message='';
    my $count;
    my $binID;
    my $binName;
    my $binList;
    my @concurrerList;
    my @concurList;
    my %cCounts;
    my @cTotals;
    my @iTotals;
    my @sTotals;
    my $statusList = "0";
    my $foundItemCount = 0;
    my $showFirst = (($args{firstNone} eq 'T' || $args{firstPositive} eq 'T' || $args{firstNegative} eq 'T') ? 'T' : 'F');
    my $showSecond = (($args{secondNone} eq 'T' || $args{secondPositive} eq 'T' || $args{secondNegative} eq 'T') ? 'T' : 'F');
    my @showConcurrer = ($showFirst, $showSecond);

    $outputstring .= "<script language=javascript><!--\n";
    $outputstring .= "    document.title='$CRDType Comment/Response Database - Concurrence Report'\n";
    $outputstring .= "//--></script>\n";
    
    eval {
    
        if ($args{test} ne 'T') {
            $outputstring .= "<table border=0 width=670 cellpadding=0 cellspacing=0><tr><td>\n";
            $outputstring .= "<center><font size=+1>$CRDType Comment/Response Database<br>Concurrence Report</font>\n";
            $outputstring .= (($args{root_bin} != 0) ? "<br>" . get_value($args{dbh},$args{schema},'bin','name',"id=$args{root_bin}") : "");
            $outputstring .= "<font size=-2><br><br></font>";
            $outputstring .= "<font size=-1>$args{'run_date'}<br>&nbsp;</font></center>\n";
        }
            
        $sqlquery = "SELECT id, name FROM $args{schema}.concurrence_type ORDER BY name";
        $csr = $args{dbh}->prepare($sqlquery);
        $status = $csr->execute;
        my $count=0;
        while (@values = $csr->fetchrow_array) {
            my $concurrerID = $values[0];
            $concurrerList[$count][0] = $concurrerID;
            $concurrerList[$count][1] = $values[1];
            $iTotals[$concurrerID][0] = 0;
            $iTotals[$concurrerID][1] = 0;
            $iTotals[$concurrerID][2] = 0;
            $sTotals[$concurrerID][0] = 0;
            $sTotals[$concurrerID][1] = 0;
            $sTotals[$concurrerID][2] = 0;
            $count++;
        }
        $csr->finish;
            
        if ($args{test} ne 'T') {
            $outputstring .= "<table border=0 width=100%>\n";
            $outputstring .= "<tr><td align=center valign=center><font size=-1><br>ID<br><hr></font></td><td align=center valign=center><font size=-1><br>Response<br><hr></font></td>\n";
            for (my $i=0; $i<= $#concurrerList; $i++) {
                if ($showConcurrer[$i] eq 'T') {
                    $outputstring .= "<td align=center valign=center><font size=-1>$concurrerList[$i][1]<br>Concurrence<br><hr></font></td>\n";
                }
            }
            $outputstring .= "</tr>\n";
        }
        if ($args{showIndividual} eq 'T') {
            if ($args{firstReview} eq 'T') {$statusList .= ',7';}
            if ($args{secondReview} eq 'T') {$statusList .= ',8';}
            if ($args{approved} eq 'T') {$statusList .= ',9';}
            if ($args{root_bin} eq 0) {
                $sqlquery = "SELECT rv.document,rv.commentnum,rv.lastsubmittedtext FROM $args{schema}.response_version rv WHERE rv.status IN ($statusList) ORDER BY rv.document,rv.commentnum";
            } else {
                $binList = getBinTree (\%args);
                $sqlquery = "SELECT rv.document,rv.commentnum,rv.lastsubmittedtext FROM $args{schema}.response_version rv, $args{schema}.comments com WHERE (rv.document=com.document AND rv.commentnum=com.commentnum) AND com.bin IN ($binList) AND rv.status IN ($statusList) ORDER BY rv.document,rv.commentnum";
            }
            $csr = $args{dbh}->prepare($sqlquery);
            $status = $csr->execute;
            
            while (my($docID, $comID, $text) = $csr->fetchrow_array) {
                for (my $i=0; $i<= $#concurrerList; $i++) {
                    my $concurrerID = $concurrerList[$i][0];
                    my $concurrence;
                    if ($showConcurrer[$i] eq 'T') {
                        $concurrence = get_value($args{'dbh'},$args{'schema'},'concurrence','concurs',"document=$docID AND commentnum=$comID AND concurrencetype=$concurrerID");
                    } else {
                        $concurrence = 'N';
                    }
                    $concurList[$concurrerID] = ((defined($concurrence) && ($concurrence eq 'T' || $concurrence eq 'F')) ? $concurrence : "N");
                }
                if (($args{firstNone} eq 'T' && $concurList[1] eq 'N') || ($args{firstPositive} eq 'T' && $concurList[1] eq 'T') || ($args{firstNegative} eq 'T' && $concurList[1] eq 'F') || 
                        ($args{secondNone} eq 'T' && $concurList[2] eq 'N') || ($args{secondPositive} eq 'T' && $concurList[2] eq 'T') || ($args{secondNegative} eq 'T' && $concurList[2] eq 'F')) { 
                    if ($args{test} ne 'T') {
                        $outputstring .= "<tr><td align=center valign=top><font size=-1>$CRDType" . lpadzero($docID, 6) . "/<br>" . lpadzero($comID,4) . "</font></td>\n";
                        $text = lastSubmittedText(dbh => $dbh, schema => $schema, documentID => $docID, commentID => $comID);
                        $text =~ s/\n/<br>/g;
                        $text =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<td valign=top><font size=-1>" . $text . "</font></td>\n";
                    }
                    for (my $i=0; $i<= $#concurrerList; $i++) {
                        if ($showConcurrer[$i] eq 'T') {
                            my $concurrerID = $concurrerList[$i][0];
                            if ($args{test} ne 'T') {$outputstring .= "<td align=center valign=top><font size=-1>";}
                            if ($concurList[$concurrerID] eq 'T') {
                                if ($args{test} ne 'T') {$outputstring .= "Positive";}
                                $iTotals[$concurrerID][0]++;
                            } elsif ($concurList[$concurrerID] eq 'F') {
                                if ($args{test} ne 'T') {$outputstring .= "Negative";}
                                $iTotals[$concurrerID][1]++;
                            } else {
                                if ($args{test} ne 'T') {$outputstring .= "None Entered";}
                                $iTotals[$concurrerID][2]++;
                            }
                            if ($args{test} ne 'T') {$outputstring .= "</font></td>";}
                        }
                    }
                    if ($args{test} ne 'T') {$outputstring .= "</tr>\n";}
                    $foundItemCount++;
                }
                
            }
            $csr->finish;
        }
        
        if ($args{showSCR} eq 'T') {
            if ($args{root_bin} eq 0) {
                $sqlquery = "SELECT id,responsetext FROM $args{schema}.summary_comment WHERE dateapproved IS NOT NULL ORDER BY id";
            } else {
                $binList = getBinTree (\%args);
                $sqlquery = "SELECT id,responsetext FROM $args{schema}.summary_comment WHERE bin IN ($binList) AND dateapproved IS NOT NULL ORDER BY id";
            }
            $csr = $args{dbh}->prepare($sqlquery);
            $status = $csr->execute;
            
            while (my($ID, $text) = $csr->fetchrow_array) {
                for (my $i=0; $i<= $#concurrerList; $i++) {
                    my $concurrerID = $concurrerList[$i][0];
                    my $concurrence;
                    if ($showConcurrer[$i] eq 'T') {
                        $concurrence = get_value($args{'dbh'},$args{'schema'},'concurrence_summary','concurs',"summarycomment=$ID AND concurrencetype=$concurrerID");
                    } else {
                        $concurrence = 'N';
                    }
                    $concurList[$concurrerID] = ((defined($concurrence) && ($concurrence eq 'T' || $concurrence eq 'F')) ? $concurrence : "N");
                }
                if (($args{firstNone} eq 'T' && $concurList[1] eq 'N') || ($args{firstPositive} eq 'T' && $concurList[1] eq 'T') || ($args{firstNegative} eq 'T' && $concurList[1] eq 'F') || 
                        ($args{secondNone} eq 'T' && $concurList[2] eq 'N') || ($args{secondPositive} eq 'T' && $concurList[2] eq 'T') || ($args{secondNegative} eq 'T' && $concurList[2] eq 'F')) { 
                    if ($args{test} ne 'T') {
                        $outputstring .= "<tr><td align=center valign=top><font size=-1>SCR" . lpadzero($ID,4) . "</font></td>\n";
                        $text =~ s/\n/<br>/g;
                        $text =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<td valign=top><font size=-1>" . $text . "</font></td>\n";
                    }
                    for (my $i=0; $i<= $#concurrerList; $i++) {
                        if ($showConcurrer[$i] eq 'T') {
                            my $concurrerID = $concurrerList[$i][0];
                            if ($args{test} ne 'T') {$outputstring .= "<td align=center valign=top><font size=-1>";}
                            if ($concurList[$concurrerID] eq 'T') {
                                if ($args{test} ne 'T') {$outputstring .= "Positive";}
                                $sTotals[$concurrerID][0]++;
                            } elsif ($concurList[$concurrerID] eq 'F') {
                                if ($args{test} ne 'T') {$outputstring .= "Negative";}
                                $sTotals[$concurrerID][1]++;
                            } else {
                                if ($args{test} ne 'T') {$outputstring .= "None Entered";}
                                $sTotals[$concurrerID][2]++;
                            }
                            if ($args{test} ne 'T') {$outputstring .= "</font></td>";}
                        }
                    }
                    if ($args{test} ne 'T') {$outputstring .= "</tr>\n";}
                    $foundItemCount++;
                }
            }
            $csr->finish;
        }
        
        if ($args{test} ne 'T') {
            if ($args{showIndividual} eq 'T') {
                $outputstring .= "<tr><td colspan=" . (($showFirst eq 'T' && $showSecond eq 'T') ? "4" : "3") . " height=4><font size=1>&nbsp;</font><hr><font size=1>&nbsp;</font></td></tr>\n";
                $outputstring .= "<tr><td colspan=2><font size=-1>Totals for Selected Individual Responses</td></tr>\n";
                $outputstring .= "<tr><td colspan=2><font size=-1>" . nbspaces(6) . "Positive</font></td>";
                for (my $i=0; $i<= $#concurrerList; $i++) {
                    if ($showConcurrer[$i] eq 'T') {$outputstring .= "<td align=center><font size=-1>$iTotals[$concurrerList[$i][0]][0]</font></td>";}
                }
                $outputstring .= "</tr>\n";
                $outputstring .= "<tr><td colspan=2><font size=-1>" . nbspaces(6) . "Negative</font></td>";
                for (my $i=0; $i<= $#concurrerList; $i++) {
                    if ($showConcurrer[$i] eq 'T') {$outputstring .= "<td align=center><font size=-1>$iTotals[$concurrerList[$i][0]][1]</font></td>";}
                }
                $outputstring .= "</tr>\n";
                $outputstring .= "<tr><td colspan=2><font size=-1>" . nbspaces(6) . "None Entered</font></td>";
                for (my $i=0; $i<= $#concurrerList; $i++) {
                    if ($showConcurrer[$i] eq 'T') {$outputstring .= "<td align=center><font size=-1>$iTotals[$concurrerList[$i][0]][2]</font></td>";}
                }
                $outputstring .= "</tr>\n";
                $outputstring .= "<tr><td colspan=2>&nbsp;</td>";
                for (my $i=0; $i<= $#concurrerList; $i++) {
                    if ($showConcurrer[$i] eq 'T') {$outputstring .= "<td align=center><font size=-1><hr width=50%>" . ($iTotals[$concurrerList[$i][0]][0] + $iTotals[$concurrerList[$i][0]][1] + $iTotals[$concurrerList[$i][0]][2]) . "</font></td>";}
                }
                $outputstring .= "</tr>\n";
            }
            if ($args{showSCR} eq 'T') {
                $outputstring .= "<tr><td colspan=" . (($showFirst eq 'T' && $showSecond eq 'T') ? "4" : "3") . " height=4><font size=1>&nbsp;</font><hr><font size=1>&nbsp;</font></td></tr>\n";
                $outputstring .= "<tr><td colspan=2><font size=-1>Total for Selected Summary Comment/Responses</td></tr>\n";
                $outputstring .= "<tr><td colspan=2><font size=-1>" . nbspaces(6) . "Positive</font></td>";
                for (my $i=0; $i<= $#concurrerList; $i++) {
                    if ($showConcurrer[$i] eq 'T') {$outputstring .= "<td align=center><font size=-1>$sTotals[$concurrerList[$i][0]][0]</font></td>";}
                }
                $outputstring .= "</tr>\n";
                $outputstring .= "<tr><td colspan=2><font size=-1>" . nbspaces(6) . "Negative</font></td>";
                for (my $i=0; $i<= $#concurrerList; $i++) {
                    if ($showConcurrer[$i] eq 'T') {$outputstring .= "<td align=center><font size=-1>$sTotals[$concurrerList[$i][0]][1]</font></td>";}
                }
                $outputstring .= "</tr>\n";
                $outputstring .= "<tr><td colspan=2><font size=-1>" . nbspaces(6) . "None Entered</font></td>";
                for (my $i=0; $i<= $#concurrerList; $i++) {
                    if ($showConcurrer[$i] eq 'T') {$outputstring .= "<td align=center><font size=-1>$sTotals[$concurrerList[$i][0]][2]</font></td>";}
                }
                $outputstring .= "</tr>\n";
                $outputstring .= "<tr><td colspan=2>&nbsp;</td>";
                for (my $i=0; $i<= $#concurrerList; $i++) {
                    if ($showConcurrer[$i] eq 'T') {$outputstring .= "<td align=center><font size=-1><hr width=50%>" . ($sTotals[$concurrerList[$i][0]][0] + $sTotals[$concurrerList[$i][0]][1] + $sTotals[$concurrerList[$i][0]][2]) . "</font></td>";}
                }
                $outputstring .= "</tr>\n";
            }

            $outputstring .= "</table>\n";
            $outputstring .= "</td></tr></table>\n";
        } else {
            if ($foundItemCount > 0) {
                $outputstring .= "<input type=hidden name=includescrcon value='$args{showSCR}'>\n";
                $outputstring .= "<input type=hidden name=includeindividualcon value='$args{showIndividual}'>\n";
                $outputstring .= "<input type=hidden name=includefirstreviewcon value='$args{firstReview}'>\n";
                $outputstring .= "<input type=hidden name=includesecondreviewcon value='$args{secondReview}'>\n";
                $outputstring .= "<input type=hidden name=includeapprovedcon value='$args{approved}'>\n";
                $outputstring .= "<input type=hidden name=includefirstnonecon value='$args{firstNone}'>\n";
                $outputstring .= "<input type=hidden name=includefirstpositivecon value='$args{firstPositive}'>\n";
                $outputstring .= "<input type=hidden name=includefirstnegativecon value='$args{firstNegative}'>\n";
                $outputstring .= "<input type=hidden name=includesecondnonecon value='$args{secondNone}'>\n";
                $outputstring .= "<input type=hidden name=includesecondpositivecon value='$args{secondPositive}'>\n";
                $outputstring .= "<input type=hidden name=includesecondnegativecon value='$args{secondNegative}'>\n";
                $outputstring .= "<input type=hidden name=concurbin value='$args{root_bin}'>\n\n";
                
                $outputstring .= "<script language=javascript><!--\n";
                $outputstring .= "    submitFormNewWindow('$form', 'report','ConcurrenceReport');\n";
                $outputstring .= "//--></script>\n";
            } else {
                $outputstring .= "<script language=javascript><!--\n";
                $outputstring .= "    alert('Selections Returned Empty Report')\n";
                $outputstring .= "//--></script>\n";
            }
        }
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate a concurrence summary report.",$@);
        print doAlertBox( text => $message);
    }
    
    return($outputstring);
}


###################################################################################################################################
sub doCommentsReportTest {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        type => '',
        displayCommentor => 'F',
        @_,
    );
    
    my @row;
    my $message = '';
    my $outputstring = '';
    my $whereClause = '1=1';
    my $reportTitle = '';
    my $reportMessage = '';
    my $nextReport = '';
    my $fromClause = '';
    my $key;
    my $invalidData = 'F';

    eval {
    
        $outputstring .= "<input type=hidden name=sortbybin value='$args{'sortByBin'}'>\n";
        $outputstring .= "<input type=hidden name=displaycommentor value='$args{'displayCommentor'}'>\n";
        if ($args{'type'} eq "commitments") {
            $whereClause = "com.hascommitments='T'";
            $reportTitle = "Potential DOE Commitments";
            $reportMessage = "Potential DOE Commitments";
            $nextReport = 'DOECommitmentsReport';
        }
        if ($args{'type'} eq "change impact") {
            $whereClause = "com.changeimpact>1";
            $reportTitle = "$CRDType Change Impact";
            $reportMessage = "$CRDType Change Impact";
            $nextReport = 'CRDChangesReport';
        }
        if ($args{'type'} eq "byDocId" && $args{'docIdType'} eq 'range') {
            $whereClause = "com.document BETWEEN $args{'startingDocId'} AND $args{'endingDocId'}";
            $reportTitle = "$CRDType" . lpadzero($args{'startingDocId'},6) . " &nbsp; through &nbsp; $CRDType" . lpadzero($args{'endingDocId'},6);
            $reportMessage = "$CRDType" . lpadzero($args{'startingDocId'},6) . " through $CRDType" . lpadzero($args{'endingDocId'},6);
            $nextReport = 'CommentsByDocIdReport';
            $outputstring .= "<input type=hidden name=docidtype value=$args{'docIdType'}>\n";
            $outputstring .= "<input type=hidden name=startingdocid value=$args{'startingDocId'}>\n";
            $outputstring .= "<input type=hidden name=endingdocid value=$args{'endingDocId'}>\n";
        }
        if ($args{'type'} eq "byDocId" && $args{'docIdType'} eq 'list') {
            $whereClause = "com.document IN (";
            for $key (0 .. $#{ $args{'docIdList'} }) {
                $whereClause .= "$args{'docIdList'}[$key],";
            }
            chop($whereClause);
            $whereClause .= ")";
            $reportTitle = "Selected Documents";
            $reportMessage = "Selected Documents";
            $nextReport = 'CommentsByDocIdReport';
            $outputstring .= "<input type=hidden name=docidtype value=$args{'docIdType'}>\n";
            $outputstring .= "<select multiple name=docidlist>\n";
            for $key (0 .. $#{ $args{'docIdList'} }) {
                $outputstring .= "<option value='$args{'docIdList'}[$key]' selected>$args{'docIdList'}[$key]</option>\n";
            }
            $outputstring .= "</select>\n";
        }
        if ($args{'type'} eq "byDocType") {
            $whereClause = "doc.documenttype=$args{'docType'} AND com.document=doc.id";
            $fromClause = ", $args{'schema'}.document doc";
            $reportTitle = "Document Type:" . nbspaces(3) . get_value($args{'dbh'},$args{'schema'},'document_type','name',"id=$args{'docType'}");
            $reportMessage = "Document Type: " . get_value($args{'dbh'},$args{'schema'},'document_type','name',"id=$args{'docType'}");
            $nextReport = 'CommentsByDocTypeReport';
            $outputstring .= "<input type=hidden name=doctype value=$args{'docType'}>\n";
        }
        if ($args{'type'} eq "byCommentId" && $args{'comIdType'} eq 'range') {
            $whereClause = "(com.document*10000 + com.commentnum) BETWEEN ($args{'startingDocId'}*10000 + $args{'startingCommentId'}) AND ($args{'endingDocId'}*10000 + $args{'endingCommentId'})";
            $reportTitle = "$CRDType" . lpadzero($args{'startingDocId'},6) . "/" . lpadzero($args{'startingCommentId'},4) . " &nbsp; through &nbsp; $CRDType" . lpadzero($args{'endingDocId'},6) . "/" . lpadzero($args{'endingCommentId'},4);
            $reportMessage = "$CRDType" . lpadzero($args{'startingDocId'},6) . "/" . lpadzero($args{'startingCommentId'},4) . " through $CRDType" . lpadzero($args{'endingDocId'},6) . "/" . lpadzero($args{'endingCommentId'},4);
            $nextReport = 'CommentsByCommentIdReport';
            $outputstring .= "<input type=hidden name=startingdocid value=$args{'startingDocId'}>\n";
            $outputstring .= "<input type=hidden name=startingcommentid value=$args{'startingCommentId'}>\n";
            $outputstring .= "<input type=hidden name=endingdocid value=$args{'endingDocId'}>\n";
            $outputstring .= "<input type=hidden name=endingcommentid value=$args{'endingCommentId'}>\n";
            $outputstring .= "<input type=hidden name=comidtype value=$args{'comIdType'}>\n";
        }
        if ($args{'type'} eq "byCommentId" && $args{'comIdType'} eq 'list') {
            $whereClause = "(com.document*10000+com.commentnum) IN (";
            for $key (0 .. $#{ $args{'comIdList'} }) {
                $whereClause .= "$args{'comIdList'}[$key],";
            }
            chop($whereClause);
            $whereClause .= ")";
            $reportTitle = "Selected Documents";
            $reportMessage = "Selected Documents";
            $nextReport = 'CommentsByCommentIdReport';
            $outputstring .= "<input type=hidden name=comidtype value=$args{'comIdType'}>\n";
            $outputstring .= "<select multiple name=comidlist>\n";
            for $key (0 .. $#{ $args{'comIdList'} }) {
                $outputstring .= "<option value='$args{'comIdList'}[$key]' selected>$args{'comIdList'}[$key]</option>\n";
            }
            $outputstring .= "</select>\n";
        }
        if ($args{'type'} eq "byCommentId" && $args{'comIdType'} eq 'paste') {
            $whereClause = "(com.document*10000+com.commentnum) IN (";
            $args{comIdPasteList} = uc($args{comIdPasteList});
            my $idListString = $args{comIdPasteList};
            if ($idListString =~ /[^(($CRDType){0,1}\d{1,6}\s{0,4}\/\s{0,4}\d{1,4}(\n|\r)*)]/gi) {
                $invalidData = "T";
            } else {
                $idListString =~ s/\r//g;
                $idListString =~ s/ //g;
                $idListString =~ s/\n/\t/g;
                $idListString =~ s/$CRDType//g;
                my @idList = split('\t', $idListString);
                for $key (0 .. $#idList) {
                    my ($docid,$comid) = split('/', $idList[$key]);
                    $whereClause .= $docid*10000+$comid . ",";
                }
                chop($whereClause);
                $whereClause .= ")";
                $reportTitle = "Selected Documents";
                $reportMessage = "Selected Documents";
                $nextReport = 'CommentsByCommentIdReport';
                $outputstring .= "<input type=hidden name=comidtype value=$args{'comIdType'}>\n";
                $outputstring .= "<input type=hidden name=comidpastelist value='$idListString'>\n";
            }
        }
        if ($args{'type'} eq "byBinId") {
            $whereClause = "com.bin=$args{'binId'}";
            $reportTitle = "Bin:" . nbspaces(3) . get_value($args{'dbh'},$args{'schema'},'bin','name',"id=$args{'binId'}");
            $reportMessage = "Bin: " . get_value($args{'dbh'},$args{'schema'},'bin','name',"id=$args{'binId'}");
            $nextReport = 'CommentsByBinReport';
            $outputstring .= "<input type=hidden name=binid value=$args{'binId'}>\n";
        }
        if ($args{'type'} eq "byDate") {
            $whereClause = "com.document=doc.id AND TO_CHAR(doc.datereceived,'YYYYMMDD') BETWEEN TO_CHAR(TO_DATE('$args{'beginDate'}'),'YYYYMMDD') AND TO_CHAR(TO_DATE('$args{'endDate'}'),'YYYYMMDD')";
            $fromClause = ", $args{'schema'}.document doc";
            $reportTitle = "Recieved Between: " . uc($args{'beginDate'}) . " and " . uc($args{'endDate'});
            $reportMessage = "Recieved Between: " . uc($args{'beginDate'}) . " and " . uc($args{'endDate'});
            $nextReport = 'CommentsByDateReport';
            $outputstring .= "<input type=hidden name=begindate value=$args{'beginDate'}>\n";
            $outputstring .= "<input type=hidden name=enddate value=$args{'endDate'}>\n";
        }
        if ($args{'type'} eq "byAffiliation") {
            $whereClause = "com.document=doc.id AND doc.commentor=cmtr.id AND cmtr.affiliation=$args{'affiliation'}";
            $fromClause = ", $args{'schema'}.document doc, $args{'schema'}.commentor cmtr";
            $reportTitle = "Affiliation:" . nbspaces(3) . get_value($args{'dbh'},$args{'schema'},'commentor_affiliation','name',"id=$args{'affiliation'}");
            $reportMessage = "Affiliation: " . get_value($args{'dbh'},$args{'schema'},'commentor_affiliation','name',"id=$args{'affiliation'}");
            $nextReport = 'CommentsByAffiliationReport';
            $outputstring .= "<input type=hidden name=affiliation value=\"$args{'affiliation'}\">\n";
        }
        if ($args{'type'} eq "byState") {
            $whereClause = "com.document=doc.id AND doc.commentor=cmtr.id AND cmtr.state='$args{'state'}'";
            $fromClause = ", $args{'schema'}.document doc, $args{'schema'}.commentor cmtr";
            $reportTitle = "State: $args{'state'}";
            $reportMessage = "State: $args{'state'}";
            $nextReport = 'CommentsByStateReport';
            $outputstring .= "<input type=hidden name=state value=\"$args{'state'}\">\n";
        }
        if ($args{'type'} eq "byCity") {
            $whereClause = "com.document=doc.id AND doc.commentor=cmtr.id AND cmtr.city='$args{'city'}'";
            $fromClause = ", $args{'schema'}.document doc, $args{'schema'}.commentor cmtr";
            $reportTitle = "City: $args{'city'}";
            $reportMessage = "City: $args{'city'}";
            $nextReport = 'CommentsByCityReport';
            $outputstring .= "<input type=hidden name=city value=\"$args{'city'}\">\n";
        }
        if ($args{'type'} eq "byOrganization") {
            $whereClause = "com.document=doc.id AND doc.commentor=cmtr.id AND cmtr.organization='$args{'organization'}'";
            $fromClause = ", $args{'schema'}.document doc, $args{'schema'}.commentor cmtr";
            $reportTitle = "Organization: $args{'organization'}";
            $reportMessage = "Organization: $args{'organization'}";
            $nextReport = 'CommentsByOrganizationReport';
            $outputstring .= "<input type=hidden name=organization value=\"$args{'organization'}\">\n";
        }
        if ($args{'type'} eq "byPostalCode") {
            $whereClause = "com.document=doc.id AND doc.commentor=cmtr.id AND cmtr.postalcode BETWEEN '$args{'startPostalCode'}' AND '$args{'endPostalCode'}'";
            $fromClause = ", $args{'schema'}.document doc, $args{'schema'}.commentor cmtr";
            $reportTitle = "Postal Code Between: $args{'startPostalCode'} and $args{'endPostalCode'}";
            $reportMessage = "Postal Code Between: $args{'startPostalCode'} and $args{'endPostalCode'}";
            $nextReport = 'CommentsByPostalCodeReport';
            $outputstring .= "<input type=hidden name=startpostalcode value=\"$args{'startPostalCode'}\">\n";
            $outputstring .= "<input type=hidden name=endpostalcode value=\"$args{'endPostalCode'}\">\n";
        }
        if ($args{'type'} eq "byName") {
            $whereClause = "com.document=doc.id AND doc.commentor=cmtr.id AND UPPER(cmtr.lastname) BETWEEN UPPER('$args{'beginName'}') AND UPPER('$args{'endName'}')";
            $fromClause = ", $args{'schema'}.document doc, $args{'schema'}.commentor cmtr";
            $reportTitle = "Last Name Between: $args{'beginName'} and $args{'endName'}";
            $reportMessage = "Last Name Between: $args{'beginName'} and $args{'endName'}";
            $nextReport = 'CommentsByNameReport';
            $outputstring .= "<input type=hidden name=beginname value=\"$args{'beginName'}\">\n";
            $outputstring .= "<input type=hidden name=endname value=\"$args{'endName'}\">\n";
        }
    
        $outputstring .= "\n\n<!-- SELECT count(*) FROM $args{'schema'}.comments com $fromClause WHERE ($whereClause) -->\n\n";
        
        if ($invalidData ne 'T') {
            @row = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.comments com $fromClause WHERE ($whereClause)");
            
            if ($row[0] < 1) {
                $outputstring .= "<script language=javascript><!--\n";
                $outputstring .= "    alert('No comments for $reportMessage found.')\n";
                $outputstring .= "//--></script>\n";
            } else {
                #$outputstring .= "<input type=hidden name=bin value=$args{'type'}>\n";
                
                $outputstring .= "<script language=javascript><!--\n";
                $outputstring .= "    submitFormNewWindow('$form', 'report','$nextReport');\n";
                $outputstring .= "//--></script>\n";
            }
        } else {
                $outputstring .= "<script language=javascript><!--\n";
                $outputstring .= "    alert('Invalid data entered.')\n";
                $outputstring .= "//--></script>\n";
        }
        
        
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"test for comment report by $reportTitle in database.",$@);
        print doAlertBox( text => $message);
    }
    return ($outputstring);
}


###################################################################################################################################
sub doCommentsReport {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        type => '',
        displayComments => 'T',
        displayResponse => 'T',
        @_,
    );
    
    my @row;
    my $message = '';
    my $outputstring = '';
    my $whereClause = '1=1';
    my $fromClause = '';
    my $valueClause = '';
    my $orderByClause ='';
    my $reportTitle = '';
    my $reportMessage = '';
    my $sqlquery = '';
    my $csr;
    my $status;
    my @values;
    my @rsvalues;
    my @cmntrvalues;
    my $count=0;
    my $key;

    eval {
    
        if ($args{'type'} eq "commitments") {
            $whereClause = "com.hascommitments='T'";
            $reportTitle = "Potential DOE Commitments";
            $reportMessage = "Potential DOE Commitments";
        }
        if ($args{'type'} eq "change impact") {
            $whereClause = "com.changeimpact>1";
            $reportTitle = "$CRDType Change Impact";
            $reportMessage = "$CRDType Change Impact";
        }
        if ($args{'type'} eq "byDocId" && $args{'docIdType'} eq 'range') {
            $whereClause = "com.document BETWEEN $args{'startingDocId'} AND $args{'endingDocId'}";
            $reportTitle = "$CRDType" . lpadzero($args{'startingDocId'},6) . " &nbsp; through &nbsp; $CRDType" . lpadzero($args{'endingDocId'},6);
            $reportMessage = "$CRDType" . lpadzero($args{'startingDocId'},6) . " through $CRDType" . lpadzero($args{'endingDocId'},6);
        }
        if ($args{'type'} eq "byDocId" && $args{'docIdType'} eq 'list') {
            $whereClause = "com.document IN (";
            for $key (0 .. $#{ $args{'docIdList'} }) {
                $whereClause .= "$args{'docIdList'}[$key],";
            }
            chop($whereClause);
            $whereClause .= ")";
            $reportTitle = "Selected Documents";
            $reportMessage = "Selected Documents";
        }
        if ($args{'type'} eq "byDocType") {
            $whereClause = "doc.documenttype=$args{'docType'}";
            $reportTitle = "Document Type:" . nbspaces(3) . get_value($args{'dbh'},$args{'schema'},'document_type','name',"id=$args{'docType'}");
            $reportMessage = "Document Type: " . get_value($args{'dbh'},$args{'schema'},'document_type','name',"id=$args{'docType'}");
        }
        if ($args{'type'} eq "byCommentId" && $args{'comIdType'} eq 'range') {
            $whereClause = "(com.document*10000 + com.commentnum) BETWEEN ($args{'startingDocId'}*10000 + $args{'startingCommentId'}) AND ($args{'endingDocId'}*10000 + $args{'endingCommentId'})";
            $reportTitle = "$CRDType" . lpadzero($args{'startingDocId'},6) . " / " . lpadzero($args{'startingCommentId'},4) . " &nbsp; through &nbsp; $CRDType" . lpadzero($args{'endingDocId'},6) . " / " . lpadzero($args{'endingCommentId'},4);
            $reportMessage = "$CRDType" . lpadzero($args{'startingDocId'},6) . " / " . lpadzero($args{'startingCommentId'},4) . " through $CRDType" . lpadzero($args{'endingDocId'},6) . " / " . lpadzero($args{'endingCommentId'},4);
        }
        if ($args{'type'} eq "byCommentId" && $args{'comIdType'} eq 'list') {
            $whereClause = "(com.document*10000+com.commentnum) IN (";
            for $key (0 .. $#{ $args{'comIdList'} }) {
                $whereClause .= "$args{'comIdList'}[$key],";
            }
            chop($whereClause);
            $whereClause .= ")";
            $reportTitle = "Selected Documents";
            $reportMessage = "Selected Documents";
        }
        if ($args{'type'} eq "byCommentId" && $args{'comIdType'} eq 'paste') {
            $whereClause = "(com.document*10000+com.commentnum) IN (";
            my $idListString = $args{comIdPasteList};
            $idListString =~ s/\r//g;
            $idListString =~ s/ //g;
            $idListString =~ s/$CRDType//g;
            my @idList = split('\t', $idListString);
            for $key (0 .. $#idList) {
                my ($docid,$comid) = split('/', $idList[$key]);
                $whereClause .= $docid*10000+$comid . ",";
            }
            chop($whereClause);
            $whereClause .= ")";
            $reportTitle = "Selected Documents";
            $reportMessage = "Selected Documents";
        }
        if ($args{'type'} eq "byBinId") {
            $whereClause = "com.bin=$args{'binId'}";
            $reportTitle = "Bin:" . get_value($args{'dbh'},$args{'schema'},'bin','name',"id=$args{'binId'}");
            $reportMessage = "Bin: " . get_value($args{'dbh'},$args{'schema'},'bin','name',"id=$args{'binId'}");
        }
        if ($args{'type'} eq "byDate") {
            $whereClause = "com.document=doc.id AND TO_CHAR(doc.datereceived,'YYYYMMDD') BETWEEN TO_CHAR(TO_DATE('$args{'beginDate'}'),'YYYYMMDD') AND TO_CHAR(TO_DATE('$args{'endDate'}'),'YYYYMMDD')";
            $reportTitle = "Recieved Between: " . uc($args{'beginDate'}) . " and " . uc($args{'endDate'});
            $reportMessage = "Recieved Between: " . uc($args{'beginDate'}) . " and " . uc($args{'endDate'});
        }
        if ($args{'type'} eq "byAffiliation") {
            $whereClause = "doc.commentor=cmtr.id AND cmtr.affiliation=$args{'affiliation'}";
            $fromClause = ", $args{'schema'}.commentor cmtr";
            $reportTitle = "Affiliation: " . get_value($args{'dbh'},$args{'schema'},'commentor_affiliation','name',"id=$args{'affiliation'}");
        }
        if ($args{'type'} eq "byState") {
            $whereClause = "doc.commentor=cmtr.id AND cmtr.state='$args{'state'}'";
            $fromClause = ", $args{'schema'}.commentor cmtr";
            $reportTitle = "State: $args{'state'}";
            $reportMessage = "State: $args{'state'}";
        }
        if ($args{'type'} eq "byCity") {
            $whereClause = "doc.commentor=cmtr.id AND cmtr.city='$args{'city'}'";
            $fromClause = ", $args{'schema'}.commentor cmtr";
            $reportTitle = "City: $args{'city'}";
            $reportMessage = "City: $args{'city'}";
        }
        if ($args{'type'} eq "byOrganization") {
            $whereClause = "doc.commentor=cmtr.id AND cmtr.organization='$args{'organization'}'";
            $fromClause = ", $args{'schema'}.commentor cmtr";
            $reportTitle = "Organization: $args{'organization'}";
            $reportMessage = "Organization: $args{'organization'}";
        }
        if ($args{'type'} eq "byPostalCode") {
            $whereClause = "doc.commentor=cmtr.id AND cmtr.postalcode BETWEEN '$args{'startPostalCode'}' AND '$args{'endPostalCode'}'";
            $fromClause = ", $args{'schema'}.commentor cmtr";
            $valueClause = ", cmtr.postalcode ";
            $reportTitle = "Postal Code Between: $args{'startPostalCode'} and $args{'endPostalCode'}";
            $reportMessage = "Postal Code Between: $args{'startPostalCode'} and $args{'endPostalCode'}";
        }
        if ($args{'type'} eq "byName") {
            $whereClause = "doc.commentor=cmtr.id AND UPPER(cmtr.lastname) BETWEEN UPPER('$args{'beginName'}') AND UPPER('$args{'endName'}')";
            $fromClause = ", $args{'schema'}.commentor cmtr";
            $valueClause = ", cmtr.lastname, cmtr.firstname, cmtr.id ";
            $orderByClause = "cmtr.lastname, cmtr.firstname, ";
            $reportTitle = "Last Name Between: $args{'beginName'} and $args{'endName'}";
            $reportMessage = "Last Name Between: $args{'beginName'} and $args{'endName'}";
        }
    
        if ($args{'sortByBin'} eq 'T') {
            $whereClause .= " AND (com.bin=bin.id) ";
            $fromClause .= ", $args{'schema'}.bin bin";
            $orderByClause = "bin.name, " . $orderByClause;
        }
    
        $outputstring .= "<script language=javascript><!--\n";
        $outputstring .= "    document.title='$CRDType Comment/Response Database - $reportTitle Report'\n";
        $outputstring .= "//--></script>\n";
    
        $outputstring .= "<table border=0 width=670 cellpadding=0 cellspacing=0><tr><td>\n";
        $outputstring .= "<center><font size=+2>$CRDType Comment/Response Database<br>Comment Report</font><br><font size=+1>$reportTitle</font><font size=-1><br><br></font>";
        $outputstring .= "<font size=-1>$args{'run_date'}</font></center>\n";

        $sqlquery = "SELECT com.document,com.commentnum,com.text,com.hascommitments,com.changeimpact,com.changecontrolnum,com.bin,com.doereviewer, ";
        $sqlquery .= "NVL(com.summary,0),com.dupsimstatus,com.dupsimdocumentid,com.dupsimcommentid, ";
        $sqlquery .= "doc.documenttype,TO_CHAR(doc.datereceived,'DD-MON-YYYY'),doc.proofreaddate,doc.dupsimstatus,doc.dupsimid,doc.hassrcomments,doc.haslacomments, ";
        $sqlquery .= "doc.has960comments,doc.hasenclosures,doc.addressee,doc.namestatus,doc.commentor $valueClause ";
        $sqlquery .= "FROM $args{'schema'}.comments com, $args{'schema'}.document doc $fromClause WHERE (com.document=doc.id) AND $whereClause ";
        $sqlquery .= "ORDER BY $orderByClause com.document,com.commentnum";
        $csr = $args{'dbh'}->prepare($sqlquery);
        $status = $csr->execute;

        print "\n\n<!-- $sqlquery -->\n\n";
        
        
        while (@values = $csr->fetchrow_array) {
            print "<!-- $CRDType" . lpadzero($values[0],6) . " / " . lpadzero($values[1],4) . " -->\n";
            $count++;
            $outputstring .= "<hr>\n";
            @rsvalues = $args{'dbh'}->selectrow_array("SELECT version,status,originaltext,lastsubmittedtext,responsewriter,TO_CHAR(dateupdated,'DD-MON-YYYY HH24:MI:SS') FROM $schema.response_version WHERE document=$values[0] AND commentnum=$values[1] ORDER BY version DESC");
#print "\n<!-- SELECT version,status,originaltext,lastsubmittedtext,responsewriter,TO_CHAR(dateupdated,'DD-MON-YYYY HH24:MI:SS') FROM $schema.response_version WHERE document=$values[0] AND commentnum=$values[1] ORDER BY version DESC -->\n\n";
            $outputstring .= "<b>$CRDType" . lpadzero($values[0],6) . " / " . lpadzero($values[1],4) . "</b>" . 
            (($values[9] ==1 && $#rsvalues>1 && $values[8] == 0) ? " - Status: ". get_value($args{'dbh'},$args{'schema'},'response_status','name',"id=$rsvalues[1]") : "") . "<br>\n";
            if ($args{'type'} ne "byBinId") {
                $outputstring .= "Bin: " . get_value($args{'dbh'},$args{'schema'},'bin','name', "id=$values[6]") . "<br>\n";
                $outputstring .= "Coordinator: " . get_fullname($args{'dbh'},$args{'schema'},(get_value($args{'dbh'},$args{'schema'},'bin','coordinator', "id=$values[6]"))) . "<br>\n";
            }
            $outputstring .= (($args{'type'} ne 'commitments') ? (($values[3] eq 'T') ? "Potential DOE Commitments<br>" : "") : "");
            $outputstring .= (($values[4] > 1) ? get_value($args{'dbh'},$args{'schema'},'document_change_impact','name', "id=$values[4]") . " - Control Number: " . ((defined($values[5])) ? $values[5] : "") . "<br>" : "");
            $outputstring .= (($values[8] > 0) ? "Comment is Summarized by SCR" . lpadzero($values[8],4) . "<br>\n" : "");
            if ($values[9] != 1) {
                $outputstring .= "Comment is a duplicate of $CRDType" . lpadzero($values[10],6) . " / " . lpadzero($values[11],4) . "<br>\n";
            } else {
                if ($#rsvalues >1 && $values[8] == 0) {
                    $outputstring .= "Response Writer: " . get_fullname($args{'dbh'},$args{'schema'},$rsvalues[4]) . "<br>\n";
                }
            }
            if ($args{'type'} eq "byName" && $args{'displayCommentor'} eq 'F') {
                $outputstring .= "Commentor: $values[25] $values[24] (C" . lpadzero($values[26],4) . ")<br>\n";
            }
            if ($args{'type'} eq "byPostalCode" && $args{'displayCommentor'} eq 'F') {
                $outputstring .= "Postal Code: $values[24]<br>\n";
            }
            if ($args{'type'} eq "byDate") {
                $outputstring .= "Date Received: $values[13]<br>\n";
            }
            $outputstring .= "<table border=0 width=100% cellpadding=0 cellspacing=0>\n";
            if ($args{'displayCommentor'} eq 'T') {
                $outputstring .= "<tr><td><hr width=50% align=left></td></tr>\n";
                $outputstring .= "<tr><td>\n";
                $outputstring .= "<b>Commentor:</b> ";
                if ($values[22] == 1) {
                    @cmntrvalues = $args{'dbh'}->selectrow_array("SELECT c.id,c.lastname,c.firstname,c.middlename,c.title,c.suffix," . 
                        "c.address,c.city,c.state,c.country,c.postalcode,c.areacode,c.phonenumber,c.phoneextension,c.faxareacode,c.faxnumber," . 
                        "c.faxextension,c.email,c.organization,c.position,c.affiliation, a.name " .
                        "FROM $schema.commentor c,$schema.commentor_affiliation a WHERE (c.affiliation=a.id(+)) AND c.id=$values[23]");
                    $outputstring .= ((defined($cmntrvalues[4])) ? "$cmntrvalues[4] " : "") . ((defined($cmntrvalues[2])) ? "$cmntrvalues[2] " : "") . ((defined($cmntrvalues[3])) ? "$cmntrvalues[3] " : "") . $cmntrvalues[1] . ((defined($cmntrvalues[5])) ? " $cmntrvalues[5]" : "") . "\n";
                    $outputstring .= " (C" . lpadzero($cmntrvalues[0],4) . ")";
                    $outputstring .= ((defined($cmntrvalues[21]))? "<br>Affiliation: $cmntrvalues[21]\n" : "");
                    $outputstring .= ((defined($cmntrvalues[18]))? "<br>Organization: $cmntrvalues[18]\n" : "");
                    #$outputstring .= ((defined($cmntrvalues[7]) || defined($cmntrvalues[8]))? "<br>City, State: " . ((defined($cmntrvalues[7])) ? $cmntrvalues[7] . ((defined($cmntrvalues[8])) ? ", " : "") . ((defined($cmntrvalues[8])) ? $cmntrvalues[8] : "") : "") . "\n" : "");
                    #$outputstring .= ((defined($cmntrvalues[10]))? "<br>Postal Code: $cmntrvalues[10]\n" : "");
                    $outputstring .= ((defined($cmntrvalues[7]) || defined($cmntrvalues[8]) || defined($cmntrvalues[10]))? "<br>" . ((defined($cmntrvalues[7])) ? $cmntrvalues[7] . ((defined($cmntrvalues[8])) ? ", " : "") . ((defined($cmntrvalues[8])) ? "$cmntrvalues[8] " : "") : "") . ((defined($cmntrvalues[10]))? "$cmntrvalues[10]\n" : "") . "\n" : "");
                } else {
                    $outputstring .= get_value($args{dbh},$args{schema},'commentor_name_status','name',"id=$values[22]") . "\n";
                }
                
                $outputstring .= "</td></tr>\n";
            }
            if ($args{'displayComments'} eq 'T') {
                $values[2] =~ s/\n/<br>/g;
                $values[2] =~ s/  /&nbsp;&nbsp;/g;
                $outputstring .= "<tr><td><hr width=50% align=left></td></tr>\n";
                $outputstring .= "<tr><td><b>Comment:</b></td></tr>\n<tr><td>$values[2]</td></tr>\n";
            }
            if ($args{'displayResponse'} eq 'T') {
                my $responseText = lastSubmittedText(dbh => $dbh, schema => $schema, documentID => $values[0], commentID => $values[1]);
                if (defined($responseText) && $rsvalues[1] <= 9) {
                    if ($responseText gt '') {
                        $responseText=~ s/\n/<br>/g;
                        $responseText =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "<tr><td><hr width=50% align=left></td></tr>\n";
                        $outputstring .= "<tr><td><b>Response:</b></td></tr>\n<tr><td>$responseText</td></tr>\n";
                    }
                    #if ($rsvalues[3] gt '') {
                    #    $rsvalues[3] =~ s/\n/<br>/g;
                    #    $rsvalues[3] =~ s/  /&nbsp;&nbsp;/g;
                    #    $outputstring .= "<tr><td><hr width=50% align=left></td></tr>\n";
                    #    $outputstring .= "<tr><td><b>Response:</b></td></tr>\n<tr><td>$rsvalues[3]</td></tr>\n";
                    #}
                }
            }
            $outputstring .= "</table><br>\n";
        }
        $csr->finish;
        
        $outputstring .= "<br><hr>$count Comment" . (($count!=1) ? "s" : "") . " Printed\n";
        
        $outputstring .= "</td></tr></table>\n";
        
        
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate comments report by $reportMessage.",$@);
        print doAlertBox( text => $message);
    }
    return ($outputstring);
}


###################################################################################################################################
sub doDuplicateCommentsReport {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        type => '',
        bin => 0,
        @_,
    );
    
    my $sqlquery ='';
    my $csr;
    my $sqlquery_org ='';
    my $csr_org;
    my @values;
    my @values_org;
    my $status;
    my @row;
    my $message = '';
    my $outputstring = '';
    my $whereClause = '';
    my $binlist = '';
    my $lastbin = 0;
    my $textblock = '';

    eval {
        if ($args{bin} != 0) {
            $args{root_bin} = $args{bin};
            $binlist = getBinTree (\%args);
            $whereClause = " AND bin IN ($binlist)";
        }
        if ($args{type} eq 'test'){
            $sqlquery_org = "SELECT count(*) FROM $args{schema}.comments com, $args{schema}.bin bin, $args{schema}.document doc ";
            $sqlquery_org .= "WHERE (com.bin = bin.id AND com.document = doc.id) AND (com.document || '-' || com.commentnum IN (";
            $sqlquery_org .= "SELECT UNIQUE dupsimdocumentid || '-' || dupsimcommentid FROM $args{schema}.comments WHERE dupsimstatus = 2 $whereClause )) ";
            $outputstring .= "\n\n<!-- $sqlquery_org -->\n\n";
            @row = $args{dbh}->selectrow_array($sqlquery_org);
            if ($row[0] >= 1) {
                $outputstring .= "<input type=hidden name=binfordups value=$args{bin}>\n";
                $outputstring .= "<script language=javascript><!--\n";
                $outputstring .= "    submitFormNewWindow('$form', 'report', 'DuplicateCommentsReport');\n";
                $outputstring .= "//--></script>\n";
            } else {
                $outputstring .= "<script language=javascript><!--\n";
                $outputstring .= "    alert('No Duplicates in selected bin(s)')\n";
                $outputstring .= "//--></script>\n";
            }
        } else {
            $outputstring .= "<script language=javascript><!--\n";
            $outputstring .= "    document.title='$CRDType Comment/Response Database - Duplicate Comments Reports'\n";
            $outputstring .= "//--></script>\n";
    
            $outputstring .= "<center><font size=+1>$CRDType Comment/Response Database<br>Duplicate Comments Report</font><font size=-2><br><br></font>";
            $outputstring .= "<font size=-1>$args{'run_date'}</font></center>\n";
            
            $sqlquery_org = "SELECT com.document, com.commentnum, com.text, com.bin, NVL(com.summary,0), com.dupsimstatus, bin.name, bin.coordinator, doc.namestatus, doc.commentor FROM $args{schema}.comments com, $args{schema}.bin bin, $args{schema}.document doc ";
            $sqlquery_org .= "WHERE (com.bin = bin.id AND com.document = doc.id) AND (com.document || '-' || com.commentnum IN (";
            $sqlquery_org .= "SELECT UNIQUE dupsimdocumentid || '-' || dupsimcommentid FROM $args{schema}.comments WHERE dupsimstatus = 2 $whereClause )) ";
            $sqlquery_org .= "ORDER BY bin.name, com.document, com.commentnum";
            $outputstring .= "\n\n<!-- $sqlquery_org -->\n\n";
            
            $csr_org = $args{dbh}->prepare($sqlquery_org);
            $status = $csr_org->execute;
            
            while (@values_org = $csr_org->fetchrow_array) {
                # keep connection alive
                print "<!-- ... keep alive ... -->\n";
                if ($lastbin != $values_org[3]) {
                    $lastbin = $values_org[3];
                    $outputstring .= "<br><hr><br>\n";
                    $outputstring .= "$values_org[6]<br>\n";
                    $outputstring .= "Coordinator: " . get_fullname($args{dbh}, $args{schema}, $values_org[7]) . "<br>\n";
                }
                $outputstring .= "<font size=-1><br><hr width=50%>\n";
                @values = $dbh->selectrow_array("SELECT status,lastsubmittedtext,responsewriter FROM $args{schema}.response_version WHERE document=$values_org[0] AND commentnum=$values_org[1] ORDER BY version DESC");
                $outputstring .= "<br>Original: $CRDType" . lpadzero($values_org[0],6) . " / " . lpadzero($values_org[1],4);
                if ($values_org[5] == 1 && $values_org[4] == 0 && $#values > 1) {
                    $outputstring .= " - <i>" . get_value ($dbh, $schema, 'response_status','name',"id=$values[0]") . "</i><br>\n";
                } elsif ($values_org[4] > 0) {
                    $outputstring .= " - <i>Summarized by SCR" . lpadzero($values_org[4],4) . "</i><br>\n";
                }
                if ($#values > 1) {
                    $outputstring .= "Response Writer: " . get_fullname($args{dbh}, $args{schema}, $values[2]) . "<br>\n";
                }
                $outputstring .= "Commentor: ";
                if ($values_org[8] == 1) {
                    $outputstring .= get_value($args{dbh}, $args{schema}, 'commentor', "firstname || ' ' || lastname", "id = $values_org[9]") . "<br>\n";
                } else {
                    $outputstring .= get_value($args{dbh}, $args{schema}, 'commentor_name_status', 'name', "id = $values_org[8]") . "<br>\n";
                }
                $outputstring .= "<br><u>Comment:</u><br>\n";
                $textblock = $values_org[2];
                $textblock =~ s/\n/<br>/g;
                $textblock =~ s/  /&nbsp;&nbsp;/g;
                $outputstring .= "$textblock\n";
                $outputstring .= "<br><br>\n";
                if ($#values > 1 && defined($values[1]) && $values[1] gt ' ') {
                    $outputstring .= "<u>Response:</u><br>\n";
                    $textblock = lastSubmittedText(dbh => $dbh, schema => $schema, documentID => $values_org[0], commentID => $values_org[1]);
                    #$textblock = $values[1];
                    $textblock =~ s/\n/<br>/g;
                    $textblock =~ s/  /&nbsp;&nbsp;/g;
                    $outputstring .= "$textblock\n";
                    $outputstring .= "<br><br>\n";
                }
                
                $outputstring .= "Duplicates:<br><br>\n";
                $sqlquery = "SELECT com.document,com.commentnum,com.text,doc.namestatus,doc.commentor FROM $args{schema}.comments com, $args{schema}.document doc WHERE (com.document = doc.id) AND (com.dupsimdocumentid = $values_org[0] AND com.dupsimcommentid = $values_org[1]) ORDER BY com.document, com.commentnum";
                $csr = $args{dbh}->prepare($sqlquery);
                $status = $csr->execute;
                $outputstring .= "<table border=0 cellpadding=0 cellspacing=0>\n";
                while (@values = $csr->fetchrow_array) {
                    $outputstring .= "<tr><td colspan=2><font size=-1>$CRDType" . lpadzero($values[0], 6) . " / " . lpadzero($values[1], 4) . "\n";
                    
                    if ($values[3] == 1) {
                        $outputstring .= " - " . get_value($args{dbh}, $args{schema}, 'commentor', "firstname || ' ' || lastname", "id = $values[4]") . "\n";
                    } else {
                        $outputstring .= " - " . get_value($args{dbh}, $args{schema}, 'commentor_name_status', 'name', "id = $values[3]") . "\n";
                    }
                    $outputstring .= "</font></td></tr>\n";
                    
                    if ($values_org[2] ne $values[2]) {
                        $outputstring .= "<tr><td>" . nbspaces(6) . "</td><td><font size=-1><u>Different Text:</u><br>\n";
                        $textblock = $values[2];
                        $textblock =~ s/\n/<br>/g;
                        $textblock =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "$textblock\n";
                        $outputstring .= "</font></td></tr>\n";
                    }
                    
                    
                }
                $outputstring .= "</table>\n";
                
                $csr->finish;
                
                $outputstring .= "</font>\n";
                
            }
            
            $csr_org->finish;
        }
        
        
        
        
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate duplicate comments report.",$@);
        print doAlertBox( text => $message);
    }
    return ($outputstring);
}


###################################################################################################################################
sub doSearchStringsReport {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        sortBy => 'id',
        comments => 'T',
        responses => 'T',
        scrs => 'T',
        bin => 0,
        byCommentor => 'F',
        strings => '',
        @_,
    );
    
#print "\n<!-- Args: @_ -->\n";

    my $outputstring = '';
    my $message = '';
    my @testStrings;
    my %commentHash;
    my %responseHash;
    my %scHash;
    my %scrHash;
    my %scHashFull;
    my %scrHashFull;
    my %idHash;
    my $idList = '0';
    my %idHashFull;
    my %rvHashFull;
    my $scrList = '0';
    my $sqlquery;
    my $csr;
    my @values;
    my $status;
    my $binlist = '';
    my $whereClause = '';
    
    eval {
    
        if ($args{bin} != 0) {
            $args{root_bin} = $args{bin};
            $binlist = getBinTree (\%args);
            $whereClause = " AND bin IN ($binlist)";
        }
        
        $args{strings} =~ s/ \n/\n/g;
        $args{strings} =~ s/\n\n/\n/g;
        $args{strings} =~ s/\r//g;
#print "\n<!-- Strings2: $args{strings} -->\n";
        @testStrings = split('\n',$args{strings});
        
####
        if ($args{comments} eq 'T') {
            $sqlquery = "SELECT document,commentnum,text FROM $args{schema}.comments";
            if ($args{bin} != 0) {
                $sqlquery .= " WHERE bin IN ($binlist)";
            }
            $sqlquery .= " ORDER BY document,commentnum";
print "\n<!-- $sqlquery -->\n\n";
            $csr = $args{dbh}->prepare($sqlquery);
            $status = $csr->execute;
            
            for (my $i=0; $i <= $#testStrings; $i++) {
                $testStrings[$i] =~ s/\n//g;
                #if ($i != $#testStrings) {chop($testStrings[$i]);}
                print "<!-- $testStrings[$i] -->\n";
                $commentHash{$testStrings[$i]} = '';
            }
            
            while (@values = $csr->fetchrow_array) {
                for (my $i=0; $i <= $#testStrings; $i++) {
                    if (matchFound('text'=>$values[2], 'searchString'=>$testStrings[$i])) {
                        $commentHash{$testStrings[$i]} .= lpadzero($values[0],6) . "-" . lpadzero($values[1],4) . ",";
                        $idHashFull{($values[0]*10000+$values[1])}{$testStrings[$i]} = 'T';
                    }
                }
                print "<!-- $values[0] / $values[1] -->";
            }
            $csr->finish;
            print "<!-- Keep Alive -->\n";
            for (my $i=0; $i <= $#testStrings; $i++) {
                chop($commentHash{$testStrings[$i]});
            }
        }
        
####
        if ($args{responses} eq 'T') {
            $sqlquery = "SELECT document,commentnum,lastsubmittedtext FROM $args{schema}.response_version";
            $sqlquery .= " WHERE status IN (2,3,4,5,6,7,8,9)";
            if ($args{bin} != 0) {
                $sqlquery = "SELECT rv.document,rv.commentnum,rv.lastsubmittedtext FROM $args{schema}.response_version rv, $args{schema}.comments com";
                $sqlquery .= " WHERE rv.document=com.document AND rv.commentnum=com.commentnum AND rv.status IN (2,3,4,5,6,7,8,9)";
                $sqlquery .= " AND com.bin IN ($binlist)";
            }
            $sqlquery .= " ORDER BY document,commentnum";
print "\n<!-- $sqlquery -->\n\n";
            $csr = $args{dbh}->prepare($sqlquery);
            $status = $csr->execute;
            
            for (my $i=0; $i <= $#testStrings; $i++) {
                $testStrings[$i] =~ s/\n//g;
                #if ($i != $#testStrings) {chop($testStrings[$i]);}
                print "<!-- $testStrings[$i] -->\n";
                $responseHash{$testStrings[$i]} = '';
            }
            
            while (@values = $csr->fetchrow_array) {
                print "<!-- $values[0] / $values[1] -->";
                my $responseText = lastSubmittedText(dbh => $args{dbh}, schema => $args{schema}, documentID => $values[0], commentID => $values[1]);
                for (my $i=0; $i <= $#testStrings; $i++) {
                    if (matchFound('text'=>$responseText, 'searchString'=>$testStrings[$i])) {
                    #if (matchFound('text'=>$values[2], 'searchString'=>$testStrings[$i])) {
                        $responseHash{$testStrings[$i]} .= lpadzero($values[0],6) . "-" . lpadzero($values[1],4) . ",";
                        $rvHashFull{($values[0]*10000+$values[1])}{$testStrings[$i]} = 'T';
                    }
                }
            }
            $csr->finish;
            print "<!-- Keep Alive -->\n";
            for (my $i=0; $i <= $#testStrings; $i++) {
                chop($responseHash{$testStrings[$i]});
            }
        }
    
####
        if ($args{scrs} eq 'T') {
            $sqlquery = "SELECT id,commenttext,responsetext FROM $args{schema}.summary_comment";
            if ($args{bin} != 0) {
                $sqlquery .= " WHERE bin IN ($binlist)";
            }
            $sqlquery .= " ORDER BY id";
print "\n<!-- $sqlquery -->\n\n";
            $csr = $args{dbh}->prepare($sqlquery);
            $status = $csr->execute;
            
            for (my $i=0; $i <= $#testStrings; $i++) {
                $scHash{$testStrings[$i]} = '';
                $scrHash{$testStrings[$i]} = '';
            }
            
            while (@values = $csr->fetchrow_array) {
                for (my $i=0; $i <= $#testStrings; $i++) {
                    if (matchFound('text'=>$values[1], 'searchString'=>$testStrings[$i])) {
                        $scHash{$testStrings[$i]} .= lpadzero($values[0],4) . ",";
                        $scHashFull{$values[0]}{$testStrings[$i]} = 'T';
                    }
                    if (matchFound('text'=>$values[2], 'searchString'=>$testStrings[$i])) {
                        $scrHash{$testStrings[$i]} .= lpadzero($values[0],4) . ",";
                        $scrHashFull{$values[0]}{$testStrings[$i]} = 'T';
                    }
                }
                print "<!-- $values[0] -->";
            }
            $csr->finish;
            for (my $i=0; $i <= $#testStrings; $i++) {
                chop($scHash{$testStrings[$i]});
                chop($scrHash{$testStrings[$i]});
            }
        }
        
        $outputstring .= "<table border=0 width=670><tr><td>\n";
        $outputstring .= "<script language=javascript><!--\n";
        $outputstring .= "    document.title='$CRDType Comment/Response Database - Search Strings Report'\n";
        $outputstring .= "//--></script>\n";

        $outputstring .= "<center><font size=+1>$CRDType Comment/Response Database<br>Search Strings Report</font><font size=-2><br><br></font>";
        $outputstring .= "<font size=-1>$args{'run_date'}</font></center>\n";
        
        if ($args{byCommentor} ne 'T') {
            if ($args{sortBy} eq 'strings') {
                for (my $i=0; $i <= $#testStrings; $i++) {
                    my $found = 0;
                    $outputstring .= "<br><u>$testStrings[$i]</u>:\n";
                    if ($responseHash{$testStrings[$i]} gt '') {
                        @values = split(',',$responseHash{$testStrings[$i]});
                        $outputstring .= "<br><br>Found in Response" . (($#values > 0) ? 's' : '') . " to: ";
                        for (my $j = 0; $j <= $#values; $j++) {
                            my ($document, $comment) = split ('-', $values[$j]);
                            $outputstring .= "$CRDType" . lpadzero($document,6) . " / " . lpadzero($comment,4) . ", ";
                        }
                        chop($outputstring);
                        chop($outputstring);
                        $found = 1;
                    }
                    if ($scHash{$testStrings[$i]} gt '') {
                        @values = split(',',$scHash{$testStrings[$i]});
                        $outputstring .= "<br><br>Found in Summary Comment" . (($#values > 0) ? 's' : '') . ": ";
                        for (my $j = 0; $j <= $#values; $j++) {
                            $outputstring .= "SCR" . lpadzero($values[$j],4) . ", ";
                        }
                        chop($outputstring);
                        chop($outputstring);
                        $found = 1;
                    }
                    if ($scrHash{$testStrings[$i]} gt '') {
                        @values = split(',',$scrHash{$testStrings[$i]});
                        $outputstring .= "<br><br>Found in Summary Comment Response" . (($#values > 0) ? 's' : '') . ": ";
                        for (my $j = 0; $j <= $#values; $j++) {
                            $outputstring .= "SCR" . lpadzero($values[$j],4) . ", ";
                        }
                        chop($outputstring);
                        chop($outputstring);
                        $found = 1;
                    }
                    if ($found == 0) {
                        $outputstring .= "<br>Was Not Found<br>\n";
                    }
                    $outputstring .= "<br>\n";
                }
            } else {
                my $found = 0;
                my $count = 0;
                my @row;
    
#####
                for (my $i=0; $i <= $#testStrings; $i++) {
                    @values = split(',',$commentHash{$testStrings[$i]});
                    for (my $j = 0; $j <= $#values; $j++) {
                        if (!defined($idHash{$values[$j]})) {
                            for (my $k=0; $k < $#testStrings; $k++) {
                                $idHash{$values[$j]}[$k] = 0;
                            }
                        }
                        $idHash{$values[$j]}[$i] = 1;
                        $count++;
                    }
                }
                if ($count > 0) {
                    $found = 1;
                    $outputstring .= "<table border=0 width=100%><tr><td colspan=2><u>Comments</u></td></tr>\n";
                    for my $key (sort keys %idHash) {
                        my ($document, $comment) = split('-',$key);
                        @row = $args{'dbh'}->selectrow_array("SELECT bin.name FROM $args{'schema'}.bin,$args{'schema'}.comments com WHERE (bin.id = com.bin) AND com.document=$document AND com.commentnum=$comment");
                        $outputstring .= "<tr><td colspan=2>$CRDType$document / $comment - $row[0]</td></tr>\n";
                        if (defined($idHash{$key})) {
                            for (my $i=0; $i <= $#testStrings; $i++) {
                                if (defined($idHash{$key}[$i]) && $idHash{$key}[$i] == 1) {
                                    $outputstring .= "<tr><td width=1%>" . nbspaces(6) . "</td><td>&#149;&nbsp;$testStrings[$i]</td></tr>\n";
                                }
                            }
                        }
                    }
                    $outputstring .= "</table><br>\n";
                }
                
#####
                $count = 0;
                undef %idHash;
                for (my $i=0; $i <= $#testStrings; $i++) {
                    @values = split(',',$responseHash{$testStrings[$i]});
                        for (my $j = 0; $j <= $#values; $j++) {
                        if (!defined($idHash{$values[$j]})) {
                            for (my $k=0; $k < $#testStrings; $k++) {
                                $idHash{$values[$j]}[$k] = 0;
                            }
                        }
                        $idHash{$values[$j]}[$i] = 1;
                        $count++;
                    }
                }
                if ($count > 0) {
                    $found = 1;
                    $outputstring .= "<table border=0 width=100%><tr><td colspan=2><u>Responses</u></td></tr>\n";
                    for my $key (sort keys %idHash) {
                        my ($document, $comment) = split('-',$key);
                        @row = $args{'dbh'}->selectrow_array("SELECT bin.name FROM $args{'schema'}.bin,$args{'schema'}.comments com WHERE (bin.id = com.bin) AND com.document=$document AND com.commentnum=$comment");
                        $outputstring .= "<tr><td colspan=2>$CRDType$document / $comment - $row[0]</td></tr>\n";
                        if (defined($idHash{$key})) {
                            for (my $i=0; $i <= $#testStrings; $i++) {
                                if (defined($idHash{$key}[$i]) && $idHash{$key}[$i] == 1) {
                                    $outputstring .= "<tr><td width=1%>" . nbspaces(6) . "</td><td>&#149;&nbsp;$testStrings[$i]</td></tr>\n";
                                }
                            }
                        }
                    }
                    $outputstring .= "</table><br>\n";
                }
                
#####
                $count = 0;
                undef %idHash;
                for (my $i=0; $i <= $#testStrings; $i++) {
                    @values = split(',',$scHash{$testStrings[$i]});
                    for (my $j = 0; $j <= $#values; $j++) {
                        if (!defined($idHash{$values[$j]})) {
                            for (my $k=0; $k < $#testStrings; $k++) {
                                $idHash{$values[$j]}[$k] = 0;
                            }
                        }
                        $idHash{$values[$j]}[$i] = 1;
                        $count++;
                    }
                }
                if ($count > 0) {
                    $found = 1;
                    $outputstring .= "<table border=0 width=100%><tr><td colspan=2><u>Summary Comments</u></td></tr>\n";
                    for my $key (sort keys %idHash) {
                        @row = $args{'dbh'}->selectrow_array("SELECT bin.name FROM $args{'schema'}.bin,$args{'schema'}.summary_comment scr WHERE (bin.id = scr.bin) AND scr.id=$key");
                        $outputstring .= "<tr><td colspan=2>SCR$key - $row[0]</td></tr>\n";
                        if (defined($idHash{$key})) {
                            for (my $i=0; $i <= $#testStrings; $i++) {
                                if (defined($idHash{$key}[$i]) && $idHash{$key}[$i] == 1) {
                                    $outputstring .= "<tr><td width=1%>" . nbspaces(6) . "</td><td>&#149;&nbsp;$testStrings[$i]</td></tr>\n";
                                }
                            }
                        }
                    }
                    $outputstring .= "</table><br>\n";
                }
                
#####
                $count = 0;
                undef %idHash;
                for (my $i=0; $i <= $#testStrings; $i++) {
                    @values = split(',',$scrHash{$testStrings[$i]});
                    for (my $j = 0; $j <= $#values; $j++) {
                        if (!defined($idHash{$values[$j]})) {
                            for (my $k=0; $k < $#testStrings; $k++) {
                                $idHash{$values[$j]}[$k] = 0;
                            }
                        }
                        $idHash{$values[$j]}[$i] = 1;
                        $count++;
                    }
                }
                if ($count > 0) {
                    $found = 1;
                    $outputstring .= "<table border=0 width=100%><tr><td colspan=2><u>Summary Comment Responses</u></td></tr>\n";
                    for my $key (sort keys %idHash) {
                        @row = $args{'dbh'}->selectrow_array("SELECT bin.name FROM $args{'schema'}.bin,$args{'schema'}.summary_comment scr WHERE (bin.id = scr.bin) AND scr.id=$key");
                        $outputstring .= "<tr><td colspan=2>SCR$key - $row[0]</td></tr>\n";
                        if (defined($idHash{$key})) {
                            for (my $i=0; $i <= $#testStrings; $i++) {
                                if (defined($idHash{$key}[$i]) && $idHash{$key}[$i] == 1) {
                                    $outputstring .= "<tr><td width=1%>" . nbspaces(6) . "</td><td>&#149;&nbsp;$testStrings[$i]</td></tr>\n";
                                }
                            }
                        }
                    }
                    $outputstring .= "</table>\n";
                }
                
                if ($found == 0) {
                    $outputstring .= "<br>Strings not found";
                }
            }
        } else {
            my %foundIDHash;
            my %foundSCRHash;
            
            foreach my $key (keys %idHashFull) {
                $idList .= ", $key";
                $foundIDHash{$key} = 'T';
            }
            foreach my $key (keys %rvHashFull) {
                $idList .= ", $key";
                $foundIDHash{$key} = 'T';
            }
            foreach my $key (keys %scHash) {
                if (defined($scHash{$key}) && $scHash{$key} gt "  ") {
                    $scrList .= ", $scHash{$key}";
                }
            }
            foreach my $key (keys %scrHash) {
                if (defined($scrHash{$key}) && $scrHash{$key} gt "  ") {
                    $scrList .= ", $scrHash{$key}";
                }
            }
            foreach my $key (keys %scHashFull) {
                $foundSCRHash{$key} = 'T';
            }
            foreach my $key (keys %scrHashFull) {
                $foundSCRHash{$key} = 'T';
            }
            
            $sqlquery = "SELECT cmtr.id,cmtr.lastname,cmtr.firstname,cmtr.middlename,cmtr.title,cmtr.suffix,cmtr.address,cmtr.city,cmtr.state,cmtr.country,";
            $sqlquery .= "cmtr.postalcode,cmtr.organization,cmtr.affiliation,doc.namestatus,com.document,com.commentnum,com.bin,com.summary ";
            $sqlquery .= "FROM $args{schema}.commentor cmtr, $args{schema}.document doc, $args{schema}.comments com ";
            $sqlquery .= "WHERE (doc.commentor = cmtr.id(+)) AND (doc.id = com.document) ";
            #$sqlquery .= "AND (((com.document*10000+com.commentnum) IN ($idList)) OR (com.summary IN ($scrList))) ";
            $sqlquery .= "ORDER BY cmtr.organization,cmtr.lastname,cmtr.firstname,com.document,com.commentnum";
            
            $csr = $args{dbh}->prepare($sqlquery);
            print "\n<!-- $sqlquery -->\n\n";
            $status = $csr->execute;
            
            $outputstring .= "<table border=0>\n";
            
            my $lastCommentor = 0;
            my $lastNameStatus = 0;
            my $testID;
            my $found = 0;
            
            while (@values = $csr->fetchrow_array) {
                if (($values[13] == 1 && $lastCommentor != $values[0]) || ($values[13] != 1 && $values[13] != $lastNameStatus)) {
                    $outputstring .= "<tr><td>&nbsp;</td></tr>\n";
                    if ($values[13] == 1) {
                        $lastCommentor = $values[0];
                        $outputstring .= "<tr><td>$values[2] $values[1] - " . ((defined($values[7])) ? "$values[7]" : "") . (((defined($values[7])) && (defined($values[8]))) ? "," : "") . ((defined($values[8])) ? " $values[8]" : "") . "\n";
                        $outputstring .= ((defined($values[11])) ? "<br>" . nbspaces(2) . "Organization: $values[11]" : "") . "\n";
                        $outputstring .= ((defined($values[12])) ? "<br>" . nbspaces(2) . "Affiliation: " . get_value($args{dbh},$args{schema}, "commentor_affiliation", "name", "id = $values[12]") : "") . "\n";
                        $outputstring .= "</td></tr>\n";
                    } else {
                        $lastNameStatus = $values[13];
                        $outputstring .= "<tr><td>" . get_value($args{dbh},$args{schema},"commentor_name_status","name", "id=$values[13]") . "</td></tr>\n";
                    }
                }
                $outputstring .= "<tr><td>" . nbspaces(5) . "$CRDType" . lpadzero($values[14],6) . " / " . lpadzero($values[15],4) . " - " . get_value($args{dbh},$args{schema}, "bin", "name", "id = $values[16]") . "</b>\n";
                if (defined($values[17])) {
                    $outputstring .= "<br>" . nbspaces(7) . "Summarized By SCR" . lpadzero($values[17],4) . "\n";
                }
                $outputstring .= "</td></tr>\n";
                $testID = $values[14]*10000+$values[15];
                my %idMatches;
                my $foundMatch;
                my $count;
                $outputstring .= "<tr><td><table border=0>\n";
                for (my $i=0; $i <= $#testStrings; $i++) {
                    $foundMatch = 'F';
                    $idMatches{comment} = 'F';
                    $idMatches{rv} = 'F';
                    $idMatches{sc} = 'F';
                    $idMatches{scr} = 'F';
                    if (defined($idHashFull{$testID}{$testStrings[$i]})) {
                        if ($idHashFull{$testID}{$testStrings[$i]} eq 'T') {
                            $idMatches{comment} = 'T';
                            $foundMatch = 'T';
                            $found = 1;
                        }
                    }
                    if (defined($rvHashFull{$testID}{$testStrings[$i]})) {
                        if ($rvHashFull{$testID}{$testStrings[$i]} eq 'T') {
                            $idMatches{rv} = 'T';
                            $foundMatch = 'T';
                            $found = 1;
                        }
                    }
                    if (defined($values[17])) {
                        if (defined($scHashFull{$values[17]}{$testStrings[$i]})) {
                            if ($scHashFull{$values[17]}{$testStrings[$i]} eq 'T') {
                                $idMatches{sc} = 'T';
                                $foundMatch = 'T';
                                $found = 1;
                            }
                        }
                        if (defined($scrHashFull{$values[17]}{$testStrings[$i]})) {
                            if ($scrHashFull{$values[17]}{$testStrings[$i]} eq 'T') {
                                $idMatches{scr} = 'T';
                                $foundMatch = 'T';
                                $found = 1;
                            }
                        }
                    }
                    if ($foundMatch eq 'T') {
                        $outputstring .= "<tr><td>" . nbspaces(10) . "</td><td colspan=2>Search String: &nbsp; $testStrings[$i]</td></tr>\n";
                        $outputstring .= "<tr><td>" . nbspaces(10) . "</td><td>" . nbspaces(5) . "</td><td>Found in: \n";
                        $count = 0;
                        if ($idMatches{comment} eq 'T') {
                            $outputstring .= "Comment";
                            $count++;
                        }
                        if ($idMatches{rv} eq 'T') {
                            $outputstring .= (($count > 0) ? ", " : "") . "Response";
                            $count++;
                        }
                        if ($idMatches{sc} eq 'T') {
                            $outputstring .= (($count > 0) ? ", " : "") . "Summary Comment";
                            $count++;
                        }
                        if ($idMatches{scr} eq 'T') {
                            $outputstring .= (($count > 0) ? ", " : "") . "Summary Comment Response";
                            $count++;
                        }
                        $outputstring .= "</td></tr>\n";
                    }
                }
                $outputstring .= "</table>\n";
            }
            if ($found == 0) {
                $outputstring .= "<br>Strings not found";
            }
        }
        
    
        $outputstring .= "</td></tr><table>\n";
    
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate Search Strings Report.",$@);
        print doAlertBox( text => $message);
    }
    return ($outputstring);
}
    


###################################################################################################################################
sub doWeeklyStatusReport {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        beginDate => '',
        endDate => '',
        @_,
    );
    
#print "\n<!-- Args: @_ -->\n";

    my $outputstring = '';
    my $message = '';
    my $sqlquery = '';
    my $csr;
    
    
    eval {
        $outputstring .= "<table border=0 width=670><tr><td>\n";
        $outputstring .= "<script language=javascript><!--\n";
        $outputstring .= "    document.title='$CRDType Comment/Response Database - Weekly Status Report for Comment Documents Received'\n";
        $outputstring .= "//--></script>\n";

        $outputstring .= "<center><font size=+1>$CRDType Comment/Response Database<br>Weekly Status Report for Comment Documents Received</font><font size=-2><br><br></font>";
        $outputstring .= "<font size=-1>$args{'run_date'}</font></center>\n";
        
        my %counters;
        my @docTypeList = ('US Mail','Fax','Electronic','Other','Public Hearing','Total');
        my %docTypeMap = (
            LETTER => 'US Mail',
            POSTCARD => 'US Mail',
            FAX => 'Fax',
            EMAIL => 'Electronic',
            'WEB FORM' => 'Electronic',
            PETITION => 'US Mail',
            'COMMENT FORM' => 'US Mail',
            OTHER => 'Other',
            HEARING => 'Public Hearing',
            'FAX - DOE 6 POINT RESPONSE' => 'Fax',
            'EMAIL - DOE 6 POINT RESPONSE' => 'Electronic',
            'LTR - DOE 6 POINT RESPONSE' => 'US Mail',
            total => 'Total'
        );
        my ($startLegislature, $endLegislature) = &HighProfileIDs;
        
        foreach my $key (@docTypeList) {
            $counters{$key}{legislature} = 0;
            $counters{$key}{other} = 0;
            $counters{$key}{legislatureTotal} = 0;
            $counters{$key}{otherTotal} = 0;
            $counters{$key}{total} = 0;
        }
        
        $sqlquery = "SELECT doc.id, doc.documenttype, TO_CHAR(doc.datereceived,'YYYYMMDD'), dt.name FROM $args{schema}.document doc, $args{schema}.document_type dt WHERE doc.documenttype = dt.id";
        $csr = $args{dbh}->prepare($sqlquery);
        $csr->execute;
        
        while (my ($id, $type, $dateReceived, $docType) = $csr->fetchrow_array) {
            if (substr($docType,0, 4) eq 'TRAN' || substr($docType,0,4) eq 'SUBM') {$docType = 'HEARING';}
            if ($id >= $startLegislature && $id <= $endLegislature) {
                if ($dateReceived >= $args{beginDate} && $dateReceived <= $args{endDate}) {
                    $counters{$docTypeMap{$docType}}{legislature}++;
                    $counters{$docTypeMap{total}}{legislature}++;
                }
                $counters{$docTypeMap{$docType}}{legislatureTotal}++;
                $counters{$docTypeMap{total}}{legislatureTotal}++;
            } else {
                if ($dateReceived >= $args{beginDate} && $dateReceived <= $args{endDate}) {
                    $counters{$docTypeMap{$docType}}{other}++;
                    $counters{$docTypeMap{total}}{other}++;
                }
                $counters{$docTypeMap{$docType}}{otherTotal}++;
                $counters{$docTypeMap{total}}{otherTotal}++;
            }
            $counters{$docTypeMap{$docType}}{total}++;
            $counters{$docTypeMap{total}}{total}++;
            
        }
        $csr->finish;
        
        $outputstring .= "<table border=1 cellspacing=0 width=100% bgcolor=ffffff>\n";
        $outputstring .= "<tr><td colspan=1 rowspan=2>&nbsp;</td><td align=center colspan=2><b><font size=-1>Received<br>";
        $outputstring .= substr($args{beginDate},4,2) . "/" . substr($args{beginDate},6,2) . "/" . substr($args{beginDate},0,4) . " - ";
        $outputstring .= substr($args{endDate},4,2) . "/" . substr($args{endDate},6,2) . "/" . substr($args{endDate},0,4) . "</font></b></td>";
        $outputstring .= "<td align=center colspan=3><b><font size=-1>Grand Totals<br>05/07/2001 - ";
        my @today = localtime;
        $outputstring .= lpadzero($today[4]+1,2) . "/" . lpadzero($today[3],2) . "/" . ($today[5] + 1900) . "</font></b></td></tr>\n";
        $outputstring .= "<tr><td align=center><b><font size=-1>From&nbsp;Governors<br>and&nbsp;Legislatures</font></b></td><td align=center><b><font size=-1>From&nbsp;Others</font></b></td><td align=center><b><font size=-1>From&nbsp;Governors<br>and&nbsp;Legislatures</font></b></td><td align=center><b><font size=-1>From&nbsp;Others</font></b></td><td align=center><b><font size=-1>Total</font></b></td></tr>\n";
        $outputstring .= "<tr><td colspan=6><b><font size=-1>Mode of Comment Documents Received:</font></b></td></tr>\n";
        
        foreach my $key (@docTypeList) {
            $outputstring .= "<tr><td><font size=-1>$key</font></td>";
            foreach my $type ('legislature', 'other', 'legislatureTotal', 'otherTotal', 'total') {
                $outputstring .= "<td align=center><font size=-1>$counters{$key}{$type}</font></td>";
            }
            $outputstring .= "</tr>\n";
        }
        
        $outputstring .= "<tr bordercolor=ffffff><td colspan=6 height=10></td></tr>\n";
        $outputstring .= "<tr><td colspan=6><b><font size=-1>Comments within Documents --</b> (Comment Documents usually contain multiple comments)</font></td></tr>\n";

        $sqlquery = "SELECT id, name, NVL(parent,0) FROM $args{schema}.bin ORDER BY name";
        $csr = $args{dbh}->prepare($sqlquery);
        $csr->execute;
        my %binMap;
        my @binList;
        while (my ($id, $name, $parent) = $csr->fetchrow_array) {
            my ($rootID, $rootName) = getBinRoot(dbh => $args{dbh}, schema => $args{schema}, bin => $id);
            $binMap{$id} = $rootName;
            if ($parent == 0) {
                push @binList, $rootName;
            }
        }
        push @binList, "Total";
        $binMap{total} = "Total";
        $csr->finish;

        foreach my $key (@binList) {
            $counters{$key}{legislature} = 0;
            $counters{$key}{other} = 0;
            $counters{$key}{legislatureTotal} = 0;
            $counters{$key}{otherTotal} = 0;
            $counters{$key}{total} = 0;
        }
        
        $sqlquery = "SELECT document, commentnum, bin, TO_CHAR(proofreaddate,'YYYYMMDD') FROM $args{schema}.comments";
        $csr = $args{dbh}->prepare($sqlquery);
        $csr->execute;
        while (my ($document, $commentnum, $bin, $proofreadDate) = $csr->fetchrow_array) {
            if ($document >= $startLegislature && $document <= $endLegislature) {
                if (defined($proofreadDate) && $proofreadDate >= $args{beginDate} && $proofreadDate <= $args{endDate}) {
                    $counters{$binMap{$bin}}{legislature}++;
                    $counters{$binMap{total}}{legislature}++;
                }
                $counters{$binMap{$bin}}{legislatureTotal}++;
                $counters{$binMap{total}}{legislatureTotal}++;
            } else {
                if (defined($proofreadDate) && $proofreadDate >= $args{beginDate} && $proofreadDate <= $args{endDate}) {
                    $counters{$binMap{$bin}}{other}++;
                    $counters{$binMap{total}}{other}++;
                }
                $counters{$binMap{$bin}}{otherTotal}++;
                $counters{$binMap{total}}{otherTotal}++;
            }
            $counters{$binMap{$bin}}{total}++;
            $counters{$binMap{total}}{total}++;
            
        }
        $csr->finish;
        
        foreach my $key (@binList) {
            #my ($binNumber, $binName) = getBinNumber(binName => $key);
            if ($key ne 'Total') {
                $outputstring .= "<tr><td><font size=-1>$key</font></td>";
            } else {
                $outputstring .= "<tr><td><font size=-1>$key</font></td>";
            }
            foreach my $type ('legislature', 'other', 'legislatureTotal', 'otherTotal', 'total') {
                $outputstring .= "<td align=center><font size=-1>$counters{$key}{$type}</font></td>";
            }
            $outputstring .= "</tr>\n";
        }
        
        $outputstring .= "</table>\n";
        
        $outputstring .= "<table border=0><tr><td>&nbsp;&nbsp;&nbsp;&nbsp;</td>\n<td><font size=-1><b>NOTES:</font><font size=-2><br>\n";
        $outputstring .= "1) There is a time lag between data entry of comment documents and data entry of individual comments from documents.  Therefore, the document counts in this report may include documents containing comments that have not yet been entered into the system.</font><td></tr></table>\n";
        
        
        
        $outputstring .= "</td></tr></table>\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate Weekly Status Report.",$@);
        print doAlertBox( text => $message);
    }
    return ($outputstring);
}
    


###################################################################################################################################
sub CheckID {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        documentID => 0,
        commentID => '',
        javaScript => '',
        @_,
    );
    my $message='';
    my $outputstring = '';
    my @row;
    
    eval {
        if ($args{commentID} ne '') {
            @row = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.comments WHERE (document = $args{documentID}) AND (commentnum = $args{commentID})");
        } else {
            @row = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.document WHERE (id = $args{documentID})");
        }
        if ($row[0] >= 1) {
            $outputstring .= "<script language=javascript><!--\n";
            $outputstring .= "    $args{javaScript}\n";
            $outputstring .= "//--></script>\n";
        } else {
            $outputstring .= "<script language=javascript><!--\n";
            $outputstring .= "    alert('Entered ID does not exist in the database.')\n";
            $outputstring .= "//--></script>\n";
        }

    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"checking if $CRDType" . lpadzero($args{documentID},6) . " / " . lpadzero($args{commentID},4) . " exists.",$@);
        print doAlertBox( text => $message);
    }
    return ($outputstring);

}


###################################################################################################################################
sub CommentSelectionPage {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        type => '',
        @_,
    );
    my $message='';
    my $outputstring = '';
    
    eval {
        tie my %lookup_values, "Tie::IxHash";
        tie my %lookup_values2, "Tie::IxHash";
        
        $outputstring .= "<!-- test line 1 -->\n";
    
        my $DocIdReportInput = "<table border=0><tr><td><input type=radio name=docidtype value=range checked onClick=\"setStandardCommentsByDocIdDisabled(false)\"></td>\n";
        $DocIdReportInput .= "<td><b>Documents Between &nbsp; $CRDType <input type=text size=6 maxlength=6 name=startingdocid></b>" . nbspaces(3);
        $DocIdReportInput .= "<b>and &nbsp; $CRDType <input type=text size=6 maxlength=6 name=endingdocid></b></td></tr>\n";
        $DocIdReportInput .= "<tr><td><input type=radio name=docidtype value=list onClick=\"setStandardCommentsByDocIdDisabled(false)\"></td>\n";
        $DocIdReportInput .= "<td><b>$CRDType <input type=text size=6 maxlength=6 name=includedocid> &nbsp; \n";
        $DocIdReportInput .= "<input type=button name=copyidbutton value='Add to list' onClick=\"copyDocID();\">\n" . nbspaces(6);
        $DocIdReportInput .= "ID list: <select size=3 multiple name=docidlist><option value=0>" . nbspaces(25) . "</option></select> &nbsp <input type=button name=resetidbutton value='Reset list' onClick=\"clearIdList();\"></td></tr></table><input type=button value=Submit align=center onClick=\"checkStandardCommentsByDocId();\">\n";
        #$DocIdReportInput .= "<script language=javascript><!--\n  setStandardCommentsByDocIdDisabled(false);\n//--></script>\n";
        my $DocIdReport = new Report_Forms;
        $DocIdReport->label("Select by 'Document Id'");
        $DocIdReport->contents($DocIdReportInput);
    
        %lookup_values = get_lookup_values($args{'dbh'},$args{'schema'},'document_type','id','name', '1=1 ORDER BY name');
        my $DocTypeReportInput = "<table border=0><tr><td><b>Document Type:</b> " . build_drop_box ("doctype", \%lookup_values, '0', '0') . "</td></tr></table><input type=button value=Submit align=center onClick=\"checkStandardCommentsByDocType();\">\n";
        my $DocTypeReport = new Report_Forms;
        $DocTypeReport->label("Select by 'Document Type'");
        $DocTypeReport->contents($DocTypeReportInput);
    
        my $CommentIdReportInput = "<table border=0><tr><td><input type=radio name=comidtype value=range checked onClick=\"setStandardCommentsByCommentIdDisabled(false)\"></td>\n";
        $CommentIdReportInput .= "<td><b>Starting with: &nbsp; $CRDType <input type=text size=6 maxlength=6 name=startdocid> / </b><input type=text size=4 maxlength=4 name=startingcommentid>" . nbspaces(4);
        $CommentIdReportInput .= "<b>Ending with: &nbsp; $CRDType <input type=text size=6 maxlength=6 name=enddocid> / </b><input type=text size=4 maxlength=4 name=endingcommentid></td></tr>\n";
        $CommentIdReportInput .= "<tr><td><input type=radio name=comidtype value=list onClick=\"setStandardCommentsByCommentIdDisabled(false)\"></td>\n";
        $CommentIdReportInput .= "<td><b>$CRDType <input type=text size=6 maxlength=6 name=includecomdocid> / <input type=text size=6 maxlength=6 name=includecomid> &nbsp; \n";
        $CommentIdReportInput .= "<input type=button name=copycomidbutton value='Add to list' onClick=\"copyComID();\">\n" . nbspaces(6);
        $CommentIdReportInput .= "ID list: <select size=3 multiple name=comidlist><option value=0>" . nbspaces(35) . "</option></select> &nbsp <input type=button name=resetcomidbutton value='Reset list' onClick=\"clearComIdList();\"></td></tr>\n";
        $CommentIdReportInput .= "<tr><td><input type=radio name=comidtype value=paste onClick=\"setStandardCommentsByCommentIdDisabled(false)\"></td>\n";
        $CommentIdReportInput .= "<td><table border=0><tr><td valign=bottom><b>Paste in list of Document/Comment numbers<br>use format of '$CRDType" . "000000/0000':</b>";
        $CommentIdReportInput .= "</td><td>" . nbspaces(50) . "<a href=\"javascript:expandTextBox(document.$form.comidpastelist,document.comidpastelist_button,'force',5);\"><img name=comidpastelist_button border=0 src=/eis/images/expand_button.gif></a><br>\n";
        $CommentIdReportInput .= nbspaces(10) . "<textarea name=comidpastelist rows=6 cols=20 onKeyPress=\"expandTextBox(this,document.comidpastelist_button,'dynamic');\"></textarea></td></tr></table></td></tr></table><input type=button value=Submit align=center onClick=\"checkStandardCommentsByCommentId();\">\n";
        #$CommentIdReportInput .= "<script language=javascript><!--\n  setStandardCommentsByCommentIdDisabled(false);\n//--></script>\n";
        my $CommentIdReport = new Report_Forms;
        $CommentIdReport->label("Select by 'Comment Id'");
        $CommentIdReport->contents($CommentIdReportInput);
    
        %lookup_values = get_lookup_values($args{'dbh'},$args{'schema'},'bin','id','name', '1=1 ORDER BY name');
        my $BinReportInput = "<table border=0><tr><td><b>Bin:</b> " . build_drop_box ("binid", \%lookup_values, '0', '0') . "</td></tr></table><input type=button value=Submit align=center onClick=\"checkStandardCommentsByBin();\">\n";
        my $BinReport = new Report_Forms;
        $BinReport->label("Select by 'Bin'");
        $BinReport->contents($BinReportInput);
    
        my $DateReportInput = "<table border=0><tr><td><b>From:</b> " . build_date_selection("begindate", "$form", "today") . " &nbsp; ";
        $DateReportInput .= "<b>To:</b> " . build_date_selection("enddate", "$form", "today") . "</td></tr></table><input type=button value=Submit align=center onClick=\"checkStandardCommentsByDate();\">\n";
        my $DateReport = new Report_Forms;
        $DateReport->label("Select by 'Date Received'");
        $DateReport->contents($DateReportInput);
    
        %lookup_values = get_lookup_values($args{'dbh'},$args{'schema'},'commentor_affiliation','id','name', '1=1 ORDER BY name');
        my $AffiliationReportInput = "<table border=0><tr><td><b>Document Type:</b> " . build_drop_box ("affiliation", \%lookup_values, '0', '0') . "</td></tr></table><input type=button value=Submit align=center onClick=\"checkStandardCommentsByAffiliation();\">\n";
        my $AffiliationReport = new Report_Forms;
        $AffiliationReport->label("Select by 'Commentor Affiliation'");
        $AffiliationReport->contents($AffiliationReportInput);
    
        %lookup_values2 = get_unique_commentor_values($args{'dbh'},$args{'schema'},'state', '1=1 ORDER BY state');
        my $StateReportInput = "<table border=0><tr><td><b>State:</b> " . build_drop_box ("state", \%lookup_values2, '0', '0') . "</td></tr></table><input type=button value=Submit align=center onClick=\"checkStandardCommentsByState();\">\n";
        my $StateReport = new Report_Forms;
        $StateReport->label("Select by 'Commentor State'");
        $StateReport->contents($StateReportInput);
    
        %lookup_values = get_unique_commentor_values($args{'dbh'},$args{'schema'},'city', '1=1 ORDER BY city');
        my $CityReportInput = "<table border=0><tr><td><b>City:</b> " . build_drop_box ("city", \%lookup_values, '0', '0') . "</td></tr></table><input type=button value=Submit align=center onClick=\"checkStandardCommentsByCity();\">\n";
        my $CityReport = new Report_Forms;
        $CityReport->label("Select by 'Commentor City'");
        $CityReport->contents($CityReportInput);
    
        %lookup_values2 = get_unique_commentor_values($args{'dbh'},$args{'schema'},'organization', '1=1 ORDER BY organization');
        my $OrganizationReportInput = "<table border=0><tr><td><b>Organization:</b> " . build_drop_box ("organization", \%lookup_values2, '0', '0') . "</td></tr></table><input type=button value=Submit align=center onClick=\"checkStandardCommentsByOrganization();\">\n";
        my $OrganizationReport = new Report_Forms;
        $OrganizationReport->label("Select by 'Commentor Organization'");
        $OrganizationReport->contents($OrganizationReportInput);
    
        my $PostalCodeReportInput = "<table border=0><tr><td><b>Between: &nbsp; <input type=text size=10 maxlength=10 name=startpostalcode>" . nbspaces(4);
        $PostalCodeReportInput .= "<b>and &nbsp; <input type=text size=10 maxlength=10 name=endpostalcode></td></tr></table><input type=button value=Submit align=center onClick=\"checkStandardCommentsByPostalCode();\">\n";
        my $PostalCodeReport = new Report_Forms;
        $PostalCodeReport->label("Select by 'Commentor Postal Code'");
        $PostalCodeReport->contents($PostalCodeReportInput);
    
        my $NameReportInput = "<table border=0><tr><td><b>Between: &nbsp; <input type=text size=25 maxlength=25 name=beginname>" . nbspaces(4);
        $NameReportInput .= "<b>and &nbsp; <input type=text size=25 maxlength=25 name=endname></td></tr></table><input type=button value=Submit align=center onClick=\"checkStandardCommentsByName();\">\n";
        my $NameReport = new Report_Forms;
        $NameReport->label("Select by 'Commentor Last Name'");
        $NameReport->contents($NameReportInput);
    
        #$outputstring .= "<tr><td>\n$printHeaderHelp<br></td></tr>\n";
        $outputstring .= "<!-- test marker -->\n";
        $outputstring .= "<tr><td align=center>\n";
        $outputstring .= "<table width=670 cellpadding=8 cellspacing=0 border=0>\n";
        $outputstring .= "<tr><td><input type=checkbox name=sortbybin value='T'> &nbsp; <b>Sort Output by Bin</b>\n";
        $outputstring .= nbspaces(60) . "<input type=checkbox name=displaycommentor value='T'> &nbsp; <b>Include Commentor Information</b><br><br><hr width=75%></td></tr>\n";

        my $standardCommentsMenu = new Text_Menus;

        $standardCommentsMenu->addMenu(name => "standardComments1", label => $DocIdReport->label(), contents => $DocIdReport->contents(), title => $DocIdReport->label());
        $standardCommentsMenu->addMenu(name => "standardComments2", label => $DocTypeReport->label(), contents => $DocTypeReport->contents(), title => $DocTypeReport->label());
        $standardCommentsMenu->addMenu(name => "standardComments3", label => $CommentIdReport->label(), contents => $CommentIdReport->contents(), title => $CommentIdReport->label());
        $standardCommentsMenu->addMenu(name => "standardComments4", label => $BinReport->label(), contents => $BinReport->contents(), title => $BinReport->label());
        $standardCommentsMenu->addMenu(name => "standardComments5", label => $DateReport->label(), contents => $DateReport->contents(), title => $DateReport->label());
        $standardCommentsMenu->addMenu(name => "standardComments6", label => $AffiliationReport->label(), contents => $AffiliationReport->contents(), title => $AffiliationReport->label());
        $standardCommentsMenu->addMenu(name => "standardComments7", label => $StateReport->label(), contents => $StateReport->contents(), title => $StateReport->label());
        $standardCommentsMenu->addMenu(name => "standardComments8", label => $CityReport->label(), contents => $CityReport->contents(), title => $CityReport->label());
        $standardCommentsMenu->addMenu(name => "standardComments9", label => $OrganizationReport->label(), contents => $OrganizationReport->contents(), title => $OrganizationReport->label());
        $standardCommentsMenu->addMenu(name => "standardComments10", label => $PostalCodeReport->label(), contents => $PostalCodeReport->contents(), title => $PostalCodeReport->label());
        $standardCommentsMenu->addMenu(name => "standardComments11", label => $NameReport->label(), contents => $NameReport->contents(), title => $NameReport->label());

        $outputstring .= "<tr><td align=center>" . $standardCommentsMenu->buildMenus(name => 'StandardCommentsMenu1', type => 'bullets') . "</td></tr>";

        $outputstring .= "</table>\n</td></tr>\n<tr><td height=30> </td></tr>\n";
        $outputstring .= "<tr><td><br>\n$printHeaderHelp<br></td></tr>\n";
        $outputstring .= "<input type=hidden name=checkdocumentid value=''>\n";
        $outputstring .= "<input type=hidden name=checkcommentid value=''>\n";
        $outputstring .= "<input type=hidden name=checkjavascript value=''>\n";
        $outputstring .= "<script language=javascript><!--\n";
        $outputstring .= "  function lpadzero(instring, width) {\n";
        $outputstring .= "      var result = '';\n";
        $outputstring .= "      var index;\n";
        $outputstring .= "      for (index = 1; index <= (width - instring.length); index++) {\n";
        $outputstring .= "          result += \"0\";\n";
        $outputstring .= "      }\n";
        $outputstring .= "      return (result + instring);\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function copyDocID() {\n";
        $outputstring .= "      if (isnumeric(document.$form.includedocid.value)) {\n";
        $outputstring .= "          $form.checkdocumentid.value=$form.includedocid.value;\n";
        $outputstring .= "          $form.checkjavascript.value=\"parent.main.append_option(parent.main.$form.docidlist, parent.main.$form.includedocid.value, '$CRDType' + parent.main.lpadzero(parent.main.$form.includedocid.value,6) );parent.main.$form.includedocid.value='';\"\n";
        $outputstring .= "          submitFormCGIResults ('$form', 'checkID', 0);\n";
        $outputstring .= "      } else {\n";
        $outputstring .= "          alert ('Only use positive numbers');\n";
        $outputstring .= "      }\n";
        $outputstring .= "      parent.main.$form.includedocid.focus();\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function copyComID() {\n";
        $outputstring .= "      if (isnumeric(document.$form.includecomdocid.value) && isnumeric(document.$form.includecomid.value)) {\n";
        $outputstring .= "          $form.checkdocumentid.value=$form.includecomdocid.value;\n";
        $outputstring .= "          $form.checkcommentid.value=$form.includecomid.value;\n";
        $outputstring .= "          $form.checkjavascript.value=\"parent.main.append_option(parent.main.$form.comidlist, ((parent.main.$form.includecomdocid.value - 0) * 10000 + (parent.main.$form.includecomid.value - 0)), '$CRDType' + parent.main.lpadzero(parent.main.$form.includecomdocid.value,6) + ' / ' + parent.main.lpadzero(parent.main.$form.includecomid.value,4) );parent.main.$form.includecomdocid.value='';parent.main.$form.includecomid.value='';\"\n";
        $outputstring .= "          submitFormCGIResults ('$form', 'checkID', 0);\n";
        $outputstring .= "      } else {\n";
        $outputstring .= "          alert ('Only use positive numbers');\n";
        $outputstring .= "      }\n";
        $outputstring .= "      parent.main.$form.includecomdocid.focus();\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function setStandardCommentsByDocIdDisabled(value) {\n";
        $outputstring .= "      $form.docidtype[0].disabled = false;\n";
        $outputstring .= "      $form.docidtype[1].disabled = false;\n";
        $outputstring .= "      var disabled = (value) ? true : eval(!document.$form.docidtype[0].checked);\n";
        $outputstring .= "      $form.startingdocid.disabled = disabled;\n";
        $outputstring .= "      $form.endingdocid.disabled = disabled;\n";
        $outputstring .= "      var disabled = (value) ? true : eval(!document.$form.docidtype[1].checked);\n";
        $outputstring .= "      $form.includedocid.disabled = disabled;\n";
        $outputstring .= "      $form.docidlist.disabled = disabled;\n";
        $outputstring .= "      $form.copyidbutton.disabled = disabled;\n";
        $outputstring .= "      $form.resetidbutton.disabled = disabled;\n";
        $outputstring .= "      $form.docidtype[0].disabled = value;\n";
        $outputstring .= "      $form.docidtype[1].disabled = value;\n";
        $outputstring .= "  }\n";
        #$outputstring .= "  setStandardCommentsByDocIdDisabled(false);\n";
        $outputstring .= "  function clearIdList() {\n";
        $outputstring .= "      for (index=document.$form.docidlist.length-2; index >= 0 ;index--) {\n";
        $outputstring .= "          document.$form.docidlist.options[index].selected = true;\n";
        $outputstring .= "          remove_option(document.$form.docidlist);\n";
        $outputstring .= "      }\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function clearComIdList() {\n";
        $outputstring .= "      for (index=document.$form.comidlist.length-2; index >= 0 ;index--) {\n";
        $outputstring .= "          document.$form.comidlist.options[index].selected = true;\n";
        $outputstring .= "          remove_option(document.$form.comidlist);\n";
        $outputstring .= "      }\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function setStandardCommentsByDocTypeDisabled(value) {\n";
        $outputstring .= "      $form.doctype.disabled = value;\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function setStandardCommentsByCommentIdDisabled(value) {\n";
        $outputstring .= "      $form.comidtype[0].disabled = false;\n";
        $outputstring .= "      $form.comidtype[1].disabled = false;\n";
        $outputstring .= "      $form.comidtype[2].disabled = false;\n";
        $outputstring .= "      var disabled = (value) ? true : eval(!document.$form.comidtype[0].checked);\n";
        $outputstring .= "      $form.startdocid.disabled = disabled;\n";
        $outputstring .= "      $form.enddocid.disabled = disabled;\n";
        $outputstring .= "      $form.startingcommentid.disabled = disabled;\n";
        $outputstring .= "      $form.endingcommentid.disabled = disabled;\n";
        $outputstring .= "      var disabled = (value) ? true : eval(!document.$form.comidtype[1].checked);\n";
        $outputstring .= "      $form.includecomdocid.disabled = disabled;\n";
        $outputstring .= "      $form.includecomid.disabled = disabled;\n";
        $outputstring .= "      $form.comidlist.disabled = disabled;\n";
        $outputstring .= "      $form.copycomidbutton.disabled = disabled;\n";
        $outputstring .= "      $form.resetcomidbutton.disabled = disabled;\n";
        $outputstring .= "      var disabled = (value) ? true : eval(!document.$form.comidtype[2].checked);\n";
        $outputstring .= "      $form.comidpastelist.disabled = disabled;\n";
        $outputstring .= "      $form.comidtype[0].disabled = value;\n";
        $outputstring .= "      $form.comidtype[1].disabled = value;\n";
        $outputstring .= "      $form.comidtype[2].disabled = value;\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function setStandardCommentsByBinDisabled(value) {\n";
        $outputstring .= "      $form.binid.disabled = value;\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function setStandardCommentsByDateDisabled(value) {\n";
        $outputstring .= "      $form.begindate_month.disabled = value;\n";
        $outputstring .= "      $form.begindate_day.disabled = value;\n";
        $outputstring .= "      $form.begindate_year.disabled = value;\n";
        $outputstring .= "      $form.enddate_month.disabled = value;\n";
        $outputstring .= "      $form.enddate_day.disabled = value;\n";
        $outputstring .= "      $form.enddate_year.disabled = value;\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function setStandardCommentsByAffiliationDisabled(value) {\n";
        $outputstring .= "      $form.affiliation.disabled = value;\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function setStandardCommentsByStateDisabled(value) {\n";
        $outputstring .= "      $form.state.disabled = value;\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function setStandardCommentsByCityDisabled(value) {\n";
        $outputstring .= "      $form.city.disabled = value;\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function setStandardCommentsByOrganizationDisabled(value) {\n";
        $outputstring .= "      $form.organization.disabled = value;\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function setStandardCommentsByPostalCodeDisabled(value) {\n";
        $outputstring .= "      $form.startpostalcode.disabled = value;\n";
        $outputstring .= "      $form.endpostalcode.disabled = value;\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function setStandardCommentsByNameDisabled(value) {\n";
        $outputstring .= "      $form.beginname.disabled = value;\n";
        $outputstring .= "      $form.endname.disabled = value;\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function setDisabledAllStandardComments(disabled) {\n";
        $outputstring .= "      setStandardCommentsByDocIdDisabled(disabled);\n";
        $outputstring .= "      setStandardCommentsByDocTypeDisabled(disabled);\n";
        $outputstring .= "      setStandardCommentsByCommentIdDisabled(disabled);\n";
        $outputstring .= "      setStandardCommentsByBinDisabled(disabled);\n";
        $outputstring .= "      setStandardCommentsByDateDisabled(disabled);\n";
        $outputstring .= "      setStandardCommentsByAffiliationDisabled(disabled);\n";
        $outputstring .= "      setStandardCommentsByStateDisabled(disabled);\n";
        $outputstring .= "      setStandardCommentsByCityDisabled(disabled);\n";
        $outputstring .= "      setStandardCommentsByOrganizationDisabled(disabled);\n";
        $outputstring .= "      setStandardCommentsByPostalCodeDisabled(disabled);\n";
        $outputstring .= "      setStandardCommentsByNameDisabled(disabled);\n";
        $outputstring .= "  }\n";
        $outputstring .= "  setDisabledAllStandardComments(false);\n";
        $outputstring .= "  function checkStandardCommentsByDocId() {\n";
        $outputstring .= "          // Comments by doc id\n";
        $outputstring .= "          if (document.$form.docidtype[0].checked) {\n";
        $outputstring .= "              if (!(isnumeric(document.$form.startingdocid.value + '')) || !(isnumeric(document.$form.endingdocid.value + ''))) {\n";
        $outputstring .= "                  alert ('All fields must be filled out with positive numbers');\n";
        $outputstring .= "              } else if (isblank(document.$form.startingdocid.value) || isblank(document.$form.endingdocid.value)) {\n";
        $outputstring .= "                  alert ('All fields must be filled out');\n";
        $outputstring .= "              } else {\n";
        $outputstring .= "                  submitFormCGIResults('$form', 'report', 'CommentsByDocIdReportTest');\n";
        $outputstring .= "              }\n";
        $outputstring .= "          } else {\n";
        $outputstring .= "              if (document.$form.docidlist.length <=1) {\n";
        $outputstring .= "                  alert('No documents entered')\n";
        $outputstring .= "              } else {\n";
        $outputstring .= "                  for (index=0; index < document.$form.docidlist.length-1;index++) {;\n";
        $outputstring .= "                      document.$form.docidlist.options[index].selected = true;\n";
        $outputstring .= "                  }\n";
        $outputstring .= "                  submitFormCGIResults('$form', 'report', 'CommentsByDocIdReportTest');\n";
        $outputstring .= "                  for (index=0; index < document.$form.docidlist.length-1;index++) {;\n";
        $outputstring .= "                      document.$form.docidlist.options[index].selected = false;\n";
        $outputstring .= "                  }\n";
        $outputstring .= "              }\n";
        $outputstring .= "          }\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function checkStandardCommentsByDocType() {\n";
        $outputstring .= "          // Comments by doc type\n";
        $outputstring .= "          submitFormCGIResults('$form', 'report', 'CommentsByDocTypeReportTest');\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function checkStandardCommentsByCommentId() {\n";
        $outputstring .= "          // Comments by comment id\n";
        $outputstring .= "          if (document.$form.comidtype[0].checked) {\n";
        $outputstring .= "              if (!(isnumeric(document.$form.startdocid.value + '')) || !(isnumeric(document.$form.enddocid.value + '')) || !(isnumeric(document.$form.startingcommentid.value + '')) || !(isnumeric(document.$form.endingcommentid.value + ''))) {\n";
        $outputstring .= "                  alert ('All fields must be filled out with positive numbers');\n";
        $outputstring .= "              } else if (isblank(document.$form.startdocid.value) || isblank(document.$form.enddocid.value) || isblank(document.$form.startingcommentid.value) || isblank(document.$form.endingcommentid.value)) {\n";
        $outputstring .= "                  alert ('All fields must be filled out');\n";
        $outputstring .= "              } else {\n";
        $outputstring .= "                  submitFormCGIResults('$form', 'report', 'CommentsByCommentIdReportTest');\n";
        $outputstring .= "              }\n";
        $outputstring .= "          } else if (document.$form.comidtype[1].checked) {\n";
        $outputstring .= "              if (document.$form.comidlist.length <=1) {\n";
        $outputstring .= "                  alert('No comments entered')\n";
        $outputstring .= "              } else {\n";
        $outputstring .= "                  for (index=0; index < document.$form.comidlist.length-1;index++) {;\n";
        $outputstring .= "                      document.$form.comidlist.options[index].selected = true;\n";
        $outputstring .= "                  }\n";
        $outputstring .= "                  submitFormCGIResults('$form', 'report', 'CommentsByCommentIdReportTest');\n";
        $outputstring .= "                  for (index=0; index < document.$form.comidlist.length-1;index++) {;\n";
        $outputstring .= "                      document.$form.comidlist.options[index].selected = false;\n";
        $outputstring .= "                  }\n";
        $outputstring .= "              }\n";
        $outputstring .= "          } else {\n";
        $outputstring .= "              if (document.$form.comidpastelist.value > '                                   ') {\n";
        $outputstring .= "                  submitFormCGIResults('$form', 'report', 'CommentsByCommentIdReportTest');\n";
        $outputstring .= "              } else {\n";
        $outputstring .= "                  alert('No comments entered')\n";
        $outputstring .= "              }\n";
        $outputstring .= "          }\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function checkStandardCommentsByBin() {\n";
        $outputstring .= "          // Comments by bin\n";
        $outputstring .= "          submitFormCGIResults('$form', 'report', 'CommentsByBinReportTest');\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function checkStandardCommentsByDate() {\n";
        $outputstring .= "          // Comments by date\n";
        $outputstring .= "          submitFormCGIResults('$form', 'report', 'CommentsByDateReportTest');\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function checkStandardCommentsByAffiliation() {\n";
        $outputstring .= "          // Comments by affiliation\n";
        $outputstring .= "          submitFormCGIResults('$form', 'report', 'CommentsByAffiliationReportTest');\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function checkStandardCommentsByState() {\n";
        $outputstring .= "          // Comments by state\n";
        $outputstring .= "          submitFormCGIResults('$form', 'report', 'CommentsByStateReportTest');\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function checkStandardCommentsByCity() {\n";
        $outputstring .= "          // Comments by city\n";
        $outputstring .= "          submitFormCGIResults('$form', 'report', 'CommentsByCityReportTest');\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function checkStandardCommentsByOrganization() {\n";
        $outputstring .= "          // Comments by organization\n";
        $outputstring .= "          submitFormCGIResults('$form', 'report', 'CommentsByOrganizationReportTest');\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function checkStandardCommentsByPostalCode() {\n";
        $outputstring .= "          // Comments by postal code\n";
        $outputstring .= "          if (isblank(document.$form.startpostalcode.value) || isblank(document.$form.endpostalcode.value)) {\n";
        $outputstring .= "              alert ('All fields must be filled out');\n";
        $outputstring .= "          } else {\n";
        $outputstring .= "              submitFormCGIResults('$form', 'report', 'CommentsByPostalCodeReportTest');\n";
        $outputstring .= "          }\n";
        $outputstring .= "  }\n";
        $outputstring .= "  function checkStandardCommentsByName() {\n";
        $outputstring .= "          // Comments by name\n";
        $outputstring .= "          if (isblank(document.$form.beginname.value) || isblank(document.$form.endname.value)) {\n";
        $outputstring .= "              alert ('All fields must be filled out');\n";
        $outputstring .= "          } else {\n";
        $outputstring .= "              submitFormCGIResults('$form', 'report', 'CommentsByNameReportTest');\n";
        $outputstring .= "          }\n";
        $outputstring .= "  }\n";
        $outputstring .= "//--></script>\n";
    
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate standard comments report selection page.",$@);
        print doAlertBox( text => $message);
    }


    return ($outputstring);
}


###################################################################################################################################
sub DocumentSelectionPage {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        type => '',
        @_,
    );
    
    my $outputstring = '';
    tie my %lookup_values, "Tie::IxHash";
    tie my %lookup_values2, "Tie::IxHash";
    
    $outputstring .= "<!-- test line 1 -->\n";

    my $DocIdReportInput = "<table border=0><tr><td><b>Documents Between &nbsp; $CRDType <input type=text size=6 maxlength=6 name=startingdocid></b>" . nbspaces(3);
    $DocIdReportInput .= "<b>and &nbsp; $CRDType <input type=text size=6 maxlength=6 name=endingdocid></b></td></tr></table><input type=button value=Submit align=center onClick=\"checkDocIdReport();\">\n";
    my $DocIdReport = new Report_Forms;
    $DocIdReport->label("Select by 'Document Id'");
    $DocIdReport->contents($DocIdReportInput);
    
    %lookup_values = get_lookup_values($args{'dbh'},$args{'schema'},'document_type','id','name', '1=1 ORDER BY name');
    my $DocTypeReportInput = "<table border=0><tr><td><b>Document Type:</b> " . build_drop_box ("doctype1", \%lookup_values, '0', '0') . "</td></tr></table><input type=button value=Submit align=center onClick=\"checkDocTypeReport();\">\n";
    my $DocTypeReport = new Report_Forms;
    $DocTypeReport->label("Select by 'Document Type'");
    $DocTypeReport->contents($DocTypeReportInput);
    
    my $DateReportInput = "<table border=0><tr><td><b>From:</b> " . build_date_selection("date_received_start", "$form", "today") . " &nbsp; ";
    $DateReportInput .= "<b>To:</b> " . build_date_selection("date_received_end", "$form", "today") . "</td></tr></table><input type=button value=Submit align=center onClick=\"checkDocDateReport();\">\n";
    my $DateReport = new Report_Forms;
    $DateReport->label("Select by 'Date Received'");
    $DateReport->contents($DateReportInput);
    
    my $NameReportInput = "<table border=0><tr><td><b>Between: &nbsp; <input type=text size=25 maxlength=25 name=beginname>" . nbspaces(4);
    $NameReportInput .= "<b>and &nbsp; <input type=text size=25 maxlength=25 name=endname></td></tr></table><input type=button value=Submit align=center onClick=\"checkDocComNameReport();\">\n";
    my $NameReport = new Report_Forms;
    $NameReport->label("Select by 'Commentor Last Name'");
    $NameReport->contents($NameReportInput);
    
    #$outputstring .= "<tr><td>\n$printHeaderHelp<br></td></tr>\n";
    $outputstring .= "<!-- test marker -->\n";
    $outputstring .= "<tr><td align=center>\n";
    $outputstring .= "<table width=670 cellpadding=8 cellspacing=0 border=0><tr><td align=center>\n";

    my $documentsMenu = new Text_Menus;

    $documentsMenu->addMenu(name => "documents1", label => $DocIdReport->label(), contents => $DocIdReport->contents(), title => $DocIdReport->label());
    $documentsMenu->addMenu(name => "documents2", label => $DocTypeReport->label(), contents => $DocTypeReport->contents(), title => $DocTypeReport->label());
    $documentsMenu->addMenu(name => "documents3", label => $DateReport->label(), contents => $DateReport->contents(), title => $DateReport->label());
    $documentsMenu->addMenu(name => "documents4", label => $NameReport->label(), contents => $NameReport->contents(), title => $NameReport->label());

    $outputstring .= $documentsMenu->buildMenus(name => 'DocumentMenu1', type => 'bullets');

    $outputstring .= "</td></tr></table>\n</td></tr>\n<tr><td height=30> </td></tr>\n";
    $outputstring .= "<tr><td><br>\n$printHeaderHelp<br></td></tr>\n";
    $outputstring .= "<script language=javascript><!--\n";
    $outputstring .= "  function lpadzero(instring, width) {\n";
    $outputstring .= "      var result = '';\n";
    $outputstring .= "      var index;\n";
    $outputstring .= "      for (index = 1; index <= (width - instring.length); index++) {\n";
    $outputstring .= "          result += \"0\";\n";
    $outputstring .= "      }\n";
    $outputstring .= "      return (result + instring);\n";
    $outputstring .= "  }\n";
    $outputstring .= "  function disableDocIdReport(value) {\n";
    $outputstring .= "      document.$form.startingdocid.disabled = value;\n";
    $outputstring .= "      document.$form.endingdocid.disabled = value;\n";
    $outputstring .= "  }\n";
    $outputstring .= "  function disableDocTypeReport(value) {\n";
    $outputstring .= "      document.$form.doctype1.disabled = value;\n";
    $outputstring .= "  }\n";
    $outputstring .= "  function disableDocDateReport(value) {\n";
    $outputstring .= "      document.$form.date_received_start_month.disabled = value;\n";
    $outputstring .= "      document.$form.date_received_start_day.disabled = value;\n";
    $outputstring .= "      document.$form.date_received_start_year.disabled = value;\n";
    $outputstring .= "      document.$form.date_received_end_month.disabled = value;\n";
    $outputstring .= "      document.$form.date_received_end_day.disabled = value;\n";
    $outputstring .= "      document.$form.date_received_end_year.disabled = value;\n";
    $outputstring .= "  }\n";
    $outputstring .= "  function disableDocComNameReport(value) {\n";
    $outputstring .= "      document.$form.beginname.disabled = value;\n";
    $outputstring .= "      document.$form.endname.disabled = value;\n";
    $outputstring .= "  }\n";
    $outputstring .= "  function disableAllCD(value) {\n";
    $outputstring .= "      disableDocIdReport(value);\n";
    $outputstring .= "      disableDocTypeReport(value);\n";
    $outputstring .= "      disableDocDateReport(value);\n";
    $outputstring .= "      disableDocComNameReport(value);\n";
    $outputstring .= "  }\n";
    $outputstring .= "  function checkDocIdReport() {\n";
    $outputstring .= "          // Documents by doc id\n";
    $outputstring .= "          if (!(isnumeric(document.$form.startingdocid.value + '')) || !(isnumeric(document.$form.endingdocid.value + ''))) {\n";
    $outputstring .= "              alert ('All fields must be filled out with positive numbers');\n";
    $outputstring .= "          } else if (isblank(document.$form.startingdocid.value) || isblank(document.$form.endingdocid.value)) {\n";
    $outputstring .= "              alert ('All fields must be filled out');\n";
    $outputstring .= "          } else {\n";
    $outputstring .= "              document.$form.reporttitle.value = \"<b>$CRDType Comment/Response Database<br>Document Report<br>Documents Between '$CRDType\" + lpadzero(document.$form.startingdocid.value,6) + \"' and '$CRDType\" + lpadzero(document.$form.endingdocid.value,6) + \"'</b><br>\";\n";
    $outputstring .= "              document.$form.sortorder.value = 'doc_sort';\n";
    $outputstring .= "              document.$form.doc_selected.value = 'T';\n";
    $outputstring .= "              document.$form.use_only_docs.value = 'T';\n";
    $outputstring .= "              document.$form.doctype_selected.value = 'T';\n";
    $outputstring .= "              document.$form.commentor_selected.value = 'T';\n";
    $outputstring .= "              document.$form.commentordetail.value = 'F';\n";
    $outputstring .= "              document.$form.date_received_selected.value = 'T';\n";
    $outputstring .= "              document.$form.addressee_selected.value = 'T';\n";
    $outputstring .= "              document.$form.hassrcomments_selected.value = 'T';\n";
    $outputstring .= "              document.$form.haslacomments_selected.value = 'T';\n";
    $outputstring .= "              document.$form.has960comments_selected.value = 'T';\n";
    $outputstring .= "              document.$form.wasrescanned_selected.value = 'T';\n";
    $outputstring .= "              document.$form.doc_remarks_selected.value = 'T';\n";
    $outputstring .= "              disableAllCD(true);\n";
    $outputstring .= "              disableDocIdReport(false)\n";
    $outputstring .= "              submitFormCGIResults('ad_hoc_reports', 'adhoctest', 'document');\n";
    $outputstring .= "              disableAllCD(false);\n";
    $outputstring .= "          }\n";
    $outputstring .= "  }\n";
    $outputstring .= "  function checkDocTypeReport() {\n";
    $outputstring .= "          // Documents by doc type\n";
    $outputstring .= "          document.$form.reporttitle.value = \"<b>$CRDType Comment/Response Database<br>Document Report<br>Document Type '\" + document.$form.doctype1.options[document.$form.doctype1.selectedIndex].text + \"'</b><br>\";\n";
    $outputstring .= "          document.$form.sortorder.value = 'doc_sort';\n";
    $outputstring .= "          document.$form.doc_selected.value = 'T';\n";
    $outputstring .= "          document.$form.doctype_selected.value = 'T';\n";
    $outputstring .= "          document.$form.commentor_selected.value = 'T';\n";
    $outputstring .= "          document.$form.commentordetail.value = 'F';\n";
    $outputstring .= "          document.$form.date_received_selected.value = 'T';\n";
    $outputstring .= "          document.$form.addressee_selected.value = 'T';\n";
    $outputstring .= "          document.$form.hassrcomments_selected.value = 'T';\n";
    $outputstring .= "          document.$form.haslacomments_selected.value = 'T';\n";
    $outputstring .= "          document.$form.has960comments_selected.value = 'T';\n";
    $outputstring .= "          document.$form.wasrescanned_selected.value = 'T';\n";
    $outputstring .= "          document.$form.doctype_selected.value = 'F';\n";
    $outputstring .= "          document.$form.doctype.value = document.$form.doctype1.value;\n";
    $outputstring .= "          document.$form.use_only_docs.value = 'T';\n";
    $outputstring .= "          document.$form.doc_remarks_selected.value = 'T';\n";
    $outputstring .= "          disableAllCD(true);\n";
    $outputstring .= "          disableDocTypeReport(false)\n";
    $outputstring .= "          submitFormCGIResults('ad_hoc_reports', 'adhoctest', 'document');\n";
    $outputstring .= "          document.$form.doctype.value = '';\n";
    $outputstring .= "          disableAllCD(false);\n";
    $outputstring .= "  }\n";
    $outputstring .= "  function checkDocDateReport() {\n";
    $outputstring .= "          // Documents by date\n";
    $outputstring .= "          var months = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];\n";
    $outputstring .= "          var dates1 = $form.date_received_start_day.value + '-' + months[$form.date_received_start_month.value] + '-' + $form.date_received_start_year.value;\n";
    $outputstring .= "          var dates2 = $form.date_received_end_day.value + '-' + months[$form.date_received_end_month.value] + '-' + $form.date_received_end_year.value;\n";
    $outputstring .= "          document.$form.reporttitle.value = \"<b>$CRDType Comment/Response Database<br>Document Report<br>From '\" + dates1 + ' to ' + dates2 + \"'</b><br>\";\n";
    $outputstring .= "          document.$form.sortorder.value = 'doc_sort';\n";
    $outputstring .= "          document.$form.doc_selected.value = 'T';\n";
    $outputstring .= "          document.$form.doctype_selected.value = 'T';\n";
    $outputstring .= "          document.$form.commentor_selected.value = 'T';\n";
    $outputstring .= "          document.$form.commentordetail.value = 'F';\n";
    $outputstring .= "          document.$form.date_received_selected.value = 'T';\n";
    $outputstring .= "          document.$form.addressee_selected.value = 'T';\n";
    $outputstring .= "          document.$form.hassrcomments_selected.value = 'T';\n";
    $outputstring .= "          document.$form.haslacomments_selected.value = 'T';\n";
    $outputstring .= "          document.$form.has960comments_selected.value = 'T';\n";
    $outputstring .= "          document.$form.wasrescanned_selected.value = 'T';\n";
    $outputstring .= "          document.$form.use_only_docs.value = 'T';\n";
    $outputstring .= "          document.$form.doc_remarks_selected.value = 'T';\n";
    $outputstring .= "          disableAllCD(true);\n";
    $outputstring .= "          disableDocDateReport(false)\n";
    $outputstring .= "          submitFormCGIResults('ad_hoc_reports', 'adhoctest', 'document');\n";
    $outputstring .= "          disableAllCD(false);\n";
    $outputstring .= "  }\n";
    $outputstring .= "  function checkDocComNameReport() {\n";
    $outputstring .= "          // Documents by name\n";
    $outputstring .= "          if (isblank(document.$form.beginname.value) || isblank(document.$form.endname.value)) {\n";
    $outputstring .= "              alert ('All fields must be filled out');\n";
    $outputstring .= "          } else {\n";
    $outputstring .= "              document.$form.reporttitle.value = \"<b>$CRDType Comment/Response Database<br>Document Report<br>Commentors with Last Names Starting<br>Between '\" + document.$form.beginname.value + \"' and '\" + document.$form.endname.value + \"'</b><br>\";\n";
    $outputstring .= "              document.$form.sortorder.value = 'doc_sort';\n";
    $outputstring .= "              document.$form.doc_selected.value = 'T';\n";
    $outputstring .= "              document.$form.doctype_selected.value = 'T';\n";
    $outputstring .= "              document.$form.commentor_selected.value = 'T';\n";
    $outputstring .= "              document.$form.commentordetail.value = 'F';\n";
    $outputstring .= "              document.$form.date_received_selected.value = 'T';\n";
    $outputstring .= "              document.$form.addressee_selected.value = 'T';\n";
    $outputstring .= "              document.$form.hassrcomments_selected.value = 'T';\n";
    $outputstring .= "              document.$form.haslacomments_selected.value = 'T';\n";
    $outputstring .= "              document.$form.has960comments_selected.value = 'T';\n";
    $outputstring .= "              document.$form.wasrescanned_selected.value = 'T';\n";
    $outputstring .= "              document.$form.use_only_docs.value = 'T';\n";
    $outputstring .= "              document.$form.doc_remarks_selected.value = 'T';\n";
    $outputstring .= "              document.$form.extra_where_info.value = \" (UPPER(cmntr.lastname) BETWEEN UPPER('\" + document.$form.beginname.value + \"') AND UPPER('\" + document.$form.endname.value + \"'))\";\n";
    $outputstring .= "              disableAllCD(true);\n";
    $outputstring .= "              disableDocComNameReport(false)\n";
    $outputstring .= "              submitFormCGIResults('ad_hoc_reports', 'adhoctest', 'document');\n";
    $outputstring .= "              document.$form.extra_where_info.value = '';\n";
    $outputstring .= "              disableAllCD(false);\n";
    $outputstring .= "          }\n";
    $outputstring .= "  }\n";
    $outputstring .= "//--></script>\n";



    return ($outputstring);
}


###################################################################################################################################
sub CommentorSelectionPage {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        type => '',
        @_,
    );
    
    my $outputstring = '';
    tie my %lookup_values, "Tie::IxHash";
    tie my %lookup_values2, "Tie::IxHash";
    
    $outputstring .= "<!-- test line 1 -->\n";

    my $NameReportInput = "<table border=0><tr><td><b>Between: &nbsp; <input type=text size=25 maxlength=25 name=beginname>" . nbspaces(4);
    $NameReportInput .= "<b>and &nbsp; <input type=text size=25 maxlength=25 name=endname></td></tr></table><input type=button value=Submit align=center onClick=\"checkCommentorLastName();\">\n";
    my $NameReport = new Report_Forms;
    $NameReport->label("Select by 'Commentor Last Name'");
    $NameReport->contents($NameReportInput);
    
    %lookup_values = get_unique_commentor_values($args{'dbh'},$args{'schema'},'organization', '1=1 ORDER BY organization');
    my $OrganizationReportInput = "<table border=0><tr><td><b>Organization:</b> " . build_drop_box ("organization1", \%lookup_values, '0', '0') . "</td></tr></table><input type=button value=Submit align=center onClick=\"checkCommentorOrganization();\">\n";
    my $OrganizationReport = new Report_Forms;
    $OrganizationReport->label("Select by 'Organization'");
    $OrganizationReport->contents($OrganizationReportInput);
    
    %lookup_values = get_lookup_values($args{'dbh'},$args{'schema'},'commentor_affiliation','id','name', '1=1 ORDER BY name');
    my $AffiliationReportInput = "<table border=0><tr><td><b>Affiliation:</b> " . build_drop_box ("affiliation1", \%lookup_values, '0', '0') . "</td></tr></table><input type=button value=Submit align=center onClick=\"checkCommentorAffiliation();\">\n";
    my $AffiliationReport = new Report_Forms;
    $AffiliationReport->label("Select by 'Affiliation'");
    $AffiliationReport->contents($AffiliationReportInput);
    
    %lookup_values = get_unique_commentor_values($args{'dbh'},$args{'schema'},'city', '1=1 ORDER BY city');
    my $CityReportInput = "<table border=0><tr><td><b>City:</b> " . build_drop_box ("city1", \%lookup_values, '0', '0') . "</td></tr></table><input type=button value=Submit align=center onClick=\"checkCommentorCity();\">\n";
    my $CityReport = new Report_Forms;
    $CityReport->label("Select by 'City'");
    $CityReport->contents($CityReportInput);
    
    %lookup_values = get_unique_commentor_values($args{'dbh'},$args{'schema'},'state', '1=1 ORDER BY state');
    my $StateReportInput = "<table border=0><tr><td><b>State:</b> " . build_drop_box ("state1", \%lookup_values, '0', '0') . "</td></tr></table><input type=button value=Submit align=center onClick=\"checkCommentorState();\">\n";
    my $StateReport = new Report_Forms;
    $StateReport->label("Select by 'State'");
    $StateReport->contents($StateReportInput);
    
    %lookup_values = get_unique_commentor_values($args{'dbh'},$args{'schema'},'country', '1=1 ORDER BY country');
    my $PostalCodeReportInput = "<table border=0><tr><td><b>Between: &nbsp; <input type=text size=10 maxlength=10 name=beginpostalcode>" . nbspaces(4);
    $PostalCodeReportInput .= "<b>and &nbsp; <input type=text size=10 maxlength=10 name=endpostalcode></td></tr></table><input type=button value=Submit align=center onClick=\"checkCommentorPostalCode();\">\n";
    my $PostalCodeReport = new Report_Forms;
    $PostalCodeReport->label("Select by 'Postal Code'");
    $PostalCodeReport->contents($PostalCodeReportInput);
    
    my $AreaCodeReportInput = "<table border=0><tr><td><b>Between: &nbsp; <input type=text size=3 maxlength=3 name=beginareacode>" . nbspaces(4);
    $AreaCodeReportInput .= "<b>and &nbsp; <input type=text size=3 maxlength=3 name=endareacode></td></tr></table><input type=button value=Submit align=center onClick=\"checkCommentorAreaCode();\">\n";
    my $AreaCodeReport = new Report_Forms;
    $AreaCodeReport->label("Select by 'Area Code'");
    $AreaCodeReport->contents($AreaCodeReportInput);
    
    #$outputstring .= "<tr><td>\n$printHeaderHelp<br></td></tr>\n";
    $outputstring .= "<!-- test marker -->\n";
    $outputstring .= "<tr><td align=center>\n";
    $outputstring .= "<table width=670 cellpadding=8 cellspacing=0 border=0><tr><td align=center>\n";
    
    my $commentorsMenu = new Text_Menus;

    $commentorsMenu->addMenu(name => "commentors1", label => $NameReport->label(), contents => $NameReport->contents(), title => $NameReport->label());
    $commentorsMenu->addMenu(name => "commentors2", label => $OrganizationReport->label(), contents => $OrganizationReport->contents(), title => $OrganizationReport->label());
    $commentorsMenu->addMenu(name => "commentors3", label => $AffiliationReport->label(), contents => $AffiliationReport->contents(), title => $AffiliationReport->label());
    $commentorsMenu->addMenu(name => "commentors4", label => $CityReport->label(), contents => $CityReport->contents(), title => $CityReport->label());
    $commentorsMenu->addMenu(name => "commentors5", label => $StateReport->label(), contents => $StateReport->contents(), title => $StateReport->label());
    $commentorsMenu->addMenu(name => "commentors6", label => $PostalCodeReport->label(), contents => $PostalCodeReport->contents(), title => $PostalCodeReport->label());
    $commentorsMenu->addMenu(name => "commentors7", label => $AreaCodeReport->label(), contents => $AreaCodeReport->contents(), title => $AreaCodeReport->label());

    $outputstring .= $commentorsMenu->buildMenus(name => 'CommentorsMenu1', type => 'bullets');
    
    $outputstring .= "</td></tr></table>\n</td></tr>\n<tr><td height=30> </td></tr>\n";
    $outputstring .= "<tr><td><br>\n$printHeaderHelp<br></td></tr>\n";
    $outputstring .= "<script language=javascript><!--\n";
    $outputstring .= "  function setStandardCommentorsByNameDisabled(value) {\n";
    $outputstring .= "      $form.beginname.disabled = value;\n";
    $outputstring .= "      $form.endname.disabled = value;\n";
    $outputstring .= "  }\n";
    $outputstring .= "  function setStandardCommentorsByOrganizationDisabled(value) {\n";
    $outputstring .= "      $form.organization1.disabled = value;\n";
    $outputstring .= "  }\n";
    $outputstring .= "  function setStandardCommentorsByAffiliationDisabled(value) {\n";
    $outputstring .= "      $form.affiliation1.disabled = value;\n";
    $outputstring .= "  }\n";
    $outputstring .= "  function setStandardCommentorsByCityDisabled(value) {\n";
    $outputstring .= "      $form.city1.disabled = value;\n";
    $outputstring .= "  }\n";
    $outputstring .= "  function setStandardCommentorsByStateDisabled(value) {\n";
    $outputstring .= "      $form.state1.disabled = value;\n";
    $outputstring .= "  }\n";
    $outputstring .= "  function setStandardCommentorsByPostalCodeDisabled(value) {\n";
    $outputstring .= "      $form.beginpostalcode.disabled = value;\n";
    $outputstring .= "      $form.endpostalcode.disabled = value;\n";
    $outputstring .= "  }\n";
    $outputstring .= "  function setStandardCommentorsByAreaCodeDisabled(value) {\n";
    $outputstring .= "      $form.beginareacode.disabled = value;\n";
    $outputstring .= "      $form.endareacode.disabled = value;\n";
    $outputstring .= "  }\n";
    $outputstring .= "  function setDisabledAllStandardCommentors(disabled) {\n";
    $outputstring .= "      setStandardCommentorsByNameDisabled(disabled);\n";
    $outputstring .= "      setStandardCommentorsByOrganizationDisabled(disabled);\n";
    $outputstring .= "      setStandardCommentorsByAffiliationDisabled(disabled);\n";
    $outputstring .= "      setStandardCommentorsByCityDisabled(disabled);\n";
    $outputstring .= "      setStandardCommentorsByStateDisabled(disabled);\n";
    $outputstring .= "      setStandardCommentorsByPostalCodeDisabled(disabled);\n";
    $outputstring .= "      setStandardCommentorsByAreaCodeDisabled(disabled);\n";
    $outputstring .= "  }\n";
    $outputstring .= "  document.$form.excludetable.value = 'document';\n";
    $outputstring .= "  function checkCommentorLastName() {\n";
    $outputstring .= "          // Commentors by name\n";
    $outputstring .= "          if (isblank(document.$form.beginname.value) || isblank(document.$form.endname.value)) {\n";
    $outputstring .= "              alert ('All fields must be filled out');\n";
    $outputstring .= "          } else {\n";
    $outputstring .= "              document.$form.reporttitle.value = \"<b>$CRDType Comment/Response Database<br>Commentor Report<br>Commentors with Last Names Starting<br>Between '\" + document.$form.beginname.value + \"' and '\" + document.$form.endname.value + \"'</b><br>\";\n";
    $outputstring .= "              document.$form.sortorder.value = 'commentor_sort';\n";
    $outputstring .= "              document.$form.commentor_selected.value = 'T';\n";
    $outputstring .= "              document.$form.commentordetail.value = 'T';\n";
    $outputstring .= "              document.$form.extra_where_info.value = \" (UPPER(cmntr.lastname) BETWEEN UPPER('\" + document.$form.beginname.value + \"') AND UPPER('\" + document.$form.endname.value + \"'))\";\n";
    $outputstring .= "              setDisabledAllStandardCommentors(true);\n";
    $outputstring .= "              setStandardCommentorsByNameDisabled(false);\n";
    $outputstring .= "              submitFormCGIResults('ad_hoc_reports', 'adhoctest', 'commentor');\n";
    $outputstring .= "              setDisabledAllStandardCommentors(false);\n";
    $outputstring .= "              document.$form.extra_where_info.value = '';\n";
    $outputstring .= "          }\n";
    $outputstring .= "  }\n";
    $outputstring .= "  function checkCommentorOrganization() {\n";
    $outputstring .= "          // Commentors by organization\n";
    $outputstring .= "          document.$form.reporttitle.value = \"<b>$CRDType Comment/Response Database<br>Commentor Report<br>Organization '\" + document.$form.organization1.options[document.$form.organization1.selectedIndex].text + \"'</b><br>\";\n";
    $outputstring .= "          document.$form.sortorder.value = 'commentor_sort';\n";
    $outputstring .= "          document.$form.commentor_selected.value = 'T';\n";
    $outputstring .= "          document.$form.commentordetail.value = 'T';\n";
    $outputstring .= "          document.$form.organization.value = document.$form.organization1.options[document.$form.organization1.selectedIndex].text;\n";
    $outputstring .= "          setDisabledAllStandardCommentors(true);\n";
    $outputstring .= "          setStandardCommentorsByOrganizationDisabled(false);\n";
    $outputstring .= "          submitFormCGIResults('ad_hoc_reports', 'adhoctest', 'commentor');\n";
    $outputstring .= "          setDisabledAllStandardCommentors(false);\n";
    $outputstring .= "          document.$form.organization.value = '';\n";
    $outputstring .= "  }\n";
    $outputstring .= "  function checkCommentorAffiliation() {\n";
    $outputstring .= "          // Commentors by affiliation\n";
    $outputstring .= "          document.$form.reporttitle.value = \"<b>$CRDType Comment/Response Database<br>Commentor Report<br>Affiliation '\" + document.$form.affiliation1.options[document.$form.affiliation1.selectedIndex].text + \"'</b><br>\";\n";
    $outputstring .= "          document.$form.sortorder.value = 'commentor_sort';\n";
    $outputstring .= "          document.$form.commentor_selected.value = 'T';\n";
    $outputstring .= "          document.$form.commentordetail.value = 'T';\n";
    $outputstring .= "          document.$form.affiliationid.value = document.$form.affiliation1.options[document.$form.affiliation1.selectedIndex].value;\n";
    $outputstring .= "          setDisabledAllStandardCommentors(true);\n";
    $outputstring .= "          setStandardCommentorsByAffiliationDisabled(false);\n";
    $outputstring .= "          submitFormCGIResults('ad_hoc_reports', 'adhoctest', 'commentor');\n";
    $outputstring .= "          setDisabledAllStandardCommentors(false);\n";
    $outputstring .= "          document.$form.affiliationid.value = '';\n";
    $outputstring .= "  }\n";
    $outputstring .= "  function checkCommentorCity() {\n";
    $outputstring .= "          // Commentors by city\n";
    $outputstring .= "          document.$form.reporttitle.value = \"<b>$CRDType Comment/Response Database<br>Commentor Report<br>City '\" + document.$form.city1.options[document.$form.city1.selectedIndex].text + \"'</b><br>\";\n";
    $outputstring .= "          document.$form.sortorder.value = 'commentor_sort';\n";
    $outputstring .= "          document.$form.commentor_selected.value = 'T';\n";
    $outputstring .= "          document.$form.commentordetail.value = 'T';\n";
    $outputstring .= "          document.$form.cityid.value = document.$form.city1.options[document.$form.city1.selectedIndex].value;\n";
    $outputstring .= "          setDisabledAllStandardCommentors(true);\n";
    $outputstring .= "          setStandardCommentorsByCityDisabled(false);\n";
    $outputstring .= "          submitFormCGIResults('ad_hoc_reports', 'adhoctest', 'commentor');\n";
    $outputstring .= "          setDisabledAllStandardCommentors(false);\n";
    $outputstring .= "          document.$form.cityid.value = '';\n";
    $outputstring .= "  }\n";
    $outputstring .= "  function checkCommentorState() {\n";
    $outputstring .= "          // Commentors by state\n";
    $outputstring .= "          document.$form.reporttitle.value = \"<b>$CRDType Comment/Response Database<br>Commentor Report<br>State '\" + document.$form.state1.options[document.$form.state1.selectedIndex].text + \"'</b><br>\";\n";
    $outputstring .= "          document.$form.sortorder.value = 'commentor_sort';\n";
    $outputstring .= "          document.$form.commentor_selected.value = 'T';\n";
    $outputstring .= "          document.$form.commentordetail.value = 'T';\n";
    $outputstring .= "          document.$form.stateid.value = document.$form.state1.options[document.$form.state1.selectedIndex].value;\n";
    $outputstring .= "          setDisabledAllStandardCommentors(true);\n";
    $outputstring .= "          setStandardCommentorsByStateDisabled(false);\n";
    $outputstring .= "          submitFormCGIResults('ad_hoc_reports', 'adhoctest', 'commentor');\n";
    $outputstring .= "          setDisabledAllStandardCommentors(false);\n";
    $outputstring .= "          document.$form.stateid.value = '';\n";
    $outputstring .= "  }\n";
    $outputstring .= "  function checkCommentorPostalCode() {\n";
    $outputstring .= "          // Commentors by postal code\n";
    $outputstring .= "          if (!(isnumeric(document.$form.beginpostalcode.value + '')) || !(isnumeric(document.$form.endpostalcode.value + ''))) {\n";
    $outputstring .= "              alert ('All fields must be filled out with positive numbers');\n";
    $outputstring .= "          } else if (isblank(document.$form.beginpostalcode.value) || isblank(document.$form.endpostalcode.value)) {\n";
    $outputstring .= "              alert ('All fields must be filled out');\n";
    $outputstring .= "          } else {\n";
    $outputstring .= "              document.$form.reporttitle.value = \"<b>$CRDType Comment/Response Database<br>Commentor Report<br>Postal Codes Between '\" + document.$form.beginpostalcode.value + \"' and '\" + document.$form.endpostalcode.value + \"'</b><br>\";\n";
    $outputstring .= "              document.$form.sortorder.value = 'commentor_sort';\n";
    $outputstring .= "              document.$form.commentor_selected.value = 'T';\n";
    $outputstring .= "              document.$form.commentordetail.value = 'T';\n";
    $outputstring .= "              document.$form.extra_where_info.value = \" (cmntr.postalcode BETWEEN '\" + document.$form.beginpostalcode.value + \"' AND '\" + document.$form.endpostalcode.value + \"')\";\n";
    $outputstring .= "              setDisabledAllStandardCommentors(true);\n";
    $outputstring .= "              setStandardCommentorsByPostalCodeDisabled(false);\n";
    $outputstring .= "              submitFormCGIResults('ad_hoc_reports', 'adhoctest', 'commentor');\n";
    $outputstring .= "              setDisabledAllStandardCommentors(false);\n";
    $outputstring .= "              document.$form.extra_where_info.value = '';\n";
    $outputstring .= "          }\n";
    $outputstring .= "  }\n";
    $outputstring .= "  function checkCommentorAreaCode() {\n";
    $outputstring .= "          // Commentors by area code\n";
    $outputstring .= "          if (!(isnumeric(document.$form.beginareacode.value + '')) || !(isnumeric(document.$form.endareacode.value + ''))) {\n";
    $outputstring .= "              alert ('All fields must be filled out with positive numbers');\n";
    $outputstring .= "          } else if (isblank(document.$form.beginareacode.value) || isblank(document.$form.endareacode.value)) {\n";
    $outputstring .= "              alert ('All fields must be filled out');\n";
    $outputstring .= "          } else {\n";
    $outputstring .= "              document.$form.reporttitle.value = \"<b>$CRDType Comment/Response Database<br>Commentor Report<br>Area Codes Between '\" + document.$form.beginareacode.value + \"' and '\" + document.$form.endareacode.value + \"'</b><br>\";\n";
    $outputstring .= "              document.$form.sortorder.value = 'commentor_sort';\n";
    $outputstring .= "              document.$form.commentor_selected.value = 'T';\n";
    $outputstring .= "              document.$form.commentordetail.value = 'T';\n";
    $outputstring .= "              document.$form.extra_where_info.value = \" (cmntr.areacode BETWEEN '\" + document.$form.beginareacode.value + \"' AND '\" + document.$form.endareacode.value + \"')\";\n";
    $outputstring .= "              setDisabledAllStandardCommentors(true);\n";
    $outputstring .= "              setStandardCommentorsByAreaCodeDisabled(false);\n";
    $outputstring .= "              submitFormCGIResults('ad_hoc_reports', 'adhoctest', 'commentor');\n";
    $outputstring .= "              setDisabledAllStandardCommentors(false);\n";
    $outputstring .= "              document.$form.extra_where_info.value = '';\n";
    $outputstring .= "          }\n";
    $outputstring .= "  }\n";
    $outputstring .= "//--></script>\n";



    return ($outputstring);
}


###################################################################################################################################
sub doPrintCommentResponse {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        documentID => '0',
        commentID => '0',
        version => '0',
        @_,
    );
    
    my $outputstring = '';
    my $message = '';
    my $sqlquery ='';
    my $csr;
    my @values;
    my $status;
    
    eval {

        if ($args{documentID} eq "0" || $args{commentID} eq "0") {
            $outputstring .= "<script language=javascript><!--\n";
            $outputstring .= "    alert('Invalid document/comment ID\\n$CRDType" . lpadzero($args{documentID}, 6) . " / " . lpadzero($args{commentID}, 4) . "')\n";
            $outputstring .= "//--></script>\n";
        } else {
            $sqlquery = "SELECT com.document,com.commentnum,com.text,com.summary,com.dupsimstatus,com.dupsimdocumentid,com.dupsimcommentid ";
            $sqlquery .= "FROM $args{schema}.comments com ";
            $sqlquery .= "WHERE com.document = $args{documentID} AND com.commentnum = $args{commentID}";
            
            $outputstring .= "\n<!-- $sqlquery -->\n\n";
            
            $csr = $args{dbh}->prepare($sqlquery);
            $status = $csr->execute;
            @values = $csr->fetchrow_array;
            $csr->finish;
            
            if (!(defined($values[0]))) {
                $outputstring .= "<script language=javascript><!--\n";
                $outputstring .= "    alert('$CRDType" . lpadzero($args{documentID}, 6) . " / " . lpadzero($args{commentID}, 4) . " Not Found') \n";
                $outputstring .= "//--></script>\n";
            } else {
                
                my $titletext = $CRDType . lpadzero($args{documentID}, 6) . " / " . lpadzero($args{commentID}, 4);
                $outputstring .= "<script language=javascript><!--\n";
                $outputstring .= "    document.title='$titletext'\n";
                $outputstring .= "//--></script>\n";
                $outputstring .= "<table border=0 width=670>\n";
                $outputstring .= "<tr><td align=center><b>$titletext</b>\n";
                $outputstring .= "<br><font size=-1>$args{run_date}</font></td></tr>\n";
                $values[2] =~ s/\n/<br>/g;
                $values[2] =~ s/  /&nbsp;&nbsp;/g;
                $outputstring .= "<tr><td><font size=-1><b><u>Comment:</u></b>\n";
                if ($values[4] ==2) {
                    $outputstring .= "(duplicate of $CRDType" . lpadzero($values[5],6) . " / " . lpadzero($values[6],4) . ")\n";
                }
                $outputstring .= "<br>$values[2]</font></td></tr>\n";
                
                while ($values[4] == 2) {
                    $sqlquery = "SELECT com.document,com.commentnum,com.text,com.summary,com.dupsimstatus,com.dupsimdocumentid,com.dupsimcommentid ";
                    $sqlquery .= "FROM $args{schema}.comments com ";
                    $sqlquery .= "WHERE com.document = $values[5] AND com.commentnum = $values[6]";
                    $csr = $args{dbh}->prepare($sqlquery);
                    $status = $csr->execute;
                    @values = $csr->fetchrow_array;
                    $csr->finish;
                }
                
                if (defined($values[3])) {
                    $sqlquery = "SELECT id,title,commenttext,responsetext FROM $args{schema}.summary_comment WHERE id = $values[3]";
                    $csr = $args{dbh}->prepare($sqlquery);
                    $status = $csr->execute;
                    @values = $csr->fetchrow_array;
                    $csr->finish;
                    $outputstring .= "<tr><td><hr width=50%></td></tr>\n";
                    $outputstring .= "<tr><td><font size=-1><b><u>Response:</u></b> (Summarized by SCR" . lpadzero($values[0],4) . ")<br>\n";
                    if (defined($values[3])) {
                        $values[3] =~ s/\n/<br>/g;
                        $values[3] =~ s/  /&nbsp;&nbsp;/g;
                        $outputstring .= "$values[3]\n";
                    } else {
                        $outputstring .= "None Entered\n";
                    }
                    $outputstring .= "</font></td></tr>\n";
                } else {
                
                    $sqlquery = "SELECT rv.document,rv.commentnum,rv.originaltext,rv.lastsubmittedtext, rv.version ";
                    $sqlquery .= "FROM $args{schema}.response_version rv ";
                    $sqlquery .= "WHERE rv.document = $values[0] AND rv.commentnum = $values[1] ";
                    if ($args{version} eq '0') {
                        
                    } else {
                        $sqlquery .= "AND rv.version = $args{version} ";
                    }
                    $sqlquery .= "ORDER BY rv.version DESC";
                    $outputstring .= "\n<!-- $sqlquery -->\n\n";
                    $csr = $args{dbh}->prepare($sqlquery);
                    $status = $csr->execute;
                    while (@values = $csr->fetchrow_array) {
                    
                        $outputstring .= "<tr><td><hr width=50%></td></tr>\n";
                        $outputstring .= "<tr><td><font size=-1><b><u>Response" . ((defined($values[4])) ? " Version $values[4]" : "") . ":</u></b><br>\n";
                        my $responseText = lastSubmittedText(dbh => $dbh, schema => $schema, documentID => $values[0], commentID => $values[1]);
                        if (defined($responseText)) {
                            $responseText =~ s/\n/<br>/g;
                            $responseText =~ s/  /&nbsp;&nbsp;/g;
                            $outputstring .= "$responseText\n";
                        } else {
                            $outputstring .= "None Entered\n";
                        }
                        #if (defined($values[3])) {
                        #    $values[3] =~ s/\n/<br>/g;
                        #    $values[3] =~ s/  /&nbsp;&nbsp;/g;
                        #    $outputstring .= "$values[3]\n";
                        #} elsif (defined($values[2])) {
                        #    $values[2] =~ s/\n/<br>/g;
                        #    $values[2] =~ s/  /&nbsp;&nbsp;/g;
                        #    $outputstring .= "$values[2]\n";
                        #} else {
                        #    $outputstring .= "None Entered\n";
                        #}
                        $outputstring .= "</font></td></tr>\n";
                    }
                    $csr->finish;
                }
                $outputstring .= "</table>\n";
                
            }
        }
    
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"print comment/response pair.",$@);
        print doAlertBox( text => $message);
    }

    return ($outputstring);
}


###################################################################################################################################
sub doPrintSummaryCommentResponse {
###################################################################################################################################
    my %args = (
        run_date => getReportDateTime,
        dbh => '',
        schema => '',
        scrID => '0',
        @_,
    );
    
    my $outputstring = '';
    my $message = '';
    my $sqlquery ='';
    my $csr;
    my @values;
    my $status;
    
    eval {

        if ($args{scrID} eq "0") {
            $outputstring .= "<script language=javascript><!--\n";
            $outputstring .= "    alert('Invalid summary comment ID\\n$CRDType" . lpadzero($args{documentID}, 6) . " / " . lpadzero($args{commentID}, 4) . "')\n";
            $outputstring .= "//--></script>\n";
        } else {
            $sqlquery = "SELECT id,title,commenttext,responsetext ";
            $sqlquery .= "FROM $args{schema}.summary_comment ";
            $sqlquery .= "WHERE id = $args{scrID}";
            
            $outputstring .= "\n<!-- $sqlquery -->\n\n";
            
            $csr = $args{dbh}->prepare($sqlquery);
            $status = $csr->execute;
            my ($scrID, $title, $commenttext,$responsetext) = $csr->fetchrow_array;
            $csr->finish;
            
            if (!(defined($scrID))) {
                $outputstring .= "<script language=javascript><!--\n";
                $outputstring .= "    alert('SCR" . lpadzero($args{scrID}, 4) . " Not Found') \n";
                $outputstring .= "//--></script>\n";
            } else {
                
                my $titletext = "$CRDType - SCR" . lpadzero($args{scrID}, 4);
                $outputstring .= "<script language=javascript><!--\n";
                $outputstring .= "    document.title='$titletext'\n";
                $outputstring .= "//--></script>\n";
                $outputstring .= "<table border=0 width=670>\n";
                $outputstring .= "<tr><td align=center><b>$titletext</b>\n";
                $outputstring .= "<br><font size=-1>$args{run_date}</font></td></tr>\n";
                
                $title =~ s/  /&nbsp;&nbsp;/g;
                $outputstring .= "<tr><td><font size=-1><b><u>Title:</u></b>\n";
                $outputstring .= "<br>$title</font></td></tr>\n";
                
                $outputstring .= "<tr><td align=center><hr width=50%></td></tr>\n";

                $commenttext =~ s/\n/<br>/g;
                $commenttext =~ s/  /&nbsp;&nbsp;/g;
                $outputstring .= "<tr><td><font size=-1><b><u>Summary Comment:</u></b>\n";
                $outputstring .= "<br>$commenttext</font></td></tr>\n";
                
                $outputstring .= "<tr><td align=center><hr width=50%></td></tr>\n";
                
                $outputstring .= "<tr><td><font size=-1><b><u>Summary Response:</u></b><br>\n";
                if (defined($responsetext)) {
                    $responsetext =~ s/\n/<br>/g;
                    $responsetext =~ s/  /&nbsp;&nbsp;/g;
                    $outputstring .= "$responsetext";
                } else {
                    $outputstring .= "None Entered";
                }
                $outputstring .= "</font></td></tr>\n";
                
                $outputstring .= "</table>\n";
                
            }
        }
    
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"print summary comment response pair.",$@);
        print doAlertBox( text => $message);
    }

    return ($outputstring);
}


###################################################################################################################################
# begin main
###################################################################################################################################


#$dbh = &db_connect(server => "ydoracle");
$dbh = &db_connect();
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
$dbh->{LongReadLen} = 10000000;
#$crdcgi->use_named_parameters(1);
#print $crdcgi->header('type'=>'text/html', 'expires'=>'now');
print $crdcgi->header('text/html');
print <<end;
<html>
<head>
   <script src=$CRDJavaScriptPath/utilities.js></script>
   <script src=$CRDJavaScriptPath/widgets.js></script>
   <script language=javascript><!--
      function report(script, report) {
         document.$form.command.value = 'report';         
         document.$form.action = '$path' + script + '.pl';
         document.$form.id.value = report;
         document.$form.submit();
      }
      function submitForm(script, command, id) {
          //var old_command = document.$form.command.value;
          //var old_id = document.$form.command.id.value;
          //var old_action = document.$form.action;
          //var old_target = document.$form.target;
          document.$form.command.value = command;
          document.$form.id.value = id;
          document.$form.action = '$path' + script + '.pl';
          document.$form.target = 'main';
          document.$form.submit();
          //document.$form.command.value = old_command;
          //document.$form.id.value = old_id;
          //document.$form.action = old_action;
          //document.$form.target = old_target;
      }
      function submitFormNewWindow(script, command, id) {
          //var old_command = document.$form.command.value;
          //var old_id = document.$form.command.id.value;
          //var old_action = document.$form.action;
          //var old_target = document.$form.target;
          var myDate = new Date();
          var winName = myDate.getTime();
          document.$form.command.value = command;
          document.$form.id.value = id;
          document.$form.action = '$path' + script + '.pl';
          document.$form.target = winName;
          var newwin = window.open("",winName);
          newwin.creator = self;
          document.$form.submit();
          //newwin.focus();
          //document.$form.command.value = old_command;
          //document.$form.id.value = old_id;
          //document.$form.action = old_action;
          //document.$form.target = old_target;
      }
      function submitFormCGIResults(script, command, id) {
          //var old_command = document.$form.command.value;
          //var old_id = document.$form.command.id.value;
          //var old_action = document.$form.action;
          //var old_target = document.$form.target;
          document.$form.command.value = command;
          document.$form.id.value = id;
          document.$form.action = '$path' + script + '.pl';
          document.$form.target = 'cgiresults';
          document.$form.submit();
          //document.$form.command.value = old_command;
          //document.$form.id.value = old_id;
          //document.$form.action = old_action;
          //document.$form.target = old_target;
      }
      function submitReportPage() {
          document.$form.target = '_popup';
          document.$form.submit();
      }
      function enableSetBinStatusReportDates (status) {
          document.$form.binstatusbegindate_month.disabled = (status);
          document.$form.binstatusbegindate_day.disabled = (status);
          document.$form.binstatusbegindate_year.disabled = (status);
          document.$form.binstatusenddate_month.disabled = (status);
          document.$form.binstatusenddate_day.disabled = (status);
          document.$form.binstatusenddate_year.disabled = (status);
      }
      function setDocumentCommentCountByTypeDisabled(value) {
          $form.displayhearings.disabled = value;
      }
      function setBinStatisticsDisabled(value) {
          $form.bin1.disabled = value;
          $form.includeorgs.disabled = value;
      }
      function setBinStatusDisabled(value) {
          $form.bin.disabled = value;
          $form.user2.disabled = value;
          $form.displaycomments.disabled = value;
          $form.displayresponses.disabled = value;
          $form.displayduplicates.disabled = value;
          $form.displaytechreview.disabled = value;
          $form.binstatusselectdates.disabled = value;
          if (value) {
              enableSetBinStatusReportDates(value);
          } else {
              enableSetBinStatusReportDates(!(document.$form.binstatusselectdates.checked));
          }
      }
      function setBinWorkloadDisabled(value) {
          $form.bin2.disabled = value;
      }
      function setUserWorkloadDisabled(value) {
          $form.user.disabled = value;
      }
      function setEntryCountsDisabled(value) {
          //document.$form.entrycountsbegindate_month.disabled = (value);
          //document.$form.entrycountsbegindate_day.disabled = (value);
          //document.$form.entrycountsbegindate_year.disabled = (value);
          //document.$form.entrycountsenddate_month.disabled = (value);
          //document.$form.entrycountsenddate_day.disabled = (value);
          //document.$form.entrycountsenddate_year.disabled = (value);
          //document.$form.entrycountscounttype.disabled = (value);
      }
      function setStandardCommentDisabled(value) {
          //$form.commentreporttype.disabled = value;
      }
      function setSCRIDTypeDisabled(object) {
          if (object != 'all') {
              if ($form.scridtype[0].checked) {
                  $form.binforscrs.disabled = false;
                  $form.scrid.disabled = false;
                  $form.scridpastelist.disabled = true;
              } else {
                  $form.binforscrs.disabled = true;
                  $form.scrid.disabled = true;
                  $form.scridpastelist.disabled = false;
              }
          }
          //;
      }
      function setSummaryCommentReportDisabled(value) {
          $form.includescrcomments.disabled = value;
          $form.binforscrs.disabled = value;
          $form.scrusesubbins.disabled = value;
          $form.scruseremarks.disabled = value;
          $form.scrid.disabled = value;
          $form.scruseorganizations.disabled = value;
          $form.scrhaschangeimpact.disabled = value;
          $form.scrsortbyscr.disabled = value;
          $form.scridpastelist.disabled = value;
          $form.scridtype.disabled = value;
          $form.scridtype[0].disabled = value;
          $form.scridtype[1].disabled = value;
          
          //if (value == false) {
          //    setSCRIDTypeDisabled('one');
          //}
      }
      function setDuplicateCommentsReportDisabled(value) {
          $form.binfordups.disabled = value;
      }
      function setCommentSearchStringsDisabled(value) {
          $form.commentsearchstrings.disabled = value;
          $form.cwsbin.disabled = value;
          $form.cwscomments.disabled = value;
          $form.cwsresponses.disabled = value;
          $form.cwsscr.disabled = value;
          $form.cwscommentors.disabled = value;
      }
      function setIndividualConcurrenceReportDisabled(value) {
          var disabled = (value == true) ? true : ((value == 'all') ? false : eval(!document.$form.includeindividualcon.checked));
          $form.includefirstreviewcon.disabled = disabled;
          $form.includesecondreviewcon.disabled = disabled;
          $form.includeapprovedcon.disabled = disabled;
      }
      function setConcurrenceReportDisabled(value) {
          $form.concurbin.disabled = value;
          $form.includeindividualcon.disabled = value;
          $form.includescrcon.disabled = value;
          $form.includefirstreviewcon.disabled = value;
          $form.includesecondreviewcon.disabled = value;
          $form.includeapprovedcon.disabled = value;
          setIndividualConcurrenceReportDisabled(value);
          $form.includefirstnonecon.disabled = value;
          $form.includefirstpositivecon.disabled = value;
          $form.includefirstnegativecon.disabled = value;
          $form.includesecondnonecon.disabled = value;
          $form.includesecondpositivecon.disabled = value;
          $form.includesecondnegativecon.disabled = value;
      }
      function setResponseStatusDisabled(value) {
          $form.rsstartid.disabled = value;
          $form.rsendid.disabled = value;
      }
      function setEnabled(object) {
end
print <<end;
      }
      function setEnabledComments(object) {
end
print <<end;
      }
      function submitCommentReport() {
          var msg ='';
          setEnabledComments('all');
          if (document.$form.reportSelectComments[0].checked) {
              // Fully customizable comments report
              //submitFormNewWindow('$form', 'report', 'CustomizableCommentsReport');
              submitForm('ad_hoc_reports','adhocsetup','comment');
          } else if (document.$form.reportSelectComments[1].checked) {
              // Standard Comment report selection
              submitForm('$form', 'reportselect', 'StandardCommentReport');
          } else if (document.$form.reportSelectComments[2].checked) {
              // DOE commitments report
              submitFormCGIResults('$form', 'report', 'DOECommitmentsReportTest');
          } else if (document.$form.reportSelectComments[3].checked) {
              // CRD change report
              submitFormCGIResults('$form', 'report', 'CRDChangesReportTest');
          } else if (document.$form.reportSelectComments[4].checked) {
              // summary comment/response report
              if (document.$form.scridtype[1].checked) {
                  var s = document.$form.scridpastelist.value;
                  var hasnumb = false;
                  var valid = true;
                  if (s.length == 0) valid = false;
                  for(var i = 0; i < s.length; i++) {
                      var c = s.charAt(i);
                      if ((c >= '0') || (c <= '9')) hasnumb = true;
                      if (!(c == 's' || c == 'S' || c== 'c' || c == 'C' || c == 'r' || c == 'R' || (c >= '0' && c <= '9') || c==' ' || c=='\\n' || c=='\\r' || c==',')) valid = false;
                  }
                  
                  if (hasnumb == false || valid == false) {
                      msg = "SCR ID List must contain one or more items in the form of 'SCR0000'.";
                  }
              }
              if (msg != "") {
                  alert (msg);
              } else {
                  submitFormCGIResults('$form', 'report', 'SummaryCommentReportTest');
              }
          } else if (document.$form.reportSelectComments[5].checked) {
              // duplicate comment report
              submitFormCGIResults('$form', 'report', 'DuplicateCommentsReportTest');
          } else if (document.$form.reportSelectComments[6].checked) {
              // Search Strings Report
              if (isblank(document.$form.commentsearchstrings.value)) {
                  msg += "You must input one or more strings to search for\\n";
              }
              if (!document.$form.cwscomments.checked && !document.$form.cwsresponses.checked && !document.$form.cwsscr.checked) {
                  msg += "You must check at least one of the search options\\n";
              }
              if (msg != "") {
                  alert (msg);
              } else {
                  submitFormNewWindow('$form', 'report', 'CommentsWithStringsReport');
              }
          } else if (document.$form.reportSelectComments[7].checked) {
              // Concurrence Report
              if (!document.$form.includeindividualcon.checked && !document.$form.includescrcon.checked) {
                  msg += "You must check at least one of the include options\\n";
              }
              if (document.$form.includeindividualcon.checked && !document.$form.includeindividualcon.disabled && !document.$form.includefirstreviewcon.checked && !document.$form.includesecondreviewcon.checked && !document.$form.includeapprovedcon.checked) {
                  msg += "You must check at least one of the options for individual responses\\n";
              }
              //if (!document.$form.includeindividualcon.checked && !document.$form.includefirstreviewcon.checked && !document.$form.includesecondreviewcon.checked && !document.$form.includeapprovedcon.checked) {
              //    msg += "You must check at least one of the options for individual responses\\n";
              //}
              if (!document.$form.includefirstnonecon.checked && !document.$form.includefirstpositivecon.checked && !document.$form.includefirstnegativecon.checked && !document.$form.includesecondnonecon.checked && !document.$form.includesecondpositivecon.checked && !document.$form.includesecondnegativecon.checked) {
                  msg += "You must check at least one of the concurrence options\\n";
              }
              if (msg != "") {
                  alert (msg);
              } else {
                  submitFormCGIResults('$form', 'report', 'ConcurrenceReportTest');
              }
          }
          setEnabledComments($form.reportSelectComments);
      }
      function submitDocumentReport() {
          if (document.$form.reportSelectDocuments[0].checked) {
              // Fully customizable Documents report
              submitForm('ad_hoc_reports','adhocsetup','document');
          } else if (document.$form.reportSelectDocuments[1].checked) {
              // Standard Document report selection
              submitForm('$form', 'reportselect', 'StandardDocumentReport');
          } else if (document.$form.reportSelectDocuments[2].checked) {
              // postcard report
              submitDocumentPostcardReport();
          }
      }
      function submitCommentorReport() {
          if (document.$form.reportSelectCommentors[0].checked) {
              // Fully customizable Commentors report
              submitForm('ad_hoc_reports','adhocsetup','commentor');
          } else if (document.$form.reportSelectCommentors[1].checked) {
              // Standard Commentor report selection
              submitForm('$form', 'reportselect', 'StandardCommentorReport');
          } else if (document.$form.reportSelectCommentors[2].checked) {
              // mailing list report
              //submitDocumentCommentorMaillingListReport();
          }
      }
      function submitDocumentPostcardReport() {
          document.$form.reporttitle.value = "<b>$CRDType Comment/Response Database<br>Post Card Report</b><br>";
          document.$form.sortorder.value = 'doc_sort';
          document.$form.doc_selected.value = 'T';
          document.$form.use_all_docs.value = 'T';
          document.$form.addressee_selected.value = 'T';
          document.$form.comments_selected.value = 'T';
          document.$form.doc_remarks_selected.value = 'T';
          document.$form.com_remarks_selected.value = 'T';
          document.$form.doctype.value = '2';
          document.$form.extra_where_info.value = ' doc.dupsimstatus=1';
          submitFormCGIResults('ad_hoc_reports', 'adhoctest', 'adhoctest');
          
      }
      function checkResponseStatusReport() {
          var msg = '';
          // Response Status Report
          if (!isnumeric(document.$form.rsstartid.value)) {
              msg = "Starting Document ID must be a positive number\\n";
          }
          if (!isnumeric(document.$form.rsendid.value)) {
              msg = "Ending Document ID must be a positive number\\n";
          }
          if (Number(document.$form.rsendid.value) < Number(document.$form.rsstartid.value)) {
              msg = "Ending Document ID must not be less than Starting Document ID\\n";
          }
          if (msg != "") {
              alert (msg);
          } else {
             submitFormNewWindow('$form', 'report','ResponseStatusReport');
          }
      }
      
      function checkWeeklyStatusReport() {
          var msg = '';
          // Weekly Status Report
          if (msg != "") {
              alert (msg);
          } else {
             submitFormNewWindow('$form', 'report','WeeklyStatusReport');
          }
      }
      
      function checkEvaluationFactorReport() {
          var msg = '';
          // Evaluation Factor Report
          if (msg != "") {
              alert (msg);
          } else {
             submitFormNewWindow('$form', 'report','EvaluationFactorReport');
          }
      }
      
      function checkBinSectionMappingReport() {
          var msg = '';
          // Weekly Status Report
          if (msg != "") {
              alert (msg);
          } else {
             submitFormNewWindow('$form', 'report','BinMappingReport');
          }
      }
      
      function checkSCRReport() {
          var msg = '';
          // summary comment/response report
          if (document.$form.scridtype[1].checked) {
              var s = document.$form.scridpastelist.value;
              var hasnumb = false;
              var valid = true;
              if (s.length == 0) valid = false;
              for(var i = 0; i < s.length; i++) {
                  var c = s.charAt(i);
                  if ((c >= '0') || (c <= '9')) hasnumb = true;
                  if (!(c == 's' || c == 'S' || c== 'c' || c == 'C' || c == 'r' || c == 'R' || (c >= '0' && c <= '9') || c==' ' || c=='\\n' || c=='\\r' || c==',')) valid = false;
              }
              
              if (hasnumb == false || valid == false) {
                  msg = "SCR ID List must contain one or more items in the form of 'SCR0000'.";
              }
          }
          if (msg != "") {
              alert (msg);
          } else {
              submitFormCGIResults('$form', 'report', 'SummaryCommentReportTest');
          }
      }
      
      function checkSearchStringsReport() {
          var msg = '';
          // Search Strings Report
          if (isblank(document.$form.commentsearchstrings.value)) {
              msg += "You must input one or more strings to search for\\n";
          }
          if (!document.$form.cwscomments.checked && !document.$form.cwsresponses.checked && !document.$form.cwsscr.checked) {
              msg += "You must check at least one of the search options\\n";
          }
          if (msg != "") {
              alert (msg);
          } else {
              submitFormNewWindow('$form', 'report', 'CommentsWithStringsReport');
          }
      }
      
      function checkConcurrenceReport() {
          var msg = '';
          // Concurrence Report
          if (!document.$form.includeindividualcon.checked && !document.$form.includescrcon.checked) {
              msg += "You must check at least one of the include options\\n";
          }
          if (document.$form.includeindividualcon.checked && !document.$form.includeindividualcon.disabled && !document.$form.includefirstreviewcon.checked && !document.$form.includesecondreviewcon.checked && !document.$form.includeapprovedcon.checked) {
              msg += "You must check at least one of the options for individual responses\\n";
          }
          if (!document.$form.includefirstnonecon.checked && !document.$form.includefirstpositivecon.checked && !document.$form.includefirstnegativecon.checked && !document.$form.includesecondnonecon.checked && !document.$form.includesecondpositivecon.checked && !document.$form.includesecondnegativecon.checked) {
              msg += "You must check at least one of the concurrence options\\n";
          }
          if (msg != "") {
              alert (msg);
          } else {
              submitFormCGIResults('$form', 'report', 'ConcurrenceReportTest');
          }
      }
   //-->
   </script>
end
print "</head>\n\n";
print "<body background=$CRDImagePath/background.gif text=$CRDFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n";
print "<!-- command - $command -->\n";
print "<!-- id - $documentid -->\n";
print "<font face=$CRDFontFace color=$CRDFontColor>\n";
if ($command ne 'report') {
   print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Reports");
}
print "<form name=$form action=$ENV{SCRIPT_NAME} method=post>\n";
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=server value=$Server>\n";
print "<input type=hidden name=command value=$command>\n";
print "<input type=hidden name=id value=$documentid>\n";
print "<input type=hidden name=useFormValues value=1>\n";

#
if ($command ne 'report' && $command ne 'checkID' && !($command eq 'reportselect' && $documentid eq 'StandardCommentReport')) {
    print "<input type=hidden name='reporttitle' value=\"\">\n";
    print "<input type=hidden name='sortdirection' value='assending'>\n";
    print "<input type=hidden name='report_boolean' value='all'>\n";
    print "<input type=hidden name='text_limit' value='F'>\n";
                
    print "<input type=hidden name='sortorder' value=''>\n";

    print "<input type=hidden name='doc_selected' value='F'>\n";
    print "<input type=hidden name='documentid' value=''>\n";
    print "<input type=hidden name='commentnum' value=''>\n";
    print "<input type=hidden name='use_all_docs' value='T'>\n";
    
    print "<input type=hidden name='use_only_docs' value='F'>\n";

    print "<input type=hidden name='doctype_selected' value='F'>\n";
    print "<input type=hidden name='doctype' value='0'>\n";
                
    print "<input type=hidden name='bin_selected' value='F'>\n";
    print "<input type=hidden name='binid' value='0'>\n";
    print "<input type=hidden name='usesubbins' value='T'>\n";
    print "<input type=hidden name='nepareviewer' value='F'>\n";
                
    print "<input type=hidden name='bincoordinator_selected' value='F'>\n";
    print "<input type=hidden name='bincoordinator' value=''>\n";
    print "<input type=hidden name='bincoordinator_detail' value='F'>\n";
                
    print "<input type=hidden name='responsewriter_selected' value='F'>\n";
    print "<input type=hidden name='responsewriter' value=''>\n";
    print "<input type=hidden name='responsewriter_detail' value='F'>\n";
                
    print "<input type=hidden name='responsestatus_selected' value='F'>\n";
    print "<input type=hidden name='responsestatus' value=''>\n";
                
    print "<input type=hidden name='commentor_selected' value='F'>\n";
    print "<input type=hidden name='commentorid' value='0'>\n";
    print "<input type=hidden name='cityid' value='0'>\n";
    print "<input type=hidden name='stateid' value='0'>\n";
    print "<input type=hidden name='organization' value='0'>\n";
    print "<input type=hidden name='affiliationid' value='0'>\n";
    print "<input type=hidden name='commentordetail' value='0'>\n";
    print "<input type=hidden name='postalcode' value='0'>\n";
    print "<input type=hidden name='areacode' value='0'>\n";
                
    print "<input type=hidden name='date_received_selected' value='F'>\n";
    print "<input type=hidden name='date_received_start' value=''>\n";
    print "<input type=hidden name='date_received_end' value=''>\n";
                
    print "<input type=hidden name='date_assigned_selected' value='F'>\n";
    print "<input type=hidden name='date_assigned_start' value=''>\n";
    print "<input type=hidden name='date_assigned_end' value=''>\n";
                
    print "<input type=hidden name='date_approved_selected' value='F'>\n";
    print "<input type=hidden name='date_approved_start' value=''>\n";
    print "<input type=hidden name='date_approved_end' value=''>\n";
                
    print "<input type=hidden name='date_due_selected' value='F'>\n";
    print "<input type=hidden name='date_due_start' value=''>\n";
    print "<input type=hidden name='date_due_end' value=''>\n";
                
    print "<input type=hidden name='addressee_selected' value='F'>\n";
    print "<input type=hidden name='addressee' value='0'>\n";
                
    print "<input type=hidden name='hassrcomments_selected' value='F'>\n";
    print "<input type=hidden name='hassrcomments' value=''>\n";
                
    print "<input type=hidden name='haslacomments_selected' value='F'>\n";
    print "<input type=hidden name='haslacomments' value=''>\n";
                
    print "<input type=hidden name='has960comments_selected' value='F'>\n";
    print "<input type=hidden name='has960comments' value=''>\n";
                
    print "<input type=hidden name='wasrescanned_selected' value='F'>\n";
    print "<input type=hidden name='wasrescanned' value=''>\n";
                
    print "<input type=hidden name='changeimpact_selected' value='F'>\n";
    print "<input type=hidden name='changeimpact' value=''>\n";
                
    print "<input type=hidden name='commitments_selected' value='F'>\n";
    print "<input type=hidden name='commitments' value=''>\n";
                
    print "<input type=hidden name='comments_selected' value='F'>\n";
                
    print "<input type=hidden name='response_selected' value='F'>\n";
                
    print "<input type=hidden name='doc_remarks_selected' value='F'>\n";
                
    print "<input type=hidden name='com_remarks_selected' value='F'>\n";
                
    print "<input type=hidden name='start_page_selected' value='F'>\n";
                
    print "<input type=hidden name='scr_indicator_selected' value='F'>\n";
                
    print "<input type=hidden name='dup_comment_selected' value='F'>\n";
                
    print "<input type=hidden name='extra_where_info' value=''>\n";
                
    print "<input type=hidden name='excludetable' value=''>\n";
}


if ($command eq 'report') {
   print "<table border=0 width=670 align=center><tr><td>\n";

# summary reports
   if ($documentid eq 'SummaryStatusReport') {
      print doSummaryStatusReport(dbh => $dbh, schema => $schema, userId => $userid);
   } elsif ($documentid eq 'DocumentCommentCountByType') {
      print doDocumentCommentCountByTypeReport(dbh => $dbh, schema => $schema, userId => $userid, 
      combineHearings => ((defined($crdcgi->param('displayhearings'))) ? (($crdcgi->param('displayhearings') eq 'T') ? 'F' : 'T') : 'T'));
   } elsif ($documentid eq 'BinStatusReport') {
      my $displaycomments = ((defined($crdcgi->param('displaycomments'))) ? $crdcgi->param('displaycomments') : 'F');
      my $displayresponses = ((defined($crdcgi->param('displayresponses'))) ? $crdcgi->param('displayresponses') : 'F');
      my $displayduplicates = ((defined($crdcgi->param('displayduplicates'))) ? $crdcgi->param('displayduplicates') : 'F');
      my $displaytechreview = ((defined($crdcgi->param('displaytechreview'))) ? $crdcgi->param('displaytechreview') : 'F');
      my $selectdates = ((defined($crdcgi->param('binstatusselectdates'))) ? $crdcgi->param('binstatusselectdates') : 'F');
      my $begindate = $crdcgi->param('binstatusbegindate');
      my $enddate = $crdcgi->param('binstatusenddate');
      my $commentswithresponses = ((defined($crdcgi->param('commentswithresponses'))) ? $crdcgi->param('commentswithresponses') : 'F');
      print doBinStatusReport(dbh => $dbh, schema => $schema, userId => $userid, root_bin => $crdcgi->param('bin'),
        displayComments => $displaycomments, displayResponses => $displayresponses, displayDuplicates => $displayduplicates,
        displayUser => $crdcgi->param('user2'), displayTechReview => $displaytechreview, selectDates => $selectdates, 
        beginDate => $begindate, endDate => $enddate, displayEmptyBins => 'T', commentsWithResponses => $commentswithresponses);
   } elsif ($documentid eq 'BinStatusReportTest') {
      my $displaycomments = ((defined($crdcgi->param('displaycomments'))) ? $crdcgi->param('displaycomments') : 'F');
      my $displayresponses = ((defined($crdcgi->param('displayresponses'))) ? $crdcgi->param('displayresponses') : 'F');
      my $displayduplicates = ((defined($crdcgi->param('displayduplicates'))) ? $crdcgi->param('displayduplicates') : 'F');
      my $displaytechreview = ((defined($crdcgi->param('displaytechreview'))) ? $crdcgi->param('displaytechreview') : 'F');
      my $selectdates = ((defined($crdcgi->param('binstatusselectdates'))) ? $crdcgi->param('binstatusselectdates') : 'F');
      my $begindate = $crdcgi->param('binstatusbegindate_year') . lpadzero($crdcgi->param('binstatusbegindate_month'),2) . lpadzero($crdcgi->param('binstatusbegindate_day'),2);
      my $enddate = $crdcgi->param('binstatusenddate_year') . lpadzero($crdcgi->param('binstatusenddate_month'),2) . lpadzero($crdcgi->param('binstatusenddate_day'),2);
      my $commentswithresponses = ((defined($crdcgi->param('commentswithresponses'))) ? $crdcgi->param('commentswithresponses') : 'F');
      print doBinStatusReportTest(dbh => $dbh, schema => $schema, userId => $userid, root_bin => $crdcgi->param('bin'), displayUser => $crdcgi->param('user2'),
        displayComments => $displaycomments, displayResponses => $displayresponses, displayDuplicates => $displayduplicates,
        displayTechReview => $displaytechreview, selectDates => $selectdates, beginDate => $begindate, endDate => $enddate,
        displayEmptyBins => 'T', commentsWithResponses => $commentswithresponses);
   } elsif ($documentid eq 'ResponseReport') {
      my $displaycomments = 'T';
      my $displayresponses = 'T';
      my $displaytechreview = 'F';
      my $selectdates = 'F';
      my $begindate = '19980101';
      my $enddate = '29991231';
      print doBinStatusReport(dbh => $dbh, schema => $schema, userId => $userid, root_bin => $crdcgi->param('bin'),
        displayComments => $displaycomments, displayResponses => $displayresponses, displayUser => $crdcgi->param('user2'), 
        displayTechReview => $displaytechreview, selectDates => $selectdates, beginDate => $begindate, endDate => $enddate,
        displayEmptyBins => 'F', commentsWithResponses => 'T');
   } elsif ($documentid eq 'BinStatisticsReport') {
      print doBinStatisticsReport(dbh => $dbh, schema => $schema, userId => $userid, root_bin => $crdcgi->param('bin1'),
          includeOrgs => ((defined($crdcgi->param('includeorgs'))) ? $crdcgi->param('includeorgs') : "F"));
   } elsif ($documentid eq 'BinWorkLoadReport') {
      if ($crdcgi->param('bin2') eq '0') {
          print doWorkLoadReportAllBins(dbh => $dbh, schema => $schema, userId => $userid, root_bin => $crdcgi->param('bin2'), type => "Bin");
      } else {
          print doWorkLoadReport(dbh => $dbh, schema => $schema, userId => $userid, root_bin => $crdcgi->param('bin2'), type => "Bin");
      }
   } elsif ($documentid eq 'SystemWorkLoadReport') {
      print doWorkLoadReport(dbh => $dbh, schema => $schema, userId => $userid, root_bin => $crdcgi->param('bin2'), type => "System");
   } elsif ($documentid eq 'UserWorkLoadReport') {
      print doWorkLoadReport(dbh => $dbh, schema => $schema, userId => $userid, root_bin => $crdcgi->param('bin2'), type => "User", displayUser => $crdcgi->param('user'));
   } elsif ($documentid eq 'CommentorReport') {
      print doCommentorReport(dbh => $dbh, schema => $schema, userId => $userid, orderBy => "lastname,firstname, state,city");
   } elsif ($documentid eq 'UsersReport') {
      print doUsersReport(dbh => $dbh, schema => $schema, userId => $userid);
   } elsif ($documentid eq 'ResponseStatusReport') {
      print doResponseStatusReport(dbh => $dbh, schema => $schema, userId => $userid, startID => $crdcgi->param('rsstartid'), endID => $crdcgi->param('rsendid'));
   } elsif ($documentid eq 'BinCountsReport') {
      print doBinCountsReport(dbh => $dbh, schema => $schema, userId => $userid);
   } elsif ($documentid eq 'OrgCountsReport') {
      print doOrgCountsReport(dbh => $dbh, schema => $schema, userId => $userid);
   } elsif ($documentid eq 'ConcurrenceSummaryReport') {
      print doConcurrenceSummaryReport(dbh => $dbh, schema => $schema, userId => $userid);
   } elsif ($documentid eq 'FinalCRDIndex4Report') {
      print doFinalCRDIndex4Report(dbh => $dbh, schema => $schema, userId => $userid);
   } elsif ($documentid eq 'BinMappingReport') {
      print doBinMappingReport(dbh => $dbh, schema => $schema, userId => $userid, type => $crdcgi->param('binsectionmaptype'));
   } elsif ($documentid eq 'EvaluationFactorReport') {
      my $begindate = $crdcgi->param('evaluationFactorbegindate_year') . lpadzero($crdcgi->param('evaluationFactorbegindate_month'),2) . lpadzero($crdcgi->param('evaluationFactorbegindate_day'),2);
      my $enddate = $crdcgi->param('evaluationFactorenddate_year') . lpadzero($crdcgi->param('evaluationFactorenddate_month'),2) . lpadzero($crdcgi->param('evaluationFactorenddate_day'),2);
      print doEvaluationFactorReport(dbh => $dbh, schema => $schema, userId => $userid, beginDate => $begindate, endDate => $enddate);
   } elsif ($documentid eq 'EntryCountsReportTest') {
      my $begindate = $crdcgi->param('entrycountsbegindate_year') . lpadzero($crdcgi->param('entrycountsbegindate_month'),2) . lpadzero($crdcgi->param('entrycountsbegindate_day'),2);
      my $enddate = $crdcgi->param('entrycountsenddate_year') . lpadzero($crdcgi->param('entrycountsenddate_month'),2) . lpadzero($crdcgi->param('entrycountsenddate_day'),2);
      print doEntryCountsReport(dbh => $dbh, schema => $schema, userId => $userid, type => 'test', beginDate => $begindate, endDate => $enddate, countBy =>$crdcgi->param('entrycountscounttype'));
   } elsif ($documentid eq 'EntryCountsReport') {
      my $begindate = $crdcgi->param('entrycountsbegindate');
      my $enddate = $crdcgi->param('entrycountsenddate');
      print doEntryCountsReport(dbh => $dbh, schema => $schema, userId => $userid, type => 'main', beginDate => $begindate, endDate => $enddate, countBy =>$crdcgi->param('entrycountscounttype'));
   } elsif ($documentid eq 'WeeklyStatusReport') {
      my $begindate = $crdcgi->param('weeklystatusbegindate_year') . lpadzero($crdcgi->param('weeklystatusbegindate_month'),2) . lpadzero($crdcgi->param('weeklystatusbegindate_day'),2);
      my $enddate = $crdcgi->param('weeklystatusenddate_year') . lpadzero($crdcgi->param('weeklystatusenddate_month'),2) . lpadzero($crdcgi->param('weeklystatusenddate_day'),2);
      print doWeeklyStatusReport(dbh => $dbh, schema => $schema, userId => $userid, beginDate => $begindate, endDate => $enddate);
#      
#  Comment reports
   } elsif ($documentid eq 'SummaryCommentReportTest') {
      print doSummaryCommentReportTest(dbh => $dbh, schema => $schema, userId => $userid, SCR => $crdcgi->param('scrid'),
        bin => $crdcgi->param('binforscrs'), 
        includeComments => ((defined($crdcgi->param('includescrcomments'))) ? $crdcgi->param('includescrcomments') : "F"),
        useSubBins => ((defined($crdcgi->param('scrusesubbins'))) ? $crdcgi->param('scrusesubbins') : "F"),
        useRemarks => ((defined($crdcgi->param('scruseremarks'))) ? $crdcgi->param('scruseremarks') : "F"),
        useOrganizations => ((defined($crdcgi->param('scruseorganizations'))) ? $crdcgi->param('scruseorganizations') : "F"),
        changeImpact => ((defined($crdcgi->param('scrhaschangeimpact'))) ? $crdcgi->param('scrhaschangeimpact') : "F"),
        sortBySCR => ((defined($crdcgi->param('scrsortbyscr'))) ? $crdcgi->param('scrsortbyscr') : "F"),
        scrIDType => ((defined($crdcgi->param('scridtype'))) ? $crdcgi->param('scridtype') : "select"),
        pasteList => ((defined($crdcgi->param('scridpastelist'))) ? $crdcgi->param('scridpastelist') : ""));
   } elsif ($documentid eq 'SummaryCommentReport') {
      print doSummaryCommentReport(dbh => $dbh, schema => $schema, userId => $userid, SCR => $crdcgi->param('scrid'),
        bin => $crdcgi->param('binforscrs'), 
        includeComments => ((defined($crdcgi->param('includescrcomments'))) ? $crdcgi->param('includescrcomments') : "F"),
        useSubBins => ((defined($crdcgi->param('scrusesubbins'))) ? $crdcgi->param('scrusesubbins') : "F"),
        useRemarks => ((defined($crdcgi->param('scruseremarks'))) ? $crdcgi->param('scruseremarks') : "F"),
        useOrganizations => ((defined($crdcgi->param('scruseorganizations'))) ? $crdcgi->param('scruseorganizations') : "F"),
        changeImpact => ((defined($crdcgi->param('scrhaschangeimpact'))) ? $crdcgi->param('scrhaschangeimpact') : "F"),
        sortBySCR => ((defined($crdcgi->param('scrsortbyscr'))) ? $crdcgi->param('scrsortbyscr') : "F"),
        scrIDType => ((defined($crdcgi->param('scridtype'))) ? $crdcgi->param('scridtype') : "select",
        pasteList => ((defined($crdcgi->param('scridpastelist'))) ? $crdcgi->param('scridpastelist') : "")));
   } elsif ($documentid eq 'ConcurrenceReportTest') {
      print doConcurrenceReport(dbh => $dbh, schema => $schema, userId => $userid,
        showSCR => ((defined($crdcgi->param('includescrcon'))) ? $crdcgi->param('includescrcon') : "F"), 
        showIndividual => ((defined($crdcgi->param('includeindividualcon'))) ? $crdcgi->param('includeindividualcon') : "F"), 
        firstReview => ((defined($crdcgi->param('includefirstreviewcon'))) ? $crdcgi->param('includefirstreviewcon') : "F"),
        secondReview => ((defined($crdcgi->param('includesecondreviewcon'))) ? $crdcgi->param('includesecondreviewcon') : "F"),
        approved => ((defined($crdcgi->param('includeapprovedcon'))) ? $crdcgi->param('includeapprovedcon') : "F"),
        firstNone => ((defined($crdcgi->param('includefirstnonecon'))) ? $crdcgi->param('includefirstnonecon') : "F"),
        firstPositive => ((defined($crdcgi->param('includefirstpositivecon'))) ? $crdcgi->param('includefirstpositivecon') : "F"),
        firstNegative => ((defined($crdcgi->param('includefirstnegativecon'))) ? $crdcgi->param('includefirstnegativecon') : "F"),
        secondNone => ((defined($crdcgi->param('includesecondnonecon'))) ? $crdcgi->param('includesecondnonecon') : "F"),
        secondPositive => ((defined($crdcgi->param('includesecondpositivecon'))) ? $crdcgi->param('includesecondpositivecon') : "F"),
        secondNegative => ((defined($crdcgi->param('includesecondnegativecon'))) ? $crdcgi->param('includesecondnegativecon') : "F"),
        root_bin => ((defined($crdcgi->param('concurbin'))) ? $crdcgi->param('concurbin') : 0),
        test => 'T');
   } elsif ($documentid eq 'ConcurrenceReport') {
      print doConcurrenceReport(dbh => $dbh, schema => $schema, userId => $userid,
        showSCR => ((defined($crdcgi->param('includescrcon'))) ? $crdcgi->param('includescrcon') : "F"), 
        showIndividual => ((defined($crdcgi->param('includeindividualcon'))) ? $crdcgi->param('includeindividualcon') : "F"), 
        firstReview => ((defined($crdcgi->param('includefirstreviewcon'))) ? $crdcgi->param('includefirstreviewcon') : "F"),
        secondReview => ((defined($crdcgi->param('includesecondreviewcon'))) ? $crdcgi->param('includesecondreviewcon') : "F"),
        approved => ((defined($crdcgi->param('includeapprovedcon'))) ? $crdcgi->param('includeapprovedcon') : "F"),
        firstNone => ((defined($crdcgi->param('includefirstnonecon'))) ? $crdcgi->param('includefirstnonecon') : "F"),
        firstPositive => ((defined($crdcgi->param('includefirstpositivecon'))) ? $crdcgi->param('includefirstpositivecon') : "F"),
        firstNegative => ((defined($crdcgi->param('includefirstnegativecon'))) ? $crdcgi->param('includefirstnegativecon') : "F"),
        secondNone => ((defined($crdcgi->param('includesecondnonecon'))) ? $crdcgi->param('includesecondnonecon') : "F"),
        secondPositive => ((defined($crdcgi->param('includesecondpositivecon'))) ? $crdcgi->param('includesecondpositivecon') : "F"),
        secondNegative => ((defined($crdcgi->param('includesecondnegativecon'))) ? $crdcgi->param('includesecondnegativecon') : "F"),
        root_bin => ((defined($crdcgi->param('concurbin'))) ? $crdcgi->param('concurbin') : 0),
        test => 'F');
   } elsif ($documentid eq 'DOECommitmentsReportTest') {
      print doCommentsReportTest(dbh => $dbh, schema => $schema, userId => $userid, type => 'commitments', 
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'DOECommitmentsReport') {
      print doCommentsReport(dbh => $dbh, schema => $schema, userId => $userid, type => 'commitments', 
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CRDChangesReportTest') {
      print doCommentsReportTest(dbh => $dbh, schema => $schema, userId => $userid, type => 'change impact', 
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CRDChangesReport') {
      print doCommentsReport(dbh => $dbh, schema => $schema, userId => $userid, type => 'change impact', 
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CommentsByDocIdReportTest') {
      print doCommentsReportTest(dbh => $dbh, schema => $schema, userId => $userid, type => 'byDocId', docIdType => $crdcgi->param('docidtype'),
        startingDocId => ((defined($crdcgi->param('startingdocid'))) ? $crdcgi->param('startingdocid') : 0),
        endingDocId => ((defined($crdcgi->param('endingdocid'))) ? $crdcgi->param('endingdocid') : 0),
        docIdList => [ $crdcgi->param('docidlist') ], 
        displayCommentor => ((defined($crdcgi->param('displaycommentor'))) ? $crdcgi->param('displaycommentor') : "F"),
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CommentsByDocIdReport') {
      print doCommentsReport(dbh => $dbh, schema => $schema, userId => $userid, type => 'byDocId', docIdType => $crdcgi->param('docidtype'),
        startingDocId => ((defined($crdcgi->param('startingdocid'))) ? $crdcgi->param('startingdocid') : 0),
        endingDocId => ((defined($crdcgi->param('endingdocid'))) ? $crdcgi->param('endingdocid') : 0),
        docIdList => [ $crdcgi->param('docidlist') ], 
        displayCommentor => ((defined($crdcgi->param('displaycommentor'))) ? $crdcgi->param('displaycommentor') : "F"),
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CommentsByDocTypeReportTest') {
      print doCommentsReportTest(dbh => $dbh, schema => $schema, userId => $userid, type => 'byDocType',
        docType => $crdcgi->param('doctype'), 
        displayCommentor => ((defined($crdcgi->param('displaycommentor'))) ? $crdcgi->param('displaycommentor') : "F"),
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CommentsByDocTypeReport') {
      print doCommentsReport(dbh => $dbh, schema => $schema, userId => $userid, type => 'byDocType',
        docType => $crdcgi->param('doctype'), 
        displayCommentor => ((defined($crdcgi->param('displaycommentor'))) ? $crdcgi->param('displaycommentor') : "F"),
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CommentsByCommentIdReportTest') {
      print doCommentsReportTest(dbh => $dbh, schema => $schema, userId => $userid, type => 'byCommentId',
        startingDocId => ((defined($crdcgi->param('startdocid'))) ? $crdcgi->param('startdocid') : 0),
        startingCommentId => ((defined($crdcgi->param('startingcommentid'))) ? $crdcgi->param('startingcommentid') : 0),
        endingDocId => ((defined($crdcgi->param('enddocid'))) ? $crdcgi->param('enddocid') : 0),
        endingCommentId => ((defined($crdcgi->param('endingcommentid'))) ? $crdcgi->param('endingcommentid') : 0),
        comIdType => $crdcgi->param('comidtype'), comIdList => [ $crdcgi->param('comidlist') ], 
        comIdPasteList => ((defined($crdcgi->param('comidpastelist'))) ? $crdcgi->param('comidpastelist') : ''),
        displayCommentor => ((defined($crdcgi->param('displaycommentor'))) ? $crdcgi->param('displaycommentor') : "F"),
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CommentsByCommentIdReport') {
      print doCommentsReport(dbh => $dbh, schema => $schema, userId => $userid, type => 'byCommentId',
        startingDocId => ((defined($crdcgi->param('startingdocid'))) ? $crdcgi->param('startingdocid') : 0),
        startingCommentId => ((defined($crdcgi->param('startingcommentid'))) ? $crdcgi->param('startingcommentid') : 0),
        endingDocId => ((defined($crdcgi->param('endingdocid'))) ? $crdcgi->param('endingdocid') : 0),
        endingCommentId => ((defined($crdcgi->param('endingcommentid'))) ? $crdcgi->param('endingcommentid') : 0),
        comIdType => $crdcgi->param('comidtype'), comIdList => [ $crdcgi->param('comidlist') ], 
        comIdPasteList => ((defined($crdcgi->param('comidpastelist'))) ? $crdcgi->param('comidpastelist') : ''),
        displayCommentor => ((defined($crdcgi->param('displaycommentor'))) ? $crdcgi->param('displaycommentor') : "F"),
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CommentsByBinReportTest') {
      print doCommentsReportTest(dbh => $dbh, schema => $schema, userId => $userid, type => 'byBinId',
        binId => ((defined($crdcgi->param('binid'))) ? $crdcgi->param('binid') : 0), 
        displayCommentor => ((defined($crdcgi->param('displaycommentor'))) ? $crdcgi->param('displaycommentor') : "F"),
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CommentsByBinReport') {
      print doCommentsReport(dbh => $dbh, schema => $schema, userId => $userid, type => 'byBinId',
        binId => ((defined($crdcgi->param('binid'))) ? $crdcgi->param('binid') : 0), 
        displayCommentor => ((defined($crdcgi->param('displaycommentor'))) ? $crdcgi->param('displaycommentor') : "F"),
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CommentsByDateReportTest') {
      print doCommentsReportTest(dbh => $dbh, schema => $schema, userId => $userid, type => 'byDate',
        beginDate => get_date(lpadzero($crdcgi->param('begindate_month'),2) . '/' . lpadzero($crdcgi->param('begindate_day'),2) . '/' . $crdcgi->param('begindate_year')),
        endDate => get_date(lpadzero($crdcgi->param('enddate_month'),2) . '/' . lpadzero($crdcgi->param('enddate_day'),2) . '/' . $crdcgi->param('enddate_year')), 
        displayCommentor => ((defined($crdcgi->param('displaycommentor'))) ? $crdcgi->param('displaycommentor') : "F"),
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CommentsByDateReport') {
      print doCommentsReport(dbh => $dbh, schema => $schema, userId => $userid, type => 'byDate',
        beginDate => $crdcgi->param('begindate'),
        endDate => $crdcgi->param('enddate'), 
        displayCommentor => ((defined($crdcgi->param('displaycommentor'))) ? $crdcgi->param('displaycommentor') : "F"),
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CommentsByAffiliationReportTest') {
      print doCommentsReportTest(dbh => $dbh, schema => $schema, userId => $userid, type => 'byAffiliation',
        affiliation => $crdcgi->param('affiliation'), 
        displayCommentor => ((defined($crdcgi->param('displaycommentor'))) ? $crdcgi->param('displaycommentor') : "F"),
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CommentsByAffiliationReport') {
      print doCommentsReport(dbh => $dbh, schema => $schema, userId => $userid, type => 'byAffiliation',
        affiliation => $crdcgi->param('affiliation'), 
        displayCommentor => ((defined($crdcgi->param('displaycommentor'))) ? $crdcgi->param('displaycommentor') : "F"),
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CommentsByStateReportTest') {
      print doCommentsReportTest(dbh => $dbh, schema => $schema, userId => $userid, type => 'byState',
        state => $crdcgi->param('state'), 
        displayCommentor => ((defined($crdcgi->param('displaycommentor'))) ? $crdcgi->param('displaycommentor') : "F"),
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CommentsByStateReport') {
      print doCommentsReport(dbh => $dbh, schema => $schema, userId => $userid, type => 'byState',
        state => $crdcgi->param('state'), 
        displayCommentor => ((defined($crdcgi->param('displaycommentor'))) ? $crdcgi->param('displaycommentor') : "F"),
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CommentsByCityReportTest') {
      print doCommentsReportTest(dbh => $dbh, schema => $schema, userId => $userid, type => 'byCity',
        city => $crdcgi->param('city'), 
        displayCommentor => ((defined($crdcgi->param('displaycommentor'))) ? $crdcgi->param('displaycommentor') : "F"),
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CommentsByCityReport') {
      print doCommentsReport(dbh => $dbh, schema => $schema, userId => $userid, type => 'byCity',
        city => $crdcgi->param('city'), 
        displayCommentor => ((defined($crdcgi->param('displaycommentor'))) ? $crdcgi->param('displaycommentor') : "F"),
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CommentsByOrganizationReportTest') {
      print doCommentsReportTest(dbh => $dbh, schema => $schema, userId => $userid, type => 'byOrganization',
        organization => $crdcgi->param('organization'), 
        displayCommentor => ((defined($crdcgi->param('displaycommentor'))) ? $crdcgi->param('displaycommentor') : "F"),
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CommentsByOrganizationReport') {
      print doCommentsReport(dbh => $dbh, schema => $schema, userId => $userid, type => 'byOrganization',
        organization => $crdcgi->param('organization'), 
        displayCommentor => ((defined($crdcgi->param('displaycommentor'))) ? $crdcgi->param('displaycommentor') : "F"),
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CommentsByPostalCodeReportTest') {
      print doCommentsReportTest(dbh => $dbh, schema => $schema, userId => $userid, type => 'byPostalCode',
        startPostalCode => ((defined($crdcgi->param('startpostalcode'))) ? $crdcgi->param('startpostalcode') : 0),
        endPostalCode => ((defined($crdcgi->param('endpostalcode'))) ? $crdcgi->param('endpostalcode') : 0), 
        displayCommentor => ((defined($crdcgi->param('displaycommentor'))) ? $crdcgi->param('displaycommentor') : "F"),
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CommentsByPostalCodeReport') {
      print doCommentsReport(dbh => $dbh, schema => $schema, userId => $userid, type => 'byPostalCode',
        startPostalCode => ((defined($crdcgi->param('startpostalcode'))) ? $crdcgi->param('startpostalcode') : 0),
        endPostalCode => ((defined($crdcgi->param('endpostalcode'))) ? $crdcgi->param('endpostalcode') : 0), 
        displayCommentor => ((defined($crdcgi->param('displaycommentor'))) ? $crdcgi->param('displaycommentor') : "F"),
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CommentsByNameReportTest') {
      print doCommentsReportTest(dbh => $dbh, schema => $schema, userId => $userid, type => 'byName',
        beginName => ((defined($crdcgi->param('beginname'))) ? $crdcgi->param('beginname') : 0),
        endName => ((defined($crdcgi->param('endname'))) ? $crdcgi->param('endname') : 0), 
        displayCommentor => ((defined($crdcgi->param('displaycommentor'))) ? $crdcgi->param('displaycommentor') : "F"),
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'CommentsByNameReport') {
      print doCommentsReport(dbh => $dbh, schema => $schema, userId => $userid, type => 'byName',
        beginName => ((defined($crdcgi->param('beginname'))) ? $crdcgi->param('beginname') : 0),
        endName => ((defined($crdcgi->param('endname'))) ? $crdcgi->param('endname') : 0), 
        displayCommentor => ((defined($crdcgi->param('displaycommentor'))) ? $crdcgi->param('displaycommentor') : "F"),
        sortByBin => ((defined($crdcgi->param('sortbybin'))) ? $crdcgi->param('sortbybin') : "F"));
   } elsif ($documentid eq 'DuplicateCommentsReportTest') {
      print doDuplicateCommentsReport(dbh => $dbh, schema => $schema, userId => $userid, type => 'test',
        bin => $crdcgi->param('binfordups'));
   } elsif ($documentid eq 'DuplicateCommentsReport') {
      print doDuplicateCommentsReport(dbh => $dbh, schema => $schema, userId => $userid, type => 'report',
        bin => $crdcgi->param('binfordups'));
   } elsif ($documentid eq 'CommentsWithStringsReport') {
      print doSearchStringsReport(dbh => $dbh, schema => $schema, userId => $userid, sortBy => 'id',
        comments => ((defined($crdcgi->param('cwscomments'))) ? $crdcgi->param('cwscomments') : "F"),
        responses => ((defined($crdcgi->param('cwsresponses'))) ? $crdcgi->param('cwsresponses') : "F"),
        scrs => ((defined($crdcgi->param('cwsscr'))) ? $crdcgi->param('cwsscr') : "F"),
        byCommentor => ((defined($crdcgi->param('cwscommentors'))) ? $crdcgi->param('cwscommentors') : "F"),
        bin => $crdcgi->param('cwsbin'), strings => $crdcgi->param('commentsearchstrings'));
   } elsif ($documentid eq 'PrintCommentResponse') {
      print doPrintCommentResponse(dbh => $dbh, schema => $schema, userId => $userid, 
        documentID => ((defined($crdcgi->param('documentid'))) ? $crdcgi->param('documentid') : "0"), 
        commentID => ((defined($crdcgi->param('commentid'))) ? $crdcgi->param('commentid') : "0"),
        version => ((defined($crdcgi->param('version'))) ? $crdcgi->param('version') : "0"));
   } elsif ($documentid eq 'PrintSummaryCommentResponse') {
      print doPrintSummaryCommentResponse(dbh => $dbh, schema => $schema, userId => $userid, 
        scrID => ((defined($crdcgi->param('scrid'))) ? $crdcgi->param('scrid') : "0"));
   }
   print "</td></tr>\n";
} elsif ($command eq 'reportselect') {
    print "<br><table border=0 width=750>\n";
    if ($documentid eq 'StandardCommentReport') {
        print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Standard Comment Report");
        print CommentSelectionPage(dbh => $dbh, schema => $schema, userId => $userid, 
          type => ((defined($crdcgi->param('commentreporttype'))) ? $crdcgi->param('commentreporttype') : ""));
    } elsif ($documentid eq 'StandardDocumentReport') {
        print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Standard Document Report");
        print DocumentSelectionPage(dbh => $dbh, schema => $schema, userId => $userid);
    } elsif ($documentid eq 'StandardCommentorReport') {
        print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Standard Commentor Report");
        print CommentorSelectionPage(dbh => $dbh, schema => $schema, userId => $userid);
    }
    print "</table>\n";
} elsif ($command eq 'checkID') {
    print &CheckID(dbh => $dbh, schema => $schema, userId => $userid,
        documentID => ((defined($crdcgi->param('checkdocumentid'))) ? $crdcgi->param('checkdocumentid') : ""),
        commentID => ((defined($crdcgi->param('checkcommentid'))) ? $crdcgi->param('checkcommentid') : ""),
        javaScript=> ((defined($crdcgi->param('checkjavascript'))) ? $crdcgi->param('checkjavascript') : ""));
} else {
    print "<br>";
    print "<table border=0 width=750 cellpadding=0 cellspacing=0><tr><td align=center>\n";
    print "<table border=0 width=750><tr><td align=center>\n";
    
    print &doMainMenu;
    
    if ($CRDProductionStatus == 0) {
        #print "<a href=\"javascript:submitForm('final_crd','menu',0);\">Test Final $CRDType Report Page</a><br>\n";
        
        #print "<input type=hidden name=docid value=0>\n<input type=hidden name=commid value=0>\n";
        #print "<a href=\"javascript:submitPrintCommentResponse(200,1);\">Print a report for EIS000200 / 0001</a>\n";
        #print "<a href=\"javascript:submitPrintSummaryCommentResponse(1);\">Print a report for SCR0001</a>\n";
    }
    
    print "</td></tr>\n";
    print "<tr><td><br>\n$printHeaderHelp<br>\n</td></tr>\n";
    print "</td></tr></table>\n";
}
print "</table></form>\n";
#print &BuildPrintCommentResponse($username,$userid,$schema,$path);
#print &BuildPrintSummaryCommentResponse($username,$userid,$schema,$path);
print "</font>\n</center>\n";
print "<script language=javascript>\n<!--\nvar mytext ='$errorstr';\nalert(unescape(mytext));\n//-->\n</script>\n" if ($errorstr);
print "</body>\n</html>\n";
&db_disconnect($dbh);
exit();

#----------------------------------------------------------------------------------------------------------------------------------------------
# Object definitions 
#
package Report_Forms; {

my $warn = $^W;
$^W = 0;
my %objHash = {
        'label' => '',
        'contents' => ''
    };
$^W = $warn;

sub label {
    my $self = shift;
    if (@_) {
        return $self->{label} = shift;
    } else {
        return $self->{label};
    }
}

sub contents {
    my $self = shift;
    if (@_) {
        return $self->{contents} = shift;
    } else {
        return $self->{contents};
    }
}

sub new {
    my $self = {};
    $self = { %objHash };
    bless $self;
    return $self;
}

}
