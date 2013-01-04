#!/usr/local/bin/perl -w

use strict;
use SharedHeader qw(:Constants);
use CGI;
use Mail_Utilities_Lib;
use Tie::IxHash;

# create cgi object for processing
my $crdcgi = new CGI;

# tell the browser that this is an html page using the header method
print $crdcgi->header('text/html');

    my $output = "";
    my $message = "";
    my $subject = "";
    my $sender = "bill.atchley\@ymp.gov";
    my $sendTo = "";
    my $status;
    
    print "<HTML><HEAD><TITLE>test e-mail</TITLE></HEAD><BODY>Running Test<br><br>\n";

    
        $sendTo = "bill.atchley\@ymp.gov, brian_munroe\@ymp.gov, alvin.busey\@rw.doe.gov,";
        $subject = "Test E-Mail Message";
        $message .= "This is a test e-mail message sent to: '$sendTo'\nPlease reply when you get it.\nThank You";

        $status = &SendMailMessage(sendTo => $sendTo, sender => $sender, subject => $subject, message => $message);
    
    print "Finished\n</BODY></HTML>\n";

