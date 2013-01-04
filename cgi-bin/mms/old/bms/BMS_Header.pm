#
# BMS Header file
#
# $Source$
#
# $Revision$
#
# $Date$
#
# $Author$
#
# $Locker$
#
# $Log$
#
#
#
package BMS_Header;
use strict;
use Carp;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw ($BMSType $BMSUser $DefPassword $SCHEMA $BMSFontFace $BMSFontColor 
             $BMSDocPath $BMSFullDocPath $BMSJavaScriptPath $BMSImagePath %BMSHash 
             $BMSProductionStatus $BMSDebug $BMSConnectPath $BMSDocDir $BMSReportPath 
             $BMSFullReportPath $BMSTempReportPath $BMSFullTempReportPath $BMSServer $SCMPath $BMSTimeout $BMSUseSessions);

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw($BMSType $BMSUser $DefPassword $SCHEMA $BMSFontFace $BMSFontColor $BMSDocPath 
                $BMSFullDocPath $BMSJavaScriptPath $BMSImagePath %BMSHash $BMSProductionStatus 
                $BMSDebug $BMSConnectPath $BMSReportPath $BMSFullReportPath $BMSTempReportPath 
                $BMSFullTempReportPath $BMSServer $SCMPath $BMSTimeout $BMSUseSessions);
%EXPORT_TAGS =(
    Constants => [qw($BMSType $BMSUser $DefPassword $SCHEMA $BMSFontFace $BMSFontColor $BMSDocPath 
                     $BMSFullDocPath $BMSJavaScriptPath $BMSImagePath %BMSHash $BMSProductionStatus 
                     $BMSDebug $BMSConnectPath $BMSReportPath $BMSFullReportPath $BMSTempReportPath 
                     $BMSFullTempReportPath $BMSServer $SCMPath $BMSTimeout $BMSUseSessions) ]
);

$ENV{'ORACLE_HOME'} = "/usr/local/oracle8";

#$BMSType = "BMS";
#$BMSUser = "BMS";

my $temp = substr($ENV{'SCRIPT_FILENAME'},0,(rindex($ENV{'SCRIPT_FILENAME'},'/')));
$temp = substr($temp,(rindex($temp,'/') + 1));
$BMSType = uc($temp);
$ENV{'BMSType'} = $BMSType;

$BMSProductionStatus = (index($ENV{'DOCUMENT_ROOT'}, "dev") >= 1) ? 0 : 1;
$BMSDebug = !$BMSProductionStatus;

$BMSConnectPath = ($BMSProductionStatus) ? "/usr/local/www" : "/data/dev" ;
$BMSConnectPath .= "/cgi-bin/" . lc($BMSType) . "/oracle_bms_connect.pl";

if (open (FH, "$BMSConnectPath |")) {
    ($temp, $BMSUser) = split('//', <FH>);
    close (FH);
    chop($BMSUser);
} else {
    $BMSUser = "null";
}

#$SCHEMA = $BMSUser;
$SCHEMA = "ATCHLEYW";
$BMSServer = (($BMSProductionStatus == 1) ? "ydoracle" : "ydoradev");

$DefPassword = 'PASSWORD';
$BMSFontFace = "Times New Roman";
$BMSFontColor = "#000099";
$BMSJavaScriptPath = "/" . lc($BMSType) . "/javascript";
$BMSImagePath = "/" . lc($BMSType) . "/images";
#$SCMPath = ($BMSProductionStatus) ? "/usr/local/www" : "/data/dev" ;
$SCMPath = "/cgi-bin/scm";

$BMSDocDir = ($BMSProductionStatus) ? "prod" : "dev" ;
#$BMSDocPath .= "/temp/bms/" . lc($BMSType) . "/" . $BMSDocDir . "/cd_images/bracketed";
#$BMSFullDocPath = "/data" . $BMSDocPath;
$BMSReportPath = "/bms/" . lc($BMSType) . "/" . $BMSDocDir . "/reports";
$BMSFullReportPath = "/data" . $BMSReportPath;
$BMSTempReportPath = "/temp/bms/" . lc($BMSType) . "/" . $BMSDocDir . "/reports";
$BMSFullTempReportPath = "/data" . $BMSTempReportPath;
$BMSUseSessions = 0;
$BMSTimeout = 30;

%BMSHash = ("BMSType" => $BMSType, "BMSUser" => $BMSUser, "DefPassword" => $DefPassword,
            "SCHEMA" => $SCHEMA, "BMSFontFace" => $BMSFontFace, "BMSFontColor" =>$BMSFontColor,
            "BMSDocPath" => $BMSDocPath, "BMSFullDocPath" => $BMSFullDocPath, "BMSJavaScriptPath" => $BMSJavaScriptPath, 
            "BMSImagePath" => $BMSImagePath, "BMSProductionStatus" => $BMSProductionStatus, "BMSConnectPath" => $BMSConnectPath, 
            "BMSReportPath" => $BMSReportPath, "BMSFullReportPath" => $BMSFullReportPath,
            "BMSTempReportPath" => $BMSTempReportPath, "BMSFullTempReportPath" => $BMSFullTempReportPath, 
            "BMSServer" => $BMSServer, "BMSTimeout" => $BMSTimeout, "BMSUseSessions" => $BMSUseSessions);

$ENV{'DBUser'} = $BMSUser;
$ENV{'BMSConnectPath'} = $BMSConnectPath;
$ENV{'DefPassword'} = $DefPassword;
$ENV{'SCHEMA'} = $SCHEMA;
$ENV{'BMSServer'} = $BMSServer;
$ENV{'BMSFontFace'} = $BMSFontFace;
$ENV{'BMSFontColor'} = $BMSFontColor;
#$ENV{'BMSDocPath'} = $BMSDocPath;
#$ENV{'BMSFullDocPath'} = $BMSFullDocPath;
$ENV{'BMSJavaScriptPath'} = $BMSJavaScriptPath;
$ENV{'BMSReportPath'} = $BMSReportPath;
$ENV{'BMSFullReportPath'} = $BMSFullReportPath;
$ENV{'BMSTempReportPath'} = $BMSTempReportPath;
$ENV{'BMSFullTempReportPath'} = $BMSFullTempReportPath;
$ENV{'BMSTimeout'} = $BMSTimeout;
$ENV{'BMSUseSessions'} = $BMSUseSessions;

sub new {
    my $self = {};
    $self = { %BMSHash };
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
