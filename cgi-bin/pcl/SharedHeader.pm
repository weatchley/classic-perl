#
# SCM Header file
# $Source: /usr/local/www/gov.ymp.intradev/rcs/pcl/perl/RCS/SharedHeader.pm,v $
# $Revision: 1.16 $
# $Date: 2007/11/23 19:45:07 $
# $Author: atchleyb $
# $Locker:  $
#
# $Log: SharedHeader.pm,v $
# Revision 1.16  2007/11/23 19:45:07  atchleyb
# CR 20 - Removed hard coded path to root
#
# Revision 1.15  2006/12/12 19:07:59  atchleyb
# updated for new environment
#
# Revision 1.14  2004/06/08 21:41:05  munroeb
# Added SysLockoutCount to fix problem with people getting locked out after failing once.
#
# Revision 1.13  2004/05/26 17:50:17  munroeb
# Added $SYSLockoutTime to module, to prevent error with incorrect userid/password combos
#
# Revision 1.12  2004/05/21 19:26:04  munroeb
# modified to reflect cybersecurity password change issue
#
# Revision 1.11  2003/12/04 17:46:42  naydenoa
# Changed the production timeout from 60 to 240 minutes.
#
# Revision 1.10  2003/03/03 17:02:35  atchleyb
# changed flag to turn on session management on procution
#
# Revision 1.9  2003/02/14 18:16:38  atchleyb
# added improved password security
#
# Revision 1.8  2003/02/12 18:48:00  atchleyb
# added session management
#
# Revision 1.7  2003/02/03 18:49:42  atchleyb
# updated to removed PCL from script and variable names
#
# Revision 1.6  2003/01/27 23:51:04  atchleyb
# updated password key
#
# Revision 1.5  2003/01/27 22:38:26  atchleyb
# added encryption key for schema password
# changed all refferences to SCM to PCL
# removed unneeded object code
#
# Revision 1.4  2002/12/31 21:30:58  atchleyb
# changed scm to pcl
#
# Revision 1.3  2002/09/24 18:25:13  atchleyb
# removed unneeded values and cleaned up structure
#
# Revision 1.2  2002/09/18 16:41:39  atchleyb
# removed the use of oracle connect script, replaced with readFile.pl
#
# Revision 1.1  2002/09/17 20:07:06  atchleyb
# Initial revision
#
#

package SharedHeader;
use strict;
use Carp;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw (
      $SYSType               $SYSUser             $DefPassword
      $SCHEMA                $SYSFontFace         $SYSFontColor
      $SYSDocPath            $SYSFullDocPath      $SYSJavaScriptPath
      $SYSImagePath          $SYSProductionStatus $SYSDebug
      $SYSConnectPath        $SYSDocDir           $SYSReportPath
      $SYSFullReportPath     $SYSTempReportPath   $SYSFullTempReportPath
      $SYSServer             $SYSCGIDir           $SYSPassKey
      $SYSTimeout            $SYSUseSessions      $SYSPasswordExpireMonths
      $SYSPasswordExpireWarn $SYSDir              $SYSLockoutCount
      $SYSLockoutTime        $SYSPathRoot
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
      $SYSServer             $SYSCGIDir           $SYSPassKey
      $SYSTimeout            $SYSUseSessions      $SYSPasswordExpireMonths
      $SYSPasswordExpireWarn $SYSDir              $SYSLockoutCount
      $SYSLockoutTime        $SYSPathRoot
);
%EXPORT_TAGS =(
    Constants => [qw(
      $SYSType               $SYSUser             $DefPassword
      $SCHEMA                $SYSFontFace         $SYSFontColor
      $SYSDocPath            $SYSFullDocPath      $SYSJavaScriptPath
      $SYSImagePath          $SYSProductionStatus $SYSDebug
      $SYSConnectPath        $SYSDocDir           $SYSReportPath
      $SYSFullReportPath     $SYSTempReportPath   $SYSFullTempReportPath
      $SYSServer             $SYSCGIDir           $SYSPassKey
      $SYSTimeout            $SYSUseSessions      $SYSPasswordExpireMonths
      $SYSPasswordExpireWarn $SYSDir              $SYSLockoutCount
      $SYSLockoutTime        $SYSPathRoot
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

$DefPassword = 'PASSWORD';
#$DefPassword = 'aCCESS1cODE2!';
$SYSPasswordExpireMonths = 6;
$SYSPasswordExpireWarn = 14; #days
$SYSFontFace = "Times New Roman";
$SYSFontColor = "#000099";
$SYSJavaScriptPath = "/" . lc($SYSType) . "/javascript";
$SYSImagePath = "/" . lc($SYSType) . "/images";

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
$SYSCGIDir = "/cgi-bin/pcl";
$SYSPassKey = "pjo2kntg8s5seyhiad72ivgd4lg7dr7e";
$SYSTimeout = (($SYSProductionStatus == 1) ? 240 : 480);
#$SYSTimeout = (($SYSProductionStatus == 1) ? 60 : 480);
$SYSUseSessions = (($SYSProductionStatus == 1) ? 'T' : 'T');
$SYSLockoutTime = 5; # minutes
$SYSLockoutCount = 5;

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

1; #return true
