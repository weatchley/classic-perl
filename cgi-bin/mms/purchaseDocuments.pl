#!/usr/local/bin/perl -w

# purchase document functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/purchaseDocuments.pl,v $
#
# $Revision: 1.16 $
#
# $Date: 2010/02/22 22:44:05 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: purchaseDocuments.pl,v $
# Revision 1.16  2010/02/22 22:44:05  atchleyb
# ACR0911_002 - fixed issue with vhange winning vendor utility
#
# Revision 1.15  2009/09/04 16:55:30  atchleyb
# ACR0908_007 - Changes to implement new Tax Report
#
# Revision 1.14  2009/05/29 21:35:51  atchleyb
# ACR0905_001 - user change request, multiple changes
#
# Revision 1.13  2008/02/11 18:32:03  atchleyb
# SCR000037 - Updates related to change request, see change request for details
#
# Revision 1.12  2007/02/07 17:28:29  atchleyb
# CR 0030 - Updated to handle default PO clauses
#
# Revision 1.11  2006/05/17 22:55:35  atchleyb
# CR0026 - Added code for pushing a PO with accounting open to receiving
#
# Revision 1.10  2006/01/31 23:13:29  atchleyb
# CR 0022 - added code for cancel init PR and moving po pend back to rfp
# CR 0022 - added code so buyer could be displayed on po selection screens
#
# Revision 1.9  2005/08/18 18:51:55  atchleyb
# CR00015 - combined code for browse and copyprform, added filters to browse for site and vendor
#
# Revision 1.8  2005/06/10 22:30:52  atchleyb
# added control code for assignBuyer function
#
# Revision 1.7  2004/12/07 18:38:09  atchleyb
# added new controls for reports
#
# Revision 1.6  2004/05/05 23:20:01  atchleyb
# added parameters passed to function
#
# Revision 1.5  2004/04/16 17:57:33  atchleyb
# updated to add RFP amendment
#
# Revision 1.4  2004/04/05 23:33:19  atchleyb
# added code for dev cycle 11
#
# Revision 1.3  2004/04/02 00:05:45  atchleyb
# updated for po processing
#
# Revision 1.2  2004/02/27 00:23:36  atchleyb
# added fy and requester to some lookup/browse calls
#
# Revision 1.1  2003/11/12 20:41:17  atchleyb
# Initial revision
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
use CGI;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $dbh;
$dbh = db_connect();
#$dbh = db_connect(server => 'ydoracle');
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

&checkLogin(cgi => $cgi);
#! test for invalid or timed out session
&validateCurrentSession(dbh => $dbh, schema => $schema, userID => $userid, sessionID => $settings{sessionID});


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
#
if ($command eq "browse" || $command eq "amendposelect" || 
    $command eq "reopenposelect" || $command eq "cancelinitprselect" || 
    $command eq "cancelprselect" || $command eq "cancelrfpselect" || 
    $command eq "cancelposelect" || $command eq "amendrfpselect" || 
    $command eq "assignbuyerselect" || $command eq "popendtorfpselect" || 
    $command eq "copyprform" || $command eq "pushpofromaptorecselect" ||
    $command eq "changevendorselect") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    my $type = 'browse';
    eval {
        if ($command eq "amendposelect") {
            $type = 'amendment';
        } elsif ($command eq "reopenposelect") {
            $type = 'reopen';
        } elsif ($command eq "cancelinitprselect") {
            $type = 'cancelinitpr';
        } elsif ($command eq "cancelprselect") {
            $type = 'cancelpr';
        } elsif ($command eq "cancelrfpselect") {
            $type = 'cancelrfp';
        } elsif ($command eq "cancelposelect") {
            $type = 'cancelpo';
        } elsif ($command eq "amendrfpselect") {
            $type = 'amendrfp';
        } elsif ($command eq "assignbuyerselect") {
            $type = 'assignbuyerselect';
        } elsif ($command eq "popendtorfpselect") {
            $type = 'popendtorfp';
        } elsif ($command eq "copyprform") {
            $type = 'copyprform';
        } elsif ($command eq "pushpofromaptorecselect") {
            $type = 'pushpofromaptorec';
        } elsif ($command eq "changevendorselect") {
            $type = 'changevendor';
        }
        print &doBrowse(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, sortBy=>$settings{sortby},
            path => $path, fy => $settings{viewfy}, requester=>$settings{requester2}, buyer=>$settings{buyer2}, 
            siteID=>$settings{siteid}, vendorID=>$settings{vendorid}, command => $command,
            poAmendment=>(($command ne "amendposelect") ? 'F' : 'T'), type=>$type, statusList=>$settings{viewstatus}, deptID=>$settings{deptid});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "$type in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "displaypd" || $command eq "browsehistory") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doDisplayPD(dbh => $dbh, schema => $schema, title => $title, form => $form,  userID => $userid, path => $path, 
              history => (($command eq "browsehistory") ? "T" : "F"), settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display PD ($settings{id}) in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "addpdform" || $command eq "updatepdform" || 
         $command eq "addprform" || $command eq "updateprform" ||  
         $command eq "addpoform" || $command eq "updatepoform" ||
         $command eq "approvepdform" || $command eq "updaterfpform" ||
         $command eq "acceptpo" || $command eq "placepoform" || 
         $command eq "acceptplacepoform") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path, includeJSCalendar=>'T',
           includeJSWidgets=>'T', useFileUpload=>'T');
    eval {
        #if ($command eq "acceptpo" || $command eq "acceptplacepoform") {
        #    &doProcessAcceptPO(dbh => $dbh, schema => $schema, pd=>$settings{id}, userID => $userid);
        #}
        print &doPDEntryForm(dbh => $dbh, schema => $schema, type => ((substr($command,0,3) eq "add") ? 'new' : 'update'), 
              title => $title, form => $form, path => $path,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Add/Update PD" . 
                        ((defined($settings{id})) ? " ($settings{id})" : "") . " form in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "addpd" || $command eq "updatepd" || 
         $command eq "addpr" || $command eq "updatepr" ||  
         $command eq "addpo" || $command eq "updatepo") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doPDEntry(dbh => $dbh, schema => $schema, type => ((substr($command,0,3) eq "add") ? 'new' : 'update'), 
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Add/Update PD" . 
                        ((defined($settings{id})) ? " ($settings{id})" : "") . " in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "pdapproved" || $command eq "pddisapproved") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doPDApproval(dbh => $dbh, schema => $schema, type => (($command eq "pdapproved") ? 'approve' : 'disapprove'), 
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Approve PD ($settings{id}) in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "dochangevendor") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doChangeVendor(dbh => $dbh, schema => $schema, 
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Change Winning Vendor, PD ($settings{id}) in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "displayattachment") {
    eval {
        print &doDisplayAttachment(dbh => $dbh, schema => $schema, id=>$settings{id}, settings => \%settings);
    };
    if ($@) {
        print &doHeader(displayTitle => 'F', settings => \%settings, form => $form, path => $path);
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display attachment in $form", $@));
        print &doFooter(form => $form, path => $path, settings => \%settings);
    }
###################################################################################################################################
} elsif ($command eq "printpr") {
    eval {
        print &doPrintPR(dbh => $dbh, schema => $schema, id=>$settings{id}, settings => \%settings);
    };
    if ($@) {
        print &doHeader(displayTitle => 'F', settings => \%settings, form => $form, path => $path);
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Generate a PR ($settings{id}) PDF for display in $form", $@));
        print &doFooter(form => $form, path => $path, settings => \%settings);
    }
###################################################################################################################################
} elsif ($command eq "printrfp") {
    eval {
        print &doPrintRFP(dbh => $dbh, schema => $schema, id=>$settings{id}, settings => \%settings);
    };
    if ($@) {
        print &doHeader(displayTitle => 'F', settings => \%settings, form => $form, path => $path);
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Generate a RFP ($settings{id}) PDF for display in $form", $@));
        print &doFooter(form => $form, path => $path, settings => \%settings);
    }
###################################################################################################################################
} elsif ($command eq "printpo") {
    eval {
        print &doPrintPO(dbh => $dbh, schema => $schema, id=>$settings{id}, settings => \%settings);
    };
    if ($@) {
        print &doHeader(displayTitle => 'F', settings => \%settings, form => $form, path => $path);
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Generate a PO ($settings{id}) PDF for display in $form", $@));
        print &doFooter(form => $form, path => $path, settings => \%settings);
    }
###################################################################################################################################
} elsif ($command eq "printpoinfo") {
    eval {
        print &doPrintPOInfo(dbh => $dbh, schema => $schema, id=>$settings{id}, settings => \%settings);
    };
    if ($@) {
        print &doHeader(displayTitle => 'F', settings => \%settings, form => $form, path => $path);
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Generate a PO ($settings{id}) Info PDF for display in $form", $@));
        print &doFooter(form => $form, path => $path, settings => \%settings);
    }
###################################################################################################################################
} elsif ($command eq "printpoactivity") {
    eval {
        print &doPrintPOActivity(dbh => $dbh, schema => $schema, id=>$settings{id}, site=>$settings{site},
            startDate=>$settings{startdate}, endDate=>$settings{enddate}, format=>$settings{poactformat}, 
            sortBy=>$settings{actsortby}, settings => \%settings);
    };
    if ($@) {
        print &doHeader(displayTitle => 'F', settings => \%settings, form => $form, path => $path);
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Generate a PO ($settings{id}) Activity PDF for display in $form", $@));
        print &doFooter(form => $form, path => $path, settings => \%settings);
    }
###################################################################################################################################
} elsif ($command eq "printposocioeconomic") {
    eval {
        print &doPrintPOSocioEconomic(dbh => $dbh, schema => $schema, id=>$settings{id}, site=>$settings{sesite},
            startDate=>$settings{sestartdate}, endDate=>$settings{seenddate}, format=>$settings{poseformat}, 
            sortBy=>$settings{sesortby}, settings => \%settings);
    };
    if ($@) {
        print &doHeader(displayTitle => 'F', settings => \%settings, form => $form, path => $path);
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Generate a PO Socio Economic PDF for display in $form", $@));
        print &doFooter(form => $form, path => $path, settings => \%settings);
    }
###################################################################################################################################
} elsif ($command eq "printpoaging") {
    eval {
        print &doPrintPOAging(dbh => $dbh, schema => $schema, id=>$settings{id}, site=>$settings{agesite},
            howOld=>$settings{agehowold}, type=>$settings{agetype}, format=>$settings{poageformat}, 
            sortBy=>$settings{agesortby}, settings => \%settings);
    };
    if ($@) {
        print &doHeader(displayTitle => 'F', settings => \%settings, form => $form, path => $path);
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Generate a PO ($settings{id}) Aging PDF for display in $form", $@));
        print &doFooter(form => $form, path => $path, settings => \%settings);
    }
###################################################################################################################################
} elsif ($command eq "printobnotinv") {
    eval {
        print &doPrintObligatedNotInvoiced(dbh => $dbh, schema => $schema, id=>$settings{id}, site=>$settings{onisite},
            format=>$settings{oniformat}, sortBy=>$settings{onisortby}, settings => \%settings);
    };
    if ($@) {
        print &doHeader(displayTitle => 'F', settings => \%settings, form => $form, path => $path);
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Generate a PO Obligated Not Invoiced PDF for display in $form", $@));
        print &doFooter(form => $form, path => $path, settings => \%settings);
    }
###################################################################################################################################
} elsif ($command eq "printtaxrep") {
    eval {
        print &doPrintTaxReport(dbh => $dbh, schema => $schema, id=>$settings{id}, site=>$settings{trsite},
            startDate=>$settings{trstartdate}, endDate=>$settings{trenddate}, format=>$settings{trformat}, 
            sortBy=>$settings{trsortby}, taxType=>$settings{taxtype}, settings => \%settings);
    };
    if ($@) {
        print &doHeader(displayTitle => 'F', settings => \%settings, form => $form, path => $path);
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Generate a Tax Report PDF for display in $form", $@));
        print &doFooter(form => $form, path => $path, settings => \%settings);
    }
###################################################################################################################################
} elsif ($command eq "printcommitted") {
    eval {
        print &doPrintCommitted(dbh => $dbh, schema => $schema, id=>$settings{id}, site=>$settings{comsite},
            startDate=>$settings{comstartdate}, endDate=>$settings{comenddate}, format=>$settings{comformat}, 
            sortBy=>$settings{comsortby}, settings => \%settings);
    };
    if ($@) {
        print &doHeader(displayTitle => 'F', settings => \%settings, form => $form, path => $path);
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Generate a PO Committed PDF for display in $form", $@));
        print &doFooter(form => $form, path => $path, settings => \%settings);
    }
###################################################################################################################################
} elsif ($command eq "printinvlog") {
    eval {
        print &doPrintInvoiceLog(dbh => $dbh, schema => $schema, id=>$settings{id}, site=>$settings{invlsite},
            startDate=>$settings{invlstartdate}, endDate=>$settings{invlenddate}, format=>$settings{invlformat}, 
            sortBy=>$settings{invlsortby}, startingPO=>$settings{startpo}, settings => \%settings);
    };
    if ($@) {
        print &doHeader(displayTitle => 'F', settings => \%settings, form => $form, path => $path);
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Generate a PO Invoice Log PDF for display in $form", $@));
        print &doFooter(form => $form, path => $path, settings => \%settings);
    }
###################################################################################################################################
} elsif ($command eq "copypr") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doCopyPR(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, deptID=>$settings{deptid}, 
            id=>$settings{id});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Copy PR Form in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "acceptprforrfp") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doAcceptPRForRFP(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, id=>$settings{id});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Accept PR for RFP in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "addclausetext") {
    print &doHeader(displayTitle => 'F', dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doAddClauseText(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, id=>$settings{id}, 
                   clause=>$settings{clauseselect});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Add clause text to PD in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "updaterfp") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
#        my ($name, $fileContents) = &getFile(fileParam=>'attachment');
#        print &doRFPUpdate(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, 
#               fileName=>$name, fileContents=>$fileContents, settings => \%settings);
        print &doRFPUpdate(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, 
               settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update RFP in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "placepo" || $command eq "acceptplacepoform") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doPlacePO(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, 
               settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Place PO in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "doamendpo") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doAmendPO(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, 
               settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Amend PO in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "doamendrfp") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doAmendRFP(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, 
               settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Amend RFP in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "doreopenpo") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doReopenPO(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, 
               settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Reopen PO in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "docancelpr") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doCancelPR(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, 
               settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Reopen PO in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "docancelrfp") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doCancelRFP(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, 
               settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Reopen PO in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "docancelpo") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doCancelPO(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, 
               settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Reopen PO in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "printarchive") {
    eval {
        print &doPrintArchive(dbh => $dbh, schema => $schema, id=>$settings{id}, date=>$settings{datetest}, settings => \%settings);
    };
    if ($@) {
        print &doHeader(displayTitle => 'F', settings => \%settings, form => $form, path => $path);
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display a PDF in $form", $@));
        print &doFooter(form => $form, path => $path, settings => \%settings);
    }
###################################################################################################################################
} elsif ($command eq "assignbuyerform") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doAssignBuyerForm(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, PD=>$settings{id}, 
              settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Reopen PO in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "doassignbuyer") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doAssignBuyer(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, 
               settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Reopen PO in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "dopopendtorfp") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doPOPendingToRFP(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, 
               settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Reopen PO in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "pushpofromaptorec") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doPOAPOpenToRec(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, 
               settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Reopen PO in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "dosavepdremark") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doSavePDRemark(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, refresh => 'F', 
               settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Save PD Remark", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
###################################################################################################################################
} else {
    print &doHeader(dbh => $dbh, title => 'Bad Command', settings => \%settings, form => $form, path => $path);
    print "<br><center>Command $command not known</center>\n";
    print &doFooter(form => $form, path => $path, settings => \%settings);
}


&db_disconnect($dbh);
exit();
