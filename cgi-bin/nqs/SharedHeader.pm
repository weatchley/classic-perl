#
# $Source: /usr/local/homes/atchleyb/rcs/qa/perl/RCS/SharedHeader.pm,v $
# $Revision: 1.3 $
# $Date: 2007/11/21 21:27:29 $
# $Author: atchleyb $
#
# $Source: /usr/local/homes/atchleyb/rcs/qa/perl/RCS/SharedHeader.pm,v $
# $Revision: 1.3 $
# $Date: 2007/11/21 21:27:29 $
# $Author: atchleyb $
# $Locker:  $
# $Log: SharedHeader.pm,v $
# Revision 1.3  2007/11/21 21:27:29  atchleyb
# CREQ000112 - removed hardcoded path to root info
#
# Revision 1.2  2006/12/12 18:53:54  atchleyb
# updated for new environment
#
# Revision 1.1  2004/01/13 14:33:41  starkeyj
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
      $SYSPasswordExpireWarn $SYSDir		  $SYSPathRoot
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
      $SYSPasswordExpireWarn $SYSDir		  $SYSPathRoot
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
      $SYSPasswordExpireWarn $SYSDir		  $SYSPathRoot
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
$SYSConnectPath .= "/cgi-bin/" . lc($SYSType) . "/readFile.pl -file /data/apps/" . lc($SYSType) . "/.init";
if (open (FH, "$SYSConnectPath |")) {
    ($SYSUser, $temp) = split('//', <FH>);
    close (FH);
    chomp($SYSUser);
} 
else {
    $SYSUser = "null";
}

#$SCHEMA = $SYSUser;
$SCHEMA = "NQS";
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
$SYSFullDocPath = "$SYSPathRoot/data" . $SYSDocPath;
$SYSReportPath = "/$SYSDir/" . $SYSDocDir;
$SYSFullReportPath = "$SYSPathRoot/data" . $SYSReportPath;
$SYSTempReportPath = "/temp/$SYSDir/" . $SYSDocDir;
$SYSFullTempReportPath = "$SYSPathRoot/data" . $SYSTempReportPath;
$SYSCGIDir = "/cgi-bin/pcl";
$SYSPassKey = "pjo2kntg8s5seyhiad72ivgd4lg7dr7e";
$SYSTimeout = (($SYSProductionStatus == 1) ? 240 : 480);
#$SYSTimeout = (($SYSProductionStatus == 1) ? 60 : 480);
$SYSUseSessions = (($SYSProductionStatus == 1) ? 'T' : 'T');

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
