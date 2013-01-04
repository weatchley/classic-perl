#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/pcl/perl/RCS/project_items.pl,v $
#
# $Revision: 1.5 $
#
# $Date: 2003/02/25 19:38:31 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: project_items.pl,v $
# Revision 1.5  2003/02/25 19:38:31  atchleyb
# added missing parameter (userID) to displayNonCodeItemsTables call
#
# Revision 1.4  2003/02/12 16:36:05  atchleyb
# added session management
#
# Revision 1.3  2003/02/04 00:09:25  atchleyb
# removed refs to SCM
#
# Revision 1.2  2002/11/27 23:21:16  mccartym
# modified use clauses to support move of &getUserUnixID() from DB_scm to DBUsers module
#
# Revision 1.1  2002/11/25 21:03:50  mccartym
# Initial revision
#
#
#

use strict;
use integer;
use CGI;
use SharedHeader ('$SYSImagePath', '$SYSUseSessions');
use UIShared ('writeHTTPHeader', 'checkLogin', 'validateCurrentSession');
use UI_Widgets ('writeTitleBar');
use UIDocuments ('displayNonCodeItemsTables', 'displayNonCodeItemCheckOutTable');
use DBShared ('db_connect', 'db_disconnect', 'getLookupValues');
use DBUsers ('getUserUnixID');
use RCS ('writeRCSForm', 'displayRCSItemsTables', 'displayRCSItemCheckOutTable');

###################################################################################################################################
sub processSubmittedData {                                                                                                        #
###################################################################################################################################
   my %args = (
      @_,
   );
   my ($success, $message, $activity, $project) = (0, "", "", 0);
   my $username = $args{cgi}->param("username");
   my $userid = $args{cgi}->param("userid");
   my $schema = $args{cgi}->param("schema");
   eval {
      #############################################################################################################################
      if ($args{process} eq '') {                                                                                                 #
      #############################################################################################################################
      }
      &logActivity (dbh => $args{dbh}, schema => $schema, userID => $userid, logMessage => $activity, projectID => $project);
      $args{dbh}->commit;
   };
   ################################################################################################################################
   if ($@) {
      $args{dbh}->rollback;
      $message = &errorMessage($args{dbh}, $username, $userid, $schema, $activity, $@);
   } else {
      $success = 1;
      $message = $activity . "was successful"; 
   }
   return ($success, $message);
}

###################################################################################################################################
sub processCommand {                                                                                                              #
###################################################################################################################################
   my %args = (
      @_,
   );
   my %projectAcronyms = %{&getLookupValues(dbh => $args{dbh}, schema => $args{schema}, table => "project", idColumn => "id", nameColumn => "acronym")};
   my $projectAcronym = lc($projectAcronyms{$args{project}});
   my @project = ($args{project}, $projectAcronym);
   my ($out, $title) = ("", "");
   $out .= "<table width=750 align=center cellpadding=5 cellspacing=5>\n";
   if ($args{command} eq 'browse') {
      $title = "Browse " . uc($projectAcronym) . " Project Items";
      $out .= &writeTitleBar(userName => $args{username}, userID => $args{userid}, schema => $args{schema}, title => $title);
      $out .= &writeRCSForm(schema => $args{schema}, username => $args{username}, userid => $args{userid}, project => $args{project}, sessionID=>$args{sessionID});
      $out .= &displayRCSItemsTables(project => $projectAcronym, username => $args{username}, sessionID=>$args{sessionID});
      $out .= &displayNonCodeItemsTables(dbh => $args{dbh}, schema => $args{schema}, project => $args{project}, userID => $args{userid}, sessionID=>$args{sessionID});
   } elsif ($args{command} eq 'checkout') {
      $title = "Check Out " . uc($projectAcronym) . " Project Item";
      $out .= &writeTitleBar(userName => $args{username}, userID => $args{userid}, schema => $args{schema}, title => $title);
      my $unixid = &getUserUnixID(dbh => $args{dbh}, schema => $args{schema}, username => $args{username});
      $out .= &writeRCSForm(schema => $args{schema}, username => $args{username}, userid => $args{userid}, unixid => $unixid, sessionID=>$args{sessionID});
      $out .= &displayRCSItemCheckOutTable(username => $args{username}, project => \@project, sessionID=>$args{sessionID});
      $out .= &displayNonCodeItemCheckOutTable(dbh => $args{dbh}, schema => $args{schema}, project => $args{project}, userID => $args{userid}, sessionID=>$args{sessionID});
   }
   $out .= "</table>";
   return ($out);
}

###################################################################################################################################
sub writeBody {                                                                                                                   #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "";
   $ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
   my $path = $1;
   my $form = $2;
   my $username = $args{cgi}->param("username");
   my $userid = $args{cgi}->param("userid");
   my $schema = $args{cgi}->param("schema");
   my $command = (defined ($args{cgi}->param("command"))) ? $args{cgi}->param("command") : "";
   my $process = (defined ($args{cgi}->param("process"))) ? $args{cgi}->param("process") : "";
   my $project = $args{cgi}->param("project");
   my $sessionID = ((defined($args{cgi}->param("sessionid"))) ? $args{cgi}->param("sessionid") : "0");
   my $target = ($process) ? "main" : "cgiresults";
   $out .= "<body background=$SYSImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n<center>\n";
   $out .= "<form name=$form method=post target=$target action=$ENV{SCRIPT_NAME}>\n";
   $out .= "<input type=hidden name=username value=$username>\n";
   $out .= "<input type=hidden name=userid value=$userid>\n";
   $out .= "<input type=hidden name=schema value=$schema>\n";
   $out .= "<input type=hidden name=command value=$command>\n";
   $out .= "<input type=hidden name=process value=0>\n";
   $out .= "<input type=hidden name=sessionid value='$sessionID'>\n";
   $out .= "</form>\n";
   my $dbh = &db_connect();
   if ($SYSUseSessions eq 'T') {
       &validateCurrentSession(dbh=>$dbh, schema=>$schema, userID=>$userid, sessionID=>$sessionID);
   }
   if ($process) {
      my ($success, $message) = &processSubmittedData(dbh => $dbh, cgi => $args{cgi}, process => $process);
      $out .= &writeAlert(msg => $message) if ($message);
      $out .= "<script language=javascript>\n<!--\n $form.submit();\n//-->\n</script>\n" if ($success);
   } else {
      $out .= &processCommand(dbh => $dbh, schema => $schema, username => $username, userid => $userid, command => $command, project => $project, sessionID=>$sessionID);
   }
   &db_disconnect($dbh);

   $out .= "</center>\n</body>\n</html>\n";
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
&checkLogin(cgi => $cgi);
my $output = &writeHTTPHeader();
$output .= &writeHead();
$output .= &writeBody(cgi => $cgi);
print $output;
exit();
