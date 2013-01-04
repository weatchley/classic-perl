#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/pcl/perl/RCS/RCS.pm,v $
#
# $Revision: 1.7 $
#
# $Date: 2003/02/12 18:47:43 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: RCS.pm,v $
# Revision 1.7  2003/02/12 18:47:43  atchleyb
# added session management
#
# Revision 1.6  2003/02/03 21:43:11  atchleyb
# removed refs to SCM
#
# Revision 1.5  2003/01/03 16:45:19  atchleyb
# Change date formats, change system from scm to pcl
#
# Revision 1.4  2002/11/28 00:45:04  mccartym
# unixid to full name conversion - replaced temporary hardcoded convertName() function with database call
# corrected display of multi-line unit and revision descriptions
# added code for check in/out - still in development, not implemented yet on production
# disabled production display of checked out files on home - need to improve performance before release
#
# Revision 1.3  2002/11/26 23:27:24  mccartym
# add data structure for improved handling of item types
# change script references from 'browse project' to 'rcs'
# temporarily remove initial development of check in and check out functions
#
# Revision 1.2  2002/11/19 00:15:24  mccartym
# checkpoint
#
# Revision 1.1  2002/09/15 20:50:53  mccartym
# Initial revision
#

package RCS;
use strict;
use integer;
use Exporter;
use Tie::IxHash;
use Time::Local;
use Tables;
use SharedHeader ('$SYSProductionStatus');
use DBShared ('db_connect', 'db_disconnect');
use DBUsers ('getUserFullNamebyUnixID');
use vars qw(@ISA @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT_OK = qw(
   &writeRCSForm &createRCSProject &addNewRCSItem
   &checkOutRCSItem &checkInRCSItem &updateRCSItemDescription
   &displayRCSItemsTables &displayRCSItemVersionsTable &browseRCSItem
   &compareFiles &browseDevFile &displayRCSCheckedOutItemsTable &displayRCSItemCheckOutTable
);

my $rcsBasePath = "/data/dev/rcs";
my $devBasePath = "/data/dev/cgi-bin";
my $tempBasePath = "/data/temp/pcl";

my $RLOG_END_OF_VERSION_LIST = "----------------------------";
my $RLOG_END_OF_FILE_LIST = "=============================================================================";

tie my %itemTypes, "Tie::IxHash";
%itemTypes = (
   'perl' =>       { 'description' => 'Perl Script',        'extension' => 'pl',  rcsExtension => 'pl'},
   'perlmodule' => { 'description' => 'Perl Module',        'extension' => 'pm',  rcsExtension => 'pm'},
   'plsql' =>      { 'description' => 'PL/SQL Source File', 'extension' => 'sql', rcsExtension => 'plsql'},
   'javascript' => { 'description' => 'Javascript Script',  'extension' => 'js',  rcsExtension => 'js'},
   'sql' =>        { 'description' => 'SQL Script',         'extension' => 'sql', rcsExtension => 'sql'}
);

###################################################################################################################################
sub getDevDirName { # temporary - dev cgi-bin directory for crd is 'eis', dev dir for qa is 'nqs', others same as pcl directory   #
###################################################################################################################################
   my %args = (
      @_,
   );
   my %devDirNames = (
      'crd'  => 'eis',
	  'cms'  => 'cms',
	  'dms'  => 'dms',
	  'qa'   => 'nqs',
	  'mms'  => 'mms',
	  'pcl'  => 'pcl',
      'st'   => 'st',
	  'ebs'  => 'ebs',
	  'cirs' => 'cirs'
   );
   return ($devDirNames{$args{project}});
}

###################################################################################################################################
sub writeRCSForm {                                                                                                                #
###################################################################################################################################
   my %args = (
      project => 0,
      unixid => "",
      sessionID => 0,
      @_,
   );
   my ($path, $script) = $ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
   my $out = <<end;
   <script language=javascript><!--
      function displayItemVersionsTable(itemType, itemName, project) {
         RCS.target = 'main';
         RCS.action = '$path' + 'rcs.pl';
         RCS.command.value = 'browseversions';
         if (displayItemVersionsTable.arguments.length > 2) RCS.project.value = project;
         RCS.itemType.value = itemType;
         RCS.itemName.value = itemName;
         RCS.submit();
      }
      function displayItemContents(itemType, itemName, itemVersion, newWindow, project) {
         if (!newWindow) {
            RCS.target = 'main';
         } else {
            var myDate = new Date();
            var winName = myDate.getTime();
            var w = window.open("", winName, "status=no,scrollbars=yes,toolbar=no");
            RCS.target = winName;
//            var w = window.open("http://intradev.ymp.gov/cgi-bin/pcl/mark_temp.pl?command=frameset", winName, "status=no,scrollbars=yes,toolbar=no");
//            w.creator = self;
//            RCS.target = w.frames[0];
         }
         RCS.action = '$path' + 'rcs.pl';
         RCS.command.value = 'browsefile';
         if (displayItemContents.arguments.length > 4) RCS.project.value = project;
         RCS.itemType.value = itemType;
         RCS.itemName.value = itemName;
         RCS.itemVersion.value = itemVersion;
         RCS.submit();
      }
      function displayDevFileContents(itemType, itemName, newWindow, project) {
         if (!newWindow) {
            RCS.target = 'main';
         } else {
            var myDate = new Date();
            var winName = myDate.getTime();
            var w = window.open("", winName, "status=no,scrollbars=yes,toolbar=no");
            RCS.target = winName;
         }
         RCS.action = '$path' + 'rcs.pl';
         RCS.command.value = 'browsedevfile';
         RCS.project.value = project;
         RCS.itemType.value = itemType;
         RCS.itemName.value = itemName;
         RCS.submit();
      }
      function compareFiles(itemType, itemName, itemVersion, newWindow, project) {
         if (!newWindow) {
            RCS.target = 'main';
         } else {
            var myDate = new Date();
            var winName = myDate.getTime();
            var w = window.open("", winName, "status=no,scrollbars=yes,toolbar=no");
            RCS.target = winName;
         }
         RCS.action = '$path' + 'rcs.pl';
         RCS.command.value = 'comparefiles';
         RCS.project.value = project;
         RCS.itemType.value = itemType;
         RCS.itemName.value = itemName;
         RCS.itemVersion.value = itemVersion;
         RCS.submit();
      }
      function checkIn(itemType, itemName, project, nextaction) {
         RCS.target = 'cgiresults';
         RCS.action = '$path' + 'rcs.pl';
         RCS.nextaction.value = '$path' + nextaction + '.pl';
         RCS.command.value = 'checkin';
         RCS.project.value = project;
         RCS.itemType.value = itemType;
         RCS.itemName.value = itemName;
         RCS.submit();
      }
      function checkOut(itemType, itemName, project, nextaction) {
         RCS.target = 'cgiresults';
         RCS.action = '$path' + 'rcs.pl';
         RCS.nextaction.value = '$path' + nextaction + '.pl';
         RCS.command.value = 'checkout';
         RCS.project.value = project;
         RCS.itemType.value = itemType;
         RCS.itemName.value = itemName;
         RCS.submit();
      }
      function displayUserByUnixID(id) {
         RCStemp.action = '$path' + 'users' + '.pl';
         RCStemp.target = 'main';
         RCStemp.id.value = id;
         RCStemp.command.value = 'displayuser_by_unixid';
         RCStemp.submit();
      }
   //-->
   </script>
   <form name=RCS method=post>
      <input type=hidden name=schema value=$args{schema}>
      <input type=hidden name=username value=$args{username}>
      <input type=hidden name=userid value=$args{userid}>
      <input type=hidden name=unixid value=$args{unixid}>
      <input type=hidden name=project value=$args{project}>
      <input type=hidden name=command value=0>
      <input type=hidden name=nextaction value=0>
      <input type=hidden name=itemName value=0>
      <input type=hidden name=itemType value=0>
      <input type=hidden name=itemVersion value=0>
      <input type=hidden name=sessionid value='$args{sessionID}'>
   </form>
   <form name=RCStemp method=post>
      <input type=hidden name=schema value=$args{schema}>
      <input type=hidden name=username value=$args{username}>
      <input type=hidden name=userid value=$args{userid}>
      <input type=hidden name=unixid value=$args{unixid}>
      <input type=hidden name=command value=0>
      <input type=hidden name=id value=0>
      <input type=hidden name=sessionid value='$args{sessionID}'>
   </form>
end
   return ($out);
}

###################################################################################################################################
sub getTempName {                                                                                                                 #
###################################################################################################################################
   my %args = (
      username => "nouser",
      suffix => "",
      @_,
   );
   my ($sec, $min, $hour, $day, $month, $year) = (localtime)[0,1,2,3,4,5];
   my $out = "$tempBasePath/";
   $out .= sprintf("%04d", $year + 1900);
   $out .= sprintf("%02d", $month + 1);
   $out .= sprintf("%02d", $day);
   $out .= sprintf("%02d", $hour);
   $out .= sprintf("%02d", $min);
   $out .= sprintf("%02d", $sec);
   $out .= $args{username};
   $out .= $args{suffix};
   return ($out);
}

###################################################################################################################################
sub runCommand {                                                                                                                  #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $command = "/data/dev/cgi-bin/pcl/rcsCommand.pl ";
   $command .= "--command=\"$args{command}\" ";
   $command .= "--options=\"$args{options}\" " if ($args{options});
   $command .= "--file=\"$args{file}\" " if ($args{file});
   $command .= "--file1=\"$args{file1}\" " if ($args{file1});
   $command .= "--file2=\"$args{file2}\" " if ($args{file2});
   $command .= "--from=\"$args{from}\" " if ($args{from});
   $command .= "--to=\"$args{to}\" " if ($args{to});
#print STDERR "***$command***\n";
   if (open (FH, "$command |")) {
      my $a = <FH>;
#      print STDERR "return***$a***from ***$command***\n";
      close (FH);
   }
   return();
}

###################################################################################################################################
sub createRCSProject {                                                                                                            #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "";
   return($out);
}

###################################################################################################################################
sub addNewRCSItem {                                                                                                               #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "";
   return($out);
}

###################################################################################################################################
sub checkOutRCSItem {                                                                                                             #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "";
   my $devFile = "";
   my $itemName = "$args{item}.$itemTypes{$args{type}}{'extension'}";
   my $rcsFile = "$rcsBasePath/$args{project}/$args{itemType}/RCS/$itemName,v";
   my $tempFile = "$rcsBasePath/$args{project}/$args{itemType}/RCS/$args{username}temp.pl";

#  need owner,group read/write permission 775 - also setgid attributes 2xxx where needed

   my $rcsWorkingFile = "$rcsBasePath/$args{project}/$args{itemType}/$itemName";

   &runCommand(command => "co", options => "-l", file => $rcsWorkingFile);
   if ($args{itemType} eq 'perl') {
      my $devDirName = &getDevDirName(project => $args{project});
      $devFile = "$devBasePath/$devDirName/itemName";
   } else {
      $devFile = "$rcsBasePath/$args{project}/$args{itemType}/edit/$itemName";
   }

   &runCommand(command => "editfile", options => "/Locker/s/nobody/$args{username}/", file => $rcsWorkingFile, to => $devFile);
   &runCommand(command => "deletefile", file => $rcsWorkingFile);

   if ($args{itemType} ne 'perl') {
      &runCommand(command => "setfilepermissions", options => "775", file => $devFile);
   }

   &runCommand(command => "editfile", options => "/strict/s/nobody/$args{username}/", file => $rcsFile, to => $tempFile);
   &runCommand(command => "deletefile", file => $rcsFile);
   &runCommand(command => "renamefile", from => $tempFile, to => $rcsFile);

# need to make this safer - could delete rcs file even if edit results file create failed
# use an scmsystem/RCS subdirectory for use by 'nobody' under the regular RCS directory?

   return($out);
}

###################################################################################################################################
sub checkInRCSItem {                                                                                                              #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "";
   my $devFile = "";
   my $itemName = "$args{item}.$itemTypes{$args{type}}{'extension'}";

#  need owner,group read/write permission 775 - also setgid attributes 2xxx where needed

#  capture log entry - disallow '~' character in msg
   my $msg = "this is a test message!";

   if ($args{itemType} eq 'perl') {
      my $devDirName = &getDevDirName(project => $args{project});
      $devFile = "$devBasePath/$devDirName/$itemName";
   } else {
      $devFile = "$rcsBasePath/$args{project}/$args{itemType}/edit/$itemName";
   }
   my $rcsWorkingFile = "$rcsBasePath/$args{project}/$args{itemType}/$itemName";
   my $rcsFile = "$rcsBasePath/$args{project}/$args{itemType}/RCS/$itemName,v";
   my $tempFile = "$rcsBasePath/$args{project}/$args{itemType}/RCS/$args{username}temp.pl";

   &runCommand(command => "editfile", options => "/Locker/s/$args{username}/nobody/", file => $devFile, to => $rcsWorkingFile);
   &runCommand(command => "editfile", options => "/strict/s/$args{username}/nobody/", file => $rcsFile, to => $tempFile);
   &runCommand(command => "deletefile", file => $rcsFile);
   &runCommand(command => "renamefile", from => $tempFile, to => $rcsFile);
   &runCommand(command => "ci", options => "-m'$msg'", file => $rcsWorkingFile);
   &runCommand(command => "editfile", options => "/author/s/nobody/$args{username}/", file => $rcsFile, to => $tempFile);
   &runCommand(command => "deletefile", file => $rcsFile);
   &runCommand(command => "renamefile", from => $tempFile, to => $rcsFile);
   if ($args{itemType} eq 'perl') {
      &runCommand(command => "co", options => "-p", file => $rcsFile, to => $devFile);
   } else {
      &runCommand(command => "deletefile", file => $devFile);
   }
   return($out);
}

###################################################################################################################################
sub updateRCSItemDescription {                                                                                                    #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "";
   return($out);
}

###################################################################################################################################
sub formatDateTime {                                                                                                              #
###################################################################################################################################
   my %args = (
      convertToLocalTime => 1,     # display local time after converting from GMT time if argument is non-zero
      time24 => 0,                 # display 24 hour times if argument is non-zero
      displaySeconds => 0,         # display the seconds portion of the time if argument is non-zero
      hoursLeadingZeros => 0,      # display leading zero for hours 1 through 9 if argument is non-zero
      dateFormat => "DD-MON-YY",   # display date as MM/DD/YY if other than the default is passed
      yearDigits => 2,             # display only two year digits by default, four otherwise
      @_,
   );
   my @months = ('JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC');
   my $out = "";
   $args{inputString} =~ /(\d+)\/(\d+)\/(\d+) (\d+):(\d+):(\d+)/;
   my ($sec, $min, $hour, $day, $month, $year) = ($6 - 0, $5 - 0, $4 - 0, $3 - 0, $2 - 1, $1 - 0);
   if ($args{convertToLocalTime}) {
      ($sec, $min, $hour, $day, $month, $year) = (localtime(timegm($sec, $min, $hour, $day, $month, $year - 1900)))[0,1,2,3,4,5];
      $year += 1900;
   }
   $year = substr($year, 2, 2) if ($args{yearDigits} == 2);
   $out .= ($args{dateFormat} eq "DD-MON-YY") ? sprintf("%02d", $day) : sprintf("%02d", $month + 1);
   $out .= ($args{dateFormat} eq "DD-MON-YY") ? "-" : "/";
   $out .= ($args{dateFormat} eq "DD-MON-YY") ? $months[$month] : sprintf("%02d", $day);
   $out .= ($args{dateFormat} eq "DD-MON-YY") ? "-" : "/";
   $out .= sprintf("%0$args{yearDigits}d", $year);
   $out .= "&nbsp;&nbsp;";
   my $ampm = ($hour < 12) ? "AM" : "PM";
   if (!$args{time24}) {
      if ($hour == 0) {
         $hour = 12;
      } elsif ($hour > 12) {
	     $hour -= 12;
      }
   }
   $out .= ($args{hoursLeadingZeros}) ? sprintf("%02d", $hour) : $hour;
   $out .= ":" . sprintf("%02d", $min);
   $out .= ":" . sprintf("%02d", $sec) if $args{displaySeconds};      
   $out .= "&nbsp;" . $ampm if (!$args{time24});
   return($out);
}

###################################################################################################################################
sub displayRCSItemsTables {                                                                                                       #
###################################################################################################################################
   my %args = (
      username => 'nouser',
      @_,
   );
   my @a = ();
   $ENV{PATH} = '';
   my $out2 = "<br>";
   my $dbh = &db_connect();
   foreach my $itemType (keys (%itemTypes)) {
      my $out = "";
      my $type = ($itemType eq 'perlmodule') ? "perl" : $itemType;
	  my $rcsFile = "$rcsBasePath/$args{project}/$type/RCS/*.$itemTypes{$itemType}{'extension'},v";
      my $tempFile = &getTempName(username => $args{username});
      &runCommand(command => "rlog", file => $rcsFile, to => $tempFile);
      if (open (FH, $tempFile)) {
         @a = <FH>;
         close (FH);
      }
      my $numColumns = 6;
      $out .= &startTable(columns => $numColumns, title => "$itemTypes{$itemType}{'description'}s (xxx)", width => 750);
      $out .= &startRow (bgColor => "#f0f0f0");
      $out .= &addCol (value => "Name", align => "center", width => 100);
      $out .= &addCol (value => "Current Version", align => "center", width => 40);
      $out .= &addCol (value => "Status", align => "center", width => 100);
      $out .= &addCol (value => "Created / Last Revised", align => "center", width => 260);
      $out .= &addCol (value => "Description", align => "center", width => 250);
      $out .= &endRow();
      $out .= &addSpacerRow (columns => $numColumns);
      my ($name, $version, $desc, $status, $isDesc, $isLocks, $count) = ("", "", "", "Checked in", 0, 0, 0);
	  my ($createDate, $creator, $creatorName, $reviseDate, $reviser, $reviserName) = ("", "", "", "", "", "");
      foreach my $row (@a) {
         chomp($row);
         if ($row =~ /^Working file: (.*)\./) {
            $name = $1;
         } elsif ($row =~ /^head: (\d+\.\d+)$/) {
            $version = $1;
         } elsif ($row =~ /^date: (.*);  author: (.*);  state/) {
            $createDate = $1;
            $creator = $2;
            $creatorName = &getUserFullNamebyUnixID(dbh => $dbh, unixid => $2);
            $createDate = &formatDateTime(inputString => $createDate);
            if (!$reviser) {
              $reviser = $creator;
              $reviserName = $creatorName;
              $reviseDate = $createDate;
			}
         } elsif ($row =~ /^locks:/) {
            $isLocks = 1;
         } elsif ($row =~ /^access list:/) {
            $isLocks = 0;
         } elsif ($isLocks && ($row =~ /^\s*(.*):/)) {
            my $locker = $1;
            my $lockerName = &getUserFullNamebyUnixID(dbh => $dbh, unixid => $1);
            $status = "Checked out by<br>";
            $status .= &makeLink(value => $lockerName, url => "javascript:displayUserByUnixID('$locker')", prompt => "Click here to browse user information for $lockerName");
         } elsif ($row =~ /^description:/) {
	        $isDesc = 1;
         } elsif ($isDesc && ($row ne $RLOG_END_OF_VERSION_LIST)) {
            $desc .= "<br>" if ($desc);
            $desc .= $row;
         } elsif ($row eq $RLOG_END_OF_VERSION_LIST) {
	        $isDesc = 0;
         } elsif ($row eq $RLOG_END_OF_FILE_LIST) {
            $desc = "&nbsp;" if (!$desc);
            $desc =~ s/'/&quot;/g;
            $out .= &startRow();
            my $url = "javascript:displayItemVersionsTable('$itemType','$name')";
            $out .= &addCol (value => $name, url => $url, prompt => "Click here for complete version history of $name");
            $out .= &addCol (value => $version, align => "center", url => "javascript:displayItemContents('$itemType','$name','$version',1)", prompt => "Click here to browse version $version of $name");
            $out .= &addCol (value => $status, align => "center");
            my $creatorNameLink .= &makeLink(value => $creatorName, url => "javascript:displayUserByUnixID('$creator')", prompt => "Click here to browse user information for $creatorName");
            my $reviserNameLink .= &makeLink(value => $reviserName, url => "javascript:displayUserByUnixID('$reviser')", prompt => "Click here to browse user information for $reviserName");
            my $value = "C:&nbsp;&nbsp;&nbsp;$createDate&nbsp;&nbsp;by&nbsp;&nbsp;$creatorNameLink";
			$value .= "<br>R:&nbsp;&nbsp;&nbsp;$reviseDate&nbsp;&nbsp;by&nbsp;&nbsp;$reviserNameLink" if ($reviseDate ne $createDate);
            $out .= &addCol (value => $value);
            $out .= &addCol (value => $desc);
            $out .= &endRow();
            ($name, $version, $desc, $status) = ("", "", "", "Checked in");
			($createDate, $creator, $creatorName, $reviseDate, $reviser, $reviserName) = ("", "", "", "", "", "");
            $count++;
         }
      }
      $out .= &endTable();
      $out =~ s/xxx/$count/;
      if ($count) {
         $out .= "<br><br>";
      } else {
         $out = "";
      }
      $out2 .= $out;
      &runCommand(command => "deletefile", file => $tempFile);
   }
   &db_disconnect($dbh);
   return($out2);
}

###################################################################################################################################
sub displayRCSItemVersionsTable {                                                                                                 #
###################################################################################################################################
   my %args = (
      @_,
   );
   my @a = ();
   my $out = "<br>";
   my $itemName = "$args{item}.$itemTypes{$args{type}}{'extension'}";
   my $type = ($args{type} eq 'perlmodule') ? "perl" : $args{type};
   my $rcsCommand = "rlog";
   my $rcsFile = "$rcsBasePath/$args{project}/$type/RCS/$itemName,v";
   my $tempFile = &getTempName(username => $args{username});
   &runCommand(command => $rcsCommand, file => $rcsFile, to => $tempFile);
   if (open (FH, $tempFile)) {
      @a = <FH>;
      close (FH);
   }
   my $numColumns = 4;
   $out .= &startTable(columns => $numColumns, title => "Configuration Item Version History for (nnn) (xxx)", width => 750);
   my ($name, $fileDesc, $status, $version, $desc, $date, $creator, $creatorName) = ("", "Description:&nbsp;&nbsp;", "Status:&nbsp;&nbsp;Checked in", "", "", "", "", "");
   my ($isDesc, $isFileDesc, $isLocks, $foundFirst, $count) = (0, 0, 0, 0, 0);
   my $dbh = &db_connect();
   foreach my $row (@a) {
      chomp($row);
      if ($row =~ /^Working file: (.*)\./) {
	     $name = $1;
      } elsif ($row =~ /^description:/) {
	     $isFileDesc = 1;
      } elsif ($isFileDesc && ($row ne $RLOG_END_OF_VERSION_LIST)) {
         $fileDesc .= $row;
      } elsif ($row =~ /^locks:/) {
	     $isLocks = 1;
      } elsif ($row =~ /^access list:/) {
         $isLocks = 0;
      } elsif ($isLocks && ($row =~ /^\s*(.*):/)) {
         my $locker = $1;
         my $lockerName = &getUserFullNamebyUnixID(dbh => $dbh, unixid => $1);
	     $status = "Status:&nbsp;&nbsp;Checked out by ";
		 $status .= &makeLink(value => $lockerName, url => "javascript:displayUserByUnixID('$locker')", prompt => "Click here to browse user information for $lockerName");
      } elsif ($row =~ /revision (\d+\.\d+)/) {    # also get locker on this row
         $version = $1;
         $foundFirst = 1;
      } elsif ($row =~ /^date: (.*);  author: (.*);  state/) {
	     $date = $1;
         $creator = $2;
         $creatorName = &getUserFullNamebyUnixID(dbh => $dbh, unixid => $2);
         $date = &formatDateTime(inputString => $date);
	     $isDesc = 1;
      } elsif ($isDesc && ($row ne $RLOG_END_OF_VERSION_LIST) && ($row ne $RLOG_END_OF_FILE_LIST)) {
         $desc .= "<br>" if ($desc);
         $desc .= $row;
      } elsif (($row eq $RLOG_END_OF_VERSION_LIST) || ($row eq $RLOG_END_OF_FILE_LIST)) {
	     if ($isFileDesc) {
		    $isFileDesc = 0;
            $out .= &startRow(bgColor => "#f0f0f0");
            my $value = "Project:&nbsp;&nbsp;" . uc($args{project});
            $out .= &addCol (colspan => $numColumns, value => $value);
            $out .= &endRow();
            $out .= &startRow(bgColor => "#f0f0f0");
            $out .= &addCol (colspan => $numColumns, value => $fileDesc);
            $out .= &endRow();
            $out .= &startRow(bgColor => "#f0f0f0");
            $out .= &addCol (colspan => $numColumns, value => $status);
            $out .= &endRow();
            $out .= &addSpacerRow (columns => $numColumns);
         }
         if ($foundFirst) {
            if (!$count) {
               $out .= &startRow (bgColor => "#f0f0f0");
               $out .= &addCol (value => "Version", align => "center", width => 40);
               $out .= &addCol (value => "Date Revised", align => "center", width => 125);
               $out .= &addCol (value => "Revised By", align => "center", width => 110);
               $out .= &addCol (value => "Revision Description", align => "center", width => 475);
               $out .= &endRow();
               $out .= &addSpacerRow (columns => $numColumns);
            }
            $isDesc = 0;
            $desc = "&nbsp;" if (!$desc);
            $desc =~ s/'/&quot;/g;
            $out .= &startRow();
            $out .= &addCol (value => $version, align => "center", url => "javascript:displayItemContents('$args{type}','$name','$version',1)", prompt => "Click here to browse version $version of $name");
			$out .= &addCol (value => $date);
            $out .= &addCol (value => $creatorName, align => "center", url => "javascript:displayUserByUnixID('$creator')", prompt => "Click here to browse user information for $creatorName");
            $out .= &addCol (value => $desc);
            $out .= &endRow();
            ($version, $desc, $date, $creator, $creatorName) = ("", "", "", "", "");
            $count++;
         }
	  }
   }
   &db_disconnect($dbh);
   $out .= &endTable();
   $out =~ s/\(nnn\)/$name/;
   $out =~ s/\(xxx\)/($count)/;
   if ($count) {
      $out .= "<br><br>";
   } else {
      $out = "";
   }
   &runCommand(command => "deletefile", file => $tempFile);
   return($out);
}

###################################################################################################################################
sub browseRCSItem {                                                                                                               #
###################################################################################################################################
   my %args = (
      @_,
   );
   my @a = ();
   my $out = "";
   my $itemName = "$args{item}.$itemTypes{$args{type}}{'extension'}";
   my $type = ($args{type} eq 'perlmodule') ? "perl" : $args{type};
   my $rcsFile = "$rcsBasePath/$args{project}/$type/RCS/$itemName,v";
   my $tempFile = &getTempName(username => $args{username});
   &runCommand(command => "co", options => "-p -r$args{version}", file => $rcsFile, to => $tempFile);
   if (open (FH, $tempFile)) {
      @a = <FH>;
      close (FH);
   }
   foreach my $row (@a) {
      $out .= $row;
   }
   &runCommand(command => "deletefile", file => $tempFile);
   return ($out);
}

###################################################################################################################################
sub browseDevFile {                                                                                                               #
###################################################################################################################################
   my %args = (
      @_,
   );
   my @a = ();
   my $out = "";
   my $itemName = "$args{item}.$itemTypes{$args{type}}{'extension'}";
   my $devDirName = &getDevDirName(project => $args{project});
   my $devFile = "$devBasePath/$devDirName/$itemName";
   my $tempFile = &getTempName(username => $args{username});
   &runCommand(command => "copyfile", from => $devFile, to => $tempFile);
   if (open (FH, $tempFile)) {
      @a = <FH>;
      close (FH);
   }
   foreach my $row (@a) {
      $out .= $row;
   }
   &runCommand(command => "deletefile", file => $tempFile);
   return ($out);
}

###################################################################################################################################
sub compareFiles {                                                                                                                #
###################################################################################################################################
   my %args = (
      @_,
   );
   my @a = ();
   my $out = "";
   my $itemName = "$args{item}.$itemTypes{$args{type}}{'extension'}";
   my $type = ($args{type} eq 'perlmodule') ? "perl" : $args{type};

   my $rcsFile = "$rcsBasePath/$args{project}/$type/RCS/$itemName,v";
   my $tempFile1 = &getTempName(username => $args{username}, suffix => "A");
   &runCommand(command => "co", options => "-p -r$args{version}", file => $rcsFile, to => $tempFile1);

   my $devDirName = &getDevDirName(project => $args{project});
   my $devFile = "$devBasePath/$devDirName/$itemName";
   my $tempFile2 = &getTempName(username => $args{username}, suffix => "B");
   &runCommand(command => "copyfile", from => $devFile, to => $tempFile2);

   my $tempFile3 = &getTempName(username => $args{username}, suffix => "C");
   &runCommand(command => "comparefiles", file1 => $tempFile1, file2 => $tempFile2, to => $tempFile3);
   if (open (FH, $tempFile3)) {
      @a = <FH>;
      close (FH);
   }
   foreach my $row (@a) {
      $out .= $row;
   }
   &runCommand(command => "deletefile", file => $tempFile1);
   &runCommand(command => "deletefile", file => $tempFile2);
   &runCommand(command => "deletefile", file => $tempFile3);
   return ($out);
}

###################################################################################################################################
sub displayRCSCheckedOutItemsTable {                                                                                              #
###################################################################################################################################
   my %args = (
      project => "",
      title => "",
      @_,
   );

   my $out = "";
   if ($args{unixid}) {

      # if project argument is not null, it is a array reference - get ID and acronym from the array
      # otherwise, display checked out items from all projects
      my ($project, $projectAcronym) = ($args{project}) ? @{$args{project}} : (0, "All");

      tie my %projects, "Tie::IxHash";
      if ($project) {
         %projects = ($project => $projectAcronym);
         $projectAcronym = uc($projectAcronym);
      } else {
         #temp, need to determine projects with rcs code from pcl db (or rcs?)
         %projects = (1 => 'crd', 2 => 'cms', 3 => 'dms', 4 => 'qa', 5 => 'mms', 6 => 'pcl', 7 => 'ebs', 23 => 'cirs', 27 => 'st');
      }

      $ENV{PATH} = '';
      my @a = ();
      my $count = 0;
      my $numColumns = 7;
      my $formatUser = "<font size=-1>" . $args{username} . "</font>";
      my $user = lc($args{username});
      my $title = ($args{title}) ? $args{title} : "$projectAcronym Code Items Checked Out by User $formatUser";
if (!$SYSProductionStatus) {
   $title .= " (xxx)";
} else {
   $title .= " - Under Development"
}
      $out .= &startTable(columns => $numColumns, title => $title, width => 750);
      $out .= &startRow (bgColor => "#f0f0f0");
      $out .= &addCol (value => "Project", align => "center");
      $out .= &addCol (value => "Item Name", align => "center");
      $out .= &addCol (value => "Item Type", align => "center");
      $out .= &addCol (value => "Versions", align => "center");
      $out .= &addCol (value => "Changes", align => "center");
      $out .= &addCol (value => "Reason", align => "center");
      $out .= &addCol (value => "Check In", align => "center");
      $out .= &endRow();
      $out .= &addSpacerRow (columns => $numColumns);
if (!$SYSProductionStatus) {
      foreach my $project (keys (%projects)) {
         foreach my $itemType (keys (%itemTypes)) {
            my $type = ($itemType eq 'perlmodule') ? "perl" : $itemType;
		    my $rcsFile = "$rcsBasePath/$projects{$project}/$type/RCS/*.$itemTypes{$itemType}{'extension'},v";
            my $tempFile = &getTempName(username => $args{username});
            &runCommand(command => "rlog", options => "-L -l$args{unixid}", file => $rcsFile, to => $tempFile);
            if (open (FH, $tempFile)) {
               @a = <FH>;
               close (FH);
            }
            my ($name, $version, $nextVersion, $isLocks) = ("", "", "", 0);
            foreach my $row (@a) {
               chomp($row);
               if ($row =~ /^Working file: (.*)\./) {
                  $name = $1;
               } elsif ($row =~ /^head: (\d+\.)(\d+)$/) {
                  $version = $1 . $2;
                  $nextVersion = $1 . ($2 + 1);
               } elsif ($row =~ /^locks:/) {
                  $isLocks = 1;
               } elsif ($row =~ /^access list:/) {
                  $isLocks = 0;
               } elsif ($isLocks && ($row =~ /^\s*(.*):/)) {
                  my $locker = $1;
                  $out .= &startRow();
                  my $url = "javascript:displayItemVersionsTable('$itemType','$name','$project')";
                  $out .= &addCol (value => uc($projects{$project}));
                  $out .= &addCol (value => $name, url => $url, prompt => "Click here for complete version history of $name");
                  $out .= &addCol (value => $itemTypes{$itemType}{'description'});

                  my $prompt = "Click here to browse the most recent checked-in version ($version) of $name";
                  $url = "javascript:displayItemContents('$itemType','$name','$version',1,'$project')";
                  my $value = &makeLink(value => $version, url => $url, prompt => $prompt);
                  $value .= "&nbsp&nbsp;&nbsp;" . "=>" . "&nbsp&nbsp;";

                  if (($itemType ne 'perl') && ($itemType ne 'perlmodule')) {
                     $value .= $nextVersion;
                  } else {
                     $prompt = "Click here to browse the edits (target version $nextVersion) to $name version $version";
                     $url = "javascript:displayDevFileContents('$itemType','$name',1,'$project')";
                     $value .= &makeLink(value => $nextVersion, url => $url, prompt => $prompt);
                  }
                  $out .= &addCol (value => $value, align => "center");

                  if (($itemType ne 'perl') && ($itemType ne 'perlmodule')) {
                     $value = "&nbsp;";
                  } else {
                     $prompt = "Click here to browse the differences between version $version and target version $nextVersion of $name";
                     $url = "javascript:compareFiles('$itemType','$name','$version',1,'$project')";
                     $value = &makeLink(value => "Changes", url => $url, prompt => $prompt);
                  }
                  $out .= &addCol (value => $value, align => "center");

                  $out .= &addCol (value => "The reason", align => "center");

                  $url = "javascript:checkIn('$type','$name','$project','home')";
                  $out .= &addCol (value => "Check In", align => "center", url => $url, prompt => "Click here to check in $name");
                  $out .= &endRow();
                  $count++;
               }
            }
            &runCommand(command => "deletefile", file => $tempFile);
         }
      }
}
      $out .= &endTable();
if ($SYSProductionStatus) {
   $out .= "<br><br>";
} else {
      $out =~ s/\(xxx\)/($count)/;
      if ($count) {
         $out .= "<br><br>";
      } else {
         $out = "";
      }
}
   }
   return($out);
}

###################################################################################################################################
sub displayRCSItemCheckOutTable {                                                                                              #
###################################################################################################################################
   my %args = (
      title => "",
      @_,
   );
   $ENV{PATH} = '';
   my @a = ();
   my ($project, $projectAcronym) = @{$args{project}};
   my $out = "";
   my $count = 0;
   my $numColumns = 6;
   my $title = ($args{title}) ? $args{title} : uc($projectAcronym) . " Code Items Available for Check Out";
   $title .= " (xxx)";
   $out .= &startTable(columns => $numColumns, title => $title, width => 750);
   $out .= &startRow (bgColor => "#f0f0f0");
   $out .= &addCol (value => "Item Name", align => "center", width => 100);
   $out .= &addCol (value => "Item Type", align => "center", width => 75);
   $out .= &addCol (value => "Current Version", align => "center", width => 40);
   $out .= &addCol (value => "Last Revised", align => "center", width => 135);
   $out .= &addCol (value => "Description", align => "center", width => 340);
   $out .= &addCol (value => "Check Out", align => "center", width => 60);
   $out .= &endRow();
   $out .= &addSpacerRow (columns => $numColumns);
   foreach my $itemType (keys (%itemTypes)) {
      my $type = ($itemType eq 'perlmodule') ? "perl" : $itemType;
      my $rcsFile = "$rcsBasePath/$projectAcronym/$type/RCS/*.$itemTypes{$itemType}{'extension'},v";
      my $tempFile = &getTempName(username => $args{username});
      &runCommand(command => "rlog", file => $rcsFile, to => $tempFile);
      if (open (FH, $tempFile)) {
         @a = <FH>;
         close (FH);
      }
      my ($name, $version, $desc, $date, $isDesc, $isLocks, $isLocked, $foundDate) = ("", "", "", "", 0, 0, 0, 0);
      foreach my $row (@a) {
         chomp($row);
         if ($row =~ /^Working file: (.*)\./) {
            $name = $1;
         } elsif ($row =~ /^head: (\d+\.\d+)$/) {
            $version = $1;
         } elsif (!$foundDate && ($row =~ /^date: (.*);  author: .*;  state/)) {
            $date = $1;
            $date = &formatDateTime(inputString => $date);
            $foundDate = 1;
         } elsif ($row =~ /^locks:/) {
            $isLocks = 1;
         } elsif ($row =~ /^access list:/) {
            $isLocks = 0;
         } elsif ($isLocks && ($row =~ /^\s*(.*):/)) {
            $isLocked = 1;
         } elsif ($row =~ /^description:/) {
            $isDesc = 1;
         } elsif ($isDesc && ($row ne $RLOG_END_OF_VERSION_LIST) && ($row ne $RLOG_END_OF_FILE_LIST)) {
            $desc .= "<br>" if ($desc);
            $desc .= $row;
         } elsif ($row eq $RLOG_END_OF_VERSION_LIST) {
	        $isDesc = 0;
         } elsif ($row eq $RLOG_END_OF_FILE_LIST) {
            if (!$isLocked) {
               $desc = "&nbsp;" if (!$desc);
               $desc =~ s/'/&quot;/g;            
               $out .= &startRow();
               my $url = "javascript:displayItemVersionsTable('$itemType','$name','$project')";
               $out .= &addCol (value => $name, url => $url, prompt => "Click here for complete version history of $name");
               $out .= &addCol (value => $itemTypes{$itemType}{'description'});
               $out .= &addCol (value => $version, align => "center", url => "javascript:displayItemContents('$itemType','$name','$version',1,'$project')", prompt => "Click here to browse version $version of $name");
               $out .= &addCol (value => $date);
               $out .= &addCol (value => $desc);
               $url = "javascript:checkOut('$type','$name','$project','home')";
               $out .= &addCol (value => "Check Out", align => "center", url => $url, prompt => "Click here to check out $name for editing");
               $out .= &endRow();
               $count++;
            }
            ($name, $version, $desc, $date, $isDesc, $isLocks, $isLocked, $foundDate) = ("", "", "", "", 0, 0, 0, 0);
         }
      }
      &runCommand(command => "deletefile", file => $tempFile);
   }
   $out .= &endTable();
   $out =~ s/\(xxx\)/($count)/;
   if ($count) {
      $out .= "<br><br>";
   } else {
      $out = "";
   }
   return($out);
}

1;