# Library of Mail Utilities

#
# $Source: /data/dev/cirs/perl/RCS/Mail_Utilities_Lib.pm,v $
#
# $Revision: 1.1 $
#
# $Date: 2000/11/03 17:48:13 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: Mail_Utilities_Lib.pm,v $
# Revision 1.1  2000/11/03 17:48:13  atchleyb
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
    Functions => [qw(&SendMailMessages) ]
);

#
# Contents of library:
#
# utilities
#
# 'SendMailMessage'
# (status) = &SendMailMessage( sendTo => ( email address), sender => ( from address or name ), subject => ( message subject ), message => ( text ), timeStamp => ( T or F ) );



###########

# routine to test if a comment document image has been scanned
sub SendMailMessage {
    my %args = (
        sendTo => 'IntranetWebmaster@ymp.gov',
        sender => 'CGI Script',
        subject => '',
        message => '',
        timeStamp => 'F',
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
            
            print email_file "$args{message}\n\n";
            
            if ($args{timeStamp} eq 'T') {

                my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
                my @months = ('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');

                my @ldzeros = ('00' .. '59');

                print email_file "\n\n Message sent on " . $months[$mon] . " " . $ldzeros[$mday] . ", " . ($year + 1900) . " at " . $ldzeros[$hour] . ":", $ldzeros[$min] . ":" . $ldzeros[$sec] . "\n\n";
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

