#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/pcl/perl/RCS/rcs.pl,v $
#
# $Revision: 1.5 $
#
# $Date: 2003/03/06 17:03:15 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: rcs.pl,v $
# Revision 1.5  2003/03/06 17:03:15  atchleyb
# fixed bug with session id parameter
#
# Revision 1.4  2003/02/12 16:36:17  atchleyb
# added session management
#
# Revision 1.3  2003/02/03 21:42:55  atchleyb
# removed refs to SCM
#
# Revision 1.2  2003/01/03 19:22:22  atchleyb
# updated to display code listings as pdf documents
#
# Revision 1.1  2002/11/25 21:15:35  mccartym
# Initial revision
#
#
#

use strict;
use integer;
use CGI;
use SharedHeader ('$SYSImagePath', '$SYSUseSessions');
use UIShared ('writeHTTPHeader', 'checkLogin', 'writeAlert', 'validateCurrentSession');
use UI_Widgets ('writeTitleBar');
use PDF;
use DBShared ('db_connect', 'db_disconnect', 'getLookupValues');
use RCS ('writeRCSForm', 'checkInRCSItem', 'checkOutRCSItem', 'displayRCSItemVersionsTable', 'browseRCSItem', 'browseDevFile', 'compareFiles');

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
      if ($args{process} eq 'checkin') {                                                                                          #
      #############################################################################################################################
         my %projectAcronyms = %{&getLookupValues(dbh => $args{dbh}, schema => $args{schema}, table => "project", idColumn => "id", nameColumn => "acronym")};
         my $projectAcronym = lc($projectAcronyms{$args{project}});
         my $itemType = (defined ($args{cgi}->param("itemType"))) ? $args{cgi}->param("itemType") : "";
         my $itemName = (defined ($args{cgi}->param("itemName"))) ? $args{cgi}->param("itemName") : "";
         my $unixid = (defined ($args{cgi}->param("unixid"))) ? $args{cgi}->param("unixid") : "0";
         $activity = "Check in $projectAcronym project item: $itemName ";
         my $result = &checkInRCSItem(project => $projectAcronym, itemType => $itemType, item => $itemName, username => $unixid);
      #############################################################################################################################
      } elsif ($args{process} eq 'checkout') {                                                                                    #
      #############################################################################################################################
         my %projectAcronyms = %{&getLookupValues(dbh => $args{dbh}, schema => $args{schema}, table => "project", idColumn => "id", nameColumn => "acronym")};
         my $projectAcronym = lc($projectAcronyms{$args{project}});
         my $itemType = (defined ($args{cgi}->param("itemType"))) ? $args{cgi}->param("itemType") : "";
         my $itemName = (defined ($args{cgi}->param("itemName"))) ? $args{cgi}->param("itemName") : "";
         my $unixid = (defined ($args{cgi}->param("unixid"))) ? $args{cgi}->param("unixid") : "0";
         $activity = "Check out $projectAcronym project item: $itemName ";
         my $result = &checkOutRCSItem(project => $projectAcronym, itemType => $itemType, item => $itemName, username => $unixid);
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
sub createPDF {                                                                                                              #
###################################################################################################################################
   my %args = (
      content =>'',
      @_,
   );
   my $pdf = new PDF;
   my @rows = split /\n/, $args{content};
   my $results = $pdf->generateListing(lineNumbering=>'T', addMimeHeader=>'T', text=>\@rows);
}


###################################################################################################################################
sub processCommand {                                                                                                              #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "";
   my $itemType = (defined ($args{cgi}->param("itemType"))) ? $args{cgi}->param("itemType") : "";
   my $itemName = (defined ($args{cgi}->param("itemName"))) ? $args{cgi}->param("itemName") : "";
   my $itemVersion = (defined ($args{cgi}->param("itemVersion"))) ? $args{cgi}->param("itemVersion") : "";
   my %projectAcronyms = %{&getLookupValues(dbh => $args{dbh}, schema => $args{schema}, table => "project", idColumn => "id", nameColumn => "acronym")};
   my $projectAcronym = lc($projectAcronyms{$args{project}});
   $out .= "<table width=750 align=center cellpadding=5 cellspacing=5>\n";
   $out .= &writeRCSForm(schema => $args{schema}, username => $args{username}, userid => $args{userid}, project => $args{project}, sessionID=>$args{sessionID});
   if ($args{command} eq 'browseversions') {
      $out .= &writeTitleBar(userName => $args{username}, userID => $args{userid}, schema => $args{schema}, title => "Browse Configuration Item Versions");
      $out .= &displayRCSItemVersionsTable(project => $projectAcronym, item => $itemName, type => $itemType, username => $args{username});
   } elsif ($args{command} eq 'browsefile') {
      $out = &createPDF(content => &browseRCSItem(project => $projectAcronym, item => $itemName, type => $itemType, version => $itemVersion, username => $args{username}));
      print $out;
      &db_disconnect($args{dbh});
	  exit();
   } elsif ($args{command} eq 'browsedevfile') {
      $out = &createPDF(content => &browseDevFile(project => $projectAcronym, item => $itemName, type => $itemType, username => $args{username}));
      print $out;
      &db_disconnect($args{dbh});
	  exit();
   } elsif ($args{command} eq 'comparefiles') {
      $out = &createPDF(content => &compareFiles(project => $projectAcronym, item => $itemName, type => $itemType, version => $itemVersion, username => $args{username}));
      print $out;
      &db_disconnect($args{dbh});
	  exit();
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
   my $form = $2 . "form";
   my $username = $args{cgi}->param("username");
   my $userid = $args{cgi}->param("userid");
   my $schema = $args{cgi}->param("schema");
   my $project = $args{cgi}->param("project");
   my $command = (defined ($args{cgi}->param("command"))) ? $args{cgi}->param("command") : "";
   my $process = (defined ($args{cgi}->param("process"))) ? $args{cgi}->param("process") : "";
   my $target = ($process) ? "main" : "cgiresults";
   my $sessionID = ((defined($args{cgi}->param("sessionid"))) ? $args{cgi}->param("sessionid") : 0);
   my $action = (defined ($args{cgi}->param("nextAction"))) ? $args{cgi}->param("nextAction") : $ENV{SCRIPT_NAME};
   $out .= "<body background=$SYSImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n<center>\n";
   $out .= "<form name=$form method=post target=$target action=$action>\n";
   $out .= "<input type=hidden name=username value=$username>\n";
   $out .= "<input type=hidden name=userid value=$userid>\n";
   $out .= "<input type=hidden name=schema value=$schema>\n";
   $out .= "<input type=hidden name=command value=$command>\n";
   $out .= "<input type=hidden name=process value=0>\n";
   $out .= "<input type=hidden name=sessionid value=$sessionID>\n";
   $out .= "</form>\n";

   my $dbh = &db_connect();
   if ($SYSUseSessions eq 'T') {
       &validateCurrentSession(dbh=>$dbh, schema=>$schema, userID=>$userid, sessionID=>$sessionID);
   }
   if ($process) {
      my ($success, $message) = &processSubmittedData(dbh => $dbh, cgi => $args{cgi}, process => $process, project => $project);
      $out .= &writeAlert(msg => $message) if ($message);
      if ($success) {
         $out .= "<script language=javascript>\n<!--\n $form.submit();\n//-->\n</script>\n" if ($success);
      }
   } else {
      $out .= &processCommand(dbh => $dbh, cgi => $args{cgi}, schema => $schema, username => $username, userid => $userid, command => $command, project => $project, sessionID=>$sessionID);
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
   $out .= "</head>\n\n";
   return ($out);
}

###################################################################################################################################
my $cgi = new CGI;
&checkLogin (cgi => $cgi);
my $out = &writeHTTPHeader();
$out .= &writeHead();
$out .= &writeBody(cgi => $cgi);
print $out;
exit();
