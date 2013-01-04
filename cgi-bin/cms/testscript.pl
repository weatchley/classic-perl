#!/usr/local/bin/newperl
# - !/usr/bin/perl

#use ONCS_Header qw(:Constants);
#use ONCS_Widgets qw(:Functions);
#use ONCS_Utilities_Lib qw(:Functions);
#use ONCS_specific qw(:Functions);
use UI_Widgets qw(:Functions);

#use DBI;
#use DBD::Oracle qw(:ora_types);
use CGI;
#use Tie::IxHash;
use strict;

my $testout = new CGI;

# print content type header
print $testout->header('text/html');
my $cgiaction = $testout->param('cgiaction');
$cgiaction = ($cgiaction) ? $cgiaction : "restart";
my $pagetitle = "Test Script";

#print html
print <<pagetop;
<html>
<head>
<title>$pagetitle</title>
</head>
pagetop

if ($cgiaction eq "query")
  {
  my $sec; 
  my $min; 
  my $hour;
  ($sec, $min, $hour) = localtime(time);
  print <<querypage1;
  <body>
  <form name=pageform action=/cgi-bin/oncs/testscript.pl method=post>
querypage1
  print &expire_form ("pageform", "/cgi-bin/oncs/testscript.pl");
  print <<querypage2;
  <input type=hidden name=isexpired value=0>
<!--   <script language="JavaScript" type="text/javascript">
  <!-- 
  if (document.pageform.isexpired.value == -1)
    {
    location = "/cgi-bin/testscript.pl";
    }
  else
    {
    document.pageform.isexpired.value = -1;
    }
  // - - >
  </script> -->
  <h1>Query Page</h1>
  <input type=hidden name=cgiaction value=submitform>
  <input type=submit name=submitbutton value="Click here to go to the final page">
  </form>
  The current time is: $hour : $min : $sec <br>
  </body>
  </html>
querypage2
  }
elsif ($cgiaction eq "restart")
  {
  print <<restartpage;
  <body>
  <h1>Start Page</h1>
  <form name=startform action=/cgi-bin/oncs/testscript.pl method=post>
  <input type=hidden name=cgiaction value=query>
  <input type=submit name=submitbutton value="Click here to go to the Query Page">
  </form>
  </body>
  </html>
restartpage
  }
elsif ($cgiaction eq "submitform")
  {
  print <<submitpage;
  <body>
  <h1>Form Has Been Submitted Page</h1>
  <h3>Click on the Back Button to check functionality</h3>
  <form name=startform action=/cgi-bin/oncs/testscript.pl method=post>
  <input type=hidden name=cgiaction value=restart>
  <input type=submit name=submitbutton value="Click here to go to the Start Page">
  </form>
  </body>
  </html>  
submitpage
  }
