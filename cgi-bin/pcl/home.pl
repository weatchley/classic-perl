#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/pcl/perl/RCS/home.pl,v $
#
# $Revision: 1.6 $
#
# $Date: 2003/02/12 16:34:17 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: home.pl,v $
# Revision 1.6  2003/02/12 16:34:17  atchleyb
# added session management
#
# Revision 1.5  2003/02/10 18:59:11  atchleyb
# removed refs to SCM
#
# Revision 1.4  2002/11/27 23:31:35  mccartym
# add call to display table of checked out non-code items
# modified use clauses to support move of &getUserUnixID() from DB_scm to DBUsers module
#
# Revision 1.3  2002/11/25 19:38:32  mccartym
# code reorganization
# add call to display table of checked out non-code items
#
# Revision 1.2  2002/10/04 18:28:02  naydenoa
# Took out SCR display - moved to UI_SCR module
#
# Revision 1.1  2002/09/17 22:12:34  starkeyj
# Initial revision
#
#
#
#
use integer;
use strict;
use CGI;
use Tie::IxHash;
use SharedHeader ('$SYSImagePath', '$SYSUseSessions');
use UIShared ('writeHTTPHeader', 'checkLogin', 'validateCurrentSession');
use UI_Widgets ('writeTitleBar');
use UIDocuments ('displayNonCodeCheckedOutItemsTable');
use UI_SCR ('listSCRs');
use DBShared ('db_connect', 'db_disconnect');
use DBUsers ('getUserUnixID');
use RCS ('writeRCSForm', 'displayRCSCheckedOutItemsTable', 'displayRCSItemCheckOutTable');

###################################################################################################################################
sub writeBody {                                                                                                                   #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "";
   my $dbh = &db_connect();
   my $username = $args{cgi}->param("username");
   my $userid = $args{cgi}->param("userid");
   my $schema = $args{cgi}->param("schema");
   my $sessionID = ((defined($args{cgi}->param("sessionid"))) ? $args{cgi}->param("sessionid") : 0);
   if ($SYSUseSessions eq 'T') {
       &validateCurrentSession(dbh=>$dbh, schema=>$schema, userID=>$userid, sessionID=>$sessionID);
   }
   $out = "<body background=$SYSImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n<center>\n";
   $out .= &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Home");
   my $unixid = &getUserUnixID(dbh => $dbh, schema => $schema, username => $username);
   $out .= &writeRCSForm(schema => $schema, username => $username, userid => $userid, unixid => $unixid, sessionID => $sessionID);
   $out .= &displayRCSCheckedOutItemsTable(username => $username, unixid => $unixid);

if ($username eq 'MCCARTYM') {  #temp
   my @project = (27, 'st');
   $out .= &displayRCSCheckedOutItemsTable(username => $username, unixid => $unixid, project => \@project);
   $out .= &displayRCSItemCheckOutTable(username => $username, project => \@project);
}

   $out .= &displayNonCodeCheckedOutItemsTable(dbh => $dbh, schema => $schema, userID => $userid, sessionID => $sessionID);
   $out .= &listSCRs(dbh => $dbh, schema => $schema, uid => $userid, uname => $username, sessionID => $sessionID);
   $out .= "</center>\n</body>\n</html>\n";
   &db_disconnect($dbh);
   return ($out);
}

###################################################################################################################################
sub writeHead {                                                                                                                   #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "";
   $out .= "<html>\n";
   $out .= "<head>\n";
   $out .= "<base target=main>\n";
   $out .= "<meta http-equiv=expires content=now>\n";
   $out .= "</head>\n\n";
   return ($out);
}

###################################################################################################################################
my $cgi = new CGI;
&checkLogin (cgi => $cgi);
my $output = &writeHTTPHeader(cgi => $cgi);
$output .= &writeHead();
$output .= &writeBody(cgi => $cgi);
print $output;
exit();
