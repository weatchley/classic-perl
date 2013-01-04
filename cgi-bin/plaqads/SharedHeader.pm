#
# Header file
# $Source: /usr/local/www/gov.ymp.intradev/rcs/plaqads/perl/RCS/SharedHeader.pm,v $
# $Revision: 1.3 $
# $Date: 2007/11/21 21:45:32 $
# $Author: atchleyb $
# $Locker:  $
# $Log: SharedHeader.pm,v $
# Revision 1.3  2007/11/21 21:45:32  atchleyb
# CR003 - modified to remove hard coded path to application root
#
# Revision 1.2  2006/12/12 19:13:24  atchleyb
# Updated for new environment
#
# Revision 1.1  2004/07/27 18:27:16  atchleyb
# Initial revision
#
#
#

package SharedHeader;
use strict;
use Carp;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw($SYSDir);
use vars qw (
      $SYSType               $SYSUser             $DefPassword   
      $SCHEMA                $SYSFontFace         $SYSFontColor 
      $SYSDocPath            $SYSFullDocPath      $SYSJavaScriptPath 
      $SYSImagePath          $SYSProductionStatus $SYSDebug
      $SYSConnectPath        $SYSDocDir           $SYSReportPath
      $SYSFullReportPath     $SYSTempReportPath   $SYSFullTempReportPath
      $SYSServer             $CGIDIR              $PCLPath
      $SYSUseSessions        $SYSTimeout          $SYSPasswordExpireMonths
      $SYSPasswordExpireWarn $SYSPassKey          $PCLSchema
      $SYSTitle              $IEOnly
      $SYSLockoutCount       $SYSLockoutTime      $SYSPathRoot
);

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      $SYSType               $SYSUser             $DefPassword   
      $SCHEMA                $SYSFontFace         $SYSFontColor 
      $SYSDocPath            $SYSFullDocPath      $SYSJavaScriptPath 
      $SYSImagePath          $SYSProductionStatus $SYSDebug
      $SYSConnectPath        $SYSDocDir           $SYSReportPath
      $SYSFullReportPath     $SYSTempReportPath   $SYSFullTempReportPath
      $SYSServer             $CGIDIR              $PCLPath
      $SYSUseSessions        $SYSTimeout          $SYSPasswordExpireMonths
      $SYSPasswordExpireWarn $SYSPassKey          $PCLSchema
      $SYSTitle              $IEOnly
      $SYSLockoutCount       $SYSLockoutTime      $SYSPathRoot
);
%EXPORT_TAGS =(
    Constants => [qw(
      $SYSType               $SYSUser             $DefPassword   
      $SCHEMA                $SYSFontFace         $SYSFontColor 
      $SYSDocPath            $SYSFullDocPath      $SYSJavaScriptPath 
      $SYSImagePath          $SYSProductionStatus $SYSDebug
      $SYSConnectPath        $SYSDocDir           $SYSReportPath
      $SYSFullReportPath     $SYSTempReportPath   $SYSFullTempReportPath
      $SYSServer             $CGIDIR              $PCLPath
      $SYSUseSessions        $SYSTimeout          $SYSPasswordExpireMonths
      $SYSPasswordExpireWarn $SYSPassKey          $PCLSchema
      $SYSTitle              $IEOnly
      $SYSLockoutCount       $SYSLockoutTime      $SYSPathRoot
    ) ]
);

$ENV{'ORACLE_HOME'} = "/usr/local/oracle8";

my $temp = substr($ENV{'SCRIPT_FILENAME'},0,(rindex($ENV{'SCRIPT_FILENAME'},'/')));
$SYSDir = substr($temp,(rindex($temp,'/') + 1));
$SYSType = uc($SYSDir);
$ENV{'SYSType'} = $SYSType;

#$SYSProductionStatus = (index($ENV{'DOCUMENT_ROOT'}, "dev") >= 1) ? 0 : 1;
$SYSProductionStatus = ($ENV{'SERVER_STATE'} ne "PRODUCTION") ? 0 : 1;
$SYSDebug = !$SYSProductionStatus;

#$SYSPathRoot = ($SYSProductionStatus) ? "/usr/local/www/gov.ymp.intranet" : "/usr/local/www/gov.ymp.intradev" ;
$SYSPathRoot = $ENV{PATH_TO_ROOT};

#$SYSConnectPath = ($SYSProductionStatus) ? "/usr/local/www" : "/data/dev" ;
$SYSConnectPath = $SYSPathRoot;
#$SYSConnectPath .= "/cgi-bin/" . lc($SYSType) . "/readFile.pl -file /data/apps/" . lc($SYSType) . "/.init";
$SYSConnectPath .= "/cgi-bin/" . lc($SYSType) . "/readFile.pl -file $SYSPathRoot/data/apps/" . lc($SYSType) . "/.init";
if (open (FH, "$SYSConnectPath |")) {
    ($SYSUser, $temp) = split('//', <FH>);
    close (FH);
    chomp($SYSUser);
} 
else {
    $SYSUser = "null";
}

$SCHEMA = $SYSUser;
$SYSServer = (($SYSProductionStatus == 1) ? "ydoraprd.ymp.gov" : "ydoradev");

$DefPassword = 'aCCESS1cODE2!';
$SYSPasswordExpireMonths = 6;
$SYSPasswordExpireWarn = 14; #days
$SYSFontFace = "Times New Roman";
$SYSFontColor = "#000099";
$SYSJavaScriptPath = "/$SYSDir/javascript";
$SYSImagePath = "/$SYSDir/images";
$PCLPath = "/cgi-bin/pcl";
$PCLSchema = "pcl";
$SYSTitle = "PLAQADS";

$IEOnly = (($SYSProductionStatus == 1) ? "T" : "F");

$SYSDocDir = ($SYSProductionStatus) ? "prod" : "dev" ;
$SYSDocPath .= "/temp/$SYSDir/" . $SYSDocDir;
#$SYSFullDocPath = "/data" . $SYSDocPath;
$SYSFullDocPath = "$SYSPathRoot/data" . $SYSDocPath;
$SYSReportPath = "/$SYSDir/" . $SYSDocDir;
#$SYSFullReportPath = "/data" . $SYSReportPath;
$SYSFullReportPath = "$SYSPathRoot/data" . $SYSReportPath;
$SYSTempReportPath = "/temp/$SYSDir/" . $SYSDocDir;
#$SYSFullTempReportPath = "/data" . $SYSTempReportPath;
$SYSFullTempReportPath = "$SYSPathRoot/data" . $SYSTempReportPath;
$CGIDIR = "/cgi-bin/$SYSDir";
$SYSPassKey = "6l31cx5bvk845e2k35xpd1t7258wec2n";
$SYSTimeout = (($SYSProductionStatus == 1) ? 60 : 480);
$SYSUseSessions = (($SYSProductionStatus == 1) ? 'T' : 'T');
$SYSLockoutCount = 5;
$SYSLockoutTime = 5; # minutes

$ENV{'DBUser'} = $SYSUser;
$ENV{'SYSConnectPath'} = $SYSConnectPath;
$ENV{'DefPassword'} = $DefPassword;
$ENV{'SCHEMA'} = $SCHEMA;
$ENV{'SYSServer'} = $SYSServer;
$ENV{'SYSFontFace'} = $SYSFontFace;
$ENV{'SYSFontColor'} = $SYSFontColor;
$ENV{'SYSDocPath'} = $SYSDocPath;
$ENV{'SYSFullDocPath'} = $SYSFullDocPath;
$ENV{'SYSJavaScriptPath'} = $SYSJavaScriptPath;
$ENV{'SYSReportPath'} = $SYSReportPath;
$ENV{'SYSFullReportPath'} = $SYSFullReportPath;
$ENV{'SYSTempReportPath'} = $SYSTempReportPath;
$ENV{'SYSFullTempReportPath'} = $SYSFullTempReportPath;
$ENV{'SYSPassKey'} = $SYSPassKey;
$ENV{'SYSTimeout'} = $SYSTimeout;
$ENV{'SYSUseSessions'} = $SYSUseSessions;
$ENV{'SYSTitle'} = $SYSTitle;
$ENV{'SYSLockoutCount'} = $SYSLockoutCount;
$ENV{'SYSLockoutTime'} = $SYSLockoutTime;


1; #return true
