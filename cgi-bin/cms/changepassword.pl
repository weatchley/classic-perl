#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
# Password change Screen for CIRS
#
# $Source: /data/dev/rcs/cms/perl/RCS/changepassword.pl,v $
# $Revision: 1.13 $
# $Date: 2002/10/04 21:04:15 $
# $Author: naydenoa $
# $Locker:  $
# $Log: changepassword.pl,v $
# Revision 1.13  2002/10/04 21:04:15  naydenoa
# Added "use strict"
#
# Revision 1.12  2000/10/03 20:43:05  naydenoa
# Interface update.
#
# Revision 1.11  2000/09/21 22:25:37  atchleyb
# changed page layout
#
# Revision 1.10  2000/09/21 22:02:18  atchleyb
# updated title
#
# Revision 1.9  2000/09/19 18:27:00  atchleyb
# changed ref from oncs_home.pl to home.pl
#
# Revision 1.8  2000/08/21 20:10:29  atchleyb
# fixed dir bug
#
# Revision 1.7  2000/08/21 17:40:33  atchleyb
# added check schema line
#
# Revision 1.6  2000/07/24 15:11:22  johnsonc
# Inserted GIF file for display.
#
# Revision 1.5  2000/07/17 16:40:49  atchleyb
# placed form inside a 750 width table
#
# Revision 1.4  2000/07/06 23:32:44  munroeb
# finished mods to html and javascripts.
#
# Revision 1.3  2000/07/05 23:01:56  munroeb
# made minor changes to html and javascripts
#
# Revision 1.2  2000/05/18 23:11:57  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.1  2000/04/11 23:44:13  zepedaj
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

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $cmscgi = new CGI;

$SCHEMA = (defined($cmscgi->param("schema"))) ? $cmscgi->param("schema") : $SCHEMA;

# print content type header
print $cmscgi->header('text/html');

my $pagetitle = "Password";
my $cgiaction = $cmscgi->param('cgiaction');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $submitonly = 0;
my $usersid = $cmscgi->param('loginusersid');
my $username = $cmscgi->param('loginusername');
my $updatetable = "users";
my ($one, $two, $three, $four, $badpassword);

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq "")) {
    print <<openloginpage;
    <script type="text/javascript">
    <!--
    //alert ('$usersid $username $pagetitle $updatetable $one $two $three $four');
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
print "<title>$pagetitle Maintenance</title>\n";

print <<testlabel1;
<!-- include external javascript code -->
<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>

    <script type="text/javascript">
    <!--
    var dosubmit = true;
    if (parent == self) {  // not in frames
        location = '$ONCSCGIDir/login.pl'
    }

    function comparenew(np1, np2) {
	if (np1.value != np2.value) {
	    alert ("You entered two different new passwords.");
	    return (false);
        }
	return (true);
    }

    //-->
    </script>

  <script language="JavaScript" type="text/javascript">
  <!--
      doSetTextImageLabel('Password Maintenance');
  //-->
</script>

testlabel1

$badpassword = 0;

######################################
if ($cgiaction eq "change_password") {
######################################
    # print the sql which will update this table
    my $oldpassword = $cmscgi->param('oldpass');
    my $newpassword = $cmscgi->param('newpass');
    if (!($oldpassword eq "") || !($newpassword eq "")) {
	my $password = oncs_encrypt_password($newpassword);
	# connect to the oracle database and generate a database handle
	my $dbh = oncs_connect();
	
	my $status = validate_user($dbh, $username, $oldpassword);
	if ($status == 1) {  # we have a valid user 
	    my $sqlstring = "UPDATE $SCHEMA.$updatetable 
                          SET password='$password'
                          WHERE usersid=$usersid";
	    my $rc = $dbh->do($sqlstring);
	    $cgiaction="query";
	    
	    #disconnect from the database
	    &oncs_disconnect($dbh);
	    
	    #password changed, go back to home page.
	    
	    print <<gotomainmenu;
	    </form>
	    <script type="text/javascript">
            <!--
	        location='$ONCSCGIDir/home.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA';
            //-->
            </script>
gotomainmenu
        exit 1;
	}
	# not valid old password (probably a typo), proceed and post the invalid password statement
	$badpassword = 1;
    }
    else {
	# no old or new password entered, return to the home page.
	
	print <<gotomainmenu;
	</form>
        <script type="text/javascript">
        <!--
        location='$ONCSCGIDir/home.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA';
        //-->
        </script>
gotomainmenu
    exit 1;
    }
}

print "</head>\n\n";
print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
print "<table border=0 align=center width=750><tr><td>\n";

if ($badpassword) {
    print "<center>The old password you entered was incorrect, your password has not been changed.</center><br>\n";
}

print "<form action=\"$ONCSCGIDir/changepassword.pl\" method=post name=passmaint onsubmit=\"return(comparenew(document.passmaint.newpass, document.passmaint.newpass2))\">\n";

#display the change password form
print <<userpassform;
<input name=cgiaction type=hidden value="change_password">
<input type=hidden name=schema value=$SCHEMA>
<br><br>
<table summary="modify password table" border=0 align=center>
<tr><td><b><li>User ID:</b></td>
<td align=left><b>$username</b>
<input name=usersid type=hidden value=$usersid>
<input name=username type=hidden value=$username></td></tr>
<tr><td><b><li>Old Password:</b></td>
<td><input name=oldpass type=password maxlength=50 size=50></td></tr>
<tr><td><b><li>New Password:</b></td>
<td><input name=newpass type=password maxlength=50 size=50></td></tr>
<tr><td><b><li>New Password:<br>(Re-Enter to Verify)</b></td>
<td><input name=newpass2 type=password maxlength=50 size=50></td></tr>
</table>
userpassform

print "<input name=updatetable type=hidden value=$updatetable>\n";
print "<input name=loginusername type=hidden value=$username>\n";
print "<input name=loginusersid type=hidden value=$usersid>\n";
print "<input name=pagetitle type=hidden value=\"$pagetitle\">\n";

# print html footers.
print "<br>\n";
print "<center><input name=submit type=submit value=\"Submit Changes\"></center>\n";
print "</form>\n";

print "</td></tr></table>\n";
print "</body>\n";
print "</html>\n";
