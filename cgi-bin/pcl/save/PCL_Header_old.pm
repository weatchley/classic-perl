#
# SCM Header file
# $Source: /data/dev/rcs/pcl/perl/RCS/PCL_Header.pm,v $
# $Revision: 1.6 $
# $Date: 2003/01/27 23:51:04 $
# $Author: atchleyb $
# $Locker:  $
# $Log: PCL_Header.pm,v $
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

package PCL_Header;
use strict;
use Carp;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw (
      $PCLType               $PCLUser             $DefPassword   
      $SCHEMA                $PCLFontFace         $PCLFontColor 
      $PCLDocPath            $PCLFullDocPath      $PCLJavaScriptPath 
      $PCLImagePath          $PCLProductionStatus $PCLDebug
      $PCLConnectPath        $PCLDocDir           $PCLReportPath
      $PCLFullReportPath     $PCLTempReportPath   $PCLFullTempReportPath
      $PCLServer             $PCLCGIDir           $PCLPassKey
);

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      $PCLType               $PCLUser             $DefPassword   
      $SCHEMA                $PCLFontFace         $PCLFontColor 
      $PCLDocPath            $PCLFullDocPath      $PCLJavaScriptPath 
      $PCLImagePath          $PCLProductionStatus $PCLDebug
      $PCLConnectPath        $PCLDocDir           $PCLReportPath
      $PCLFullReportPath     $PCLTempReportPath   $PCLFullTempReportPath
      $PCLServer             $PCLCGIDir           $PCLPassKey
);
%EXPORT_TAGS =(
    Constants => [qw(
      $PCLType               $PCLUser             $DefPassword   
      $SCHEMA                $PCLFontFace         $PCLFontColor 
      $PCLDocPath            $PCLFullDocPath      $PCLJavaScriptPath 
      $PCLImagePath          $PCLProductionStatus $PCLDebug
      $PCLConnectPath        $PCLDocDir           $PCLReportPath
      $PCLFullReportPath     $PCLTempReportPath   $PCLFullTempReportPath
      $PCLServer             $PCLCGIDir           $PCLPassKey
    ) ]
);

$ENV{'ORACLE_HOME'} = "/usr/local/oracle8";

my $temp = substr($ENV{'SCRIPT_FILENAME'},0,(rindex($ENV{'SCRIPT_FILENAME'},'/')));
$temp = substr($temp,(rindex($temp,'/') + 1));
$PCLType = uc($temp);
$ENV{'PCLType'} = $PCLType;

$PCLProductionStatus = (index($ENV{'DOCUMENT_ROOT'}, "dev") >= 1) ? 0 : 1;
$PCLDebug = !$PCLProductionStatus;

$PCLConnectPath = ($PCLProductionStatus) ? "/usr/local/www" : "/data/dev" ;
$PCLConnectPath .= "/cgi-bin/" . lc($PCLType) . "/readFile.pl -file /data/apps/" . lc($PCLType) . "/.init";
if (open (FH, "$PCLConnectPath |")) {
    ($PCLUser, $temp) = split('//', <FH>);
    close (FH);
    chomp($PCLUser);
} 
else {
    $PCLUser = "null";
}

$SCHEMA = $PCLUser;
$PCLServer = (($PCLProductionStatus == 1) ? "ydoracle" : "ydoradev");

$DefPassword = 'PASSWORD';
$PCLFontFace = "Times New Roman";
$PCLFontColor = "#000099";
$PCLJavaScriptPath = "/" . lc($PCLType) . "/javascript";
$PCLImagePath = "/" . lc($PCLType) . "/images";

$PCLDocDir = ($PCLProductionStatus) ? "prod" : "dev" ;
$PCLDocPath .= "/temp/pcl/" . lc($PCLType) . "/" . $PCLDocDir;
$PCLFullDocPath = "/data" . $PCLDocPath;
$PCLReportPath = "/pcl/" . lc($PCLType) . "/" . $PCLDocDir;
$PCLFullReportPath = "/data" . $PCLReportPath;
$PCLTempReportPath = "/temp/pcl/" . lc($PCLType) . "/" . $PCLDocDir;
$PCLFullTempReportPath = "/data" . $PCLTempReportPath;
$PCLCGIDir = "/cgi-bin/pcl";
$PCLPassKey = "pjo2kntg8s5seyhiad72ivgd4lg7dr7e";

$ENV{'DBUser'} = $PCLUser;
$ENV{'PCLConnectPath'} = $PCLConnectPath;
$ENV{'DefPassword'} = $DefPassword;
$ENV{'SCHEMA'} = $SCHEMA;
$ENV{'PCLServer'} = $PCLServer;
$ENV{'PCLFontFace'} = $PCLFontFace;
$ENV{'PCLFontColor'} = $PCLFontColor;
$ENV{'PCLDocPath'} = $PCLDocPath;
$ENV{'PCLFullDocPath'} = $PCLFullDocPath;
$ENV{'PCLJavaScriptPath'} = $PCLJavaScriptPath;
$ENV{'PCLReportPath'} = $PCLReportPath;
$ENV{'PCLFullReportPath'} = $PCLFullReportPath;
$ENV{'PCLTempReportPath'} = $PCLTempReportPath;
$ENV{'PCLFullTempReportPath'} = $PCLFullTempReportPath;
$ENV{'PCLPassKey'} = $PCLPassKey;

1; #return true
