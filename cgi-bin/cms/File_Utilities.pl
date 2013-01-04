#!/usr/local/bin/newperl -w

# CGI utilities for writing files to the server
#
# $Source: /data/dev/cirs/perl/RCS/File_Utilities.pl,v $
# $Revision: 1.2 $
# $Date: 2000/07/05 22:40:46 $
# $Author: munroeb $
# $Locker:  $
# $Log: File_Utilities.pl,v $
# Revision 1.2  2000/07/05 22:40:46  munroeb
# made minor changes to html and javascripts
#
# Revision 1.1  2000/04/12 00:04:47  zepedaj
# Initial revision
#
#

use strict;
#use integer;
#
$| = 1;
#
# get all required libraries and modules
use Getopt::Long;
use vars qw($EGID $GID);

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $status;
my $command='';
my $protection='';
my $fullFilePath='';
my $savePath = $ENV{PATH};
$ENV{PATH} = '';
#my $saveIfs = $ENV{IFS};
#$ENV{IFS} = '';

#use vars qw(CDFILEPTR);
#local *CDFILEPTR;
# get command line options

$status = &GetOptions("command=s" => \$command, "protection=s" => \$protection,
      "fullFilePath=s" => \$fullFilePath);

#print "Command: $command<br>\n";
#print "Text: $text\n";
#print "Full File Path: $fullFilePath<br>\n";
#print "Protection: $protection<br>\n";
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

if ($command eq "writeFile")
  {
  if ($fullFilePath =~ /^([-\@\w.\/]+)$/)
    {
    $fullFilePath = $1;
    }
  if ($protection =~ /^([0-9]+)$/)
    {
    $protection = $1;
    }
  if (open (FH, ">$fullFilePath"))
    {
    print FH <STDIN>;
    close (FH);

    $status = chmod oct($protection), "$fullFilePath";
    #$status = chmod 0774, "$fullFilePath";
    }
  else
    {
    print "Error Writting to File $fullFilePath\n";
    }
  }

$EGID = $temp;
$ENV{PATH} = $savePath;
#$ENV{IFS} = $saveIfs;

#} elsif ($command eq "deleteFile") {
#    $status = unlink($fullFilePath);
#    print $status;
#
#} elsif ($command eq "sambaTest") {
#    $connectstring = "/usr/local/samba/bin/smbclient //ydnts1/group $password -U $user -W ydservices -c 'cd $remotePath;rename ";
#    $connectstring .= "$imageFile $imageFile;exit;'|";
#    open CDFILEPTR, $connectstring ;
#    while (<CDFILEPTR>) {
#        $resultdata .= $_;
#    }
#    close CDFILEPTR;
#    if (index($resultdata, "ERRbadfile") >= 0) {
#        $status = 0;
#    } else {
#        $status = 1;
#    }
#    print $status;
#
#} elsif ($command eq "sambaCopy") {
#    $connectstring = "/usr/local/samba/bin/smbclient //ydnts1/group $password -U $user -W ydservices -c 'cd $remotePath;";
#    if ($localFile eq '') {
#        $connectstring .= "lcd $localPath;get $imageFile;exit;'|";
#    } else {
#        $connectstring .= "lcd $localPath;get $imageFile $localFile;exit;'|";
#    }
#    open CDFILEPTR, $connectstring ;
#    while (<CDFILEPTR>) {
#        $resultdata .= $_;
#    }
#    close CDFILEPTR;
#    if (index($resultdata, "ERRbadfile") >= 0) {
#        $status = 0;
#        print STDERR "\ngetBracketedImageFile Error - Parameters: $imageFile, $localFile, $remotePath, $localPath, $user, $password - \nSamba Session: $resultdata\n$connectstring\n\n";
#    } elsif (index($resultdata, "getting file") >= 0) {
#        $status = 1;
#    } else {
#        $status = -1;
#        print STDERR "\ngetBracketedImageFile Error - Parameters: $imageFile, $localFile, $remotePath, $localPath, $user, $password - \nSamba Session: $resultdata\n$connectstring\n\n";
#    }
#    if ($localFile eq '') {
#        $filename = "$localPath/$imageFile";
#    } else {
#        $filename = "$localPath/$localFile";
#    }
#    if (open (CDFILEPTR, "<$filename")) {
#        close (CDFILEPTR);
#        eval {
#            chmod 0774, "$filename";
#        };
#        if ($@) {
#            print STDERR "\ngetBracketedImageFile Error - Parameters: $imageFile, $localFile, $remotePath, $localPath, $user, $password - Error Message: $@\n";
#        }
#        if ($status != 1) {
#            eval {
#                unlink $filename;
#            };
#            if ($@) {
#                print STDERR "\ngetBracketedImageFile Error - Parameters: $imageFile, $localFile, $remotePath, $localPath, $user, $password - DocPath: $localPath - Error Message: $@\n";
#            }
#        }
#    }
#    print $status;
#} else {
#}
#$EGID = $temp;
#$ENV{PATH} = $savePath;
#
