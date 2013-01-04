#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/qa/perl/RCS/help.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2004/03/10 21:51:43 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: help.pl,v $
# Revision 1.1  2004/03/10 21:51:43  starkeyj
# Initial revision
#
#

use NQS_Header qw(:Constants);
use CGI qw(param);
use strict;
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;


my $NQScgi = new CGI;
my $outstring = "";
$outstring .= $NQScgi->header('text/html');
$outstring .= <<END_OF_LINE;
  <html>
  <head>
  <b>Audit and Surveillance Schedule Management System - <i>Help!</i></b>
  </head>
  <body background=/nqs/images/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
  <form name=help method=post>
  <p>The Audit and Surveillance Schedule Management System provides a means to enter and display the scheduled audits and
  surveillances for OCRWM, OQA, BSC and EM/RW.  The system provides the capability to run reports,
  to search for records containing specific text values, and to browse through a set of records based
  on selected criteria.</p>
  <p><a href=#Home>Home</a>&nbsp;&nbsp;&nbsp;<a href=#Browse>Browse</a>&nbsp;&nbsp;&nbsp;
  <a href=#Search>Search</a>&nbsp;&nbsp;&nbsp;<a href=#Reports>Reports</a></p>
  <p><a name=Home><b>Home</b></a></p>
  <p><u>Audit Schedules</u><br>A summary of all internal and/or external audits scheduled for a fiscal year
  is displayed by selecting the fiscal year from the select box provided and clicking on the button 
  labelled '<i>Go</i>.'</p>
  <p>To limit the audit summary to a specific type of audit, such as BSC audits only, 
  select the type of audit desired from the drop down list provided.  Keep in mind that some types of audits were
  not performed in all fiscal years and it is possible that no records will be returned.</p>
  <p>On the audit summary screen, a link to the audit detail is provided.  A link to the completed report is provided, when available.</p>
  <p><u>Surveillance Schedules</u><br>A summary of all OQA and BSC surveillances scheduled for a fiscal year
  is displayed by selecting the fiscal year from the select box provided and clicking on the button 
  labelled '<i>Go</i>.'</p>
  <p>To limit the surveillance summary to a specific type of surveillance, such as BSC surveillances only, 
  select the desired type from the drop down list provided.  Keep in mind that some types of surveillances were
  not performed in all fiscal years and it is possible that no records will be returned.</p>
  <p>On the surveillance summary screen, a link to the surveillance detail is provided.  A link to 
  the completed report is provided, when available.</p>
  <p><u>Surveillance Requests</u><br>Surveillances may be requested from this screen.  Enter the contact name,
  contact phone number, a brief sumamry of the reason for the request, and the organization or location
  to be surveilled.</p>
  <p><u>Surveillance Request Summary</u><br>A summary of the surveillances requested for a fiscal year
  is displayed by selecting the fiscal year from the select box provided and clicking on the button 
  labelled '<i>Go</i>.'</p>
  <p><u>Other Functions</u><br>Login is required for all other functions performed from the Home screen.  
  Users without the appropriate privilege will not be able to access these system functions.</p>
  
  <p><a name=Search><b>Search</b></a></p>
  <p><u>Search Internal and External Audits</u><br>To search the system for audit records containing a specific text string, select the 
  <i>'Search Internal and External Audits'</i> box on the Search screen.  Enter the search string 
  in the field provided, select a fiscal year, and select the type of audit (internal, external, 
  or both) to search.  For each type of audit selected, select the fields to be searched.  Click the 
  <i>'submit'</i> button.  The returned records will be displayed below the submit button.</p>
  <p><u>Search Surveillance and Surveillance Requests</u><br>To search the system for surveillance or request records 
  containing a specific text string, select the <i>'Search Surveillance and Surveillance Requests'</i> 
  box on the Search screen.  Enter the search string in the field provided, select a fiscal year,
  and select surveillances, surveillance requests, or both to search.  For each selection, select 
  the fields to be searched.  Click the <i>'submit'</i> button.  The returned records will be 
  displayed below the submit button.</p>  

  <p><a name=Browse><b>Browse</b></a></p>
  <p><u>Browse Internal / External Audits</u><br>Select the type of audit (internal, external, or both).
  For each type selected, a drop down box is provided for the filter criteria available.  Select the fiscal year
  to browse, and click the <i>'Submit'</i> button. The returned records will be displayed in a report
  contained in a pop up window.</p>
  <p><u>Browse Surveillances</u><br>Select the Browse Surveillances checkbox.  Select the type of 
  surveillance (internal, external, or both).  A drop down box is provided for the filter criteria 
  available.  Select the fiscal year to browse, and click the <i>'Submit'</i> button. The returned 
  records will be displayed in a report contained in a pop up window.</p>
  
  <p><a name=Reports><b>Reports</b></a></p>
  <p><u>Audit Schedule Menu</u><br>A number of predefined standard audit reports are available.  Click the
  link provided to generate the desired report.</p>
  <p><u>Surveillance Menu</u><br>A number of predefined standard surveillance reports are available.  Click the
  link provided to generate the desired report.</p>
  </form>
  </body>
  </html>
END_OF_LINE

print $outstring;
exit();



