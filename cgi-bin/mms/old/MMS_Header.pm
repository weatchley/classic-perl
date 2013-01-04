#
# MMS Header file
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
package MMS_Header;
use strict;
use Carp;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw ($MMSType $MMSUser $DefPassword $SCHEMA $MMSFontFace $MMSFontColor 
             $MMSDocPath $MMSFullDocPath $MMSJavaScriptPath $MMSImagePath %MMSHash 
             $MMSProductionStatus $MMSDebug $MMSConnectPath $MMSDocDir $MMSReportPath 
             $MMSFullReportPath $MMSTempReportPath $MMSFullTempReportPath $MMSServer $SCMPath $MMSTimeout $MMSUseSessions);

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw($MMSType $MMSUser $DefPassword $SCHEMA $MMSFontFace $MMSFontColor $MMSDocPath 
                $MMSFullDocPath $MMSJavaScriptPath $MMSImagePath %MMSHash $MMSProductionStatus 
                $MMSDebug $MMSConnectPath $MMSReportPath $MMSFullReportPath $MMSTempReportPath 
                $MMSFullTempReportPath $MMSServer $SCMPath $MMSTimeout $MMSUseSessions);
%EXPORT_TAGS =(
    Constants => [qw($MMSType $MMSUser $DefPassword $SCHEMA $MMSFontFace $MMSFontColor $MMSDocPath 
                     $MMSFullDocPath $MMSJavaScriptPath $MMSImagePath %MMSHash $MMSProductionStatus 
                     $MMSDebug $MMSConnectPath $MMSReportPath $MMSFullReportPath $MMSTempReportPath 
                     $MMSFullTempReportPath $MMSServer $SCMPath $MMSTimeout $MMSUseSessions) ]
);

$ENV{'ORACLE_HOME'} = "/usr/local/oracle8";

#$MMSType = "MMS";
#$MMSUser = "MMS";

my $temp = substr($ENV{'SCRIPT_FILENAME'},0,(rindex($ENV{'SCRIPT_FILENAME'},'/')));
$temp = substr($temp,(rindex($temp,'/') + 1));
$MMSType = uc($temp);
$ENV{'MMSType'} = $MMSType;

$MMSProductionStatus = (index($ENV{'DOCUMENT_ROOT'}, "dev") >= 1) ? 0 : 1;
$MMSDebug = !$MMSProductionStatus;

$MMSConnectPath = ($MMSProductionStatus) ? "/usr/local/www" : "/data/dev" ;
$MMSConnectPath .= "/cgi-bin/" . lc($MMSType) . "/readFile.pl -file /data/apps/" . lc($MMSType) . "/.init";

if (open (FH, "$MMSConnectPath |")) {
    ($MMSUser, $temp) = split('//', <FH>);
    close (FH);
} else {
    $MMSUser = "null";
}

#$SCHEMA = $MMSUser;
#$SCHEMA = "PROCURE";
$SCHEMA = "ATCHLEYW";
$MMSServer = (($MMSProductionStatus == 1) ? "ydoracle" : "ydoradev");

$DefPassword = 'PASSWORD';
$MMSFontFace = "Times New Roman";
$MMSFontColor = "#000099";
$MMSJavaScriptPath = "/" . lc($MMSType) . "/javascript";
$MMSImagePath = "/" . lc($MMSType) . "/images";
#$SCMPath = ($MMSProductionStatus) ? "/usr/local/www" : "/data/dev" ;
$SCMPath = "/cgi-bin/scm";

$MMSDocDir = ($MMSProductionStatus) ? "prod" : "dev" ;
#$MMSDocPath .= "/temp/mms/" . lc($MMSType) . "/" . $MMSDocDir . "/cd_images/bracketed";
#$MMSFullDocPath = "/data" . $MMSDocPath;
$MMSReportPath = "/mms/" . lc($MMSType) . "/" . $MMSDocDir . "/reports";
$MMSFullReportPath = "/data" . $MMSReportPath;
$MMSTempReportPath = "/temp/mms/" . lc($MMSType) . "/" . $MMSDocDir . "/reports";
$MMSFullTempReportPath = "/data" . $MMSTempReportPath;
$MMSUseSessions = 1;
$MMSTimeout = 30;

%MMSHash = ("MMSType" => $MMSType, "MMSUser" => $MMSUser, "DefPassword" => $DefPassword,
            "SCHEMA" => $SCHEMA, "MMSFontFace" => $MMSFontFace, "MMSFontColor" =>$MMSFontColor,
            "MMSDocPath" => $MMSDocPath, "MMSFullDocPath" => $MMSFullDocPath, "MMSJavaScriptPath" => $MMSJavaScriptPath, 
            "MMSImagePath" => $MMSImagePath, "MMSProductionStatus" => $MMSProductionStatus, "MMSConnectPath" => $MMSConnectPath, 
            "MMSReportPath" => $MMSReportPath, "MMSFullReportPath" => $MMSFullReportPath,
            "MMSTempReportPath" => $MMSTempReportPath, "MMSFullTempReportPath" => $MMSFullTempReportPath, 
            "MMSServer" => $MMSServer, "MMSTimeout" => $MMSTimeout, "MMSUseSessions" => $MMSUseSessions);

$ENV{'DBUser'} = $MMSUser;
$ENV{'MMSConnectPath'} = $MMSConnectPath;
$ENV{'DefPassword'} = $DefPassword;
$ENV{'SCHEMA'} = $SCHEMA;
$ENV{'MMSServer'} = $MMSServer;
$ENV{'MMSFontFace'} = $MMSFontFace;
$ENV{'MMSFontColor'} = $MMSFontColor;
#$ENV{'MMSDocPath'} = $MMSDocPath;
#$ENV{'MMSFullDocPath'} = $MMSFullDocPath;
$ENV{'MMSJavaScriptPath'} = $MMSJavaScriptPath;
$ENV{'MMSReportPath'} = $MMSReportPath;
$ENV{'MMSFullReportPath'} = $MMSFullReportPath;
$ENV{'MMSTempReportPath'} = $MMSTempReportPath;
$ENV{'MMSFullTempReportPath'} = $MMSFullTempReportPath;
$ENV{'MMSTimeout'} = $MMSTimeout;
$ENV{'MMSUseSessions'} = $MMSUseSessions;

sub new {
    my $self = {};
    $self = { %MMSHash };
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
