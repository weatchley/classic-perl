#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/qa/perl/RCS/login.pl,v $
#
# $Revision: 1.8 $
#
# $Date: 2004/05/30 22:05:44 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: login.pl,v $
# Revision 1.8  2004/05/30 22:05:44  starkeyj
# added subroutine testHTTPS to meet security requirements
#
# Revision 1.7  2002/02/21 21:27:21  starkeyj
# modified frameset so title frame is larger to accomodate new fonts on intranet upgrade
#
# Revision 1.6  2002/02/20 17:42:36  starkeyj
# modified writeHTTPHeader function to remove deprecated html
#
# Revision 1.5  2001/11/27 15:30:30  starkeyj
# guest login written to STDERR instead of activity log
#
# Revision 1.4  2001/11/06 15:46:47  starkeyj
# added activity log for logins
#
# Revision 1.3  2001/11/05 16:20:30  starkeyj
# changed path for background image
#
# Revision 1.2  2001/10/22 17:27:25  starkeyj
# no change, user error with RCS
#
# Revision 1.1  2001/10/19 23:30:46  starkeyj
# Initial revision
#
#
# Revision: $
#
# 
use NQS_Header qw(:Constants);
use OQA_Widgets qw(:Functions);
use OQA_Utilities_Lib qw(:Functions);
use DBLogin qw(:Functions); 
use DBPassword qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

my $NQScgi = new CGI;
$ENV{SCRIPT_NAME} =~ m%(.*)/(.*)\..*$%;
my $path = $1;
my $form = $2;
$SCHEMA = defined($NQScgi->param('schema')) ? uc($NQScgi->param('schema')) : "NQS";

 
my $username = defined($NQScgi->param('username')) ? uc($NQScgi->param('username')) : "GUEST";
my $password = defined($NQScgi->param('password')) ? $NQScgi->param('password') : "password";
my $defaultpassword = "password";
my $command = defined($NQScgi->param('command')) ? $NQScgi->param('command') : "login";
my $cgiaction = $NQScgi->param('cgiaction');
my $userid = 0;
my $dbh;


#####################
sub writeHTTPHeader {
#####################
    #$NQScgi->use_named_parameters(1);
    my $output = $NQScgi->header('text/html');  # 'target' => 'a_frame'
    return ($output);
}

###################################################################################################################################
sub testHTTPS {
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = '';
    if (!defined($ENV{HTTPS}) || lc($ENV{HTTPS}) ne "on") {
#        $output = "Location: https://$ENV{SERVER_NAME}$1$args{redirectTo}\n\n";
        $output .= &writeHTTPHeader;
        $output .= "<script>\n";
        $ENV{SCRIPT_NAME} =~ m%^(.*/)%;
        $output .= "location='https://$ENV{SERVER_NAME}$1" . "login.pl';\n";
        $output .= "</script>\n";
    }
    return ($output);
}
###############
sub writeHead {
###############
    my $output = "<html>\n<head>\n";
    $output .= "<meta name=pragma content=no-cache>\n";
    $output .= "<meta name=expires content=0>\n";
    $output .= "<meta http-equiv=expires content=0>\n";
    $output .= "<meta http-equiv=pragma content=no-cache>\n";
    $output .= "<title>Quality Assurance - Audit and Surveillance Schedule System</title>\n";
    $output .= "<script src=$NQSJavaScriptPath/utilities.js></script>\n";
    $output .= "</head>\n";
    return ($output);
}


##############
sub writeBody {
###############
    my $output;
    my $script;
    
	if ($command eq "login") {
		if ($username ne "GUEST") {
			$userid = get_userid($dbh,$username);
			&log_nqs_activity($dbh,$SCHEMA,'F',$userid,"$username logged in");
		}
		else {print STDERR "\nGuest logged in to Audit and Surveillance Schedule Management\n";}
		if ($password eq $defaultpassword) {
	   	$script = ($userid) ? "system_functions" : "home";
	   }
	   else {
	   	$script = ($userid) ? "home" : "home";
		}
		my $params = "username=$username&userid=$userid&schema=$SCHEMA&cgiaction=$cgiaction";
		$output .= "<frameset rows=76,50,*," . (($NQSProductionStatus == 1) ? "1" : "25") . " border=0 framespacing=0>\n";
		$output .=  "   <frame src=NQS_page_header.pl?$params name=header frameborder=no scrolling=no noresize marginwidth=0 marginheight=0>\n";
		$output .=  "   <frame src=title_bar2.pl?$params name=title frameborder=no scrolling=no noresize marginwidth=0 marginheight=0>\n";
		$output .=  "   <frame src=$script.pl?$params name=workspace frameborder=no noresize scrolling=yes marginwidth=0 marginheight=0>\n";
		$output .=  "   <frame src=blank2.pl?$params name=control frameborder=yes scrolling=yes noresize marginwidth=0 marginheight=0>\n";
		$output .=  "</frameset>\n";
		#$header = "newLogin";
		#$output .= "parent.location.href = 'login.pl';\n";
	
   }
	elsif ($command eq "newlogin") {
      $output .= "<script language=javascript type=text/javascript><!--\n";
		$output .= "   doSetTextImageLabel('Login');\n//-->\n</script>\n";
		$output .= "<body background=$NQSImagePath/background.gif text=$NQSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n<center>\n";
	
		$output .= "<form name=newlogin action=$path/$form.pl target=control method=post>\n";
		$output .= "<input type=hidden name=command value=validatelogin>\n";
		$output .= "<input type=hidden name=schema value=$SCHEMA>\n";
		$output .= "<table border=0 cellpadding=6 cellspacing=3>\n";
		$output .= "<tr><td><font size=4>Username:&nbsp;</font></td><td><input type=text name=username size=8 maxlength=8></td></tr>\n";
		$output .= "<tr><td><font size=4>Password:&nbsp;</font></td><td><input type=password name=password size=15 maxlength=15></td></tr>\n";
		$output .= "<tr><td align=center colspan=2><input type=submit name=submit value=Login></td></tr>\n";
		$output .= "</table>\n";
		$output .= "</form>\n";
		$output .= "<script language=javascript><!--\n   document.newlogin.username.focus();\n//-->\n</script>\n";
		$output .= "</center>\n</body>\n";

 	}
   elsif ($command eq "validatelogin") {
		$userid = get_userid($dbh, $username);
		if (!&validateUser(dbh => $dbh, schema => $SCHEMA, userID => $userid, userName => $username, password => $password)) {
	   	$output .= "<script language=javascript type=text/javascript><!--\n   alert('Invalid Username or Password');\n//-->\n</script>";
		} 
		else {
			$output .= "<body>";
			$output .= "<form name=validate action=$path/$form.pl target=_top method=post>\n";
			$output .= "<input type=hidden name=username value=$username>\n";
			$output .= "<input type=hidden name=password value=$password>\n";
			$output .= "<input type=hidden name=command value=login>\n";
			$output .= "<input type=hidden name=userid value=$userid>\n";
			$output .= "<input type=hidden name=schema value=$SCHEMA>\n";
			$output .= "<input type=hidden name=cgiaction value=change_password>\n";
			#if (NQS_encrypt_password($password) eq NQS_encrypt_password($defaultpassword)) {
			#	my $cgiaction = "change_password";
			#	$output .= "<input type=hidden name=cgiaction value=$cgiaction>\n";
			#}
			#$output .= "<script language=javascript><!--\n   alert('2');\n//-->\n</script>\n";
			$output .= "<script language=javascript><!--\n   document.validate.submit();\n//-->\n</script>\n";		
			$output .= "</form>\n";
	   	$output .= "</body>";
		}
	}
	
	
	return ($output);
}


#######################

$dbh = &NQS_connect();

print <<END_of_line;
Content-type: text/html

END_of_line

print  &testHTTPS . &writeHead() . &writeBody() . "</html>\n";
&NQS_disconnect($dbh);
exit();



 