#
# $Source: /data/dev/rcs/pcl/perl/RCS/UIBaseline.pm,v $
#
# $Revision: 1.6 $ 
#
# $Date: 2003/03/09 17:09:03 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: UIBaseline.pm,v $
# Revision 1.6  2003/03/09 17:09:03  starkeyj
# modified to include session id parameters and modified functions to
# display baseline values according to new table structure
#
# Revision 1.5  2002/11/25 20:44:20  mccartym
# change script reference from 'browse_project' to 'rcs'
#
# Revision 1.4  2002/11/08 18:00:42  starkeyj
# modified for javascript error
#
# Revision 1.3  2002/11/07 15:54:25  starkeyj
# modified all functions with a link to display a prompt describing what the link does
#
# Revision 1.2  2002/11/06 22:31:04  starkeyj
# modified functions to show baseline versions and links to files in rcs
#
# Revision 1.1  2002/10/31 17:01:08  starkeyj
# Initial revision
#
#
package UIBaseline;
use strict;
use SharedHeader qw(:Constants);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use Tables qw(:Functions);
use DBBaseline qw(:Functions);
use CGI qw(param);
use Tie::IxHash;
use Carp;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      &doBrowseBaselineTable    	&doHeader                  &doFooter                     
      &getInitialValues				&doBrowseBaselineItems		&doBrowseSelectedBaselineItems	
      &createBaselineBody
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &doBrowseBaselineTable     &doHeader                  &doFooter                
      &getInitialValues				&doBrowseBaselineItems		&doBrowseSelectedBaselineItems	
      &createBaselineBody
    )]
);

my $mycgi = new CGI;

###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub getInitialValues {  # routine to get initial CGI values and return in a hash
###################################################################################################################################
    my %args = (
        dbh => "",
        @_,
    );

    my %valueHash = (
       schema => (defined($mycgi->param("schema"))) ? $mycgi->param("schema") : $ENV{'SCHEMA'},
       command => (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "browse",
       username => (defined($mycgi->param("username"))) ? $mycgi->param("username") : "",
       userid => (defined($mycgi->param("userid"))) ? $mycgi->param("userid") : "",
       project => (defined($mycgi->param("project"))) ? $mycgi->param("project") : 0,
       nonLNproject => (defined($mycgi->param("nonLNproject"))) ? $mycgi->param("nonLNproject") : 0,
       itemType => (defined($mycgi->param("type"))) ? $mycgi->param("type") : 0,
       document => (defined($mycgi->param("document"))) ? $mycgi->param("document") : 0,
       select1 => (defined($mycgi->param("select1"))) ? $mycgi->param("select1") : 0,
       major => (defined($mycgi->param("major"))) ? $mycgi->param("major") : 0,
       minor => (defined($mycgi->param("minor"))) ? $mycgi->param("minor") : 0,
       description => (defined($mycgi->param("description"))) ? $mycgi->param("description") : 0,
       itemid => (defined($mycgi->param("itemid"))) ? $mycgi->param("itemid") : 0,
       documentfile => (defined($mycgi->param("documentfile"))) ? $mycgi->param("documentfile") : 0,
       baselinedate => (defined($mycgi->param("baselinedate"))) ? $mycgi->param("baselinedate") : 0,
       baselineid => (defined($mycgi->param("baselineid"))) ? $mycgi->param("baselineid") : 0,
       baselineversion => (defined($mycgi->param("baselineversion"))) ? $mycgi->param("baselineversion") : 0,
       sessionID => (defined($mycgi->param("sessionid"))) ? $mycgi->param("sessionid") : "0",
       title => (defined($mycgi->param("title"))) ? $mycgi->param("title") : "Software Baseline"
    );
    
    return (%valueHash);
}

###################################################################################################################################
sub doHeader {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        schema => $ENV{SCHEMA},
        title => 'Document Management',
        displayTitle => 'T',
        @_,
    );
    my $output = "";
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $form = $args{form};
    my $path = $args{path};
    my $username = $settings{username};
    my $userid = $settings{userid};
 
   $output .= $mycgi->header('text/html');
	    $output .= "<html>\n<head>\n<title>$args{title}</title>\n";
	    $output .= <<END_OF_BLOCK;
	    <script language=javascript><!--
	  	 function displayItems(baselinedate,project) {
			  $form.command.value = 'browseitems';
			  $form.project.value = project;
			  //$form.baselineversion.value = version;
			  //$form.baselineid.value = baselineid;
			  $form.baselinedate.value = baselinedate;
			  $form.action = '$path$form.pl';
			  $form.target = 'main';
			  $form.submit();
       }
			 function displayCurrentItems(baselinedate,project) {
				  //$form.command.value = 'browseversions';
				  $form.command.value = 'browsefilemoves';
				  $form.project.value = project;
				  $form.baselinedate.value = baselinedate;
				  $form.action = '$path$form.pl';
				  $form.target = 'main';
				  $form.submit();
	       }
	       function submitFormCGIResults(script,command) {
	           document.$form.command.value = command;
	           document.$form.action = '$path' + script + '.pl';
	           document.$form.target = 'cgiresults';
	           document.$form.submit();
	       }
	       function submitForm(script,command) {
	           document.$form.command.value = command;
	           document.$form.action = '$path' + script + '.pl';
	           document.$form.target = 'main';
	           document.$form.submit();
	       }
	       function displayUser(id) {
	          document.$form.id.value = id;
	          submitForm ('users', 'displayuser');
	       }
			 function displayItemContents(itemType, itemName, itemVersion, newWindow, project) {
				  if (!newWindow) {
					 document.$form.target = 'main';
				  } else {
					 var myDate = new Date();
					 var winName = myDate.getTime();
					 var w = window.open("", winName, "status=no,scrollbars=yes,toolbar=no");
					 document.$form.target = winName;
				  }
				  document.$form.action = '$path' + 'rcs.pl';
				  document.$form.command.value = 'browsefile';
				  if (displayItemContents.arguments.length > 4) document.$form.project.value = project;
				  document.$form.itemType.value = itemType;
				  document.$form.itemName.value = itemName;
				  document.$form.itemVersion.value = itemVersion;
				  document.$form.submit();
	       }
			 function displayItemVersionsTable(itemType, itemName, project) {
				  document.$form.target = 'main';
				  document.$form.action = '$path' + 'rcs.pl';
				  document.$form.command.value = 'browseversions';
				  if (displayItemVersionsTable.arguments.length > 2) document.$form.project.value = project;
				  document.$form.itemType.value = itemType;
				  document.$form.itemName.value = itemName;
				  document.$form.submit();
	       }
	       function isblank(s)
	       {
	           if (s.length == 0) return true;
	           for(var i = 0; i < s.length; i++) {
	               var c = s.charAt(i);
	               if ((c != ' ') && (c != '\\n') && (c != '\\t') && (c !='\\r')) return false;
	           }
	           return true;
	       }
	       
	       // function that returns true if a string contains only numbers
	       function isnumeric(s)
	       {
	           if (s.length == 0) return false;
	           for(var i = 0; i < s.length; i++) {
	               var c = s.charAt(i);
	               if ((c < '0') || (c > '9')) return false;
	           }
	       
	           return true;
	       }
	
	    //-->
    </script>
END_OF_BLOCK
    $output .= "</head>\n";
    $output .= "<body text=#000099 background=$SYSImagePath/background.gif>\n";
    $output .=  (($args{displayTitle} eq 'T') ? &writeTitleBar(userName => $username, userID => $userid, schema => $args{schema}, title => $args{title}) : "");
    $output .= "<form enctype=\"multipart/form-data\" name=$form method=post target=main action=$path$form.pl>\n";
    $output .= "<input type=hidden name=userid value=$userid>\n";
    $output .= "<input type=hidden name=username value=$username>\n";
    $output .= "<input type=hidden name=schema value=$args{schema}>\n";
    $output .= "<input type=hidden name=command value=''>\n";
    $output .= "<input type=hidden name=document value=''>\n";
    $output .= "<input type=hidden name=project value=''>\n";
    $output .= "<input type=hidden name=baselinedate value=''>\n";
    $output .= "<input type=hidden name=baselineid value=''>\n";
    $output .= "<input type=hidden name=itemName value=0>\n";
	 $output .= "<input type=hidden name=itemType value=0>\n";
    $output .= "<input type=hidden name=itemVersion value=0>\n";
    $output .= "<input type=hidden name=baselineversion>\n";
    $output .= "<input type=hidden name=id value=''>\n";
    $output .= "<input type=hidden name=sessionid value='$args{sessionID}'>\n";
    
    return($output);
}


###################################################################################################################################
sub doFooter {  # routine to generate html page footers
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    
    $output .= "</form>\n</body>\n</html>\n";
    
    return($output);
}


###################################################################################################################################
###################################################################################################################################

#################
sub createBaselineBody {
#################
   my %args = (
      schema => $ENV{SCHEMA},
      sessionID => 0,
      @_,
   );
   my $userlist = "";
   my $oldscr = '';
   my $olditemid = '';
   my $scr;
   my %projectinfo = &getProjectInfo(dbh=>$args{dbh}, schema=> $args{schema}, projectId => $args{project}, sessionID => $args{sessionID});
	#my @baselineFiles = &getCurrentBaseline(dbh=>$args{dbh}, schema=> $args{schema}, project => $args{project});
	my @baselineFiles = getApprovedSCRFiles(dbh=>$args{dbh}, schema=> $args{schema}, project => $args{project}, sessionID => $args{sessionID});	
	my $outstring = "";
	my $numColumns = 3;
	$outstring .= &startTable(columns => $numColumns, width => 500, border=>1,titleBackground => "#f0f0f0");
	$outstring .= &addSpacerRow (columns => $numColumns);
	$outstring .= &startRow (bgColor => "#f0f0f0");
	$outstring .= &addCol (value => "<b>Approved Software Change Requests for $projectinfo{name}</b>",colspan=>3);
	$outstring .= &endRow;
	$outstring .= &startRow (bgColor => "#f0f0f0");
	$outstring .= &addCol (value => "<font color=black size=-1><b>SCR</b></font>");
	$outstring .= &addCol (value => "<font color=black size=-1><b>Description</b></font>",colspan=>2);
	$outstring .= &endRow;
	for (my $i=0;$i<$#baselineFiles;$i++) {
		if ($baselineFiles[$i]{scrnum} ne $oldscr) {
			$scr = lpadzero($baselineFiles[$i]{scrnum},4);
			$outstring .= &addSpacerRow (columns => $numColumns);
			$outstring .= &startRow (bgColor => "#f0f0f0");;
			$outstring .= &addCol (value => "<font color=black size=-1>SCR$scr</font>",valign=>'top');
			$outstring .= &addCol (value => "<font color=black size=-1>$baselineFiles[$i]{desc}</font>",colspan=>3);
			$outstring .= &endRow;
			$outstring .= &startRow (bgColor => "#f0f0f0");
			$outstring .= &addCol (value => "&nbsp;");
			$outstring .= &addCol (value => "<font color=black size=-1><b>Associated Files</b></font>");
			$outstring .= &addCol (value => "<font color=black size=-1><b>Version</b></font>");
			$outstring .= &endRow;
		}
		if ($olditemid ne $baselineFiles[$i]{itemid}) {
			$outstring .= &startRow (bgColor => "#f0f0f0");
			$outstring .= &addCol (value => "&nbsp;");
			$outstring .= &addCol (value => "<font color=black size=-1>$baselineFiles[$i]{itemname}</font>");
			$outstring .= &addCol (value => "<font color=black size=-1>$baselineFiles[$i]{itemmajor}.$baselineFiles[$i]{itemminor}</font>");
			$outstring .= &endRow;
		}
		$oldscr = $baselineFiles[$i]{scrnum};
		$olditemid = $baselineFiles[$i]{itemid};
	}
	$outstring .= &endTable;
	$outstring .= <<END_OF_BLOCK2;
	<table width=700 border=0 align=center>
	<tr><td height=25></td></tr>
	<tr><td colspan=2 align=center><input type=button value="Create Baseline" onClick=submitProcessForm('sccb','db_create','');></td></tr>
	</table><br><br>
	</center>
END_OF_BLOCK2
	return ($outstring);
}
###################################################################################################################################
sub doBrowseBaselineTable {  # routine to display a table of documents
###################################################################################################################################
    my %args = (
        itemType => 0, # all
        project => 0,  # null
        title => 'Software Baseline Versions',
        status => 0, # all
        userID => 0, # all
        update => 'F',
        sessionID => 0,
        @_,
    );
    my $output = '';
    my $filelist = '';
    my $versionlist = '';
    my $numColumns = 4;
    my $oldbaseline = '';
    my %project = &getProjectInfo(dbh => $args{dbh}, schema => $args{schema}, projectId => $args{project}, sessionID => $args{sessionID});
    my @baselineList = &getBaselineList(dbh => $args{dbh}, schema => $args{schema}, project => $args{project}, sessionID => $args{sessionID});
	 #my $count = 0;
	 my $count =  &getBaselineCount(dbh => $args{dbh}, schema => $args{schema}, project => $args{project}, sessionID => $args{sessionID});
	 my $baselineminor = $count - 1;
	 $output .= &startTable(columns => $numColumns, title => "$project{name} - Software Baseline Updates (xxx)", width => 740);
	 $output .= &addSpacerRow (columns => $numColumns);
	 $output .= &startRow (bgColor => "#f0f0f0");
	 $output .= &addCol (value => "Baseline Version", align => 'center');
	 $output .= &addCol (value => "Date/Time Updated", align => 'center');
	 #$output .= &addCol (value => "Updated By", align => 'center');
	 #$output .= &addCol (value => "Description", align => 'center');
	 $output .= &addCol (value => "Affected Configuration Items", align => 'center');
	 $output .= &addCol (value => "Version", colspan => 2, align => 'center');
	 $output .= &endRow();
	 $output .= &startRow;
    for (my $i = 0; $i < $#baselineList; $i++) {
        my ($baselinedate,$baselinedate2,$itemid,$itemname,$itemmajor,$itemminor,$type) = 
          ($baselineList[$i]{baselinedate},$baselineList[$i]{baselinedate2},$baselineList[$i]{itemid},
          $baselineList[$i]{itemname},$baselineList[$i]{itemmajor},$baselineList[$i]{itemminor},
          $baselineList[$i]{itemtype});
        my $itemtype = $type == 1 ? 'perl' : $type == 2 ? 'perlmodule' : $type == 3 ? 'javascript' : $type == 6 ? 'sql' : 'unknowntype';
        my $itemextension = $type == 1 ? 'pl' : $type == 2 ? 'pm' : $type == 3 ? 'js' : $type == 6 ? 'sql' : 'unknownextension';
        if ($baselinedate ne $oldbaseline) {
            $output .= &addCol (value=>$filelist);
            $output .= &addCol (value=>$versionlist);
        		$filelist = '';
        		$versionlist = '';
            $output .= &endRow();
        		$output .= &startRow;
        		$output .= &addCol (value=>"1.$baselineminor",url => "javascript:displayItems($baselinedate,$args{project});",prompt => "Click here for complete configuration of baseline version 1.$baselineminor." ,valign => 'top',align => 'center');
        		$output .= &addCol (value=>$baselinedate2,valign => 'top');
        		#$output .= &addCol (value=>'Updater',valign => 'top');
        		#$output .= &addCol (value=>'The description',valign => 'top');
            $filelist .= "<a href=\"javascript:displayItemVersionsTable('$itemtype','$itemname',$args{project})\" title=\"Click here for complete version history of $itemname.$itemextension\">$itemname.$itemextension</a>\n";
            $versionlist .= "<a href=\"javascript:displayItemContents('$itemtype','$itemname','$itemmajor.$itemminor',1,$args{project})\" title=\"Click here to browse version $itemmajor.$itemminor of $itemname.$itemextension\">$itemmajor.$itemminor</a>";
        		$baselineminor--;
        }
        else {
            $filelist .= "<br><a href=\"javascript:displayItemVersionsTable('$itemtype','$itemname',$args{project})\" title=\"Click here for complete version history of $itemname.$itemextension\">$itemname.$itemextension</a>\n";
            $versionlist .= "<br><a href=\"javascript:displayItemContents('$itemtype','$itemname','$itemmajor.$itemminor',1,$args{project})\" title=\"Click here to browse version $itemmajor.$itemminor of $itemname.$itemextension\">$itemmajor.$itemminor</a>";
        }
        $oldbaseline = $baselinedate;
    }
	 $output .= &addCol (value=>$filelist);
	 $output .= &addCol (value=>$versionlist);
    $output .= &endRow();
    $output .= &endTable();
    $output =~ s/xxx/$count/;
    #$output =~ s/<yyy>/s/ if ($count != 1);
    $output =~ s/&quot;/'/g;  #should not need this, I am doing something wrong *****************************************************************
    $output = "<center>No Software Baseline data available for $project{name}</center>" if ($count == 0);
    return($output);
}


###################################################################################################################################
sub doBrowseBaselineItems{  # routine to display a table of documents
###################################################################################################################################
    my %args = (
        project => 0,  # null
        title => 'Software Baseline Items',
        userID => 0, # all
        sessionID => 0,
        @_,
    );
    my $output = '';
    my $numColumns = 3;
    my $first = 1;
    my $count = 0;
    my ($itemid,$itemmajor,$itemminor,$baselinedate,$itemname,$itemsource);
    my @itemList = &getCurrentBaseline(dbh => $args{dbh}, schema => $args{schema}, project => $args{project}, sessionID => $args{sessionID});
    for (my $i = 0; $i < $#itemList; $i++) {
         ($itemid,$itemmajor,$itemminor,$baselinedate,$itemname,$itemsource) = 
          ($itemList[$i]{itemid},$itemList[$i]{itemmajor},$itemList[$i]{itemminor},
          $itemList[$i]{baselinedate},$itemList[$i]{itemname},$itemList[$i]{itemsource});
        $count++;
        if ($first) {
			  $output .= &startTable(columns => $numColumns, title => "$args{title}", width => 500);
			  $output .= &startRow (bgColor => "#f0f0f0");
			  $output .= &addCol (value => "Configuration Item", align => "center");
			  $output .= &addCol (value => "Version", align => "center");
			  $output .= &addCol (value => "Baseline Date", align => "center");
			  $output .= &endRow();
			  $output .= &addSpacerRow (columns => $numColumns);
			  $first = 0;
        }
		  $output .= &startRow;
		  my $prompt = "";
		  $output .= &addCol (value=>$itemname);
		  $output .= &addCol (value=>$itemmajor . "." . $itemminor);
		  $output .= &addCol (value=>$baselinedate);
		  $output .= &endRow;
    }
    $output .= &endTable();
    $output =~ s/xxx/$count/;
    $output =~ s/&quot;/'/g;  #should not need this, I am doing something wrong *****************************************************************
    $output = '' if ($count == 0);
    return($output);
}


###################################################################################################################################
sub doBrowseSelectedBaselineItems{  # routine to display a table of documents
###################################################################################################################################
    my %args = (
        project => 0,  # null
        title => 'Software Baseline Configuration',
        userID => 0, # all
        sessionID => 0,
        @_,
    );
    my $output = '';
    my $count = 0;
    my $urlstring = '';
    my $oldversion = '';
    my $numColumns = 4;
    my ($titledate,$itemid,$itemname,$baselinedate,$supercededdate,$itemmajor,$itemminor,$type,$bminor,$baselinedate2);
  #  my $ampm = substr($args{selecteddate},8,2) > 12 ? " PM" : " AM";
    my %project = &getProjectInfo(dbh => $args{dbh}, schema => $args{schema}, projectId => $args{project}, sessionID => $args{sessionID});
    #my @baselineInfo = &getBaseline(dbh => $args{dbh}, schema => $args{schema}, baselinedate => $args{baselinedate}, sessionID => $args{sessionID});
    my @itemList = &getBaselineVersion(dbh => $args{dbh}, schema => $args{schema}, project => $args{project}, baselinedate => $args{baselinedate}, sessionID => $args{sessionID});
	 $output .= &startTable(columns => $numColumns, title => "$project{name}  -  Software Baseline Version $args{baselinemajor}.$args{baselineminor} (xxx items)", width => 600);
	 $output .= &startRow (bgColor => "#f0f0f0");
	 $output .= &addCol (value => "Baseline updated on $args{baselinedate}", align => "left",colspan => $numColumns);
	 $output .= &endRow();
	 $output .= &startRow (bgColor => "#f0f0f0");
	 $output .= &addCol (value => "Configuration Item", align => "center");
	 $output .= &addCol (value => "Version", align => "center");
	 $output .= &addCol (value => "Changes", align => "center");
	 $output .= &addCol (value => "Baseline Date", align => "center");
	 $output .= &endRow();
	 $output .= &addSpacerRow (columns => $numColumns);
    for (my $i = 0; $i < $#itemList; $i++) {
         ($baselinedate,$supercededdate,$itemid,$itemname,$itemmajor,$itemminor,$type,$baselinedate2) = 
          ($itemList[$i]{baselinedate},$itemList[$i]{supercededdate},$itemList[$i]{itemid},
          $itemList[$i]{itemname},$itemList[$i]{itemmajor},$itemList[$i]{itemminor},$itemList[$i]{itemtype},
          $itemList[$i]{baselinedate2});
        my $itemtype = $type == 1 ? 'perl' : $type == 2 ? 'perlmodule' : $type == 3 ? 'javascript' : $type == 6 ? 'sql' : 'unknowntype';
        my $itemextension = $type == 1 ? 'pl' : $type == 2 ? 'pm' : $type == 3 ? 'js' : $type == 6 ? 'sql' : 'unknownextension';
       # @baselineInfo = &getBaseline(dbh => $args{dbh}, schema => $args{schema}, baselinedate => $itemList[$i]{baselinedate});
        $output .= &startRow;
		  $output .= &addCol (value=>"$itemname.$itemextension",url => "javascript:displayItemVersionsTable('$itemtype','$itemname',$args{project})",prompt => "Click here for complete version history of $itemname.$itemextension");
		  $output .= &addCol (value=>$itemmajor . "." . $itemminor,url => "javascript:displayItemContents('$itemtype','$itemname','$itemmajor.$itemminor',1,$args{project})",prompt => "Click here to browse version $itemmajor.$itemminor of $itemname.$itemextension"); 
        if ($args{baselinedate} eq $baselinedate2) {
		  	  if ($itemList[$i]{itemname} ne $itemList[$i+1]{itemname}) {
		  	  		$output .= &addCol (value=>"New item");
		  	  }
		  	  else {
		  	  		$oldversion =  "$itemList[$i++]{itemmajor}.$itemList[$i]{itemminor}";
		  	  		$urlstring = "<a href=\"javascript:displayItemContents('$itemtype','$itemname','$oldversion',1,$args{project})\" ";
		  	  		$urlstring .= "title=\"Click here to browse version $oldversion of $itemname.$itemextension\">$oldversion</a>";
		  	  		$urlstring .= "&nbsp;&nbsp;=>&nbsp;&nbsp;<a href=\"javascript:displayItemContents('$itemtype','$itemname','$itemmajor.$itemminor',1,$args{project})\" ";
		  	  		$urlstring .= "title=\"Click here to browse version $itemmajor.$itemminor of $itemname.$itemextension\">$itemmajor.$itemminor</a>";
		  	 		$output .= &addCol (value=>"$urlstring");
		  	 }
		  }
		  else {$output .= &addCol (value=>"&nbsp;");}
		  $output .= &addCol (value=>$baselinedate);
		  $output .= &endRow;
		  $count++;
    }
    $output .= &endTable();
    $output =~ s/xxx/$count/;
    $output =~ s/&quot;/'/g;  #should not need this, I am doing something wrong *****************************************************************
    $output = '' if ($count == 0);
    return($output);
}
###################################################################################################################################
###################################################################################################################################

sub new {
    my $self = {};
    bless $self;
    return $self;
}

# proccess variable name methods
sub AUTOLOAD {
    my $self = shift;
    my $type = ref($self) || croak "$self is not an object";
    my $name = $AUTOLOAD;
    $name =~ s/.*://; # strip fully-qualified portion
    unless (exists $self->{$name} ) {
        croak "Can't Access '$name' field in object of class $type";
    }
    if (@_) {
        return $self->{$name} = shift;
    } else {
        return $self->{$name};
    }
}

1; #return true
