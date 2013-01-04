#
# $Source: /data/dev/rcs/scm/perl/RCS/UIMeetings.pm,v $
#
# $Revision: 1.3 $ 
#
# $Date: 2002/10/11 19:57:26 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: UIMeetings.pm,v $
# Revision 1.3  2002/10/11 19:57:26  starkeyj
# modified doBrowseMeetingTable to only pring page jump links at the top of the page
# when the selected project is 'ALL' or undefined
#
# Revision 1.2  2002/10/09 22:11:51  starkeyj
# added functions to get meeting agenda and meeting minutes
#
# Revision 1.1  2002/09/27 00:11:33  starkeyj
# Initial revision
#
#
#
#
#
package UIMeetings;
use strict;
use SCM_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_scm qw(:Functions);
use Tables qw(:Functions);
use DBMeetings qw(:Functions);
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
      &doBrowseMeetingTable      &doHeader                  &doFooter                     
      &getInitialValues				&doBrowseAgenda				&doBrowseMinutes
      &doDisplayDocument
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &doBrowseMeetingTable     	&doHeader                  &doFooter    
      &getInitialValues				&doBrowseAgenda				&doBrowseMinutes
      &doDisplayDocument
    )]
);

my $scmcgi = new CGI;

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
       schema => (defined($scmcgi->param("schema"))) ? $scmcgi->param("schema") : $ENV{'SCHEMA'},
       command => (defined ($scmcgi -> param("command"))) ? $scmcgi -> param("command") : "browse",
       username => (defined($scmcgi->param("username"))) ? $scmcgi->param("username") : "",
       userid => (defined($scmcgi->param("userid"))) ? $scmcgi->param("userid") : "",
       projectID => (defined($scmcgi->param("projectID"))) ? $scmcgi->param("projectID") : 0,
       select6 => (defined($scmcgi->param("select6"))) ? $scmcgi->param("select6") : 0,
       sccbID => (defined($scmcgi->param("sccbID"))) ? $scmcgi->param("sccbID") : 0,
       mtgdate => (defined($scmcgi->param("mtgdate"))) ? $scmcgi->param("mtgdate") : 0,
       attachmentnum => (defined($scmcgi->param("attachmentnum"))) ? $scmcgi->param("attachmentnum") : 0,
       itemType => (defined($scmcgi->param("type"))) ? $scmcgi->param("type") : 0,
       document => (defined($scmcgi->param("document"))) ? $scmcgi->param("document") : 0,
       majorversion => (defined($scmcgi->param("majorversion"))) ? $scmcgi->param("majorversion") : 0,
       minorversion => (defined($scmcgi->param("minorversion"))) ? $scmcgi->param("minorversion") : 0,
       project => (defined($scmcgi->param("project"))) ? $scmcgi->param("project") : 0,
       major => (defined($scmcgi->param("major"))) ? $scmcgi->param("major") : 0,
       minor => (defined($scmcgi->param("minor"))) ? $scmcgi->param("minor") : 0,
       description => (defined($scmcgi->param("description"))) ? $scmcgi->param("description") : 0,
       itemid => (defined($scmcgi->param("itemid"))) ? $scmcgi->param("itemid") : 0,
       documentfile => (defined($scmcgi->param("documentfile"))) ? $scmcgi->param("documentfile") : 0,
       name => (defined($scmcgi->param("name"))) ? $scmcgi->param("name") : 0,
       title => (defined($scmcgi->param("title"))) ? $scmcgi->param("title") : "Meeting"
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
    my $sccbID = $settings{sccbID};
    my $projectID = $settings{projectID};
    my $mtgdate = $settings{mtgdate};
    
    $output .= $scmcgi->header('text/html');
    $output .= "<html>\n<head>\n<title>$args{title}</title>\n";
    $output .= <<END_OF_BLOCK;
    <script language=javascript><!--

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
       function updateMeeting(documentID) {
           document.$form.document.value=documentID;
           submitForm('$form','updatemeeting');
       }
       function updatemeetingInfoformation(documentID) {
           document.$form.document.value=documentID;
           submitForm('$form','updateinformation');
       }
	  	 function displayMeeting(sccbid,mtgdate,command) {
			  var myDate = new Date();
			  var winName = myDate.getTime();
			  var newwin = window.open("", winName);
			  newwin.creator = self;
			  $args{form}.target = winName;
			  $args{form}.command.value = command;
			  $args{form}.sccbID.value = sccbid;
			  $args{form}.mtgdate.value = mtgdate;
           $args{form}.submit();
       }
	    function displaySCCB(sccbid) {
	    alert('under construction');
			//document.$form.document.value=documentID;
			//submitForm('$form','displayminutes');
       }
       function displayDocument(sccbid,mtgdate,attachmentnum) {
			  var myDate = new Date();
			  var winName = myDate.getTime();
			  $form.command.value = 'displaydocument';
			  $form.mtgdate.value = mtgdate;
			  $form.sccbID.value = sccbid;
			  $form.attachmentnum.value = attachmentnum;
			  $form.action = '$path$form.pl';
			  $form.target = winName;
			  var newwin = window.open('',winName);
			  newwin.creator = self;
			  $form.submit();
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

       // funtion to change the location of the main frame
       function changeMainLocation(script) {
           parent.main.location='$path' + script + '.pl?username=$username&userid=$userid&schema=$args{schema}';
       }
    //-->
    </script>
END_OF_BLOCK
    $output .= "</head>\n";
    $output .= "<body text=#000099 background=$SCMImagePath/background.gif>\n";
    $output .=  (($args{displayTitle} eq 'T') ? &writeTitleBar(userName => $username, userID => $userid, schema => $args{schema}, title => $args{title}) : "");
    $output .= "<form enctype=\"multipart/form-data\" name=$form method=post target=main action=$path$form.pl>\n";
    $output .= "<input type=hidden name=userid value=$userid>\n";
    $output .= "<input type=hidden name=username value=$username>\n";
    $output .= "<input type=hidden name=schema value=$args{schema}>\n";
    $output .= "<input type=hidden name=command value=''>\n";
    $output .= "<input type=hidden name=attachmentnum value=''>\n";
    $output .= "<input type=hidden name=id value=''>\n";
    $output .= "<input type=hidden name=sccbID value=$sccbID>\n";
    $output .= "<input type=hidden name=projectID value=$projectID>\n";
    $output .= "<input type=hidden name=mtgdate value=$mtgdate>\n";
    
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


###################################################################################################################################
sub doBrowseMeetingTable {  # routine to display a table of documents
###################################################################################################################################
    my %args = (
        itemType => 0, # all
        project => 0,  # null
        title => 'Meetings',
        status => 0, # all
        userID => 0, # all
        update => 'F',
        @_,
    );
	 my $oldsccb = '0';
    my $output = '';
    my $numColumns = 5;
    my $count = 0;
    my $first = 1;
    my $mtgurl = '';
    tie my %projectNames, "Tie::IxHash";
	 %projectNames = %{&getLookupValues(dbh => $args{dbh}, schema => $args{schema}, table => 'project', idColumn => "id" , nameColumn => "name", orderBy => "id")};
	 if ($args{project} == 0) {
	 	$output .= "<a name = 'top'/>";
	 	$output .= &startTable(columns => 2, width => 450, border => 0,titleBackground => "#f0f0f0");
	 	$output .= &startRow (bgColor => "#f0f0f0");
	 	##temp if
	 	foreach my $projectID (keys (%projectNames)) {
	 		if (($projectID <= 5) || ($projectID == 8) || ($projectID == 23)) {
	 			$output .= &addCol (value => "<a href ='#$projectNames{$projectID}'>$projectNames{$projectID}</a>", align => "left");
	 			$output .= $projectID % 2 == 0 ? &endRow() . &startRow(bgColor => "#f0f0f0") : "";
	 		}
	 	}
	 	$output .= &addCol() . &endRow() . &endTable(). "<br><br>\n";
	 }
    my @meetingList = &getMeetingList(dbh => $args{dbh}, schema => $args{schema}, project => $args{project}, select6 => $args{select6});
    
    for (my $i = 0; $i < $#meetingList; $i++) {
        my ($sccbid,$sccb,$mtgdate,$room,$mtgtime,$agenda,$minutes,$project,$abbr) = 
          ($meetingList[$i]{sccbid},$meetingList[$i]{sccb},$meetingList[$i]{mtgdate},$meetingList[$i]{room},
          $meetingList[$i]{mtgtime},$meetingList[$i]{agenda},$meetingList[$i]{minutes},$meetingList[$i]{project},$meetingList[$i]{abbr});
        $mtgurl = defined($minutes) ? "javascript:displayMeeting($sccbid,'$mtgdate','browseminutes')"  :  "javascript:alert('No minutes available.');";
        if ($oldsccb ne $sccb) {
        	   if (!$first) {
        	   	$output .= &endTable() . "<br><center><a href='#top'>Back to Top</a></center><br>";
        	   	$output =~ s/xxx/$count/;
					$output =~ s/&quot;/'/g;  #should not need this, I am doing something wrong *****************************************************************
   				$output = '' if ($count == 0);
   				$count = 0;
        	   }
            $output .= &startTable(columns => $numColumns, title => "<a name = '$project'>$project ($abbr) - SCCB Meetings (xxx)</a>", width => 750);
		      $output .= &startRow (bgColor => "#f0f0f0");
				$output .= &addCol (value => "SCCB Membership and Charter", colspan => $numColumns, align => "left",url => "javascript:displaySCCB($sccbid)", prompt => "Click here not working yet" );
				$output .= &endRow();
		      $output .= &startRow (bgColor => "#f0f0f0");
		      $output .= &addCol (value => "Date", align => "center");
		      $output .= &addCol (value => "Room", align => "center");
		      $output .= &addCol (value => "Time", align => "center");
		      $output .= &addCol (value => "Agenda", align => "center");
		      $output .= &addCol (value => "Minutes", align => "center");
		      $output .= &endRow();
   		   $output .= &addSpacerRow (columns => $numColumns);
   		   $first = 0;
   		   $oldsccb = $sccb;
        }
        $output .= &startRow;
        my $prompt = "";
        $output .= &addCol (value=>$mtgdate);
        $output .= &addCol (value=>$room);
        $output .= &addCol (value=>$mtgtime);
        $output .= &addCol (value=>'Agenda', url => "javascript:displayMeeting($sccbid,'$mtgdate','browseagenda')", prompt => "Click here to view meeting agenda");
        $output .= &addCol (value=>'Minutes', url => $mtgurl,  prompt => "Click here to view meeting minutes");
        $output .= &endRow;
        $count++;
    }
	 $output .= &endTable();
	 $output =~ s/xxx/$count/;
	 $output =~ s/&quot;/'/g;  #should not need this, I am doing something wrong *****************************************************************
    return($output);
}

###################################################################################################################################
sub doBrowseAgenda {  # routine to display a table of documents
###################################################################################################################################
    my %args = (
        itemType => 0, # all
        project => 0,  # null
        title => 'Meeting Agenda',
        userID => 0, # all
        @_,
    );
    my $output = '';
    my $numColumns = 1;
    my $i = 0;
    my @meeting = &getMeetingAgenda(dbh => $args{dbh}, schema => $args{schema}, sccbid => $args{sccbid}, mtgdate => $args{mtgdate});
    my ($sccbid,$sccb,$mtgdate,$room,$mtgtime,$agenda,$project,$abbr) = 
		 ($meeting[$i]{sccbid},$meeting[$i]{sccb},$meeting[$i]{mtgdate},$meeting[$i]{room},
		 $meeting[$i]{mtgtime},$meeting[$i]{agenda},$meeting[$i]{project},$meeting[$i]{abbr});
	 $agenda =~ s/\n/<br>\n/g;
	 $agenda =~ s/  / &nbsp;/g;
	 $output .= &startTable(columns => $numColumns, title => "$project ($abbr) - SCCB Meeting Agenda for $mtgdate", width => 750);
	 $output .= &startRow (bgColor => "#f0f0f0");
	 $output .= &addCol (value => "Room: $room", align => "left");
	 $output .= &endRow();
	 $output .= &startRow (bgColor => "#f0f0f0");
	 $output .= &addCol (value => "Time: $mtgtime", align => "left");
	 $output .= &endRow();
	 $output .= &startRow (bgColor => "#f0f0f0");
	 $output .= &addCol (value => $agenda, align => "left");
	 $output .= &endRow();
	 my @attachments = &getAttachments(dbh => $args{dbh}, schema => $args{schema}, sccbid => $args{sccbid}, mtgdate => $args{mtgdate}, minutes => 'F');
	 for ($i = 0; $i < $#attachments; $i++) {
	 my ($docname,$attachmentnum) = ($attachments[$i]{name},$attachments[$i]{attachmentnum});
		 $output .= &startRow (bgColor => "#f0f0f0");
		 $output .= &addCol (value => $docname , url => "javascript:displayDocument($sccbid,'$mtgdate',$attachmentnum)", align => "left");
		 $output .= &endRow();
	 }
	 $output .= &endTable();
	 $output =~ s/&quot;/'/g;  #should not need this, I am doing something wrong *****************************************************************
    return($output);
}

###################################################################################################################################
sub doBrowseMinutes {  # routine to display a table of documents
###################################################################################################################################
    my %args = (
        project => 0,  # null
        title => 'Meeting Minutes',
        userID => 0, # all
        @_,
    );
    my $output = '';
    my $numColumns = 1;
    my $i = 0;
    my @meeting = &getMeetingMinutes(dbh => $args{dbh}, schema => $args{schema}, sccbid => $args{sccbid}, mtgdate => $args{mtgdate});
	 my ($sccbid,$sccb,$mtgdate,$room,$mtgtime,$minutes,$project,$abbr) = 
		 ($meeting[$i]{sccbid},$meeting[$i]{sccb},$meeting[$i]{mtgdate},$meeting[$i]{room},
		 $meeting[$i]{mtgtime},$meeting[$i]{minutes},$meeting[$i]{project},$meeting[$i]{abbr});
	 $minutes =~ s/\n/<br>\n/g;
	 $minutes =~ s/  / &nbsp;/g;
	 $output .= &startTable(columns => $numColumns, title => "$project ($abbr) - SCCB Meeting Minutes for $mtgdate", width => 750);
	 $output .= &startRow (bgColor => "#f0f0f0");
	 $output .= &addCol (value => "Room: $room", align => "left");
	 $output .= &endRow();
	 $output .= &startRow (bgColor => "#f0f0f0");
	 $output .= &addCol (value => "Time: $mtgtime", align => "left");
	 $output .= &endRow();
	 $output .= &startRow (bgColor => "#f0f0f0");
	 $output .= &addCol (value => $minutes, align => "left");
	 $output .= &endRow();
	 my @attachments = &getAttachments(dbh => $args{dbh}, schema => $args{schema}, sccbid => $args{sccbid}, mtgdate => $args{mtgdate}, minutes => 'T');
	 for ($i = 0; $i < $#attachments; $i++) {
	 my ($docname,$attachmentnum) = ($attachments[$i]{name},$attachments[$i]{attachmentnum});
		 $output .= &startRow (bgColor => "#f0f0f0");
		 $output .= &addCol (value => $docname , url => "javascript:displayDocument($sccbid,'$mtgdate',$attachmentnum)", align => "left");
		 $output .= &endRow();
	 }
	 $output .= &endTable();
	 $output =~ s/&quot;/'/g;  #should not need this, I am doing something wrong *****************************************************************
    return($output);
}

###################################################################################################################################
sub doDisplayDocument {  # routine to display a document from the DB
###################################################################################################################################
    my %args = (
        document => 0,
        attachmentnum => 1,
        minorVersion => 0,
        @_,
    );
    my $output = '';
    my $mimeType = "application/msword";
    my %itemHash = &getDocument;
    $output .= "Content-type: $mimeType\n\n";
    $output .= $itemHash{attachment};
    
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
