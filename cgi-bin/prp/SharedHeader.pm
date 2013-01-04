#
# Header file
# $Source: /usr/local/homes/higashis/www/gov.doe.ocrwm.ydappdev/rcs/prp/perl/RCS/SharedHeader.pm,v $
# $Revision: 1.8 $
# $Date: 2007/11/27 00:58:38 $
# $Author: higashis $
# $Locker: higashis $
#
# $Log: SharedHeader.pm,v $
# Revision 1.8  2007/11/27 00:58:38  higashis
# change request implementation item a, b, c (the first try)
#
# Revision 1.6  2007/11/20 23:37:56  higashis
# ${ENV} 'PATH_TO_ROOT' added to SharedHeader.pm .
#
# Revision 1.5  2006/12/12 19:16:54  atchleyb
# updated for new environment
#
# Revision 1.4  2004/12/15 23:08:56  naydenoa
# Added standard colors for QARD text based on related source requirement
# type (phase 2 requirement)
#
# Revision 1.3  2004/06/15 23:12:08  naydenoa
# Added color and header variables
#
# Revision 1.2  2004/05/07 22:00:50  naydenoa
# Added password security updates
# New variables: $SYSLockoutCount, $SYSLockoutTime
#
# Revision 1.1  2004/04/22 20:34:34  naydenoa
# Initial revision
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
      $SYSTitle              $IEOnly              $SYSColorBlue
      $SYSColorRed           $SYSColorGreen       $SYSColorOrange
      $SYSColorRedHeader     $SYSColorGreenHeader $SYSColorBlueHeader
      $SYSLockoutCount       $SYSLockoutTime      $SYSColorPurple
      $SYSColorPurpleHeader  $Regulatory          $RegulatoryHeader
      $Commitment            $CommitmentHeader    $Guidance
      $GuidanceHeader        $Reference           $ReferenceHeader
      $SYSPathRoot
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
      $SYSTitle              $IEOnly              $SYSColorBlue
      $SYSColorRed           $SYSColorGreen       $SYSColorOrange
      $SYSColorRedHeader     $SYSColorGreenHeader $SYSColorBlueHeader
      $SYSLockoutCount       $SYSLockoutTime      $SYSColorPurple
      $SYSColorPurpleHeader  $Regulatory          $RegulatoryHeader
      $Commitment            $CommitmentHeader    $Guidance
      $GuidanceHeader        $Reference           $ReferenceHeader
      $SYSPathRoot
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
      $SYSTitle              $IEOnly              $SYSColorBlue
      $SYSColorRed           $SYSColorGreen       $SYSColorOrange
      $SYSColorRedHeader     $SYSColorGreenHeader $SYSColorBlueHeader
      $SYSLockoutCount       $SYSLockoutTime      $SYSColorPurple
      $SYSColorPurpleHeader  $Regulatory          $RegulatoryHeader
      $Commitment            $CommitmentHeader    $Guidance
      $GuidanceHeader        $Reference           $ReferenceHeader
      $SYSPathRoot
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
$SYSPathRoot = $ENV{'PATH_TO_ROOT'} ;

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
$SYSFontFace = "Helvetica";
#$SYSFontFace = "Times New Roman";
$SYSFontColor = "#000000";
#$SYSFontColor = "#000099";
$SYSJavaScriptPath = "/$SYSDir/javascript";
$SYSImagePath = "/$SYSDir/images";
$PCLPath = "/cgi-bin/pcl";
$PCLSchema = "pcl";
$SYSTitle = "Project Requirements Processing System";

$IEOnly = (($SYSProductionStatus == 1) ? "T" : "F");

$SYSDocDir = ($SYSProductionStatus) ? "prod" : "dev" ;
$SYSDocPath .= "/temp/$SYSDir/" . $SYSDocDir;
#$SYSFullDocPath = "/data" . $SYSDocPath;
$SYSFullDocPath = "$SYSPathRoot" . $SYSDocPath;
$SYSReportPath = "/$SYSDir/" . $SYSDocDir;
#$SYSFullReportPath = "/data" . $SYSReportPath;
$SYSFullReportPath = "$SYSPathRoot" . $SYSReportPath;
$SYSTempReportPath = "/temp/$SYSDir/" . $SYSDocDir;
#$SYSFullTempReportPath = "/data" . $SYSTempReportPath;
$SYSFullTempReportPath = "$SYSPathRoot" . $SYSTempReportPath;
$CGIDIR = "/cgi-bin/$SYSDir";
$SYSPassKey = "hxjgbkkmefrvnjt8riwql34ldr2bebct";
$SYSTimeout = (($SYSProductionStatus == 1) ? 120 : 480);
$SYSUseSessions = (($SYSProductionStatus == 1) ? 'T' : 'T');
$SYSLockoutCount = 5;
$SYSLockoutTime = 5; # minutes

$SYSColorBlueHeader = "#9999ff";
$SYSColorBlue = "#0000cc";
$SYSColorRedHeader = "#cc6666"; 
$SYSColorRed = "#cc0000"; 
$SYSColorGreenHeader = "#66cc66";
$SYSColorGreen = "#009900";
$SYSColorOrange = "#ff9900";
$SYSColorPurple = "#990099";
$SYSColorPurpleHeader = "#cc00ff";

$Commitment = "#009900";
$CommitmentHeader = "#66cc66";
$Guidance = "#cc0000"; 
$GuidanceHeader = "#cc6666"; 
$Regulatory = "#0000bb";
$RegulatoryHeader = "#9999ff";
$Reference = "#990099";
$ReferenceHeader = "#cc00ff";

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
