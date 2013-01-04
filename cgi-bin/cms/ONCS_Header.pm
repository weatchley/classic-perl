# CMS Header file
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/cms/perl/RCS/ONCS_Header.pm,v $
# $Revision: 1.19 $
# $Date: 2007/11/23 18:49:06 $
# $Author: atchleyb $
# $Locker:  $
# $Log: ONCS_Header.pm,v $
# Revision 1.19  2007/11/23 18:49:06  atchleyb
# CR 31 - removed hardcoded path to root
#
# Revision 1.18  2006/12/12 18:06:11  atchleyb
# updated for new invironment
#
# Revision 1.17  2003/11/21 17:12:42  naydenoa
# Updated PCL path. Was pointing to SCM - deprecated.
#
# Revision 1.16  2001/07/30 20:37:53  naydenoa
# Added $SCMPath variable
#
# Revision 1.15  2001/04/17 22:01:50  naydenoa
# Took out hard-coded path to server
#
# Revision 1.14  2000/12/07 00:24:21  atchleyb
# Updated to allow for a dev oracle server
# removed zepedaj as the dev schema
#
# Revision 1.13  2000/11/20 16:34:33  atchleyb
# turned on message notfication for production
#
# Revision 1.12  2000/11/03 17:30:25  atchleyb
# added the $CMSNotify flag to turn on and off email notifications, it is currently set to be on for dev
#
# Revision 1.11  2000/09/27 21:43:17  atchleyb
# fixed comment that was for required code
#
# Revision 1.10  2000/09/27 21:13:42  atchleyb
# added variables: $CMSProductionStatus, $CMSDebug
#
# Revision 1.9  2000/09/26 00:57:49  atchleyb
# changed user info for schema zepedaj
#
# Revision 1.8  2000/08/31 23:16:51  atchleyb
# added CMS variables & path mappings
#
# Revision 1.7  2000/05/25 23:40:09  zepedaj
# Fixed spacing of the control panel
#
# Revision 1.6  2000/05/24 19:10:18  zepedaj
# Added variable for the control frame size
#
# Revision 1.5  2000/05/24 17:56:30  zepedaj
# Removed calls to getdbpassword for CMS access
#
# Revision 1.4  2000/05/19 19:14:38  zepedaj
# Modified to support $ONCSCGIDir for the multiple directories for different schema
#
# Revision 1.3  2000/05/18 19:15:38  zepedaj
# Added functionality for cms schema and oncs schema
#
# Revision 1.2  2000/04/24 19:28:51  zepedaj
# Updated path to javascript utility file.
#
# Revision 1.1  2000/04/11 22:57:26  zepedaj
# Initial revision
#

package ONCS_Header;
use strict;
use Carp;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw($ONCSType $ONCSUser $ONCSPassword $ONCSFontFace $ONCSFontColor $ONCSDocPath $ONCSJavaScriptPath %ONCSHash);
use vars qw($MaxBytesStored $ONCSTempFilePath $TitleLength $ONCSImagePath $ONCSBackground $ONCSCGIDir $CMSControlSize $ONCSImagesDir);
use vars qw($CMSType $CMSUser $CMSPassword $SCHEMA $CMSFontFace $CMSFontColor $CMSDocPath $CMSJavaScriptPath %CMSHash);
use vars qw($CMSTempFilePath $CMSFullImagePath $CMSImagePath $CMSBackground $CMSCGIDir $CMSImagesDir);
use vars qw($CMSProductionStatus $CMSDebug $CMSNotify $CMSServer $SCMPath $SYSPathRoot);

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);
@EXPORT = qw ();
@EXPORT_OK = qw($ONCSType $ONCSUser $ONCSPassword $ONCSFontFace $ONCSFontColor $ONCSDocPath
                $ONCSJavaScriptPath %ONCSHash $ONCSTempFilePath $MaxBytesStored $TitleLength
                $ONCSImagePath $ONCSBackground $ONCSCGIDir $CMSControlSize $ONCSImagesDir
                $CMSType $CMSUser $CMSPassword $SCHEMA $CMSFontFace $CMSFontColor $CMSDocPath $CMSJavaScriptPath %CMSHash
                $CMSTempFilePath $CMSFullImagePath $CMSImagePath $CMSBackground $CMSCGIDir $CMSImagesDir
                $CMSProductionStatus $CMSDebug $CMSNotify $CMSServer $SCMPath $SYSPathRoot);
%EXPORT_TAGS =(
    Constants => [qw($ONCSType $ONCSUser $ONCSPassword $ONCSFontFace $ONCSFontColor
                     $ONCSDocPath $ONCSJavaScriptPath %ONCSHash $ONCSTempFilePath
                     $MaxBytesStored $TitleLength $ONCSImagePath $ONCSBackground $ONCSCGIDir $CMSControlSize $ONCSImagesDir
                     $CMSType $CMSUser $CMSPassword $SCHEMA $CMSFontFace $CMSFontColor $CMSDocPath $CMSJavaScriptPath %CMSHash
                     $CMSTempFilePath $CMSFullImagePath $CMSImagePath $CMSBackground $CMSCGIDir $CMSImagesDir
                     $CMSProductionStatus $CMSDebug $CMSNotify $CMSServer $SCMPath $SYSPathRoot) ]
);

$ENV{'ORACLE_HOME'} = "/usr/local/oracle8";

&customize_variables;

$ONCSFontFace = "Arial";
$ONCSFontColor = "#000099";
$ONCSDocPath = "/cms/prototype";
$ONCSJavaScriptPath = "/cms/javascript";
$ONCSBackground = "/cms/images/background.gif";
$ONCSImagesDir = "/cms/images";
%ONCSHash = ("ONCSUser" => $ONCSUser, "ONCSPassword" => $ONCSPassword,
            "SCHEMA" => $SCHEMA, "ONCSFontFace" => $ONCSFontFace, "ONCSFontColor" =>$ONCSFontColor,
            "ONCSDocPath" => $ONCSDocPath, "ONCSJavaScriptPath" => $ONCSJavaScriptPath,
            "ONCSTempFilePath" => $ONCSTempFilePath, "ONCSImagePath" => $ONCSImagePath);

$CMSFontFace = "Arial";
$CMSFontColor = "#000099";
$CMSDocPath = "/cms/prototype";
$CMSJavaScriptPath = "/cms/javascript";
$CMSBackground = "/cms/images/background.gif";
$CMSImagesDir = "/cms/images";
%CMSHash = ("CMSUser" => $CMSUser, "CMSPassword" => $CMSPassword,
            "SCHEMA" => $SCHEMA, "CMSFontFace" => $CMSFontFace, "CMSFontColor" =>$CMSFontColor,
            "CMSDocPath" => $CMSDocPath, "CMSJavaScriptPath" => $CMSJavaScriptPath,
            "CMSTempFilePath" => $CMSTempFilePath, "CMSFullImagePath" => $CMSFullImagePath, "CMSImagePath" => $CMSImagePath);

$CMSDebug = !$CMSProductionStatus;
$CMSNotify = 1;

$MaxBytesStored = '';
$MaxBytesStored = 104857600;  #100 MB file maximum (hopefully)
$TitleLength = '';
$TitleLength = 80;

#########
sub new {   # create new object
#########
    my $self = {};
    $self = { %ONCSHash };
    bless $self;
    return $self;
}

##############
sub AUTOLOAD {      # proccess variable name methods
##############
    my $self = shift;
    my $type = ref($self) || croak "$self is not an object";
    my $name = $AUTOLOAD;
    $name =~ s/.*://; # strip fully-qualified portion
    unless (exists $self->{$name} ) {
        croak "Can't Access '$name' field in object of class $type";
    }
    if (@_) {
        return $self->{$name} = shift;
    } 
    else {
        return $self->{$name};
    }
}

#########################
sub customize_variables {
#########################
    #my $server = ($ENV{'DOCUMENT_ROOT'} =~ m/dev/) ? "dev" : "prod";  #determine if the script is on the dev server.
    $CMSProductionStatus = ($ENV{SERVER_STATE} ne "PRODUCTION") ? 0 : 1;
    #$SYSPathRoot = ($CMSProductionStatus) ? "/usr/local/www/gov.ymp.intranet" : "/usr/local/www/gov.ymp.intradev";
    $SYSPathRoot = $ENV{PATH_TO_ROOT};
    $CMSServer = (($CMSProductionStatus == 1) ? "ydoraprd.ymp.gov" : "ydoradev");  #determine if the script is on the dev server.
    my $execdir = ($ENV{'SCRIPT_NAME'} =~ m/cms/) ? "cms" : "oncs";   #determine if the script is in the CMS or ONCS directory.
    $SCHEMA =  $execdir;
    if (($CMSServer eq "ydoradev") && ($execdir eq "cms")) {
        $ONCSTempFilePath = "$SYSPathRoot/data/temp/cms/dev/";
        $ONCSImagePath = "/temp/cms/dev";
        $ONCSCGIDir = "/cgi-bin/cms";
        $CMSTempFilePath = "$SYSPathRoot/data/temp/cms/dev/";
        $CMSFullImagePath = "$SYSPathRoot/data/temp/cms/dev/images";
        $CMSImagePath = "/temp/cms/dev/images";
        $CMSCGIDir = "/cgi-bin/cms";
        $CMSControlSize = 10;
        $SCMPath = "/cgi-bin/pcl";
    }
    elsif (($CMSServer eq "ydoraprd.ymp.gov") && ($execdir eq "cms")) {
        $ONCSTempFilePath = "$SYSPathRoot/data/temp/cms/prod/";
        $ONCSImagePath = "/temp/cms/prod";
        $ONCSCGIDir = "/cgi-bin/cms";
        $CMSTempFilePath = "$SYSPathRoot/data/temp/cms/prod/";
        $CMSFullImagePath = "$SYSPathRoot/data/temp/cms/prod/images";
        $CMSImagePath = "/temp/cms/prod/images";
        $CMSCGIDir = "/cgi-bin/cms";
        $CMSControlSize = 0;
        $SCMPath = "/cgi-bin/pcl";
    }
    elsif (($CMSServer eq "ydoraprd.ymp.gov") && ($execdir eq "oncs")) {
        $ONCSTempFilePath = "$SYSPathRoot/data/cirs/prod/";
        $ONCSImagePath = "/cirs/prod";
        $ONCSCGIDir = "/cgi-bin/oncs";
        $CMSTempFilePath = "$SYSPathRoot/data/cirs/prod/";
        $CMSImagePath = "/cirs/prod";
        $CMSCGIDir = "/cgi-bin/oncs";
        $CMSControlSize = 0;
    }
    else {   # (($CMSServer eq "ydoradev") && ($execdir eq "oncs"))
        $ONCSTempFilePath = "$SYSPathRoot/data/cirs/dev/";
        $ONCSImagePath = "/cirs/dev";
        $ONCSCGIDir = "/cgi-bin/oncs";
        $CMSTempFilePath = "$SYSPathRoot/data/cirs/dev/";
        $CMSImagePath = "/cirs/dev";
        $CMSCGIDir = "/cgi-bin/oncs";
        $CMSControlSize = 10;
    }
    if (($SCHEMA eq "cms")) {
        #my $CMSConnectPath = ($CMSProductionStatus) ? "usr/local/www" : "/data/dev";
        #$CMSConnectPath .= "/cgi-bin/cms/oracle_connect.pl";
        my $CMSConnectPath = $SYSPathRoot . "/cgi-bin/" . lc($execdir) . "/oracle_connect.pl";  
        $CMSUser = "cms";
        if (open (FH, "$CMSConnectPath |")) {
            $CMSPassword = <FH>;
            chomp $CMSPassword;
            close FH;
        }
        else {
            $CMSPassword = "null";  #no password, an error will likely occur
        }
    }
    elsif (($SCHEMA eq "oncs")) {
        $CMSUser = "oncs";
        $CMSPassword = getdbpassword();
    }
    $ONCSUser = $CMSUser;
    $ONCSPassword = $CMSPassword; 
}

###################
sub getdbpassword {    #read the user password
###################
    my $dbusernme = $_[0];
    open(DBPASSFILE, "/home/oracle/etc/user");
    my $dbpassword = <DBPASSFILE>;
    chomp($dbpassword);
    close(DBPASSFILE);
    return($dbpassword);
}

1; #return true
