#!/usr/local/bin/perl -w
#
# SCR submission form for legacy systmes
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/pcl/perl/RCS/legacy_scr.pl,v $
#
# $Revision: 1.6 $
#
# $Date: 2007/05/16 21:05:56 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: legacy_scr.pl,v $
# Revision 1.6  2007/05/16 21:05:56  atchleyb
# CREQ0018 - Removed low numbered product resctriction
#
# Revision 1.5  2003/02/12 16:34:31  atchleyb
# add session management
#
# Revision 1.4  2003/02/03 20:28:22  atchleyb
# removed refs to SCM
#
# Revision 1.3  2002/11/25 18:35:15  mccartym
# major revision - integrate standalone version into SCM system
# also added support for specifying SCR tye
#
# Revision 1.2  2002/10/22 21:28:13  mccartym
# change two references from 'scrproduct' table to 'product' table
#
# Revision 1.1  2002/09/19 03:09:39  mccartym
# Initial revision
#
#

use strict;
use integer;
use CGI;
use Tie::IxHash;
use SharedHeader ('$SYSImagePath', '$SYSUseSessions');
use UIShared ('writeHTTPHeader', 'checkLogin', 'writeAlert', 'validateCurrentSession');
use UI_Widgets ('writeTitleBar', 'errorMessage', 'formatID');
use DBShared ('db_connect', 'db_disconnect', 'logActivity');
use DB_SCR ('getIDforNewLegacySCR', 'createNewLegacySCR', 'getSCRRequestTypes', 'getSCRPriorityDescriptions');
use DBProducts ('getProductName', 'getProductNames', 'getProductProject');

###################################################################################################################################
sub processSubmittedData {                                                                                                        #
###################################################################################################################################
   my %args = (
      @_,
   );
   my ($success, $message, $activity, $project) = (0, "", "Create legacy SCR ", 0);
   my $username = $args{cgi}->param("username");
   my $userid = $args{cgi}->param("userid");
   my $schema = $args{cgi}->param("schema");
   eval {
      #############################################################################################################################
      if ($args{process} eq 'CreateSCR') {                                                                                        #
      #############################################################################################################################
         my $product = $args{cgi}->param ("product");
         my $description = $args{cgi}->param ("description");
         my $priority = $args{cgi}->param ("priority");
         my $requestType = $args{cgi}->param ("requesttype");
         my $rationale = $args{cgi}->param ("rationale");

         my $newID = &getIDforNewLegacySCR(dbh => $args{dbh}, schema => $schema, product => $product);
         $activity .= &formatID("", 5, $newID) . " ";

         $project = &getProductProject(dbh => $args{dbh}, schema => $schema, id => $product);
         my $productName = &getProductName(dbh => $args{dbh}, schema => $schema, id => $product);
         $activity .= "for $productName ";

         &createNewLegacySCR(
		    dbh => $args{dbh},
            schema => $schema,
			userid => $userid,
			product => $product,
            id => $newID,
			type => $requestType,
			priority => $priority,
			description => $description,
			rationale => $rationale
		 );
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
   my $out = "";
   $out .= "<table width=650 align=center cellpadding=10 cellspacing=10>\n";
   if ($args{command} eq 'displaySCREntryScreen') {

#exclude systems with sccb's (and application interfaces) - need to not hardcode this
#my $where = "where (id > 6) and (id <> 9)";
my $where = "";

      tie my %productNames, "Tie::IxHash";
      %productNames = %{&getProductNames(dbh => $args{dbh}, schema => $args{schema}, where => $where)};
      $out .= "<tr><td><li><b>Product:&nbsp;&nbsp;</b>\n";
      $out .= "<select name=product>\n";
      $out .= "<option value='' selected>Select Product&nbsp;\n";
      foreach my $productID (keys (%productNames)) {
         $out .= "<option value='$productID'>$productNames{$productID}\n";
      }
      $out .= "</select></td></tr>\n";

      tie my %requestTypes, "Tie::IxHash";
      %requestTypes = %{&getSCRRequestTypes(dbh => $args{dbh}, schema => $args{schema})};
      $out .= "<tr><td><li><b>Request Type:&nbsp;&nbsp;</b>\n";
      $out .= "<select name=requesttype>\n";
      $out .= "<option value='' selected>Select Request Type&nbsp;\n";
      foreach my $requestID (keys (%requestTypes)) {
         $out .= "<option value='$requestID'>$requestTypes{$requestID}\n";
      }
      $out .= "</select></td></tr>\n";
 
      tie my %priorityNames, "Tie::IxHash";
      %priorityNames = %{&getSCRPriorityDescriptions(dbh => $args{dbh}, schema => $args{schema})};
      $out .= "<tr><td><li><b>Priority:&nbsp;&nbsp;</b>\n";
      $out .= "<select name=priority>\n";
      $out .= "<option value='' selected>Select Request Priority&nbsp;\n";
      foreach my $priorityID (keys (%priorityNames)) {
         $out .= "<option value='$priorityID'>$priorityNames{$priorityID}\n";
      }
      $out .= "</select></td></tr>\n";

      $out .= "<tr><td><table border=0 cellpadding=0 cellspacing=0><tr>";
      $out .= "<td><li><b>Detailed Description of the Requested Software Change:</b></td>\n";
      $out .= "<tr><td colspan=2><textarea cols=80 rows=5 name=description></textarea></tr></table></td></tr>\n";

      $out .= "<tr><td><table border=0 cellpadding=0 cellspacing=0><tr>";
      $out .= "<td><li><b>Rationale for Request:</b></td>\n";
      $out .= "<tr><td colspan=2><textarea cols=80 rows=5 name=rationale></textarea></tr></table></td></tr>\n";

      $out .= <<end;
      <script language=javascript><!--
         function processForm() {
            var msg = "";
            if ($args{form}.product.value == "") msg += "You must enter the product for the request.\\n";
            if ($args{form}.requesttype.value == "") msg += "You must enter the tpye of request.\\n";
            if ($args{form}.priority.value == "") msg += "You must enter the priority of the request.\\n";
            if ($args{form}.description.value == "") msg += "You must enter the description of the request.\\n";
            if ($args{form}.rationale.value == "") msg += "You must enter the rationale for making the request.\\n";
            if (msg != "") {
               alert(msg);
            } else {
               $args{form}.process.value = 'CreateSCR';
               $args{form}.submit();
            }
         }
      //-->
      </script>
end
      $out .= "<tr><td align=center><input type=button value='Submit Request' onClick=javascript:processForm()></td></tr>\n";
   }
   $out .= "</table>";
   return ($out);
}

###################################################################################################################################
sub writeHead {                                                                                                                   #
###################################################################################################################################
   my $out = "";
   $out .= "<html>\n";
   $out .= "<head>\n";
   $out .= "<meta http-equiv=expires content=now>\n";
   $out .= "</head>\n\n";
   return ($out);
}

###################################################################################################################################
sub writeBody {                                                                                                                   #
###################################################################################################################################
   my %args = (
      @_,
   );
   $ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
   my $path = $1;
   my $form = $2;
   my $username = $args{cgi}->param("username");
   my $userid = $args{cgi}->param("userid");
   my $schema = $args{cgi}->param("schema");
   my $command = (defined ($args{cgi}->param("command"))) ? $args{cgi}->param("command") : "";
   my $process = (defined ($args{cgi}->param("process"))) ? $args{cgi}->param("process") : "";
   my $target = ($process) ? "main" : "cgiresults";
   my $sessionID = ((defined($args{cgi}->param("sessionid"))) ? $args{cgi}->param("sessionid") : 0);
   my $out = &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Enter SCR for Legacy System");
   $out .= "<body background=$SYSImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n<center>\n";
   $out .= "<form name=$form method=post target=$target action=$ENV{SCRIPT_NAME}>\n";
   $out .= "<input type=hidden name=username value=$username>\n";
   $out .= "<input type=hidden name=userid value=$userid>\n";
   $out .= "<input type=hidden name=schema value=$schema>\n";
   $out .= "<input type=hidden name=sessionid value=$sessionID>\n";
   $out .= "<input type=hidden name=command value=$command>\n";
   $out .= "<input type=hidden name=process value=0>\n";

   my $dbh = &db_connect();
   if ($SYSUseSessions eq 'T') {
       &validateCurrentSession(dbh=>$dbh, schema=>$schema, userID=>$userid, sessionID=>$sessionID);
   }
   if ($process) {
      my ($success, $message) = &processSubmittedData(dbh => $dbh, cgi => $args{cgi}, process => $process);
      $out .= "</form>\n";
      $out .= &writeAlert(msg => $message) if ($message);
      $out .= "<script language=javascript>\n<!--\n $form.submit();\n//-->\n</script>\n" if ($success);
   } else {
      $out .= &processCommand(dbh => $dbh, form => $form, schema => $schema, command => $command);
      $out .= "</form>\n";
   }
   &db_disconnect($dbh);

   $out .= "</center>\n</body>\n</html>\n";
   return ($out);
}

###################################################################################################################################
my $cgi = new CGI;
&checkLogin (cgi => $cgi);
my $output = &writeHTTPHeader();
$output .= &writeHead();
$output .= &writeBody(cgi => $cgi);
print $output;
exit();
