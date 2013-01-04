#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/mms/perl/RCS/browse.pl,v $
#
# $Revision: 1.2 $
#
# $Date: 2002/11/25 21:09:03 $
#
# $Author: mccartym $
#
# $Locker: mccartym $
#
# $Log: browse.pl,v $
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
use SharedHeader ('$SYSImagePath');
use UIShared ('writeHTTPHeader', 'checkLogin');
use UI_Widgets ('writeTitleBar');
use DBShared ('db_connect', 'db_disconnect', 'getLookupValues');

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
            script = "project_items";
            $form.project.value = $form.select0.value;
         } else if ($form.browseoption[1].checked) {
            script = "baseline";
            $form.project.value = $form.select1.value;
         } else if ($form.browseoption[2].checked) {
            script = "scrbrowse";
            $form.project.value = $form.select2.value;
         } else if ($form.browseoption[3].checked) {
            script = "documents";
            $form.type.value = 10;
         } else if ($form.browseoption[4].checked) {
            script = "documents";
            $form.type.value = 11;
         } else if ($form.browseoption[5].checked) {
            script = "training";
         } else if ($form.browseoption[6].checked) {
            script = "meetings";
            $form.project.value = $form.select6.value;
         } else if ($form.browseoption[7].checked) {
            script = "users";
         }
         $form.action = '$path' + script + '.pl';
         $form.submit();
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
   my $out = "";
   $out .= "<body background=$SYSImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
   $out .= &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Browse");
   $out .= "<form name=$form target=main method=post>\n";
   $out .= "<input type=hidden name=username value=$username>\n";
   $out .= "<input type=hidden name=userid value=$userid>\n";
   $out .= "<input type=hidden name=schema value=$schema>\n";
   $out .= "<input type=hidden name=command value=0>\n";
   $out .= "<input type=hidden name=project value=0>\n";
   $out .= "<input type=hidden name=type value=0>\n";
   $out .= "<br><table align=center border=0 cellpadding=3 cellspacing=8 align=center>\n";
   $out .= "<tr>" . &buildNextRadioButton() . "<td><b>Project Configuration Items</b>&nbsp;&nbsp;";
   $out .= &buildProjectSelect(dbh => $args{dbh}, cgi => $args{cgi}, schema => $schema, name => $value, includeNotesProjects => 0) . "</td></tr>\n";
   $out .= "<tr>" . &buildNextRadioButton() . "<td><b>Project Software Baselines</b>&nbsp;&nbsp;";
   $out .= &buildProjectSelect(dbh => $args{dbh}, cgi => $args{cgi}, schema => $schema, name => $value, includeNotesProjects => 0) . "</td></tr>\n";
   $out .= "<tr>" . &buildNextRadioButton() . "<td><b>Software Change Requests</b>&nbsp;&nbsp;";
   $out .= &buildProjectSelect(dbh => $args{dbh}, cgi => $args{cgi}, schema => $schema, name => $value) . "</td></tr>\n";
   $out .= "<tr>" . &buildNextRadioButton() . "<td><b>Documented Procedures and Standards</b></td></tr>\n";
   $out .= "<tr>" . &buildNextRadioButton() . "<td><b>Document Templates</b></td></tr>\n";
   $out .= "<tr>" . &buildNextRadioButton() . "<td><b>Software Development Staff Training Records</b></td></tr>\n";
   $out .= "<tr>" . &buildNextRadioButton() . "<td><b>Software Configuration Control Boards</b>&nbsp;&nbsp;";
   $out .= &buildProjectSelect(dbh => $args{dbh}, cgi => $args{cgi}, schema => $schema, mustHaveSCCB => 1, name => $value) . "</td></tr>\n";
   $out .= "<tr>" . &buildNextRadioButton() . "<td><b>System Users</b></td></tr>\n";
   $out .= "</table>\n</form>\n";
   $out .= "<p align=center><input type=button name=submitForm value=Submit onClick=javascript:doBrowse()></p>\n";
   $out .= "</body>\n</html>";
   return ($out);
}

###################################################################################################################################
my $cgi = new CGI;
&checkLogin(cgi => $cgi);
my $dbh = &db_connect();
my $output = &writeHTTPHeader();
$output .= &writeHead();
$output .= &writeBody(dbh => $dbh, cgi => $cgi);
&db_disconnect($dbh);
print $output;
exit();
