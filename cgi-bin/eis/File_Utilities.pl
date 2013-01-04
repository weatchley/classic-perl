#!/usr/local/bin/newperl -w

# CGI utilities for writing files to the server
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/crd/perl/RCS/File_Utilities.pl,v $
#
# $Revision: 1.6 $
#
# $Date: 2007/10/11 14:37:49 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: File_Utilities.pl,v $
# Revision 1.6  2007/10/11 14:37:49  atchleyb
# Updated to change server name for 'O' drive
#
# Revision 1.5  2006/11/03 16:54:04  atchleyb
# Updated to fix bug in Samba introduced by the new evironment (added the characters  2>&1 to the endof the connect strings)
#
# Revision 1.4  2005/12/08 19:44:04  atchleyb
# CR00045 - change password for 'eiscrd' user and change server for source files
#
# Revision 1.3  2000/08/28 22:00:50  atchleyb
# added mkdir function
# added getFileDate function
#
# Revision 1.2  2000/02/07 22:00:23  atchleyb
# added more reporting for errors
#
# Revision 1.1  2000/01/14 23:42:56  atchleyb
# Initial revision
#

use strict;
use integer;
#
$| = 1;
#
# get all required libraries and modules

use Getopt::Long;

use vars qw($EGID $GID);

my $status;
my $command='';
my $protection='';
my $fullFilePath='';
my $user='eiscrd';
my $password='C1r2D3c4G5i6!';
my $imageFile='';
my $localFile='';
my $remotePath='';
my $localPath='';
my $resultdata = '';
my $connectstring = '';
my $filename='';
my $text='';
my $savePath = $ENV{PATH};
$ENV{PATH} = '';
#use vars qw(CDFILEPTR);
#local *CDFILEPTR;

# get command line options
$status = &GetOptions("command=s" => \$command, "text=s" => \$text, "protection=s" =>\$protection, 
      "fullFilePath=s" => \$fullFilePath, "user=s" => \$user, "password=s" => \$password, 
      "imageFile=s" => \$imageFile, "localFile=s" => \$localFile,
      "remotePath=s" => \$remotePath, "localPath=s" => \$localPath);

#print "Command: $command\nText: $text\n";
#print "Full File Path: $fullFilePath\n";
#print "Protection: $protection\n";
#print "User: $user\n";
#print "Password: $password\n";
#print "Image File: $imageFile\n";
#print "Local File: $localFile\n";
#print "Remote Path: $remotePath\n";
#print "Local Path: $localPath\n";

#
my $temp = $EGID;
$EGID = $GID;


#
if ($command eq "writeFile") {
    if (open (FH, ">$fullFilePath")) {
        print FH <STDIN>;
        close (FH);
        #$status = chmod $protection, "$fullFilePath";
        $status = chmod 0774, "$fullFilePath";

    } else {
        print "Error Writting to File $fullFilePath\n";
    }
    
    
} elsif ($command eq "deleteFile") {
    $status = unlink($fullFilePath);
    print $status;
    
    
} elsif ($command eq "sambaTest") {
    $connectstring = "/usr/local/samba/bin/smbclient //ydnts200/group $password -U $user -W ydservices -c 'cd $remotePath;rename ";
    $connectstring .= "$imageFile $imageFile;exit;' 2>&1|";
    open CDFILEPTR, $connectstring ;
    while (<CDFILEPTR>) {
        $resultdata .= $_;
    }
    close CDFILEPTR;
    if (index($resultdata, "ERRbadfile") >= 0) {
        $status = 0;
    } else {
        $status = 1;
    }
    print $status;
    
    
} elsif ($command eq "sambaCopy") {
    $connectstring = "/usr/local/samba/bin/smbclient //ydnts200/group $password -U $user -W ydservices -c 'cd $remotePath;";
    if ($localFile eq '') {
        $connectstring .= "lcd $localPath;get $imageFile;exit;' 2>&1|";
    } else {
        $connectstring .= "lcd $localPath;get $imageFile $localFile;exit;' 2>&1|";
    }
    open CDFILEPTR, $connectstring ;
    while (<CDFILEPTR>) {
        $resultdata .= $_;
    }
    close CDFILEPTR;
    if (index($resultdata, "ERRbadfile") >= 0) {
        $status = 0;
        print STDERR "\ngetBracketedImageFile Error - Parameters: $imageFile, $localFile, $remotePath, $localPath - \nSamba Session: $resultdata\n$connectstring\n\n";
    } elsif (index($resultdata, "getting file") >= 0) {
        $status = 1;
    } else {
        $status = -1;
        print STDERR "\ngetBracketedImageFile Error - Parameters: $imageFile, $localFile, $remotePath, $localPath - \nSamba Session: $resultdata\n$connectstring\n\n";
    }
    if ($localFile eq '') {
        $filename = "$localPath/$imageFile";
    } else {
        $filename = "$localPath/$localFile";
    }
    if (open (CDFILEPTR, "<$filename")) {
        close (CDFILEPTR);
        eval {
            chmod 0774, "$filename";
        };
        if ($@) {
            print STDERR "\ngetBracketedImageFile Error - Parameters: $imageFile, $localFile, $remotePath, $localPath - Error Message: $@\n";
        }
        if ($status != 1) {
            eval {
                unlink $filename;
            };
            if ($@) {
                print STDERR "\ngetBracketedImageFile Error - Parameters: $imageFile, $localFile, $remotePath, $localPath - DocPath: $localPath - Error Message: $@\n";
            }
        }
    }
    print $status;
} elsif ($command eq "getFileDate") {
    $connectstring = "/usr/local/samba/bin/smbclient //ydnts200/group $password -U $user -W ydservices -c 'cd $remotePath;";
    $connectstring .= "dir $imageFile;exit;' 2>&1|";
    open CDFILEPTR, $connectstring ;
    while (<CDFILEPTR>) {
        $resultdata .= $_;
    }
    close CDFILEPTR;
    if (index($resultdata, "$imageFile") < 0) {
        $status = 0;
        print STDERR "\ngetBracketedImageFile Error - Parameters: $imageFile, $remotePath - \nSamba Session: $resultdata\n$connectstring\n\n";
        print $status;
    } else {
        my $startpos = index($resultdata, "$imageFile");
        my $datedata = substr($resultdata, $startpos + 57, 2);
        $datedata =~ s/ /0/;
        $datedata .= '-' . substr($resultdata, $startpos + 53, 3) . '-' . substr($resultdata, $startpos + 69, 4) . ' ' . substr($resultdata, $startpos + 60, 8);
        print $datedata;
    }
} elsif ($command eq "mkdir") {
    eval {
        mkdir ($fullFilePath, 0775);
    };
    if ($@) {
        print STDERR "\nmkdir Error - Parameters: $fullFilePath, $protection - Error Message: $@\n";
    }
} else {
}

$EGID = $temp;
$ENV{PATH} = $savePath;
