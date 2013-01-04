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
package UIWorkproducts;
use strict;
use SharedHeader qw(:Constants);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use Tables qw(:Functions);
use DBWorkproducts qw(:Functions);
use UIShared qw(JSUtilities JSWidgets);
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
        title => 'Document Management',
        displayTitle => 'T',
        includeJSUtilities => 'F',
        includeJSWidgets => 'F',
        @_,
    );
    my $output = "";
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $form = $args{form};
    my $path = $args{path};
    my $username = $settings{username};
    my $userid = $settings{userid};
    my $project = $settings{project};
    #my $projectID = $settings{projectID};
    
    $output .= $mycgi->header('text/html');
    $output .= "<html>\n<head>\n<title>$args{title}</title>\n";
    $output .= "<script language=javascript>\n<!--\n";
	$output .= ($args{includeJSUtilities} eq 'T') ? &JSUtilities() : "";
	$output .= ($args{includeJSWidgets} eq 'T') ? &JSWidgets() : "";
    $output .= <<END_OF_BLOCK;
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
       function selectOptions(select) {
	   	   for (var i = 0; i < select.options.length - 1; i++) {\
	   	 //  	  alert(select.options[i].value);
	   	      select.options[i].selected = true;
	   	   }
	   }

END_OF_BLOCK
    $output .= "//-->\n";
    $output .= "</script>\n";
    $output .= "</head>\n";
    $output .= "<body text=#000099 background=$SYSImagePath/background.gif>\n";
    $output .=  (($args{displayTitle} eq 'T') ? &writeTitleBar(userName => $username, userID => $userid, schema => $args{schema}, title => $args{title}) : "");
    $output .= "<form enctype=\"multipart/form-data\" name=$form method=post target=main action=$path$form.pl>\n";
    $output .= "<input type=hidden name=userid value=$userid>\n";
    $output .= "<input type=hidden name=username value=$username>\n";
    $output .= "<input type=hidden name=schema value=$args{schema}>\n";
    $output .= "<input type=hidden name=command value=''>\n";
    $output .= "<input type=hidden name=id value=''>\n";
    $output .= "<input type=hidden name=project value=$project>\n";
    #$output .= "<input type=hidden name=projectID value=$projectID>\n";
    
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
        project => 0,  # null
        title => 'Meetings',
        status => 0, # all
        userID => 0, # all
        @_,
    );
    my $output = '';
    my $count = 0;
    my $numColumns = 5;
    my $displaystatus = "";
    my @productList = &getWorkproducts(dbh => $args{dbh}, schema => $args{schema}, project => $args{project});

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
