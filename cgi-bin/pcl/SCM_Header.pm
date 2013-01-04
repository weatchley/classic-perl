#
# SCM Header file
# $Source: /usr/local/www/gov.ymp.intradev/rcs/pcl/perl/RCS/SCM_Header.pm,v $
# $Revision: 1.2 $
# $Date: 2007/11/23 19:45:07 $
# $Author: atchleyb $
# $Locker:  $
# $Log: SCM_Header.pm,v $
# Revision 1.2  2007/11/23 19:45:07  atchleyb
# CR 20 - Removed hard coded path to root
#
# Revision 1.1  2006/12/12 19:07:59  atchleyb
# Initial revision
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

package SCM_Header;
use strict;
use Carp;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw (
      $SCMType               $SCMUser             $DefPassword   
      $SCHEMA                $SCMFontFace         $SCMFontColor 
      $SCMDocPath            $SCMFullDocPath      $SCMJavaScriptPath 
      $SCMImagePath          $SCMProductionStatus $SCMDebug
      $SCMConnectPath        $SCMDocDir           $SCMReportPath
      $SCMFullReportPath     $SCMTempReportPath   $SCMFullTempReportPath
      $SCMServer             $SCMCGIDir           $SCMPassKey
      $SYSPathRoot
);

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      $SCMType               $SCMUser             $DefPassword   
      $SCHEMA                $SCMFontFace         $SCMFontColor 
      $SCMDocPath            $SCMFullDocPath      $SCMJavaScriptPath 
      $SCMImagePath          $SCMProductionStatus $SCMDebug
      $SCMConnectPath        $SCMDocDir           $SCMReportPath
      $SCMFullReportPath     $SCMTempReportPath   $SCMFullTempReportPath
      $SCMServer             $SCMCGIDir           $SCMPassKey
);
%EXPORT_TAGS =(
    Constants => [qw(
      $SCMType               $SCMUser             $DefPassword   
      $SCHEMA                $SCMFontFace         $SCMFontColor 
      $SCMDocPath            $SCMFullDocPath      $SCMJavaScriptPath 
      $SCMImagePath          $SCMProductionStatus $SCMDebug
      $SCMConnectPath        $SCMDocDir           $SCMReportPath
      $SCMFullReportPath     $SCMTempReportPath   $SCMFullTempReportPath
      $SCMServer             $SCMCGIDir           $SCMPassKey
    ) ]
);

$ENV{'ORACLE_HOME'} = "/usr/local/oracle8";

my $temp = substr($ENV{'SCRIPT_FILENAME'},0,(rindex($ENV{'SCRIPT_FILENAME'},'/')));
$temp = substr($temp,(rindex($temp,'/') + 1));
$SCMType = uc($temp);
$ENV{'SCMType'} = $SCMType;

#$SCMProductionStatus = (index($ENV{'DOCUMENT_ROOT'}, "dev") >= 1) ? 0 : 1;
$SCMProductionStatus = ($ENV{'SERVER_STATE'} ne "PRODUCTION") ? 0 : 1;
$SCMDebug = !$SCMProductionStatus;

#$SYSPathRoot = ($SCMProductionStatus) ? "/usr/local/www/gov.ymp.intranet" : "/usr/local/www/gov.ymp.intradev" ;
$SYSPathRoot = $ENV{PATH_TO_ROOT};

#$SCMConnectPath = ($SCMProductionStatus) ? "/usr/local/www" : "/data/dev" ;
$SCMConnectPath = $SYSPathRoot;
#$SCMConnectPath .= "/cgi-bin/" . lc($SCMType) . "/readFile.pl -file /data/apps/" . lc($SCMType) . "/.init";
$SCMConnectPath .= "/cgi-bin/" . lc($SCMType) . "/readFile.pl -file $SYSPathRoot/data/apps/" . lc($SCMType) . "/.init";
if (open (FH, "$SCMConnectPath |")) {
    ($SCMUser, $temp) = split('//', <FH>);
    close (FH);
    chomp($SCMUser);
} 
else {
    $SCMUser = "null";
}

$SCHEMA = $SCMUser;
$SCMServer = (($SCMProductionStatus == 1) ? "ydoraprd.ymp.gov" : "ydoradev");

$DefPassword = 'PASSWORD';
$SCMFontFace = "Times New Roman";
$SCMFontColor = "#000099";
$SCMJavaScriptPath = "/" . lc($SCMType) . "/javascript";
$SCMImagePath = "/" . lc($SCMType) . "/images";

$SCMDocDir = ($SCMProductionStatus) ? "prod" : "dev" ;
$SCMDocPath .= "/temp/pcl/" . lc($SCMType) . "/" . $SCMDocDir;
#$SCMFullDocPath = "/data" . $SCMDocPath;
$SCMFullDocPath = "$SYSPathRoot/data" . $SCMDocPath;
$SCMReportPath = "/pcl/" . lc($SCMType) . "/" . $SCMDocDir;
#$SCMFullReportPath = "/data" . $SCMReportPath;
$SCMFullReportPath = "$SYSPathRoot/data" . $SCMReportPath;
$SCMTempReportPath = "/temp/pcl/" . lc($SCMType) . "/" . $SCMDocDir;
#$SCMFullTempReportPath = "/data" . $SCMTempReportPath;
$SCMFullTempReportPath = "$SYSPathRoot/data" . $SCMTempReportPath;
$SCMCGIDir = "/cgi-bin/pcl";
$SCMPassKey = "pjo2kntg8s5seyhiad72ivgd4lg7dr7e";

$ENV{'DBUser'} = $SCMUser;
$ENV{'SCMConnectPath'} = $SCMConnectPath;
$ENV{'DefPassword'} = $DefPassword;
$ENV{'SCHEMA'} = $SCHEMA;
$ENV{'SCMServer'} = $SCMServer;
$ENV{'SCMFontFace'} = $SCMFontFace;
$ENV{'SCMFontColor'} = $SCMFontColor;
$ENV{'SCMDocPath'} = $SCMDocPath;
$ENV{'SCMFullDocPath'} = $SCMFullDocPath;
$ENV{'SCMJavaScriptPath'} = $SCMJavaScriptPath;
$ENV{'SCMReportPath'} = $SCMReportPath;
$ENV{'SCMFullReportPath'} = $SCMFullReportPath;
$ENV{'SCMTempReportPath'} = $SCMTempReportPath;
$ENV{'SCMFullTempReportPath'} = $SCMFullTempReportPath;
$ENV{'SCMPassKey'} = $SCMPassKey;

1; #return true
