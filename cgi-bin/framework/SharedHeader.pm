#
# Header file
# $Source$
# $Revision$
# $Date$
# $Author$
# $Locker$
# $Log$
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

$SYSPathRoot = ($SYSProductionStatus) ? "/usr/local/www/gov.ymp.intranet" : "/usr/local/www/gov.ymp.intradev" ;

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
$SYSServer = (($SYSProductionStatus == 1) ? "ydoraprd.ymp.gov" : "ydoraprd.ymp.gov");
#$SYSServer = (($SYSProductionStatus == 1) ? "host=ydoraprd.ymp.gov;sid=ydor" : "host=ydoradev.ymp.gov;sid=ydor");
#$SYSServer = (($SYSProductionStatus == 1) ? "ydoracle" : "host=204.140.46.92;sid=xe");
#$SYSServer = (($SYSProductionStatus == 1) ? "ydoracle" : "204.140.46.92");

$DefPassword = 'aCCESS1cODE2!';
$SYSPasswordExpireMonths = 6;
$SYSPasswordExpireWarn = 14; #days
$SYSFontFace = "Times New Roman";
$SYSFontColor = "#000099";
$SYSJavaScriptPath = "/$SYSDir/javascript";
$SYSImagePath = "/$SYSDir/images";
$PCLPath = "/cgi-bin/pcl";
$PCLSchema = "pcl";
$SYSTitle = "System Frame Work";

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
$SYSPassKey = "s44uc4ed6wdrwxrsphf4tb8o0x8mjx0p";
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
