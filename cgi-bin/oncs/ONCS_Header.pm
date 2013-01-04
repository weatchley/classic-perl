#
# ONCS Header file
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
package ONCS_Header;
use strict;
use Carp;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw($ONCSType $ONCSUser $ONCSPassword $SCHEMA $ONCSFontFace $ONCSFontColor $ONCSDocPath $ONCSJavaScriptPath %ONCSHash);
use vars qw($MaxBytesStored $ONCSTempFilePath $TitleLength $ONCSImagePath $ONCSBackground $ONCSConnectPath $ONCSProductionStatus
$SYSPathRoot);

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);
@EXPORT = qw ();
@EXPORT_OK = qw($ONCSType $ONCSUser $ONCSPassword $SCHEMA $ONCSFontFace 
                $ONCSFontColor $ONCSDocPath 
                $ONCSJavaScriptPath %ONCSHash $ONCSTempFilePath 
                $MaxBytesStored $TitleLength $ONCSConnectPath
                $ONCSImagePath $ONCSBackground $SYSPathRoot);
%EXPORT_TAGS =(
    Constants => [qw($ONCSType $ONCSUser $ONCSPassword $SCHEMA 
                     $ONCSFontFace $ONCSFontColor 
                     $ONCSDocPath $ONCSJavaScriptPath 
                     %ONCSHash $ONCSTempFilePath $ONCSConnectPath
                     $MaxBytesStored $TitleLength $ONCSImagePath 
                     $ONCSBackground $SYSPathRoot) ]
);

$ENV{'ORACLE_HOME'} = "/usr/local/oracle8";
$ENV{'TWO_TASK'} = "T:ydoraprd.ymp.gov:ydor";

#$ONCSType = "EIS";
$ONCSUser = "oncs";
#$ONCSPassword = &getdbpassword();
#$SCHEMA = "oncs";
$ONCSFontFace = "Arial";
$ONCSFontColor = "#000099";
$ONCSDocPath = "/dcmm/prototype";
$ONCSJavaScriptPath = "/cms/javascript";
$ONCSBackground = "/cms/images/background.gif";
#$ONCSProductionStatus = (index($ENV{'DOCUMENT_ROOT'}, "dev") >= 1) ? 0 : 1;
$ONCSProductionStatus = ($ENV{'SERVER_STATE'} ne "PRODUCTION") ? 0 : 1;
#$SYSPathRoot = ($ONCSProductionStatus) ? "/usr/local/www/gov.ymp.intranet" : "/usr/local/www.gov.ymp.intradev" ;
$SYSPathRoot = $ENV{PATH_TO_ROOT};
$ONCSTempFilePath = "$SYSPathRoot/data/cirs/prod/";
$ONCSImagePath = "/cirs/prod";

#$ONCSConnectPath = ($ONCSProductionStatus) ? "/usr/local/www" : "/data/dev" ;
$ONCSConnectPath = $SYSPathRoot ;
$ONCSConnectPath .= "/cgi-bin/oncs/oracle_oncs_connect.pl";
($SCHEMA, $ONCSPassword) = getOracleID();

%ONCSHash = ("ONCSUser" => $ONCSUser, "ONCSPassword" => $ONCSPassword,
             "SCHEMA" => $SCHEMA, "ONCSFontFace" => $ONCSFontFace, 
             "ONCSFontColor" =>$ONCSFontColor,
             "ONCSDocPath" => $ONCSDocPath, 
             "ONCSJavaScriptPath" => $ONCSJavaScriptPath,
             "ONCSTempFilePath" => $ONCSTempFilePath, 
             "ONCSImagePath" => $ONCSImagePath);

$MaxBytesStored = '';
$MaxBytesStored = 104857600;  #100 MB file maximum (hopefully)
$TitleLength = '';
$TitleLength = 80;

# create new object
sub new {
    my $self = {};
    $self = { %ONCSHash };
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

#read the user password
sub getdbpassword {
    my $dbusernme = $_[0];
	
    open(DBPASSFILE, "$SYSPathRoot/data/apps/cms_historical/.init");
#    open(DBPASSFILE, "/home/oracle/etc/user");
#    open(DBPASSFILE, "/home/zepedaj/user");
    my $dbpassword = <DBPASSFILE>;
    chomp($dbpassword);
    close(DBPASSFILE);
    return($dbpassword);
}

#################
sub getOracleID {
#################
    my $username = $ONCSUser;
    my $password;
    my $temp;
    if (open (FH, "$ONCSConnectPath |")) {
        ($password, $temp) = split('//', <FH>);
        close (FH);
    } else {
        $username = "null";
        $password = "null";
    }

    return ($username, $password);
}


1; #return true






