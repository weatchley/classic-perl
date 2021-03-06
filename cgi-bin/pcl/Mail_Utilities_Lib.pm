# Library of Mail Utilities

#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/pcl/perl/RCS/Mail_Utilities_Lib.pm,v $
#
# $Revision: 1.2 $
#
# $Date: 2003/11/28 21:33:19 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: Mail_Utilities_Lib.pm,v $
# Revision 1.2  2003/11/28 21:33:19  starkeyj
# added a value to sendMailMessage for cc (copyTo)
#
# Revision 1.1  2002/09/26 18:19:45  atchleyb
# Initial revision
#
#
# 
package Mail_Utilities_Lib;
use strict;
use Carp;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
#use vars qw();

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw (&SendMailMessage);
@EXPORT_OK = qw(&SendMailMessage);
%EXPORT_TAGS =(
    Functions => [qw(&SendMailMessage) ]
);

#
# Contents of library:
#
# utilities
#
# 'SendMailMessage'
# (status) = &SendMailMessage( sendTo => ( email address), sender => ( from address or name ), subject => ( message subject ), message => ( text ),
#                 timeStamp => ( T or F ), attachmentCount => ( # ), attachmentFileName1 => (file name), attachmentContents1 => (file contents) [, ...]);



###########

sub uuencode
{
    local ($_) = @_;
    my $result = '';
    
    # break into chunks of 45 input chars, and use perl's builtin
    # uuencoder to convert each chunk to uuencode format.
    # (newline is added by builtin uuencoder.)
    while (s/^((.|\n){45})//) {
	$result .= pack("u", $&);
    }

    # any leftover chars go onto a shorter line
    # with padding to the next multiple of 4 chars
    if ($_ ne "") {
	$result .= pack("u", $_);
    }

    # return result
    return ($result);
}

sub MakeAttachment {
    my %args = (
        FileName => '',
        Contents => '',
        @_,
    );
    my $outputstring = '';
    $outputstring = "begin 777 $args{FileName}\n";
    $outputstring .= &uuencode($args{Contents});
    $outputstring .= "`\n";
    $outputstring .= "end\n\n";
    
    return ($outputstring);
}


###########

# routine to test if a comment document image has been scanned
sub SendMailMessage {
    my %args = (
        sendTo => 'IntranetWebmaster@ymp.gov',
        sender => 'CGI Script',
        subject => '',
        message => '',
        timeStamp => 'F',
        attachmentCount => 0,
        attachmentFileName1 => '',
        attachmentContents1 => '',
        @_,
    );
    my $status = 0;

    eval {
        if (!open(email_file, "|/usr/lib/sendmail -oi -t")) {
            $status=-2;
        } else {
        
            # pass parameters to sendmail
            print email_file "From: $args{sender}\n";
            print email_file "To: $args{sendTo}\n";
            print email_file "Subject: $args{subject}\n";
            print email_file "cc: $args{copyto}\n";
            
            print email_file "$args{message}\n\n";
            
            if ($args{timeStamp} eq 'T') {

                my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
                my @months = ('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');

                my @ldzeros = ('00' .. '59');

                print email_file "\n\n Message sent on " . $months[$mon] . " " . $ldzeros[$mday] . ", " . ($year + 1900) . " at " . $ldzeros[$hour] . ":", $ldzeros[$min] . ":" . $ldzeros[$sec] . "\n\n";
            }
            for (my $i=1; $i<=$args{attachmentCount}; $i++) {
                print email_file &MakeAttachment(FileName => $args{"attachmentFileName$i"}, Contents => $args{"attachmentContents$i"});
            }
            
            $status = 1;
            close (email_file);
        }
    
    };
    if ($@) {
        $status = -3;
    }

    return ($status);
}

###########



###########

1; #return true

