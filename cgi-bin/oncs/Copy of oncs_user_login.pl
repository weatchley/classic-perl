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

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

#use vars qw{ $oncsvals};

# $oncsvals = new ONCS_Header;
# create cgi object for processing
my $oncscgi = new CGI;

# tell the browser that this is an html page using the header method
print $oncscgi->header('text/html');

# output page header
print "<html>\n";
print "<head>\n";
print "<meta name=pragma content=no-cache>\n";
print "<meta name=expires content=0>\n";
print "<meta http-equiv=expires content=0>\n";
print "<meta http-equiv=pragma content=no-cache>\n";
print "<title>Commitment Management System</title>\n";
print "<!-- include external javascript code -->\n";
print<<javascriptblock;
<script language="JavaScript" type="text/javascript"><!--
// Routine to check the data from the login form
function verify_login(usernamefield, passwordfield)
  {
  var msg ="";
  if (isblank(usernamefield.value))
    {
    msg += "You must enter your system User Name.\\n";
    }
  if (isblank(passwordfield.value))
    {
    msg += "You must enter your System Password.\\n";
    }

  if (msg != "")
    {
    alert (msg);
    return false;
    }
  return true;
  }

// A utility function that returns true if a string contains only
// whitespace characters.
function isblank(s)
  {
  for(var i = 0; i < s.length; i++)
    {
    var c = s.charAt(i);
    if ((c != ' ') && (c != '\\n') && (c != '\\t') && (c !='\\r')) return false;
    }
  return true;
  }

//-->
</script>
javascriptblock
print " \n";
print "<!-- declare javascript functions unique to this form -->\n";
print " \n";
print "</head>\n";

my $cgiaction = $oncscgi->param('cgiaction');
$cgiaction = (! defined($cgiaction)) ? "" : $cgiaction;

# test username and cgiaction
if ($cgiaction eq "login")
  {
  # Connect to the oracle database and generate an object 'handle' to the database
  my $dbh = oncs_connect();

  # Get username and password from the previous form
  my $username = $oncscgi->param("username");
  my $password = $oncscgi->param("password");
  my $usersid = get_userid($dbh, $username);
  my $reportname = $oncscgi->param("reportname");
  my $status = &validate_user($dbh, $username, $password);
  if (($status == 1) || ($status == 2))
    {
    if ($status == 2)
      {
      $usersid = 0;
      $username = "GUEST";
      }
    &log_history($dbh, "User Logged In", 'F', $usersid, '', '', "User $username logged in.");

    $username = uc($username);
    #my $userid = &get_userid($dbh, $username);
    # generate new frames page
    print<<CMSFrame1;
      <frameset rows=60,0,55,* frameborder=no frameborder=0 framespacing=0>
      <frame src="/cgi-bin/oncs/oncs_page_header.pl?loginusername=$username&loginusersid=$usersid" name=header noresize scrolling=no frameborder=yes frameborder=1>
      <frame src="/oncs/blank.htm" name=control noresize scrolling=no frameborder=yes frameborder=1>
      <!-- <frame src="/cgi-bin/oncs/oncs_menu.pl?loginusername=$username&loginusersid=$usersid" name=menu noresize scrolling=no> -->
CMSFrame1
    if ($usersid == 0)
      {
      print "<!-- $reportname -->\n";
      if ($reportname eq "managers")
          {
          print "      <frame src=\"/cgi-bin/oncs/commitment_module_menu.pl?loginusername=$username&loginusersid=$usersid&loadworkspace=F\" name=menu noresize scrolling=no>\n";
          print "      <frame src=\"/cgi-bin/oncs/manager_report.pl?loginusername=$username&loginusersid=$usersid\" noresize name=workspace frameborder=1 frameborder=yes>\n";
          }
      else
          {
          print "      <frame src=\"/cgi-bin/oncs/commitment_module_menu.pl?loginusername=$username&loginusersid=$usersid&loadworkspace=F\" name=menu noresize scrolling=no>\n";
          print "      <frame src=\"/cgi-bin/oncs/ad_hoc_reports.pl?loginusername=$username&loginusersid=$usersid\" noresize name=workspace frameborder=1 frameborder=yes>\n";
          }
      }
    else
      {
      print "      <frame src=\"/cgi-bin/oncs/oncs_menu.pl?loginusername=$username&loginusersid=$usersid\" name=menu noresize scrolling=no>\n";
      print "      <frame src=\"/cgi-bin/oncs/oncs_home.pl?loginusername=$username&loginusersid=$usersid\" noresize name=workspace frameborder=1 frameborder=yes>\n";
      }
    print"    </frameset>\n";
    }
  else
    {
    &log_history($dbh, "User Login Failed", 'F', 0, '', '', "User $username could not log in, bad username or bad password.");

    $cgiaction = "makeform";
    print <<alertbadpassword;
    <script language=javascript><!--
    alert('Invalid User Name or Password');
    //-->
    </script>
alertbadpassword
    }
  # close connection to the oracle database
  &oncs_disconnect($dbh);
  }

if ($cgiaction ne "login")
  {
  print "<body onload=\"document.login.username.focus()\">\n";
  # set default font atributes
  # print "<font face=\"$CRDFontFace\" color=$CRDFontColor>\n";

  print "<center>\n";
  print "<table border=0 width=640><tr><td>\n";

  # generate login form
  # setup form for the page (use filename_form as name of form)
  print "<form name=login action=\"/cgi-bin/oncs/oncs_user_login.pl\" method=post onsubmit=\"return(verify_login(document.login.username, document.login.password))\">\n";
  # use a hidden field to tell the next cgi what to do
  print "<input type=hidden name=cgiaction value=login>\n";

  print "<center>\n";
  print "<h2>Login to the Commitment Management System</h2><br>\n";
  print "<b><h3>User Name</h3></b>\n";
  print "<input type=text name=username size=30 maxlength=10><br><br>\n";
  print "<b><h3>Password</h3></b>\n";
  print "<input type=password name=password size=30 maxlength=50><br><br>\n";
  print "<input type=hidden name=reportname value=custom>\n";
  print "<input type=submit name=submit value=Submit>\n";
  print "<br><br><br><input type=submit name=guest value='Managers Report' onclick=\"document.login.username.value='guest'; document.login.password.value='guest'; document.login.reportname.value='managers';\">\n";
  print "<br><br><br><input type=submit name=adhocbutton value='Customizable Report' onclick=\"document.login.username.value='guest'; document.login.password.value='guest'; document.login.reportname.value='custom';\">\n";

  # close the form for the page
  print "</form>\n";

  print "<br><br>\n";

  #
  print "</td></tr></table>\n";
  print "</center>\n";

  # end font atributes for page
  #print "</font>\n";

  print "</body>";
  }

print "</html>\n";
