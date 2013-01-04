#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/cms/perl/RCS/login.pl,v $
#
# $Revision: 1.11 $
#
# $Date: 2006/06/27 16:48:11 $
#
# $Author: naydenoa $
#
# $Locker:  $
#
# $Log: login.pl,v $
# Revision 1.11  2006/06/27 16:48:11  naydenoa
# CREQ00030 - fix security issue - force https (see top of script).
#
# Revision 1.10  2002/04/12 23:49:01  naydenoa
# Checkpoint
#
# Revision 1.9  2000/11/22 00:01:23  naydenoa
# Sends user to changepassword if password = defaultpassword
#
# Revision 1.8  2000/10/26 19:30:57  atchleyb
# modified to only allow MS IE to log in to read/write functions
# Netscape can only do read only fuctions
#
# Revision 1.7  2000/10/11 00:32:11  mccartym
# change form name/reference to work on netscape
#
# Revision 1.6  2000/10/11 00:14:22  mccartym
# finish cleanup
#
# Revision 1.5  2000/10/06 19:13:12  mccartym
# clean up a mess
#
# Revision 1.4  2000/10/05 22:16:14  munroeb
# added log_activity() functionality
#
# Revision 1.3  2000/10/04 19:28:12  atchleyb
# changed default to reports from browse
#
# Revision 1.2  2000/09/25 21:15:14  atchleyb
# checkpoint
#
# Revision 1.1  2000/08/31 23:21:37  atchleyb
# Initial revision
#
# get all required libraries and modules
#
use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

my $cmscgi = new CGI;
$ENV{SCRIPT_NAME} =~ m%(.*)/(.*)\..*$%;
my $path = $1;
my $form = $2;
$SCHEMA = $cmscgi->param("schema") if (defined($cmscgi->param("schema")));
my $username = defined($cmscgi->param('username')) ? uc($cmscgi->param('username')) : "GUEST";
my $password = defined($cmscgi->param('password')) ? $cmscgi->param('password') : "GUEST";
my $defaultpassword = "password";
my $command = defined($cmscgi->param('command')) ? $cmscgi->param('command') : "login";
my $userid = 0;
my $dbh;

#####################
sub writeHTTPHeader {
#####################
if (!(defined($ENV{HTTPS}) && $ENV{HTTPS} eq 'on')) {
    print "Location: https://$ENV{SERVER_NAME}$1/" . "login.pl\n\n";
}
    my $output = $cmscgi->header('text/html');
    return ($output);
}

###############
sub writeHead {
###############
    my $output = "<head>\n";
    $output .= "<meta name=pragma content=no-cache>\n";
    $output .= "<meta name=expires content=0>\n";
    $output .= "<meta http-equiv=expires content=0>\n";
    $output .= "<meta http-equiv=pragma content=no-cache>\n";
    $output .= "<title>Commitment Management System</title>\n";
    $output .= "<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>\n";
    $output .= "</head>\n";
    return ($output);
}

###############
sub writeBody {
###############
    my $output;
    if ($command eq "login") {
	if ($username ne "GUEST") {
	    $userid = get_userid($dbh, $username);
	    &log_activity($dbh, 'F', $userid, "User $username logged in");
	}
	my $script;
	if ($password ne $defaultpassword) {
	    $script = ($userid) ? "home" : "reports_module_main";
	}
	else {
	    $script = ($userid) ? "changepassword" : "reports_module_main";
	}
	my $frameConfig = "frameborder=no noresize marginwidth=0 marginheight=0";
	my $params = "loginusername=$username&loginusersid=$userid&schema=$SCHEMA";
	$output .= "<frameset rows=115,58,*,$CMSControlSize border=0 framespacing=0>\n";
	$output .= "<frame src=$path/oncs_page_header.pl?$params name=header $frameConfig scrolling=no>\n";
	$output .= "<frame src=$path/title_bar.pl?$params name=titlebar $frameConfig scrolling=no>\n";
	$output .= "<frame src=$path/$script.pl?$params name=workspace $frameConfig>\n";
	$output .= "<frame src=$path/blank.pl?$params name=control $frameConfig scrolling=no>\n";
	$output .= "</frameset>\n";
    } 
    elsif ($command eq "newlogin") {
	$output .= "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n<center>\n";
	$output .= "<script language=javascript type=text/javascript><!--\n";
	if ($CMSProductionStatus == 1) {
	    $output .= "      function browserNotExplorer() {\n";
	    $output .= "         return(navigator.appName.indexOf('Internet Explorer') == -1);\n";
	    $output .= "      }\n";
	    $output .= "      function browserLessThanFour() {\n";
	    $output .= "         var mozilla = \"Mozilla/\";\n";
	    $output .= "         return((navigator.userAgent.charAt(navigator.userAgent.indexOf(mozilla) + mozilla.length)) < 4);\n";
	    $output .= "      }\n";
	    $output .= "      if (browserNotExplorer() || browserLessThanFour()) {\n";
	    $output .= "         alert('Internet Explorer version 4.0 or greater is required to access the database.');\n";
	    $output .= "         parent.location.href = 'login.pl';\n";
	    $output .= "      };\n";
	}
	$output .= "   doSetTextImageLabel('Login');\n//-->\n</script>\n";
	$output .= "<form name=newlogin action=$path/$form.pl target=control method=post>\n";
	$output .= "<input type=hidden name=command value=validatelogin>\n";
	$output .= "<input type=hidden name=schema value=$SCHEMA>\n";
	$output .= "<table border=0 cellpadding=6 cellspacing=3>\n";
	$output .= "<tr><td><font size=4>Username:</font></td><td><input type=text name=username size=8 maxlength=8></td></tr>\n";
	$output .= "<tr><td><font size=4>Password:</font></td><td><input type=password name=password size=15 maxlength=15></td></tr>\n";
	$output .= "<tr><td align=center colspan=2><input type=submit name=submit value=Login></td></tr>\n";
	$output .= "</table>\n";
	$output .= "</form>\n";
	$output .= "<script language=javascript><!--\n   document.newlogin.username.focus();\n//-->\n</script>\n";
	$output .= "</center>\n</body>\n";
    } 
    elsif ($command eq "validatelogin") {
	$userid = get_userid($dbh, $username);
	if (!&validate_user($dbh, $username, $password)) {
	    $output .= "<script language=javascript type=text/javascript><!--\n   alert('Invalid Username or Password');\n//-->\n</script>";
	} 
	else {
	    $output .= "<body>";
	    $output .= "<form name=validate action=$path/$form.pl target=_top method=post>\n";
	    $output .= "<input type=hidden name=username value=$username>\n";
	    $output .= "<input type=hidden name=password value=$password>\n";
	    $output .= "<input type=hidden name=userid value=$userid>\n";
	    $output .= "<input type=hidden name=command value=login>\n";
	    $output .= "<input type=hidden name=schema value=$SCHEMA>\n";
	    $output .= "</form>\n";
	    $output .= "<script language=javascript><!--\n   document.validate.submit();\n//-->\n</script>\n";
	    $output .= "</body>";
	}
    }
    return ($output);
}

#######################
$dbh = &oncs_connect();
print &writeHTTPHeader() . "<html>\n" . &writeHead() . &writeBody() . "</html>\n";
&oncs_disconnect($dbh);
exit();



