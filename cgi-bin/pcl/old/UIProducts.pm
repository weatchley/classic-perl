#
# $Source: /data/dev/rcs/scm/perl/RCS/UIProducts.pm,v $
#
# $Revision: 1.2 $ 
#
# $Date: 2002/10/09 18:36:08 $
#
# $Author: starkeyj $
#
# $Locker: starkeyj $
#
# $Log: UIProducts.pm,v $
# Revision 1.2  2002/10/09 18:36:08  starkeyj
# functions to browse products, product versions, and configuration items for a product version
#
# Revision 1.1  2002/09/27 00:12:48  starkeyj
# Initial revision
#
#
#
#
#
package UIProducts;
use strict;
use SCM_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_scm qw(:Functions);
use Tables qw(:Functions);
use DBProducts qw(:Functions);
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
      &doBrowseProductTable    	&doHeader                  &doFooter                     
      &getInitialValues				&doBrowseProductVersions	&doBrowseProductItems
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &doBrowseProductTable     	&doHeader                  &doFooter                
      &getInitialValues				&doBrowseProductVersions	&doBrowseProductItems
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
       productID => (defined($scmcgi->param("productID"))) ? $scmcgi->param("productID") : 0,
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
       sessionID => (defined($mycgi->param("sessionid"))) ? $mycgi->param("sessionid") : "0",
       title => (defined($scmcgi->param("title"))) ? $scmcgi->param("title") : "Product"
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
    
    $output .= $scmcgi->header('text/html');
    $output .= "<html>\n<head>\n<title>$args{title}</title>\n";
    $output .= <<END_OF_BLOCK;
    <script language=javascript><!--
       function displayVersions(productID) {
           $form.command.value = 'browseversions';
           $form.productID.value = productID;
           $form.action = '$path$form.pl';
           $form.target = 'main';
           $form.submit();
       }
	  	 function displayItems(productID,minorVersion) {
			  $form.command.value = 'browseitems';
			  $form.productID.value = productID;
			  $form.minorversion.value = minorVersion;
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
    $output .= "<body text=#000099 background=$SCMImagePath/background.gif>\n";
    $output .=  (($args{displayTitle} eq 'T') ? &writeTitleBar(userName => $username, userID => $userid, schema => $args{schema}, title => $args{title}) : "");
    $output .= "<form enctype=\"multipart/form-data\" name=$form method=post target=main action=$path$form.pl>\n";
    $output .= "<input type=hidden name=userid value=$userid>\n";
    $output .= "<input type=hidden name=username value=$username>\n";
    $output .= "<input type=hidden name=schema value=$args{schema}>\n";
    $output .= "<input type=hidden name=command value=''>\n";
    $output .= "<input type=hidden name=document value=''>\n";
    $output .= "<input type=hidden name=projectID value=''>\n";
    $output .= "<input type=hidden name=productID value=''>\n";
    $output .= "<input type=hidden name=majorversion value=''>\n";
    $output .= "<input type=hidden name=minorversion value=''>\n";
    
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
sub doBrowseProductTable {  # routine to display a table of documents
###################################################################################################################################
    my %args = (
        itemType => 0, # all
        project => 0,  # null
        title => 'Products',
        status => 0, # all
        userID => 0, # all
        update => 'F',
        @_,
    );
    my $output = '';
    my $first = 1;   
    my $numColumns = 6;
    my $count = 0;
    my @productList = &getCurrentProduct(dbh => $args{dbh}, schema => $args{schema});
    
    for (my $i = 0; $i < $#productList; $i++) {
        my ($product_id,$product,$major,$minor,$approved,$released,$project,$created,$firstname,$lastname) = 
          ($productList[$i]{product_id},$productList[$i]{product},$productList[$i]{maj},$productList[$i]{minorver},
          $productList[$i]{approved},$productList[$i]{released},$productList[$i]{project},
          $productList[$i]{created},$productList[$i]{firstname},$productList[$i]{lastname});
        $count++;
        if ($first) {
			  $output .= &startTable(columns => $numColumns, title => "$project - Software Products <yyy> (xxx)", width => 750);
			  $output .= &startRow (bgColor => "#f0f0f0");
			  $output .= &addCol (value => "Product", align => "center");
			  $output .= &addCol (value => "Current Version", align => "center");
			  $output .= &addCol (value => "Created", align => "center");
			  $output .= &addCol (value => "Approved", align => "center");
			  $output .= &addCol (value => "Released", align => "center");
			  $output .= &addCol (value => "Released By", align => "center");
			  $output .= &endRow();
			  $output .= &addSpacerRow (columns => $numColumns);
			  $first = 0;
        }
        $output .= &startRow;
        my $prompt = "";
        $output .= &addCol (value=>$product, url => "javascript:displayVersions($product_id)", prompt => "Click here for complete version history of $product");
        $output .= &addCol (value=>$major . "." . $minor, url => "javascript:displayItems($product_id,$minor)", prompt => "Click here to display product configuration items", align => "center");
        $output .= &addCol (value=>$created);
        $output .= &addCol (value=>$approved);
        $output .= &addCol (value=>$released);
        $output .= &addCol (value=>$firstname . " " . $lastname);
        $output .= &endRow;
    }
    $output .= &endTable();
    
    $output =~ s/xxx/$count/;
    #$output =~ s/<yyy>/s/ if ($count != 1);
    $output =~ s/&quot;/'/g;  #should not need this, I am doing something wrong *****************************************************************
    $output = '' if ($count == 0);
    return($output);
}

###################################################################################################################################
sub doBrowseProductVersions {  # routine to display a table of documents
###################################################################################################################################
    my %args = (
        project => 0,  # null
        product => 0,
        minorversion => 1,
        title => 'Products',
        userID => 0, # all
        @_,
    );
    my $output = '';
    my $numColumns = 5;
    my $first = 1;    
    my $count = 0;
    my @versionList = &getVersionList(dbh => $args{dbh}, schema => $args{schema}, product => $args{product});

    for (my $i = 0; $i < $#versionList; $i++) {
        my ($projectname,$product,$major,$minor,$approved,$released,$created,$firstname,$lastname) = 
          ($versionList[$i]{projectname},$versionList[$i]{product},$versionList[$i]{major},$versionList[$i]{minor},
          $versionList[$i]{approved},$versionList[$i]{released},$versionList[$i]{created},
          $versionList[$i]{firstname},$versionList[$i]{lastname});
        $count++;
        if ($first) {
			  $output .= &startTable(columns => $numColumns, title => "$projectname - $product Version<yyy> (xxx)", width => 750);
			  $output .= &startRow (bgColor => "#f0f0f0");
			  $output .= &addCol (value => "Version", align => "center");
			  $output .= &addCol (value => "Created", align => "center");
			  $output .= &addCol (value => "SCCB Approved", align => "center");
			  $output .= &addCol (value => "Released", align => "center");
			  $output .= &addCol (value => "Released By", align => "center");
			  $output .= &endRow();
			  $output .= &addSpacerRow (columns => $numColumns);
			  $first = 0;
        }
        $output .= &startRow;
        $output .= &addCol (value=>$major . "." . $minor, url => "javascript:displayItems($args{product},$minor)", prompt => "Click here to display product configuration items", align => "center");
        $output .= &addCol (value=>$created);
        $output .= &addCol (value=>$approved);
        $output .= &addCol (value=>$released);
        $output .= &addCol (value=>$firstname . " " . $lastname);
        $output .= &endRow;
    }
    $output .= &endTable();
    $output =~ s/xxx/$count/;
    $output =~ s/<yyy>/s/ if ($count != 1);
    $output =~ s/&quot;/'/g;  #should not need this, I am doing something wrong *****************************************************************
    $output = '' if ($count == 0);
    return($output);
}

###################################################################################################################################
sub doBrowseProductItems{  # routine to display a table of documents
###################################################################################################################################
    my %args = (
        project => 0,  # null
        product => 0,
        majorversion => 1,
        minorversion => 1,
        title => 'Products',
        userID => 0, # all
        @_,
    );
    my $output = '';
    my $numColumns = 4;
    my $first = 1;
    my $count = 0;
    my $olditemname = '';
    my $olditemminor = 0;
    my ($itemid,$itemmajor,$itemminor,$itemname,$productname,$scr,$approvaldate);
    my @version = &getVersion(dbh => $args{dbh}, schema => $args{schema}, product => $args{product}, minorversion => $args{minorversion});
    my @itemList = &getProductVersion(dbh => $args{dbh}, schema => $args{schema}, product => $args{product}, minorversion => $args{minorversion});
    for (my $i = 0; $i < $#itemList; $i++) {
         ($itemid,$itemmajor,$itemminor,$itemname,$productname,$scr,$approvaldate) = 
          ($itemList[$i]{itemid},$itemList[$i]{itemmajor},$itemList[$i]{itemminor},
          $itemList[$i]{itemname},$itemList[$i]{productname},$itemList[$i]{scr},$itemList[$i]{approvaldate});
        $count++;
        if ($first) {
			  $output .= &startTable(columns => $numColumns, title => "$productname v$args{majorversion}.$args{minorversion} - Configuration Items (xxx)", width => 600);
			  $output .= &startRow;
			  $output .= &addCol (value => "Created:  $version[0]{created}");
			  $output .= &addCol (value => "SCCB Approved: $version[0]{approved}");
			  $output .= &addCol (value => "Released:  $version[0]{released} ", colspan => 2);
           $output .= &endRow;
			  $output .= &startRow (bgColor => "#f0f0f0");
			  $output .= &addCol (value => "Configuration Item", align => "center");
			  $output .= &addCol (value => "Version", align => "center");
			  $output .= &addCol (value => "Superceded Version", align => "center");
			  $output .= &addCol (value => "SCR", align => "center");
			  #$output .= &addCol (value => "SCCB Approved", align => "center");
			  $output .= &endRow();
			  $output .= &addSpacerRow (columns => $numColumns);
			  $first = 0;
        }
		  if ($olditemname eq $itemname) {
		  	  $output =~ s/yyyyy/$itemmajor.$itemminor  => $itemmajor.$olditemminor/g;
		  	  $output =~ s/xyz/$itemList[$i-1]{scr}&nbsp;/g;
		  	  $count--;
		  }
		  else {
		     $output =~ s/yyyyy/&nbsp;/g;
		     $output =~ s/xyz/&nbsp;/g;
        	  $output .= &startRow;
           my $prompt = "";
           $output .= &addCol (value=>$itemname);
           $output .= &addCol (value=>"zzz" .$itemmajor . "." . $itemminor);
           $output .= &addCol (value=>"yyyyy");
           $output .= &addCol (value=>"xyz");
       	  #$output .= &addCol (value=>$approvaldate . "&nbsp;");
           $output .= &endRow;
       }
       $olditemname = $itemname;
       $olditemminor = $itemminor;
    }
    $output .= &endTable();
    $output =~ s/xxx/$count/;
    $output =~ s/yyyyy/&nbsp;/g;
	 $output =~ s/zzz/ /g;
	 $output =~ s/xyz/&nbsp;/g;
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
