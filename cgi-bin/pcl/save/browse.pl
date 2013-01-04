#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/pcl/perl/RCS/browse.pl,v $
#
# $Revision: 1.7 $
#
# $Date: 2003/02/12 16:32:16 $
#
# $Author: atchleyb $
#
# $Locker: starkeyj $
#
# $Log: browse.pl,v $
# Revision 1.7  2003/02/12 16:32:16  atchleyb
# added session management
#
# Revision 1.6  2003/02/03 19:26:06  atchleyb
# removed refs to PCL and SCM
#  changed Templates to Forms
# changed Software Config... to just Config...
#
# Revision 1.5  2002/12/12 16:42:05  atchleyb
# reenabled browse SCCB
#
# Revision 1.4  2002/12/11 23:09:31  atchleyb
# disabled function to browse SCCB's
#
# Revision 1.3  2002/12/11 22:51:05  atchleyb
# added more major browse options and options to refine SCR browse
#
# Revision 1.2  2002/11/25 21:09:03  mccartym
# major reorganization
#
# Revision 1.1  2002/09/18 01:33:12  mccartym
# Initial revision
#
#

use strict;
use integer;
use CGI;
use Tie::IxHash;
use SharedHeader ('$SYSImagePath', '$SYSUseSessions');
use UIShared ('writeHTTPHeader', 'checkLogin', 'validateCurrentSession');
use UI_Widgets ('writeTitleBar');
use DBShared ('db_connect', 'db_disconnect', 'getLookupValues', 'isNotesProject');
use DBProject ('getProjectSCCB');

my ($path, $form) = $ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
$form .= "Form";
my $value = -1;

###################################################################################################################################
sub buildNextRadioButton {                                                                                                        #
###################################################################################################################################
   my %args = (
      @_,
   );
   $value++;
   my $checked = ($value) ? "" : " checked";
   my $out = "<td><input type=radio name=browseoption value=$value $checked onFocus='setRadio($value)'</td>\n";
   return ($out);
}

###################################################################################################################################
sub buildProjectSelect {                                                                                                          #
###################################################################################################################################
   my %args = (
      includeNotesProjects => 1,
      mustHaveSCCB => 0,
      @_,
   );
   my $out = "";
   my $name = "select$args{name}";
   my $selectedProject = (defined($args{cgi}->param ($name))) ? $args{cgi}->param ($name) : ""; 
   tie my %projectNames, "Tie::IxHash";
   %projectNames = %{&getLookupValues(dbh => $args{dbh}, schema => $args{schema}, table => 'project', idColumn => "id" , nameColumn => "name", orderBy => "name")};
   $out .= "<select name=$name onFocus='setRadio($args{name})'>\n";
   foreach my $projectID (keys (%projectNames)) {
      my $selected = ($projectID eq $selectedProject) ? " selected" : "";
      if ($args{includeNotesProjects} || !&isNotesProject(dbh => $args{dbh}, schema => $args{schema}, project => $projectID)) { 
         if (!$args{mustHaveSCCB} || &getProjectSCCB(dbh => $args{dbh}, schema => $args{schema}, id => $projectID)) {
            $out .= "<option value='$projectID'$selected>$projectNames{$projectID}\n";
         }
      }
   }
   $out .= "</select>";
   return ($out);
}

###################################################################################################################################
sub buildSelect {                                                                                                                 #
###################################################################################################################################
   my %args = (
      idColumn => "id",
      nameColumn => "name",
      orderBy => "id",
      @_,
   );
   my $out = "";
   my $name = "select$args{name}";
   tie my %items, "Tie::IxHash";
   %items = %{&getLookupValues(
      dbh => $args{dbh}, 
      schema => $args{schema},
      table => "$args{table}",
	  idColumn => "$args{idColumn}",
      nameColumn => "$args{nameColumn}",
      orderBy => "$args{orderBy}"
   )};
   $out .= "<select name=$name onFocus='setRadio($args{name})'>\n";
   foreach my $id (keys (%items)) {
      $out .= "<option value='$id'>$items{$id}\n";
   }
   $out .= "</select>";
   return ($out);
}

###################################################################################################################################
sub writeHead {                                                                                                                   #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "";
   $out .= <<end;
<html>
<head>
   <base target=main>
   <script language=javascript><!--
      function doBrowse() {
         var script = "";
         $form.command.value = 'browse';
         if ($form.browseoption[0].checked) {
            script = "artifacts";
            $form.project.value = $form.select0.value;
         } else if ($form.browseoption[1].checked) {
            script = "project_items";
            $form.project.value = $form.select1.value;
         } else if ($form.browseoption[2].checked) {
            script = "baseline";
            $form.project.value = $form.select2.value;
         } else if ($form.browseoption[3].checked) {
            script = "scrbrowse";
            $form.browseby.value = 'product';
            $form.product.value = $form.select3.value;
         } else if ($form.browseoption[4].checked) {
            script = "scrbrowse";
            $form.browseby.value = 'status';
            $form.status.value = $form.select4.value;
         } else if ($form.browseoption[5].checked) {
            script = "scrbrowse";
            $form.browseby.value = 'type';
            $form.type.value = $form.select5.value;
         } else if ($form.browseoption[6].checked) {
            script = "documents";
            $form.type.value = 10;
         } else if ($form.browseoption[7].checked) {
            script = "documents";
            $form.type.value = 11;
         } else if ($form.browseoption[8].checked) {
            script = "training";
         } else if ($form.browseoption[9].checked) {
            script = "meetings";
            //script = "blank";
            $form.project.value = $form.select9.value;
         } else if ($form.browseoption[10].checked) {
            script = "users";
         }
         $form.action = '$path' + script + '.pl';
         if (script != 'blank') {
             $form.submit();
         } else {
             alert ('Function Not Enabled');
         }
      }
      function setRadio(option) {
         $form.browseoption[option].checked = true;
      }
      //-->
   </script>
</head>
end
   return ($out);
}

###################################################################################################################################
sub writeBody {                                                                                                                   #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $username = $args{cgi}->param("username");
   my $userid = $args{cgi}->param("userid");
   my $schema = $args{cgi}->param("schema");
   my $command = defined($args{cgi}->param("command")) ? $args{cgi}->param("command") : "";
   my $sessionID = ((defined($args{cgi}->param("sessionid"))) ? $args{cgi}->param("sessionid") : 0);
   if ($SYSUseSessions eq 'T') {
       #&validateCurrentSession(dbh=>$args{dbh}, schema=>$schema, userID=>$userid, sessionID=>$sessionID);
   }
   my $out = "";
   $out .= "<body background=$SYSImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
   $out .= &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Browse");
   $out .= "<form name=$form target=main method=post>\n";
   $out .= "<input type=hidden name=username value=$username>\n";
   $out .= "<input type=hidden name=userid value=$userid>\n";
   $out .= "<input type=hidden name=schema value=$schema>\n";
   $out .= "<input type=hidden name=sessionid value='$sessionID'>\n";
   $out .= "<input type=hidden name=command value=0>\n";
   $out .= "<input type=hidden name=project value=0>\n";
   $out .= "<input type=hidden name=product value=0>\n";
   $out .= "<input type=hidden name=status value=0>\n";
   $out .= "<input type=hidden name=type value=0>\n";
   $out .= "<input type=hidden name=browseby value=0>\n";
   $out .= "<br><table align=center border=0 cellpadding=3 cellspacing=8 align=center>\n";
   $out .= "<tr>" . &buildNextRadioButton() . "<td><b>Project Artifacts</b>&nbsp;&nbsp;";
   $out .= &buildProjectSelect(dbh => $args{dbh}, cgi => $args{cgi}, schema => $schema, name => $value, includeNotesProjects => 0) . "</td></tr>\n";
   $out .= "<tr>" . &buildNextRadioButton() . "<td><b>Project Configuration Items</b>&nbsp;&nbsp;";
   $out .= &buildProjectSelect(dbh => $args{dbh}, cgi => $args{cgi}, schema => $schema, name => $value, includeNotesProjects => 0) . "</td></tr>\n";
   $out .= "<tr>" . &buildNextRadioButton() . "<td><b>Project Software Baselines</b>&nbsp;&nbsp;";
   $out .= &buildProjectSelect(dbh => $args{dbh}, cgi => $args{cgi}, schema => $schema, name => $value, includeNotesProjects => 0) . "</td></tr>\n";

   $out .= "<tr><td>&nbsp;</td><td><b>Software Change Requests</b></td></tr>";
   
   $out .= "<tr><td>&nbsp;&nbsp;" . &buildNextRadioButton() . "<b>By Product:</b>&nbsp;&nbsp;";
   $out .= &buildProjectSelect(dbh => $args{dbh}, cgi => $args{cgi}, schema => $schema, name => $value) . "</td></tr>\n";
   $out .= "<tr><td>&nbsp;&nbsp;" . &buildNextRadioButton() . "<b>By Status:</b>&nbsp;&nbsp;";
   $out .= &buildSelect(dbh => $args{dbh}, schema => $schema, name => $value, nameColumn => "description", table => "scrstatus") . "</td></tr>\n";
   $out .= "<tr><td>&nbsp;&nbsp;" . &buildNextRadioButton() . "<b>By Type:</b>&nbsp;&nbsp;";
   $out .= &buildSelect(dbh => $args{dbh}, schema => $schema, name => $value, table => "scrtype") . "</td></tr>\n";

   $out .= "<tr>" . &buildNextRadioButton() . "<td><b>Documented Procedures and Standards</b></td></tr>\n";
   $out .= "<tr>" . &buildNextRadioButton() . "<td><b>Document Forms</b></td></tr>\n";
   $out .= "<tr>" . &buildNextRadioButton() . "<td><b>Software Development Staff Training Records</b></td></tr>\n";
   $out .= "<tr>" . &buildNextRadioButton() . "<td><b>Configuration Control Boards</b>&nbsp;&nbsp;";
   $out .= &buildProjectSelect(dbh => $args{dbh}, cgi => $args{cgi}, schema => $schema, mustHaveSCCB => 1, name => $value) . "</td></tr>\n";
   $out .= "<tr>" . &buildNextRadioButton() . "<td><b>System Users</b></td></tr>\n";
   $out .= "</table>\n</form>\n";
   $out .= "<p align=center><input type=button name=submitForm value=Submit onClick=javascript:doBrowse()></p>\n";
   $out .= "</body>\n</html>";
   return ($out);
}

###################################################################################################################################
my $cgi = new CGI;
#&checkLogin(cgi => $cgi);
my $dbh = &db_connect();
my $output = &writeHTTPHeader();
$output .= &writeHead();
$output .= &writeBody(dbh => $dbh, cgi => $cgi);
&db_disconnect($dbh);
print $output;
exit();
