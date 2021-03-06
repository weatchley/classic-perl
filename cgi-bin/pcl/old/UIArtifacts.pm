#
# $Source:  $
#
# $Revision:  $ 
#
# $Date:  $
#
# $Author:  $
#
# $Locker:  $
#
# $Log:  $
#
package UIArtifacts;
use strict;
use SharedHeader qw(:Constants);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use Tables qw(:Functions);
use DBArtifacts qw(:Functions);
use UIShared qw(:Functions);
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
    Functions => [qw(
      &doHeader                  &doFooter          &getInitialValues	
      &doBrowseArtifacts
      
    )]
);
%EXPORT_TAGS =( 
    Functions => [qw(
      &doHeader                  &doFooter          &getInitialValues	
      &doBrowseArtifacts
      
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
       sccbID => (defined($mycgi->param("sccbID"))) ? $mycgi->param("sccbID") : 0,
       sccbIDMeeting => (defined($mycgi->param("sccbselect"))) ? $mycgi->param("sccbselect") : 0,
       itemType => (defined($mycgi->param("type"))) ? $mycgi->param("type") : 0,
       project => (defined($mycgi->param("project"))) ? $mycgi->param("project") : 0,
       title => (defined($mycgi->param("title"))) ? $mycgi->param("title") : "Meeting",
       sessionID => (defined($mycgi->param("sessionid"))) ? $mycgi->param("sessionid") : "0",
       invitees => (defined($mycgi->param("invitees"))) ? $mycgi->param("invitees") : 0
    );
    return (%valueHash);
}

###################################################################################################################################
sub doHeader {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        schema => $ENV{SCHEMA},
        title => 'PCL User Functions',
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
    my $Server = $settings{server};
    
    my $extraJS = "";
    $extraJS .= <<END_OF_BLOCK;
    function doBrowse(script) {
      	$form.command.value = 'browse';
       	$form.action = '$path' + script + '.pl';
        $form.submit();
    }
    function submitForm3(script, command, project) {
        document.$form.command.value = command;
        document.$form.project.value = project;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }
    function submitFormCheckout() {
        document.$form.command.value = 'checkout';
        document.$form.project.value = document.$form.nonLNproject.value;
        document.$form.action = '$path' + 'project_items' + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }


END_OF_BLOCK
    $output .= &doStandardHeader(schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'F', includeJSWidgets => 'F');
    
    $output .= "<input type=hidden name=type value=0>\n";
    $output .= "<input type=hidden name=project value=0>\n";
    $output .= "<input type=hidden name=projectID value=0>\n";
    #$output .= "<input type=hidden name=server value=$Server>\n";
    $output .= "<table border=0 width=750 align=center><tr><td>\n";

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
sub doBrowseArtifacts {  # routine to do display project artifacts
###################################################################################################################################
    my %args = (
        itemType => 0, # all
        project => 0,  # null
        title => 'Meetings',
        status => 0, # all
        userID => 0, # all
        nonCode => 'T',
        update => 'F',
        fromExternal => 'F',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    my $count = 0;
    my $numColumns = 5;
    my $displaystatus = "";
    my @productList = &getWorkproducts(dbh => $args{dbh}, schema => $args{schema}, project => $args{project});
   
    my @reqDoc = &getReqDoc(dbh => $args{dbh}, schema => $args{schema}, project => $args{project}, itemType => 25, 
                                   userID => $args{userID});
    
    $output .= "<table cellpadding=4 cellspacing=0 border=1 align=center width=750>\n";
    $output .= "<tr>\n";
    $output .= &addCol (value => "<font size=+1>Project Name</font>", colspan=>2,align=>"center");
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Project Software Manager:");
    $output .= &addCol (value => "PSM Name");
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Project Manager:");
    $output .= &addCol (value => "PM Name");
    $output .= &endRow();
    $output .= "<tr>\n";
    $output .= &addCol (value => "Senior Manager:");
    $output .= &addCol (value => "SM Name");
    $output .= &endTable;
    $output .= "\n<br><br>\n";
    $output .= "<table cellpadding=4 cellspacing=0 border=1 align=center width=750>\n";
    $output .= &startRow ();
    $output .= &addCol (value => "<font size=+1>Project Items</font>", colspan=>$numColumns,align=>"center");
    $output .= &endRow();
    $output .= &startRow ();
    $output .= &addCol (value => "Name", align => "center");
    $output .= &addCol (value => "ID", align => "center");
    $output .= &addCol (value => "Title", align => "center");
    $output .= &addCol (value => "Type", align => "center");
    $output .= &addCol (value => "Status", align => "center");
    $output .= &endRow();
    $output .= &addSpacerRow (columns => $numColumns);
    $output .= &startRow ();
    $output .= &addCol (value => "Work Request");
    $output .= &addCol (value => "ABCD-WR");
    $output .= &addCol (value => "System Name Work Request");
    $output .= &addCol (value => "Document");
    $output .= &addCol (value => "approved? pending?");
    $output .= &endRow();
    $output .= &startRow ();
    $output .= &addCol (value => "Allocated Requirements");
    $output .= &addCol (value => "ABCD-AR");
    $output .= &addCol (value => "System Name Allocated Requirements");
    $output .= &addCol (value => "Document");
    $output .= &addCol (value => "done?  in progress?");
    $output .= &endRow();
    $output .= &startRow ();
    $output .= &addCol (value => "Statement of Work");
    $output .= &addCol (value => "ID");
    $output .= &addCol (value => "Title");
    $output .= &addCol (value => "Type");
    $output .= &addCol (value => "Status");
    $output .= &endRow();
    $output .= &startRow ();
    $output .= &addCol (value => "Statement of Work / Allocated Requirements");
    $output .= &addCol (value => "ID");
    $output .= &addCol (value => "Title");
    $output .= &addCol (value => "Type");
    $output .= &addCol (value => "Status");
    $output .= &endRow();
    $output .= &startRow ();
    $output .= &addCol (value => "Configuration Control Board Charter");
    $output .= &addCol (value => "ID");
    $output .= &addCol (value => "Title");
    $output .= &addCol (value => "Type");
    $output .= &addCol (value => "Status");
    $output .= &endRow();
    $output .= &startRow ();
    $output .= &addCol (value => "Configuration Control Board Membership??");
    $output .= &addCol (value => "ID");
    $output .= &addCol (value => "Title");
    $output .= &addCol (value => "Type");
    $output .= &addCol (value => "Status");
    $output .= &endRow();
    $output .= &endTable;
    $output .= "\n<br><br>\n";
    $output .= "<table cellpadding=4 cellspacing=0 border=1 align=center width=750>\n";
    $output .= &startRow ();
    $output .= &addCol (value => "<font size=+1>Project Plan</font>", colspan=>3,align=>"center");
    $output .= &endRow();
    $output .= &startRow ();
    $output .= &addCol (value => "Work Products");
    $output .= &addCol (value => "Software Design Specification");
    $output .= &addCol (value => "Risks",url => "javascript:submitForm3('risks','browse',$args{project})");
    $output .= &endRow();
    $output .= &startRow ();
    $output .= &addCol (value => "Commitments");
    $output .= &addCol (value => "Issues");
    $output .= &addCol (value => "Meetings");
    $output .= &endRow();
    $output .= &startRow ();
    $output .= &addCol (value => "Baselines");
    $output .= &addCol (value => "Audits");
    $output .= &addCol (value => "Schedule");
    $output .= &endRow();
    $output .= &endTable;
    $output .= "\n<br><br>\n";
    $output .= "<table cellpadding=4 cellspacing=0 border=1 align=center width=750>\n";
    $output .= &startRow ();
    $output .= &addCol (value => "<font size=+1>Maintenance</font>", colspan=>3,align=>"center");
    $output .= &endRow();
    $output .= &startRow ();
    $output .= &addCol (value => "Open SCR's");
    $output .= &addCol (value => "Closed SCR's");
    $output .= &addCol (value => "?");
    $output .= &endRow();

    $output =~ s/xxx/$count/;
 #   $output =~ s/&quot;/'/g;  #should not need this, I am doing something wrong *****************************************************************
    return($output);
}

###################################################################################################################################
sub doBrowseArtifacts_old {  # routine to do display project artifacts
###################################################################################################################################
    my %args = (
        itemType => 0, # all
        project => 0,  # null
        title => 'Meetings',
        status => 0, # all
        userID => 0, # all
        nonCode => 'T',
        update => 'F',
        fromExternal => 'F',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    my $count = 0;
    my $numColumns = 5;
    my $displaystatus = "";
    my @productList = &getWorkproducts(dbh => $args{dbh}, schema => $args{schema}, project => $args{project});
   
    my @reqDoc = &getReqDoc(dbh => $args{dbh}, schema => $args{schema}, project => $args{project}, itemType => 25, 
                                   userID => $args{userID});
    
    $output .= &startTable(columns => $numColumns, border => 0, title => "Requirements Phase", width => 750);
    $output .= &startRow (bgColor => "#f0f0f0");
    #$output .= &addCol (value => "Work Product", align => "center");
    $output .= &addCol (value => "Name", align => "center");
    $output .= &addCol (value => "Type", align => "center");
    $output .= &addCol (value => "Versions", align => "center");
    $output .= &addCol (value => "Status", align => "center");
    $output .= &addCol (value=> "Link", align => "center");
    $output .= &endRow();
    $output .= &addSpacerRow (columns => $numColumns);
    
    for (my $i = 0; $i < $#reqDoc; $i++) {
    	my ($id,$name,$pid,$descr,$itemType,$verID,$major,$minor,$date,$statusID,$status,$developer,$locker, $acronym, $creator, $creationDate) = 
      	($reqDoc[$i]{id},$reqDoc[$i]{name},$reqDoc[$i]{pid},$reqDoc[$i]{descr},$reqDoc[$i]{itemType},$reqDoc[$i]{verID},$reqDoc[$i]{major},
      	$reqDoc[$i]{minor},$reqDoc[$i]{date},$reqDoc[$i]{statusID},$reqDoc[$i]{status},$reqDoc[$i]{developer},$reqDoc[$i]{locker},
      	$reqDoc[$i]{projAcronym},$reqDoc[$i]{creator},$reqDoc[$i]{creationDate});
    	$count++;
	$output .= &startRow;
    	$output .= &addCol (value => "$name", align => "center");
    	$output .= &addCol (value => "$itemType", align => "center");
    	$output .= &addCol (value => "$verID", align => "center");
    	$output .= &addCol (value => "$status", align => "center");
    	$output .= &addCol (value=> "Link", align => "center");	
	$output .= &endRow;
    }
    $output .= &endTable;
    
    $output .= &startTable(columns => $numColumns, border => 1, title => "Work Products (xxx)", width => 750);
    $output .= &startRow (bgColor => "#f0f0f0");
    $output .= &addCol (value => "Name", align => "center");
    $output .= &addCol (value => "Type", align => "center");
    $output .= &addCol (value => "Est Delivery", align => "center");
    $output .= &addCol (value => "NLT Delivery", align => "center");
    $output .= &addCol (value=> "Status", align => "center");
    $output .= &endRow();
    $output .= &addSpacerRow (columns => $numColumns);
     
    for (my $i = 0; $i < $#productList; $i++) {
	my ($productid,$productname,$producttype,$productdesc,$estdelivery,$nltdelivery) = 
	($productList[$i]{productid},$productList[$i]{productname},$productList[$i]{producttype},
	$productList[$i]{productdesc},$productList[$i]{estdelivery},defined($productList[$i]{nltdelivery}) ? $productList[$i]{nltdelivery} : '&nbsp');
        $output .= &startRow;
        my $prompt = "";
        $output .= &addCol (value=>$productname);
        $output .= &addCol (value=>$producttype);
        $output .= &addCol (value=>$estdelivery);
        $output .= &addCol (value=>$nltdelivery);
        $output .= &addCol (value=>'zzz');
        $output .= &endRow;
        my @breakdown = &getWorkbreakdown(dbh => $args{dbh}, schema => $args{schema}, productID => $productid);
        for (my $j = 0; $j < $#breakdown; $j++) {
		my ($bkdnid,$wpid,$version,$activity,$status,$bkdndesc,$source) = 
		($breakdown[$j]{id},$breakdown[$j]{wpid},$breakdown[$j]{version},$breakdown[$j]{activity},
		$breakdown[$j]{status},$breakdown[$j]{desc},$breakdown[$j]{source});
		$output .= &startRow;
		my $prompt = "";        
		$output .= &addCol (value=>$activity);
		$output .= &addCol (value=>$version);
		$output .= &addCol (value=>$bkdndesc,colspan=>2);
		$output .= &addCol (value=>$status);
		$output .= &endRow;     
		$displaystatus = $status eq 'In Progress' || $displaystatus eq 'In Progress' ? 'In Progress' : $displaystatus eq 'Complete' && $status eq 'Complete' ? 'Complete' : $status;
        }
        $output =~ s/zzz/$displaystatus/;
        $displaystatus = "";
        $count++;
    }
    $output .= &endTable();
    $output =~ s/xxx/$count/;
 #   $output =~ s/&quot;/'/g;  #should not need this, I am doing something wrong *****************************************************************
    return($output);
}

####################################################################################################################################

###################################################################################################################################


1; #return true
