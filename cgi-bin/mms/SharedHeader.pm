#
# Header file
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/SharedHeader.pm,v $
# $Revision: 1.6 $
# $Date: 2007/11/21 21:35:01 $
# $Author: atchleyb $
# $Locker:  $
# $Log: SharedHeader.pm,v $
# Revision 1.6  2007/11/21 21:35:01  atchleyb
# CR00038 - removed hard coded path to application root
#
# Revision 1.5  2006/12/12 18:47:39  atchleyb
# updated for new environment
#
# Revision 1.4  2006/05/17 23:02:17  atchleyb
# CR0026 - added emailHelpText and SYSClient
#
# Revision 1.3  2005/01/24 16:12:07  atchleyb
# Updated to change session time out period for production ref CREQ00002
#
# Revision 1.2  2004/05/07 16:00:15  atchleyb
# Updated with new password security changes
#
# Revision 1.1  2003/11/12 20:30:29  atchleyb
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
      $SYSTitle              $SYSFullImagePath    $SYSClient
      $SYSLockoutCount       $SYSLockoutTime      $emailHelpText
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
      $SYSTitle              $SYSFullImagePath    $SYSClient
      $SYSLockoutCount       $SYSLockoutTime      $emailHelpText
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
      $SYSTitle              $SYSFullImagePath    $SYSClient
      $SYSLockoutCount       $SYSLockoutTime      $emailHelpText
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
#$SYSServer = (($SYSProductionStatus == 1) ? "ydoraprd.ymp.gov" : "ydoradev");
$SYSServer = (($SYSProductionStatus == 1) ? "ydoraprd.ymp.gov" : "ydoradev.ymp.gov");

$DefPassword = 'aCCESS1cODE2!';
$SYSPasswordExpireMonths = 6;
$SYSPasswordExpireWarn = 14; #days
$SYSFontFace = "Times New Roman";
$SYSFontColor = "#000099";
$SYSJavaScriptPath = "/$SYSDir/javascript";
$SYSImagePath = "/$SYSDir/images";
$SYSFullImagePath = $SYSPathRoot . "/www/$SYSImagePath";
$PCLPath = "/cgi-bin/pcl";
$PCLSchema = "pcl";
$SYSTitle = "Materials Management System";

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
$SYSPassKey = "bs6bqc24a9l1ls59x8lc5jkclechkdys";
$SYSTimeout = (($SYSProductionStatus == 1) ? 240 : 480);
$SYSUseSessions = (($SYSProductionStatus == 1) ? 'T' : 'T');
$SYSLockoutCount = 5;
$SYSLockoutTime = 5; # minutes
$SYSClient = "DOE";

$emailHelpText = "\n";
#$emailHelpText = "\n    -- This is a computer generated e-mail that requires categorization by the recipient --    \n\n\n";
#$emailHelpText.= "\n    -- ---------- --    \n";
#$emailHelpText .= "This email message is an extra copy of information stored in an automated system and as such is not a Federal Record. \n"; 
#$emailHelpText .= "Delete this message after you have used it as a reminder or notice.\n\n";

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
$ENV{'SYSClient'} = $SYSClient;
$ENV{'emailHelpText'} = $emailHelpText;


1; #return true
