#
# CRD Header file
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/crd/perl/RCS/CRD_Header.pm,v $
#
# $Revision: 1.18 $
#
# $Date: 2007/11/23 19:34:24 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: CRD_Header.pm,v $
# Revision 1.18  2007/11/23 19:34:24  atchleyb
# CR 51 - Removed hard coded path to root
#
# Revision 1.17  2006/12/12 18:20:43  atchleyb
# updated for new environment
#
# Revision 1.16  2004/05/26 22:06:17  atchleyb
# updated to use newer password security
#
# Revision 1.15  2003/03/11 16:43:09  atchleyb
# updated to use new pcl schema instead of scm schema
#
# Revision 1.14  2001/07/30 20:43:19  naydenoa
# Added $SCMPath variable
#
# Revision 1.13  2001/02/12 18:15:21  atchleyb
# added determination of dev/prod server to select ydoracle/ydoradev
#
# Revision 1.12  2000/11/28 23:20:58  atchleyb
# fixed bug with $CRDFullTempReportPath
#
# Revision 1.11  2000/11/27 16:48:47  atchleyb
# fixed bug with changes to make only one header file
#
# Revision 1.10  2000/11/24 21:29:53  atchleyb
# Updated to get CRDType form directory path and CRDUser from .init file
#
# Revision 1.9  2000/11/17 22:13:40  atchleyb
# added $CRDTempReportPath and $CRDFullTempReportPath
#
# Revision 1.8  2000/11/15 21:16:09  atchleyb
# changed path from /crd to /temp/crd
#
# Revision 1.7  2000/08/14 16:44:46  atchleyb
# added CRDReportPath and full path variables
#
# Revision 1.6  2000/02/08 19:19:06  mccartym
# default schema to crduser
#
# Revision 1.5  2000/02/08 02:09:58  mccartym
# modify environment variables, remove hardcode 'EIS'
#
# Revision 1.4  2000/01/14 23:37:40  atchleyb
# updated to include $CRDFullPath
# changed oracle user to 'eis'
# revized the way $CRDDocPath is set up to match to document tree
#
# Revision 1.3  1999/09/14 22:43:33  atchleyb
# vars and code to determine if the script is running in production mode ($CRDProductionStatus, $CRDDebug)
#
# Revision 1.2  1999/07/22 22:51:03  atchleyb
# changed crddocpath
#
# Revision 1.1  1999/07/14 18:27:12  atchleyb
# Initial revision
#
#
#
package CRD_Header;
use strict;
use Carp;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw (
    $CRDType    $CRDUser        $DefPassword       $SCHEMA        $CRDFontFace           $CRDFontColor 
    $CRDDocPath $CRDFullDocPath $CRDJavaScriptPath $CRDImagePath  %CRDHash               $CRDProductionStatus 
    $CRDDebug   $CRDConnectPath $CRDDocDir         $CRDReportPath $CRDFullReportPath     $CRDTempReportPath 
    $CRDServer  $SCMPath        $PCLPath           $PCLSchema     $CRDFullTempReportPath
    $SYSLockoutCount            $SYSLockoutTime    $SYSPasswordExpireMonths              $SYSPasswordExpireWarn
    $SYSPathRoot
);

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
    $CRDType    $CRDUser        $DefPassword       $SCHEMA        $CRDFontFace           $CRDFontColor 
    $CRDDocPath $CRDFullDocPath $CRDJavaScriptPath $CRDImagePath  %CRDHash               $CRDProductionStatus 
    $CRDDebug   $CRDConnectPath $CRDDocDir         $CRDReportPath $CRDFullReportPath     $CRDTempReportPath 
    $CRDServer  $SCMPath        $PCLPath           $PCLSchema     $CRDFullTempReportPath
    $SYSLockoutCount            $SYSLockoutTime    $SYSPasswordExpireMonths              $SYSPasswordExpireWarn
);
%EXPORT_TAGS =(Constants => [qw(
    $CRDType    $CRDUser        $DefPassword       $SCHEMA        $CRDFontFace           $CRDFontColor 
    $CRDDocPath $CRDFullDocPath $CRDJavaScriptPath $CRDImagePath  %CRDHash               $CRDProductionStatus 
    $CRDDebug   $CRDConnectPath $CRDDocDir         $CRDReportPath $CRDFullReportPath     $CRDTempReportPath 
    $CRDServer  $SCMPath        $PCLPath           $PCLSchema     $CRDFullTempReportPath
    $SYSLockoutCount            $SYSLockoutTime    $SYSPasswordExpireMonths              $SYSPasswordExpireWarn
) ]);

$ENV{'ORACLE_HOME'} = "/usr/local/oracle8";

#$CRDType = "CRD";
#$CRDUser = "CRD";

my $temp = substr($ENV{'SCRIPT_FILENAME'},0,(rindex($ENV{'SCRIPT_FILENAME'},'/')));
$temp = substr($temp,(rindex($temp,'/') + 1));
$CRDType = uc($temp);
$ENV{'CRDType'} = $CRDType;

#$CRDProductionStatus = (index($ENV{'DOCUMENT_ROOT'}, "dev") >= 1) ? 0 : 1;
$CRDProductionStatus = ($ENV{'SERVER_STATE'} ne "PRODUCTION") ? 0 : 1;
$CRDDebug = !$CRDProductionStatus;

#$SYSPathRoot = ($CRDProductionStatus) ? "/usr/local/www/gov.ymp.intranet" : "/usr/local/www/gov.ymp.intradev" ;
$SYSPathRoot = $ENV{PATH_TO_ROOT};

#$CRDConnectPath = ($CRDProductionStatus) ? "/usr/local/www" : "/data/dev" ;
$CRDConnectPath = $SYSPathRoot;
$CRDConnectPath .= "/cgi-bin/" . lc($CRDType) . "/oracle_crd_connect.pl";
#$CRDConnectPath .= "/cgi-bin/" . lc($SYSType) . "/readFile.pl -file $SYSPathRoot/data/apps/" . lc($SYSType) . "/.init";

if (open (FH, "$CRDConnectPath |")) {
    ($temp, $CRDUser) = split('//', <FH>);
    close (FH);
    chop($CRDUser);
} else {
    $CRDUser = "null";
}

$SCHEMA = $CRDUser;
$CRDServer = (($CRDProductionStatus == 1) ? "ydoraprd.ymp.gov" : "ydoradev");

$DefPassword = 'PASSWORD';
$CRDFontFace = "Times New Roman";
$CRDFontColor = "#000099";
$CRDJavaScriptPath = "/" . lc($CRDType) . "/javascript";
$CRDImagePath = "/" . lc($CRDType) . "/images";
#$SCMPath = ($CRDProductionStatus) ? "/usr/local/www" : "/data/dev" ;
$SCMPath = "/cgi-bin/scm";
$PCLPath = "/cgi-bin/pcl";
$PCLSchema = "pcl";

$CRDDocDir = ($CRDProductionStatus) ? "prod" : "dev" ;
$CRDDocPath .= "/temp/crd/" . lc($CRDType) . "/" . $CRDDocDir . "/cd_images/bracketed";
#$CRDFullDocPath = "/data" . $CRDDocPath;
$CRDFullDocPath = "$SYSPathRoot/data" . $CRDDocPath;
$CRDReportPath = "/crd/" . lc($CRDType) . "/" . $CRDDocDir . "/reports";
#$CRDFullReportPath = "/data" . $CRDReportPath;
$CRDFullReportPath = "$SYSPathRoot/data" . $CRDReportPath;
$CRDTempReportPath = "/temp/crd/" . lc($CRDType) . "/" . $CRDDocDir . "/reports";
#$CRDFullTempReportPath = "/data" . $CRDTempReportPath;
$CRDFullTempReportPath = "$SYSPathRoot/data" . $CRDTempReportPath;
$SYSLockoutCount = 5;
$SYSLockoutTime = 5; # minutes
$SYSPasswordExpireMonths = 6;
$SYSPasswordExpireWarn = 14; #days

%CRDHash = ("CRDType" => $CRDType, "CRDUser" => $CRDUser, "DefPassword" => $DefPassword,
            "SCHEMA" => $SCHEMA, "CRDFontFace" => $CRDFontFace, "CRDFontColor" =>$CRDFontColor,
            "CRDDocPath" => $CRDDocPath, "CRDFullDocPath" => $CRDFullDocPath, "CRDJavaScriptPath" => $CRDJavaScriptPath, 
            "CRDImagePath" => $CRDImagePath, "CRDProductionStatus" => $CRDProductionStatus, "CRDConnectPath" => $CRDConnectPath, 
            "CRDReportPath" => $CRDReportPath, "CRDFullReportPath" => $CRDFullReportPath,
            "CRDTempReportPath" => $CRDTempReportPath, "CRDFullTempReportPath" => $CRDFullTempReportPath, "CRDServer" => $CRDServer,
            "SYSLockoutCount" => $SYSLockoutCount, "SYSLockoutTime" => $SYSLockoutTime);

$ENV{'DBUser'} = $CRDUser;
$ENV{'CRDConnectPath'} = $CRDConnectPath;
$ENV{'DefPassword'} = $DefPassword;
$ENV{'SCHEMA'} = $SCHEMA;
$ENV{'CRDServer'} = $CRDServer;
$ENV{'CRDFontFace'} = $CRDFontFace;
$ENV{'CRDFontColor'} = $CRDFontColor;
$ENV{'CRDDocPath'} = $CRDDocPath;
$ENV{'CRDFullDocPath'} = $CRDFullDocPath;
$ENV{'CRDJavaScriptPath'} = $CRDJavaScriptPath;
$ENV{'CRDReportPath'} = $CRDReportPath;
$ENV{'CRDFullReportPath'} = $CRDFullReportPath;
$ENV{'CRDTempReportPath'} = $CRDTempReportPath;
$ENV{'CRDFullTempReportPath'} = $CRDFullTempReportPath;
$ENV{'SYSLockoutCount'} = $SYSLockoutCount;
$ENV{'SYSLockoutTime'} = $SYSLockoutTime;

sub new {
    my $self = {};
    $self = { %CRDHash };
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
