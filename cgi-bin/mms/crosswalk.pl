#!/usr/local/bin/perl -w

# Crosswalk
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/crosswalk.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2010/03/26 22:52:08 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: crosswalk.pl,v $
# Revision 1.1  2010/03/26 22:52:08  atchleyb
# Initial revision
#
#
#
#

# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use UI_Widgets qw(:Functions);
use UIShared qw(:Functions);
use DBShared qw(:Functions);
use Tie::IxHash;
use UIPurchaseDocuments qw(:Functions);
use DBPurchaseDocuments qw(:Functions);
use DBAccountsPayable qw(:Functions);
use CGI;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $dbh;
$dbh = db_connect();
my %settings = getInitialValues(dbh => $dbh);
my $username = $settings{"username"};
my $userid = $settings{"userid"};
my $schema = $settings{"schema"};
# Set server parameter
my $Server = $settings{"server"};
if (!(defined($Server))) {$Server=$SYSServer;}
my $command = $settings{"command"};
my $title = $settings{title};
my $error = "";
my $errorstr = "";
my $cgi = new CGI;

#&checkLogin(cgi => $cgi);
#! test for invalid or timed out session
#&validateCurrentSession(dbh => $dbh, schema => $schema, userID => $userid, sessionID => $settings{sessionID});


###################################################################################################################################
###################################################################################################################################

    my @PDs = getPDByStatus(dbh => $dbh, schema => $schema, siteList => '5, 6');
    my $xlsBuff = '';
    my @row = ("PR Number", "PO Number", "Ref Number", "Brief Description", "Status", "Total Amount", "Invoiced Amount");
    $xlsBuff .= formatXLSRow(cols=>7, row=>\@row);
    for (my $i=0; $i<$#PDs; $i++) {
        if (defined($PDs[$i]{refnumber})) {
            $row[0] = $PDs[$i]{prnumber};
            $row[1] = $PDs[$i]{ponumber} . ((defined($PDs[$i]{amendment})) ? $PDs[$i]{amendment} : '');
            $row[2] = $PDs[$i]{refnumber};
            $row[3] = $PDs[$i]{briefdescription};
            $row[4] = getPDStatusText(dbh => $dbh, schema => $schema, status => $PDs[$i]{status});
            $row[5] = $PDs[$i]{total};
            my ($tax, $amount, $allClosed) = getAPTotals(dbh => $dbh, schema => $schema, pd => $PDs[$i]{prnumber});
            $row[6] = ((defined($tax)) ? $tax : 0.0) + ((defined($amount)) ? $amount : 0.0);
            $xlsBuff .= formatXLSRow(cols=>7, row=>\@row);
        }
    
    }
    my $mimeType = &getMimeType(dbh => $dbh, schema => $schema, name=>".xls");
        print "Content-type: $mimeType\n\n";
        print $xlsBuff;


&db_disconnect($dbh);
exit();
