#
# DMS Header file
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/dms/perl/RCS/DMS_Header.pm,v $
#
# $Revision: 1.5 $
#
# $Date: 2007/11/23 19:23:27 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DMS_Header.pm,v $
# Revision 1.5  2007/11/23 19:23:27  atchleyb
# CR 5 - changed so that path to root is not hard coded
#
# Revision 1.4  2006/12/12 18:11:39  atchleyb
# updated for new environment
#
# Revision 1.3  2002/05/28 16:35:34  atchleyb
# updated paths
#
# Revision 1.2  2002/03/15 18:26:59  atchleyb
# changed document path
#
# Revision 1.1  2002/03/08 21:07:08  atchleyb
# Initial revision
#
#
#
#
package DMS_Header;
use strict;
use Carp;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw ($DMSType $DMSUser $DefPassword $SCHEMA $DMSFontFace $DMSFontColor 
             $DMSDocPath $DMSFullDocPath $DMSJavaScriptPath $DMSImagePath %DMSHash 
             $DMSProductionStatus $DMSDebug $DMSConnectPath $DMSDocDir $DMSReportPath 
             $DMSFullReportPath $DMSTempReportPath $DMSFullTempReportPath $DMSServer $SCMPath
             $SYSPathRoot);

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw($DMSType $DMSUser $DefPassword $SCHEMA $DMSFontFace $DMSFontColor $DMSDocPath 
                $DMSFullDocPath $DMSJavaScriptPath $DMSImagePath %DMSHash $DMSProductionStatus 
                $DMSDebug $DMSConnectPath $DMSReportPath $DMSFullReportPath $DMSTempReportPath 
                $DMSFullTempReportPath $DMSServer $SCMPath
                $SYSPathRoot);
%EXPORT_TAGS =(
    Constants => [qw($DMSType $DMSUser $DefPassword $SCHEMA $DMSFontFace $DMSFontColor $DMSDocPath 
                     $DMSFullDocPath $DMSJavaScriptPath $DMSImagePath %DMSHash $DMSProductionStatus 
                     $DMSDebug $DMSConnectPath $DMSReportPath $DMSFullReportPath $DMSTempReportPath 
                     $DMSFullTempReportPath $DMSServer $SCMPath
                     $SYSPathRoot) ]
);

$ENV{'ORACLE_HOME'} = "/usr/local/oracle8";

#$DMSType = "DMS";
#$DMSUser = "DMS";

my $temp = substr($ENV{'SCRIPT_FILENAME'},0,(rindex($ENV{'SCRIPT_FILENAME'},'/')));
$temp = substr($temp,(rindex($temp,'/') + 1));
$DMSType = uc($temp);
$ENV{'DMSType'} = $DMSType;

#$DMSProductionStatus = (index($ENV{'DOCUMENT_ROOT'}, "dev") >= 1) ? 0 : 1;
$DMSProductionStatus = ($ENV{'SERVER_STATE'} ne "PRODUCTION") ? 0 : 1;
$DMSDebug = !$DMSProductionStatus;

#$SYSPathRoot = ($DMSProductionStatus) ? "/usr/local/www/gov.ymp.intranet" : "/usr/local/www/gov.ymp.intradev" ;
$SYSPathRoot = $ENV{PATH_TO_ROOT};

#$DMSConnectPath = ($DMSProductionStatus) ? "/usr/local/www" : "/data/dev" ;
$DMSConnectPath = $SYSPathRoot;
$DMSConnectPath .= "/cgi-bin/" . lc($DMSType) . "/oracle_dms_connect.pl";

if (open (FH, "$DMSConnectPath |")) {
    ($temp, $DMSUser) = split('//', <FH>);
    close (FH);
    chop($DMSUser);
} else {
    #$DMSUser = "null";
    $DMSUser = $DMSType;
}

$SCHEMA = $DMSUser;
$DMSServer = (($DMSProductionStatus == 1) ? "ydoraprd.ymp.gov" : "ydoracle.ymp.gov");

$DefPassword = 'PASSWORD';
$DMSFontFace = "Times New Roman";
$DMSFontColor = "#000099";
$DMSJavaScriptPath = "/" . lc($DMSType) . "/javascript";
$DMSImagePath = "/" . lc($DMSType) . "/images";
#$SCMPath = ($DMSProductionStatus) ? "/usr/local/www" : "/data/dev" ;
$SCMPath = $SYSPathRoot . "/cgi-bin/pcl";

$DMSDocDir = ($DMSProductionStatus) ? "prod" : "dev" ;
$DMSDocPath .= "/temp/dms/" . $DMSDocDir . "/images";
$DMSFullDocPath = $SYSPathRoot . "/data" . $DMSDocPath;
$DMSReportPath = "/dms/" . $DMSDocDir . "/reports";
$DMSFullReportPath = "/data" . $DMSReportPath;
$DMSTempReportPath = "/temp/dms/" . $DMSDocDir . "/reports";
$DMSFullTempReportPath = "/data" . $DMSTempReportPath;

%DMSHash = ("DMSType" => $DMSType, "DMSUser" => $DMSUser, "DefPassword" => $DefPassword,
            "SCHEMA" => $SCHEMA, "DMSFontFace" => $DMSFontFace, "DMSFontColor" =>$DMSFontColor,
            "DMSDocPath" => $DMSDocPath, "DMSFullDocPath" => $DMSFullDocPath, "DMSJavaScriptPath" => $DMSJavaScriptPath, 
            "DMSImagePath" => $DMSImagePath, "DMSProductionStatus" => $DMSProductionStatus, "DMSConnectPath" => $DMSConnectPath, 
            "DMSReportPath" => $DMSReportPath, "DMSFullReportPath" => $DMSFullReportPath,
            "DMSTempReportPath" => $DMSTempReportPath, "DMSFullTempReportPath" => $DMSFullTempReportPath, 
            "DMSServer" => $DMSServer);

$ENV{'DBUser'} = $DMSUser;
$ENV{'DMSConnectPath'} = $DMSConnectPath;
$ENV{'DefPassword'} = $DefPassword;
$ENV{'SCHEMA'} = $SCHEMA;
$ENV{'DMSServer'} = $DMSServer;
$ENV{'DMSFontFace'} = $DMSFontFace;
$ENV{'DMSFontColor'} = $DMSFontColor;
$ENV{'DMSDocPath'} = $DMSDocPath;
$ENV{'DMSFullDocPath'} = $DMSFullDocPath;
$ENV{'DMSJavaScriptPath'} = $DMSJavaScriptPath;
$ENV{'DMSReportPath'} = $DMSReportPath;
$ENV{'DMSFullReportPath'} = $DMSFullReportPath;
$ENV{'DMSTempReportPath'} = $DMSTempReportPath;
$ENV{'DMSFullTempReportPath'} = $DMSFullTempReportPath;

sub new {
    my $self = {};
    $self = { %DMSHash };
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
