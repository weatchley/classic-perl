#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
#
# CMS Email Notification
#
# $Source: /data/dev/rcs/cms/perl/RCS/enotify.pl,v $
# $Revision: 1.1 $
# $Date: 2002/06/25 17:15:59 $
# $Author: naydenoa $
# $Locker:  $
# $Log: enotify.pl,v $
# Revision 1.1  2002/06/25 17:15:59  naydenoa
# Initial revision
#
#

use strict;
use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;

my $cmscgi = new CGI;

$SCHEMA = (defined($cmscgi->param("schema"))) ? $cmscgi->param("schema") : $SCHEMA;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

# print content type header
print $cmscgi->header('text/html');

my $cgiaction = ($cmscgi -> param('cgiaction') eq "") ? "notification" : $cmscgi -> param('cgiaction');
my $submitonly = 0;
my $usersid = $cmscgi->param('loginusersid');
my $username = $cmscgi->param('loginusername');

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq "")) {
    print <<openloginpage;
    <script type="text/javascript">
    <!--
    parent.location='$ONCSCGIDir/login.pl';
    //-->
    </script>
openloginpage
    exit 1;
}

#print html
print "<html>\n";
print "<head>\n";
print "<meta http-equiv=\"expires\" content=\"Fri, 12 May 1996 14:35:02 EST\">\n";
print "<title>E-mail Notification</title>\n";

print <<testlabel1;
<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>
<script type="text/javascript">
<!--
    var dosubmit = true;
    if (parent == self) {   // not in frames 
	location = '$ONCSCGIDir/login.pl'
    }
//-->
</script>
  <script language="JavaScript" type="text/javascript">
  <!--
      doSetTextImageLabel('Email Notification');
  //-->
  </script>
testlabel1

print "</head>\n\n";
print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><CENTER>\n";

# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();

print "<form action=\"$ONCSCGIDir/enotify.pl\" method=post name=enotify>\n";

##########################################
if ($cgiaction eq "modify_notification") {
##########################################
    my $enable = ($cmscgi -> param('enable') eq 'T') ? 'F' : 'T';
    my $sqlstring = "UPDATE $SCHEMA.notification SET enable='$enable'";
#    print STDERR "*****\n";
    eval {
	my $rc = $dbh -> do($sqlstring);
	$dbh -> commit;
    };
    if ($@) {
	$dbh->rollback;
	my $alertstring = errorMessage($dbh, $username, $usersid, 'notification', "", "Error updating email notification status", $@);
	$alertstring =~ s/\"/\'/g;
	print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
	print "<!--\n";
	print "alert(\"$alertstring\");\n";
	print "parent.control.location=\"$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\";\n";
	print "//-->\n";
	print "</script>\n";
    }
    else {
	my $logmsg = ($enable eq 'T') ? "E-mail notification enabled" : "E-mail notification disabled";
	&log_activity($dbh, 'F', $usersid, $logmsg);
	print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
	print "<!--\n";
	print "parent.workspace.location=\"$ONCSCGIDir/home.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\";\n";
	print "parent.control.location=\"$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\";\n";
	print "//-->\n";
	print "</script>\n";
    }

}  ####  endif modify user  ####

###################################
if ($cgiaction eq "notification") {
###################################
    my $submitonly = 1;
    my ($curren) = $dbh -> selectrow_array ("select enable from $SCHEMA.notification");
    print "<input name=cgiaction type=hidden value=\"modify_notify\">\n";
    print "<input type=hidden name=schema value=$SCHEMA><br><br>\n";
    print "<table summary=\"Enable/Disable E-mail Notification\" width=380 border=0>\n";
    my $endis = ($curren eq 'F') ? "En" : "Dis";
    print "<tr><td align=center><b>Click Button to " . $endis . "able E-mail Notification:</b></td>\n";
    print "</tr></table>\n";
    print "<br>\n<br>\n";
    print "<input name=action type=hidden value=modify_notification>\n";
    print "<input name=enable type=hidden value=$curren>\n";
    print "<input name=loginusersid type=hidden value=$usersid>\n";
    print "<input name=loginusername type=hidden value=$username>\n";

    print "<input name=note type=submit value=\"" . $endis . "able Notification\" onclick=document.enotify.cgiaction.value='modify_notification'>";
}  #### endif modify selected  ####

print "</form>\n";
print "</CENTER><br><br></body>\n";
print "</html>\n";

&oncs_disconnect($dbh);





