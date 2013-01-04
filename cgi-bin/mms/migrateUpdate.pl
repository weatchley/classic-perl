#!/usr/local/bin/perl -w

# Migrate Update
#
# $Source: /data/dev/rcs/mms/perl/RCS/migrateUpdate.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2004/12/07 19:01:55 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: migrateUpdate.pl,v $
# Revision 1.1  2004/12/07 19:01:55  atchleyb
# Initial revision
#
#
#
#
#
#

$| = 1;

use strict;
#use integer;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use DBPurchaseDocuments qw(:Functions);
use UI_Widgets qw(:Functions);
use UIShared qw(:Functions);
use CGI;

my $mycgi = new CGI;


$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $dbh;
$dbh = &db_connect();
my %settings = getInitialValues(dbh => $dbh);

my $schema = $settings{schema};
my $command = $settings{command};
my $username = $settings{username};
my $userid = $settings{userid};
my $title = $settings{title};
my $error = "";
#&checkLogin(cgi => $cgi);
#&checkLogin ($username, $userid, $schema);
my $errorstr = "";

#! test for invalid or timed out session
#&validateCurrentSession(dbh => $dbh, schema => $schema, userID => $userid, sessionID => $settings{sessionID});


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub getTitle {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $title = "Migrate Update";
   if ($args{command} eq "view_errors") {
      $title = "Error Log";
   } elsif ($args{command} eq "view_activity") {
      $title = "Activity Log";
   }
   return ($title);
}


###################################################################################################################################
sub getInitialValues {  # routine to get initial CGI values and return in a hash
###################################################################################################################################
    my %args = (
        dbh => "",
        @_,
    );
    
    my %valueHash = (
       &getStandardValues, (
       command => (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "browse",
       id => (defined($mycgi->param("id"))) ? $mycgi->param("id") : "",
       type => (defined($mycgi->param("type"))) ? $mycgi->param("type") : "",
       projectID => (defined($mycgi->param("projectID"))) ? $mycgi->param("projectID") : "",
       logOption => (defined($mycgi->param("logOption"))) ? $mycgi->param("logOption") : "today",
       logactivity => (defined($mycgi->param("logactivity"))) ? $mycgi->param("logactivity") : "all",
       selecteduser => (defined($mycgi->param("selecteduser"))) ? $mycgi -> param ("selecteduser") : -1,
    ));
    $valueHash{title} = &getTitle(command => $valueHash{command});
    
    return (%valueHash);
}


###################################################################################################################################
sub doHeader {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        dbh => '',
        schema => $ENV{SCHEMA},
        title => "$SYSType User Functions",
        displayTitle => 'T',
        @_,
    );
    my $output = "";
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $form = $args{form};
    my $path = $args{path};
    my $username = $settings{username};
    my $userid = $settings{userid};
    my $Server = $settings{server};
    
    my $extraJS = "";
    $extraJS .= <<END_OF_BLOCK;
    function doBrowse(script) {
      	$form.command.value = 'browse';
       	$form.action = '$path' + script + '.pl';
        $form.submit();
    }
    function submitForm3(script, command, type) {
        document.$form.command.value = command;
        document.$form.type.value = type;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }


END_OF_BLOCK
    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'F', includeJSWidgets => 'F');
    
    $output .= "<input type=hidden name=type value=0>\n";
    $output .= "<input type=hidden name=project value=0>\n";
    $output .= "<input type=hidden name=projectID value=0>\n";
    #$output .= "<input type=hidden name=server value=$Server>\n";
    $output .= "<table border=0 width=750 align=center><tr><td>\n";

    return($output);
}


###################################################################################################################################
sub doFooter {  # routine to generate html page footers
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    
    $output .= &doStandardFooter();

    return($output);
}




###################################################################################################################################
#
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print "<h1 align=center>Data Migration Update</h1>\n";
        print "<h2 align=center>Working</h2>\n";
        print "<h3 align=center>Using schema: $schema</h3>\n";
        
        my $dateFormat = "MM/DD/YYYY-HH24:MI:SS";
        my $sqlcode = "SELECT prnumber, TO_CHAR(podate, '$dateFormat') from $schema.purchase_documents WHERE status>=15 AND prnumber IN (SELECT prnumber FROM $schema.pd_history)";
        $sqlcode .= " ORDER BY prnumber";
        my $csr = $dbh->prepare($sqlcode);
        $csr->execute;
        my $count = 0;
        $| = 1;

        while (my ($prnumber, $changeDate) = $csr->fetchrow_array) {
            if (!defined($changeDate) || ($changeDate le ' ')) {
                #($changeDate) = $dbh->selectrow_array("SELECT TO_CHAR(changedate, '$dateFormat') FROM $schema.pd_history WHERE prnumber='$prnumber' ORDER BY changedate DESC");
                ($changeDate) = $dbh->selectrow_array("SELECT TO_CHAR(tempdate, '$dateFormat') FROM $schema.pd_history WHERE prnumber='$prnumber' AND tempdate IS NOT NULL ORDER BY tempdate DESC");
            }
#######            $changeDate = substr($changeDate,0,11) . "23" . substr($changeDate,13);
            $changeDate = substr($changeDate,0,11) . "23:59:56";
            print "$prnumber, ";
            $count++;
            &addPDHistory(dbh=>$dbh, schema=>$schema, pd=>$prnumber, changes=>'Migrate Update', changeDate=>$changeDate);
        }
        $csr->finish;
        print  "\n<br>Count: $count<br>\n";
        print "<br>Working on approval lists<br><br>\n";
        my @pdList = &getPDByStatus(dbh=>$dbh, schema=>$schema, statusList=>'3, 14');
        for (my $i=0; $i<$#pdList; $i++) {
            $settings{status} = $pdList[$i]{status};
            $settings{prnumber} = $pdList[$i]{prnumber};
            $settings{userid} = 0;
#
# line 1117 in DBPurchaseDocuments.pm (line that calls doProcessPDApproval) must be commented out to run this then uncommented
#
            &genPDApprovalList(dbh=>$dbh, schema=>$schema, userID=>0, pd=>$pdList[$i]{prnumber}, status=>$pdList[$i]{status}, settings => \%settings);
        }
        $dbh->commit;

# do history dollar changes
        print "<br>Working on History<br><br>\n";
        $sqlcode = "UPDATE $schema.pd_history SET shippingchange=0.0, taxchange=0.0";
        $dbh->do($sqlcode);
        $sqlcode = "UPDATE $schema.item_history SET pricechange=0.0";
        $dbh->do($sqlcode);
        
        $sqlcode = "SELECT prnumber, status, TO_CHAR(changedate,'$dateFormat'), tax, shipping FROM $schema.pd_history WHERE status IN (15,16,17,18,19) ORDER BY prnumber, changedate";
        $csr = $dbh->prepare($sqlcode);
        $csr->execute;
        
        my $lastPR = "###";
        my $lastTax = 0.0;
        my $lastShipping = 0.0;
        while (my ($prnumber,$status, $changedate, $tax, $shipping) = $csr->fetchrow_array) {
            my $taxChange;
            my $shippingChange;
            if ($lastPR ne $prnumber) {
                $taxChange = $tax;
                $shippingChange = $shipping;
            } else {
                $taxChange = $tax - $lastTax;
                $shippingChange = $shipping - $lastShipping;
            }
            $dbh->do("UPDATE $schema.pd_history SET shippingchange=$shippingChange, taxchange=$taxChange WHERE prnumber='$prnumber' AND changedate=TO_DATE('$changedate','$dateFormat')");
            
            $lastPR = $prnumber;
            $lastTax = $tax;
            $lastShipping = $shipping;
        }
        $csr->finish;
        
        $dbh->commit;
        $sqlcode = "SELECT prnumber, itemnumber, TO_CHAR(changedate,'$dateFormat'), quantity, unitprice ";
        $sqlcode .= "FROM $schema.item_history WHERE (prnumber || changedate) IN (SELECT (prnumber || changedate) FROM $schema.pd_history WHERE status IN (15,16,17,18,19)) ";
        $sqlcode .= "ORDER BY prnumber, itemnumber, changedate";
        $csr = $dbh->prepare($sqlcode);
        $csr->execute;
        
        $lastPR = "###";
        my $lastItem = -100;
        my $lastPrice = 0.0;
        while (my ($prnumber,$itemnumber, $changedate, $quantity, $unitprice) = $csr->fetchrow_array) {
            my $priceChange = 0.0;
            my $price = $quantity * $unitprice;
            my ($testStatus) = $dbh->selectrow_array("SELECT status FROM $schema.pd_history WHERE prnumber='$prnumber' AND changedate=TO_DATE('$changedate','$dateFormat')");
            if ($testStatus >14 && $testStatus < 20) {
                if ($lastPR ne $prnumber || $lastItem != $itemnumber) {
                    $priceChange = $price;
                } else {
                    $priceChange = $price - $lastPrice;
                }
                $dbh->do("UPDATE $schema.item_history SET pricechange=$priceChange WHERE prnumber='$prnumber' AND itemnumber=$itemnumber AND changedate=TO_DATE('$changedate','$dateFormat')");
                
                $lastPR = $prnumber;
                $lastItem = $itemnumber;
                $lastPrice = $price;
                $dbh->commit;
            }
        }
        $csr->finish;

# update po cn history
        $dbh->do("UPDATE po_cn_history SET changeamount=0.0");
        $sqlcode = "SELECT prnumber, chargenumber, ec, amount, invoiced, TO_CHAR(changedate,'$dateFormat'), changeamount, changes ";
        $sqlcode .= "FROM $schema.po_cn_history ORDER BY prnumber, chargenumber, ec, changedate";
        $csr = $dbh->prepare($sqlcode);
        $csr->execute;
        
        my $lastPR = '##';
        my $lastCN = '##';
        my $lastEC = '##';
        my $lastAmount = 0.0;
        while (my ($pr, $cn, $ec, $amount, $invoiced, $changedate, $amountchange, $changes) = $csr->fetchrow_array) {
            my $changeAmount = 0.00;
            if ($lastPR ne $pr || $lastCN ne $cn || $lastEC ne $ec) {
                $lastPR = $pr;
                $lastCN = $cn;
                $lastEC = $ec;
                $changeAmount = $amount;
            } else {
                $changeAmount = $amount - $lastAmount;
            }
            $lastAmount = $amount;
            $dbh->do("UPDATE $schema.po_cn_history SET changeamount=$changeAmount WHERE prnumber='$pr' AND chargenumber='$cn' " .
                  "AND ec='$ec' AND changedate=TO_DATE('$changedate','$dateFormat')");
        }
        $csr->finish;
        
##        $dbh->do("UPDATE po_cn_history SET changeamount=amount");
        $dbh->commit;

        print "<br><h2 align=center>Done</h2>\n";
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, 0, $schema, "Migration Update in $form", $@));
    }
    print &doFooter;


&db_disconnect($dbh);
exit();
