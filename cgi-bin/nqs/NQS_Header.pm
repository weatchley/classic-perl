#
# NQS Header file
#
# $Source: /usr/local/homes/atchleyb/rcs/qa/perl/RCS/NQS_Header.pm,v $
#
# $Revision: 1.7 $
#
# $Date: 2007/11/21 21:27:29 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: NQS_Header.pm,v $
# Revision 1.7  2007/11/21 21:27:29  atchleyb
# CREQ000112 - removed hardcoded path to root info
#
# Revision 1.6  2006/12/12 18:53:54  atchleyb
# updated for new environment
#
# Revision 1.5  2005/02/02 20:43:16  starkeyj
# added the global variables NQSIntranetReportlinkPath and NQSInternetReportlinkPath
#
# Revision 1.4  2004/05/30 22:19:51  starkeyj
# added variables to meet security requirements
#
# Revision 1.3  2004/01/13 13:41:24  starkeyj
# modified to add global variables for SCR 59
#
# Revision 1.2  2001/11/03 01:04:58  atchleyb
# added new values for ddt
#
# Revision 1.1  2001/07/06 23:09:01  starkeyj
# Initial revision
#
#
package NQS_Header;
use strict;
use Carp;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw ($NQSType $NQSUser $DefPassword $SCHEMA $NQSFontFace $NQSFontColor);
use vars qw ($NQSDocPath $NQSFullDocPath $NQSJavaScriptPath $NQSImagePath %NQSHash $NQSIntranetReportlinkPath $NQSInternetReportlinkPath);
use vars qw ($NQSProductionStatus $NQSDebug $NQSConnectPath $NQSDocDir $NQSReportPath $NQSFullWebReportPath);
use vars qw ($NQSFullReportPath $NQSTempReportPath $NQSFullTempReportPath $NQSServer $SYSUseSessions $SYSTimeout);
use vars qw ($NQSBackground $NQSCGIDir $MaxBytesStored $NQSImagesDir $SYSImagePath $SYSType $SYSDir $SYSPathRoot);
use vars qw ($SYSLockoutCount $SYSLockoutTime $SYSPassKey $SYSPasswordExpireMonths $SYSPasswordExpireWarn $SYSProductionStatus);

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ($NQSType $NQSUser $DefPassword $SCHEMA $NQSFontFace $NQSFontColor 
					$NQSDocPath $NQSFullDocPath $NQSJavaScriptPath $NQSImagePath %NQSHash 
					$NQSProductionStatus $NQSDebug $NQSConnectPath $NQSReportPath 
					$NQSFullReportPath $NQSTempReportPath $NQSFullTempReportPath $NQSFullWebReportPath
					$NQSServer $NQSCGIDir $NQSBackground $MaxBytesStored $NQSImagesDir $SYSImagePath $SYSType $SYSDir
					$SYSLockoutCount $SYSLockoutTime $SYSPassKey $SYSPasswordExpireMonths $SYSPasswordExpireWarn
					$SYSUseSessions $SYSTimeout $SYSProductionStatus $NQSIntranetReportlinkPath $NQSInternetReportlinkPath
					$SYSPathRoot);
@EXPORT_OK = qw($NQSType $NQSUser $DefPassword $SCHEMA $NQSFontFace $NQSFontColor 
					$NQSDocPath $NQSFullDocPath $NQSJavaScriptPath $NQSImagePath %NQSHash 
					$NQSProductionStatus $NQSDebug $NQSConnectPath $NQSReportPath $NQSFullWebReportPath
					$NQSFullReportPath $NQSTempReportPath $NQSFullTempReportPath 
					$NQSServer $NQSCGIDir $NQSBackground $MaxBytesStored $NQSImagesDir $SYSImagePath $SYSType $SYSDir
					$SYSLockoutCount $SYSLockoutTime $SYSPassKey $SYSPasswordExpireMonths $SYSPasswordExpireWarn
					$SYSUseSessions $SYSTimeout $SYSProductionStatus $NQSIntranetReportlinkPath $NQSInternetReportlinkPath
					$SYSPathRoot);
%EXPORT_TAGS =(
    Constants => [qw($NQSType $NQSUser $DefPassword $SCHEMA $NQSFontFace $NQSFontColor 
    					$NQSDocPath $NQSFullDocPath $NQSJavaScriptPath $NQSImagePath %NQSHash 
    					$NQSProductionStatus $NQSDebug $NQSConnectPath $NQSReportPath  $NQSFullWebReportPath
    					$NQSFullReportPath $NQSTempReportPath $NQSFullTempReportPath 
    					$NQSServer $NQSCGIDir $NQSBackground $MaxBytesStored $NQSImagesDir $SYSImagePath $SYSType $SYSDir
    					$SYSLockoutCount $SYSLockoutTime $SYSPassKey $SYSPasswordExpireMonths $SYSPasswordExpireWarn
    					$SYSUseSessions $SYSTimeout $SYSProductionStatus $NQSIntranetReportlinkPath $NQSInternetReportlinkPath
    					$SYSPathRoot) ]
);

$ENV{'ORACLE_HOME'} = "/usr/local/oracle8";

#$NQSType = "NQS";
#$NQSUser = "NQS";

my $temp = substr($ENV{'SCRIPT_FILENAME'},0,(rindex($ENV{'SCRIPT_FILENAME'},'/')));
$temp = substr($temp,(rindex($temp,'/') + 1));
#########################REMOVE AFTER TESTING#########################################################
$temp = "nqs" if (!(defined($temp)) || $temp ne "nqs");
$NQSType = uc($temp);
$ENV{'NQSType'} = $NQSType;

#$NQSProductionStatus = (index($ENV{'DOCUMENT_ROOT'}, "dev") >= 1) ? 0 : 1;
#$SYSProductionStatus = (index($ENV{'DOCUMENT_ROOT'}, "dev") >= 1) ? 0 : 1;
$NQSProductionStatus = ($ENV{'SERVER_STATE'} ne "PRODUCTION") ? 0 : 1;
$SYSProductionStatus = ($ENV{'SERVER_STATE'} ne "PRODUCTION") ? 0 : 1;
$NQSDebug = !$NQSProductionStatus;
#$SYSPathRoot = ($SYSProductionStatus) ? "/usr/local/www/gov.ymp.intranet" : "/usr/local/www/gov.ymp.intradev" ;
$SYSPathRoot = $ENV{PATH_TO_ROOT};

#$NQSConnectPath = ($NQSProductionStatus) ? "/usr/local/www" : "/data/dev" ;
$NQSConnectPath = $SYSPathRoot;
$NQSConnectPath .= "/cgi-bin/" . lc($NQSType) . "/oracle_nqs_connect.pl";

if (open (FH, "$NQSConnectPath |")) {
    ($temp, $NQSUser) = split('//', <FH>);
    close (FH);
    chop($NQSUser);
} else {
    $NQSUser = "null";
}

$SCHEMA = $NQSUser;
$NQSServer = (($NQSProductionStatus == 1) ? "ydoraprd.ymp.gov" : "ydoradev");
$MaxBytesStored = 104857600;  #100 MB file maximum (hopefully)
$SYSImagePath = "/" . lc($SYSType) . "/images";
$SYSType = uc($SYSDir);
$SYSDir = substr($temp,(rindex($temp,'/') + 1));
$SYSLockoutCount = 5;
$SYSLockoutTime = 5; # minutes
$SYSPassKey = "s44uc4ed6wdrwxrsphf4tb8o0x8mjx0p";
$SYSPasswordExpireMonths = 6;
$SYSPasswordExpireWarn = 14; #days
$SYSTimeout = (($SYSProductionStatus == 1) ? 60 : 480);
$SYSUseSessions = (($SYSProductionStatus == 1) ? 'F' : 'F');
$DefPassword = 'PASSWORD';
$NQSFontFace = "Times New Roman";
$NQSFontColor = "#000099";
#$NQSJavaScriptPath = "/" . lc($NQSType) . "/javascript";
$NQSJavaScriptPath = "/nqs/javascript";
$NQSIntranetReportlinkPath = "/nqs/reports";
$NQSInternetReportlinkPath = "/qa/reports";
$NQSBackground = "/images/background.gif";
$NQSImagePath = "/" . lc($NQSType) . "/images";
$NQSImagesDir = "/nqs/images";
$NQSDocDir = ($NQSProductionStatus) ? "prod" : "dev" ;
#$NQSDocPath .= "/temp/nqs/" . lc($NQSType) . "/" . $NQSDocDir . "/cd_images/bracketed";
#$NQSFullDocPath = "/data" . $NQSDocPath;
$NQSReportPath = "/nqs/" . $NQSDocDir . "/reports";
$NQSFullReportPath = "$SYSPathRoot/data" . $NQSReportPath;
$NQSTempReportPath = "/temp/nqs/" . $NQSDocDir . "/reports";
$NQSFullTempReportPath = "$SYSPathRoot/data" . $NQSTempReportPath;
$NQSFullWebReportPath = "/temp/nqs/$NQSDocDir/reports/web";
#$NQSFullWebReportPath = "/temp/nqs/prod/reports/web";
$NQSCGIDir = "/cgi-bin/nqs";

%NQSHash = ("NQSType" => $NQSType, "NQSUser" => $NQSUser, "DefPassword" => $DefPassword,
            "SCHEMA" => $SCHEMA, "NQSFontFace" => $NQSFontFace, "NQSFontColor" =>$NQSFontColor, "NQSCGIDir" =>$NQSCGIDir,
            "NQSDocPath" => $NQSDocPath, "NQSFullDocPath" => $NQSFullDocPath, "NQSJavaScriptPath" => $NQSJavaScriptPath,
            "NQSImagePath" => $NQSImagePath, "NQSProductionStatus" => $NQSProductionStatus, "NQSConnectPath" => $NQSConnectPath,
            "NQSReportPath" => $NQSReportPath, "NQSFullReportPath" => $NQSFullReportPath,
            "NQSTempReportPath" => $NQSTempReportPath, "NQSFullTempReportPath" => $NQSFullTempReportPath,
            "NQSFullWebReportPath" => $NQSFullWebReportPath, "NQSServer" => $NQSServer,
            "SYSLockoutCount" => $SYSLockoutCount, "SYSLockoutTime" => $SYSLockoutTime, "SYSPassKey" => $SYSPassKey,
            "SYSTimeout" => $SYSTimeout, "SYSUseSessions" => $SYSUseSessions, "NQSIntranetReportlinkPath" => $NQSIntranetReportlinkPath,
            "NQSInternetReportlinkPath" => $NQSInternetReportlinkPath);

$ENV{'DBUser'} = $NQSUser;
$ENV{'NQSConnectPath'} = $NQSConnectPath;
$ENV{'DefPassword'} = $DefPassword;
$ENV{'SCHEMA'} = $SCHEMA;
$ENV{'NQSServer'} = $NQSServer;
$ENV{'NQSFontFace'} = $NQSFontFace;
$ENV{'NQSFontColor'} = $NQSFontColor;
#$ENV{'NQSDocPath'} = $NQSDocPath;
#$ENV{'NQSFullDocPath'} = $NQSFullDocPath;
$ENV{'NQSJavaScriptPath'} = $NQSJavaScriptPath;
$ENV{'NQSReportPath'} = $NQSReportPath;
$ENV{'NQSFullReportPath'} = $NQSFullReportPath;
$ENV{'NQSTempReportPath'} = $NQSTempReportPath;
$ENV{'NQSFullTempReportPath'} = $NQSFullTempReportPath;
$ENV{'NQSFullWebReportPath'} = $NQSFullWebReportPath;
$ENV{'NQSCGIDir'} = $NQSCGIDir;
$ENV{'SYSLockoutCount'} = $SYSLockoutCount;
$ENV{'SYSLockoutTime'} = $SYSLockoutTime;
$ENV{'SYSPassKey'} = $SYSPassKey;
$ENV{'SYSTimeout'} = $SYSTimeout;
$ENV{'SYSUseSessions'} = $SYSUseSessions;


sub new {
    my $self = {};
    $self = { %NQSHash };
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
