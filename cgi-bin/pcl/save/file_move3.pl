#!/usr/local/bin/perl -w
#
# $Source$
#
# $Revision$
#
# $Date$
#
# $Author$
#
# $Locker$
#
# $Log$
#
#
use SCM_Header qw(:Constants);
use DB_scm qw(:Functions);
use UI_Widgets qw(:Functions);
use CGI;
use Tables;
use PDF;
#use RCS;
use strict;
my ($path, $form) = $ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
$form .= "Form";
my $tempPath = "/data/temp/scm";

##################
sub getFileMoves {
##################
   my %args = (
      @_,
   );
	my $sql = "SELECT request, TO_CHAR(movedate, 'MM/DD/YYYY'), majorrev, minorrev, script, "
		          . "change, u.firstname || ' ' || lastname as name, p.acronym, m.moved FROM SCM.moves m, "
		          . "SCM.users u, SCM.product p WHERE m.enteredby = u.id "
		          . "AND m.subproduct = p.id AND m.moved = 'T' "
		          . "ORDER BY movedate desc, request desc, upper(script), majorrev, minorrev desc";
	my $sth = $args{dbh}->prepare($sql);
	$sth->execute;
	return ($sth);
}

# Remove when browseRCSItem function is updated in RCS.pm
###################################################################################################################################
sub getTempName {                                                                                                                 #
###################################################################################################################################
   my %args = (
      username => 'nouser',
      @_,
   );
   my ($sec, $min, $hour, $day, $month, $year) = (localtime)[0,1,2,3,4,5];
   my $out = sprintf("%04d", $year + 1900);
   $out .= sprintf("%02d", $month + 1);
   $out .= sprintf("%02d", $day);
   $out .= sprintf("%02d", $hour);
   $out .= sprintf("%02d", $min);
   $out .= sprintf("%02d", $sec);
   $out .= $args{username};
# need to improve fname create to ensure unique
   return ($out);
}

# Remove when browseRCSItem function is updated in RCS.pm
###################################################################################################################################
sub runCommand {                                                                                                                  #
###################################################################################################################################
   my %args = (
      rcsPath => "",
      rcsFile => "",
      @_,
   );
   my $command = "/data/dev/cgi-bin/scm/rcsCommand.pl ";
   $command .= "-command $args{command} ";
   $command .= "-rcspath $args{rcsPath} " if ($args{rcsPath});
   $command .= "-rcsfile $args{rcsFile} " if ($args{rcsFile});
   $command .= "-tempfile $args{tempFile} ";
   if (open (FH, "$command |")) { close (FH); }
   return();
}

# Remove when browseRCSItem function is updated in RCS.pm
###################################################################################################################################
sub browseRCSItem {                                                                                                               #
###################################################################################################################################
   my %args = (
      @_,
   );
   my @a = ();
   my $out = "";
   my $type = ($args{type} eq 'perlmodule') ? "perl" : $args{type};
   my ($rcsCommand, $rcsPath, $rcsFile) = ("co-p-r$args{version}", "$args{project}/$type/RCS", "$args{item},v");
   my $tempFile = &getTempName();
   &runCommand (command => $rcsCommand, rcsPath => $rcsPath, rcsFile => $rcsFile, tempFile => $tempFile);
   if (open (FH, "$tempPath/$tempFile")) {
      @a = <FH>;
      close (FH);
   }
   &runCommand (command => 'deletetemp', tempFile => $tempFile);
   return (@a);
}
###################################################################################################################################


###################################################################################################################################
sub writeHead {                                                                                                                   #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "";
   $out .= "<html>\n";
   $out .= "<head>\n";
   $out .= <<end if ($args{command} ne 'blank');
   <title>Browse Project Configuration Items</title>
   <meta http-equiv=expires content=now>
   <script language=javascript>
   <!--
      function browseFileForm(itemType, itemName, itemVersion, newWindow) {
         if (newWindow) {
            var myDate = new Date();
            var winName = myDate.getTime();
            var newwin = window.open("", winName);
            newwin.creator = self;
            $args{form}.target = winName;
         } else {
            $args{form}.target = 'main';
         }
         $args{form}.cgiaction.value = 'browsefile';
         $args{form}.itemType.value = itemType;
         $args{form}.itemName.value = itemName;
         $args{form}.itemVersion.value = itemVersion;
         $args{form}.submit();
      }
   //-->
   </script>
end
   $out .= "</head>\n\n";
   return ($out);
}

###################################################################################################################################
sub writeHTTPHeader {                                                                                                             #
###################################################################################################################################
   my %args = (
      type => "text/html",
      @_,
   );
   return ($args{cgi}->header($args{type}));
}

###################################################################################################################################
sub writeBody {
###################################################################################################################################
   my %args = (
      @_,
   );
	my $prevReq = 0;
	my $prevDate;
	my $displayReq;
	my $out = "";
	$out .= "<body background=$SCMImagePath/background.gif text=$SCMFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n";
	$out .= "<br>\n";
	$out .= "<form name=$form method=post action=$ENV{SCRIPT_NAME}>\n";
	$out .= "<input type=hidden name=schema value=$args{schema}>\n";
	$out .= "<input type=hidden name=cgiaction value=$args{cgiaction}>\n";
	$out .= "<input type=hidden name=itemName value=0>\n";
	$out .= "<input type=hidden name=itemType value=0>\n";
	$out .= "<input type=hidden name=itemVersion value=0>\n";
	$out .= "<input type=hidden name=project value=$args{project}>\n";
	$out .= "<center>\n";
	my $dbh = db_connect();
	$dbh->{LongReadLen} = 1000001;
	$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
	my $sth = &getFileMoves(dbh => $dbh);
	$out .= &startTable(width => 750, columns => 3, title => "QA Systems File Moves Log", cellpadding => 4);
	$out .= &startRow(bgColor => '#f0f0f0');
	$out .= &addCol(value => "Name", align => "center", isBold => 1, height => 30);
	$out .= &addCol(value => "Version", align => "center", isBold => 1, height => 30);
	$out .= &addCol(value => "Description", align => "center", isBold => 1, height => 30);
	$out .= &endRow;

	while (my ($req, $date, $majRev, $minRev, $script, $change, $name, $subproduct, $moved) = $sth->fetchrow_array) {
		if (!(defined($req))) {
			$displayReq = "N/A";
			$req = -1;
		}
		else {
			$displayReq = &lpadzero($req, 5);
		}
		if (!(defined($subproduct))) {
			$subproduct = "";
		}
		else {
			$subproduct = "$subproduct           ";
		}

		if (($prevReq != $req) || $prevDate ne $date) {
			$out .= &startRow(bgColor => "#abcfff");
			$out .= &addCol(value => "$subproduct&nbsp;&nbsp;&nbsp;$date", isBold => 1, colspan => 2);
			$out .= &addCol(value => "Software Change Request:&nbsp;$displayReq", isBold => 1, align => "right");
			$out .= &endRow;
		}
		$out .= &startRow(bgColor => "ffffff");
		$out .= &addCol(value => "$script");
		$out .= &addCol(value => "<a href=javascript:browseFileForm('','$script','$majRev.$minRev',1)>$majRev.$minRev</a>", align => "center");
		$out .= &addCol(value => "$change");		
		$out .= &endRow;
		$prevDate = $date;
		$prevReq = $req;
	}
	$out .= &endTable;
	$out .=  "</center>\n</body>\n";
	$out .= "</html>\n";
	&db_disconnect($dbh); 
	return ($out);
}

###################################################################################################################################
sub displayPDF {
###################################################################################################################################
   my %args = (
      @_,
   );
	my $pdf = new PDF;
	my $dbh = db_connect();
	my %projectAcronyms = %{&getLookupValues(dbh => $dbh, schema => $args{schema}, table => "project", idColumn => "id", nameColumn => "acronym")};
	&db_disconnect($dbh); 
	my $projectAcronym = lc($projectAcronyms{$args{project}});
	my @out = &browseRCSItem(project => $projectAcronym, item => $args{itemName}, type => $args{itemType}, version => $args{itemVersion});
	my $out = $pdf->generateListing(addMimeHeader => 'T', lineNumbering => 'T', text => \@out);
	return ($out);
}

my $cgi = new CGI;
my $schema = (defined ($cgi->param("schema"))) ? $cgi->param("schema") : "SCM";
my $cgiaction = (defined ($cgi->param("cgiaction"))) ? $cgi->param("cgiaction") : "";
my $project = (defined ($cgi->param("project"))) ? $cgi->param("project") : "4";
my $itemType = (defined ($cgi->param("itemType"))) ? $cgi->param("itemType") : "perl";
my $itemVersion = (defined ($cgi->param("itemVersion"))) ? $cgi->param("itemVersion") : "";
my $itemName = (defined ($cgi->param("itemName"))) ? $cgi->param("itemName") : "";

if ($cgiaction eq "") {
	my $out = &writeHTTPHeader(cgi => $cgi);
	$out .= &writeHead(schema => $schema, form => $form, command => 'print');
	$out .= &writeBody(project => $project, cgiaction => 'browsefile');
	print $out;
}
elsif ($cgiaction eq "browsefile") {
	print &displayPDF(schema => "SCM", project => $project, itemName => $itemName, itemVersion => $itemVersion,
	                  itemType => "perl");
}
exit();


  
