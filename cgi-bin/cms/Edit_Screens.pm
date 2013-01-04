# Module contains functions pertaining to the edit screens of CMS
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/cms/perl/RCS/Edit_Screens.pm,v $
# $Revision: 1.27 $
# $Date: 2003/01/09 18:28:30 $
# $Author: naydenoa $
# $Locker: atchleyb $
# $Log: Edit_Screens.pm,v $
# Revision 1.27  2003/01/09 18:28:30  naydenoa
# Added conditional retrieval of managers to account for records w/o managers
#
# Revision 1.26  2003/01/02 23:36:54  naydenoa
# Added NRC date and DOE manager display to commitment display functions
# CREQ00023, CREQ00024
#
# Revision 1.25  2002/11/27 21:15:02  naydenoa
# Added function getHeader to look up a form element or page header from table HEADING
#
# Revision 1.24  2002/04/12 23:39:15  naydenoa
# Checkpoint
#
# Revision 1.23  2001/12/10 22:25:29  naydenoa
# Added BSCDL select, updated commitment info display to reflect
# change in role assignments (from BSCLL to BSCDL)
#
# Revision 1.22  2001/11/15 23:01:49  naydenoa
# Added functions to handle Licensing Lead and Responsible Manager
# assignments, action entry and display.
#
# Revision 1.21  2001/06/01 23:07:17  naydenoa
# Added some Licensing Lead processing; checkpoint
#
# Revision 1.20  2001/05/02 22:39:44  naydenoa
# Code clean-up
#
# Revision 1.19  2001/02/21 22:21:25  naydenoa
# Added sub selectRSS, added RSS display in commitment table
#
# Revision 1.18  2001/01/31 22:08:21  naydenoa
# Added historicals to commitment display
# Took out secondaty discipline from commitment display
#
# Revision 1.17  2001/01/04 18:41:42  naydenoa
# Tweaks to writeResponse to work with response entry utility
#
# Revision 1.16  2001/01/02 17:33:04  naydenoa
# Added fillLetter functionality
#
# Revision 1.15  2000/12/19 21:48:11  naydenoa
# Minor tweaks and optimization
#
# Revision 1.14  2000/12/07 22:03:36  naydenoa
# Fixed SQL error in writeResponse
#
# Revision 1.13  2000/12/07 18:59:51  naydenoa
# Added writeResponse functionality, updated existing subs
#
# Revision 1.12  2000/11/20 21:54:22  naydenoa
# Added page input for source doc
#
# Revision 1.11  2000/11/20 19:41:44  naydenoa
# Added more functions to reduce redundancy in workflow screens
#
# Revision 1.10  2000/11/08 22:38:13  naydenoa
# Moved CMaker selection w/i appropriate if-stmt in doProcessingTable,
# Fixed path in doIssueSourceTable
#
# Revision 1.9  2000/11/07 23:20:59  naydenoa
# Consolidated commitment processing into one function, deleted
# old ones, deleted functions dealing with rationales
#
# Revision 1.8  2000/10/31 23:27:43  naydenoa
# Same as previous -- the time bug
#
# Revision 1.7  2000/10/31 23:24:55  naydenoa
# Fixed time display bug in remarks table
#
# Revision 1.6  2000/10/31 19:41:42  naydenoa
# Updated existing functions, added keyword processing to
# commitment table, added functions for products affected
# and orgs committed to processing
# Took out rationale functions (except for rejection rat)
#
# Revision 1.5  2000/10/24 20:08:48  naydenoa
# Updated doHeadTable to list keywords for commitments
#
# Revision 1.4  2000/10/17 17:04:45  naydenoa
# Code update.
#
# Revision 1.3  2000/09/28 18:22:50  naydenoa
# Updated and added functions
#
# Revision 1.2  2000/09/08 23:44:43  naydenoa
# Added more functions to module.
#
# Revision 1.1  2000/09/01 23:54:57  naydenoa
# Initial revision
#
#

package Edit_Screens;
use strict;
use ONCS_Header qw(:Constants); #(%ONCSHash);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific;
use ONCS_Widgets qw(:Functions);

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw(%ONCSHash);
use Exporter;
$VERSION = 1.00;
@ISA = qw(Exporter);
@EXPORT = qw (            &doIssueTable		   &doIssueSourceTable
                          &doHeadTable             &writeCommitmentText 
                          &writeWorkEstimate       &writeActionPlan
                          &writeActionSummary      &writeDLRecommend
                          &writeComment            &writeCMgrRecommend	
                          &doResponseTable         &doProcessingTable
			  &ReadOnly		   &doRemarksTable
                          &putProducts             &putCommitted
                          &selectDiscipline        &selectLevel
                          &selectSource            &selectWBS
                          &selectKeywords          &selectProducts
                          &selectCMaker            &selectOrganizations
                          &writeResponse           &fillLetter
                          &selectRSS               &writeActionsTaken
                          &selectLL                &selectRM
                          &doActionsTable          &selectBSCDL
                          &getHeading
);
@EXPORT_OK = qw (         &doIssueTable		   &doIssueSourceTable
                          &doHeadTable             &writeCommitmentText 
                          &writeWorkEstimate       &writeActionPlan
                          &writeActionSummary      &writeDLRecommend
            	          &writeComment            &writeCMgrRecommend
                          &doResponseTable         &doProcessingTable
                          &ReadOnly		   &doRemarksTable
	                  &putProducts	           &putCommitted
                          &selectDiscipline        &selectLevel
                          &selectSource            &selectWBS
                          &selectKeywords          &selectProducts
                          &selectCMaker            &selectOrganizations
                          &writeResponse           &fillLetter
                          &selectRSS               &writeActionsTaken
                          &selectLL                &selectRM
                          &doActionsTable          &selectBSCDL
                          &getHeading
);
%EXPORT_TAGS = 
	(Functions => qw [&doIssueTable		   &doIssueSourceTable
                          &doHeadTable             &writeCommitmentText 
                          &writeWorkEstimate       &writeActionPlan 
                          &writeActionSummary      &writeDLRecommend
                          &writeComment            &writeCMgrRecommend
                          &doResponseTable         &doProcessingTable
                          &ReadOnly		   &doRemarksTable
                          &putProducts             &putCommitted
                          &selectDiscipline        &selectLevel
                          &selectSource            &selectWBS
                          &selectKeywords          &selectProducts
                          &selectCMaker            &selectOrganizations
                          &writeResponse           &fillLetter
                          &selectRSS               &writeActionsTaken
                          &selectLL                &selectRM
                          &doActionsTable          &selectBSCDL
                          &getHeading
]);

#################
sub doIssueTable{
#################
    my %args = (
	iid => 0,
	cid => 0,
	@_,
    );
    $args{dbh}->{LongReadLen} = 1000000;
    $args{dbh}->{LongTruncOk} = 0;

    my $issueid;
    if ($args{iid}) {
  	$issueid = $args{iid};
    }
    else {
	if ($args{cid}) {
	    my ($issue) = $args{dbh} -> selectrow_array ("select issueid from $args{schema}.commitment where commitmentid=$args{cid}");
	    $issueid = $issue;
	}
    }
    my ($text, $date, $enteredbyid, $categoryid) = $args{dbh} -> selectrow_array ("select text, to_char(entereddate, 'MM/DD/YYYY'), enteredby, categoryid from $args{schema}.issue where issueid=$issueid");
    my ($enteredby) = $args{dbh} -> selectrow_array ("select firstname || ' ' || lastname from $args{schema}.users where usersid = $enteredbyid");
    my ($category) = $args{dbh} -> selectrow_array ("select description from $args{schema}.category where categoryid = $categoryid");
    my $issuestr = substr ('0000'.$issueid,-5);
    $text =~ s/\n/<br>/g;
    my $outstr;
    $outstr .= "<tr><td align=left><b><li>Issue Information:</b><br>\n";
    $outstr .= "<table width=100% border=1>\n";
    $outstr .= "<tr><td><table width=100% border=0 cellpadding=0 cellspacing=0>\n";
    $outstr .= "<tr bgcolor=#ffffff valign=top><td align=left width=38%><b>Issue ID:</b></td>\n";
    $outstr .= "<td><b>I$issuestr</b></td></tr>\n";
    $outstr .= "<tr bgcolor=#eeeeee valign=top><td valign=top><b>Issue Text:</b></td>\n";
    $outstr .= "<td>$text</td></tr>\n";
    $outstr .= "<tr bgcolor=#ffffff valign=top><td align=left width=38%><b>Date Entered:</b></td>\n";
    $outstr .= "<td>$date</td></tr>\n";
    $outstr .= "<tr bgcolor=#eeeeee valign=top><td align=left width=38%><b>Entered By:</b></td>\n";
    $outstr .= "<td>$enteredby</td></tr>\n";
    $outstr .= "<tr bgcolor=#ffffff valign=top><td valign=top><b>Keywords:</b></td><td>\n";
    my $keywords = $args{dbh} -> prepare ("select k.description from $args{schema}.keyword k, $args{schema}.issuekeyword ik where k.keywordid=ik.keywordid and ik.issueid=$issueid");
    $keywords -> execute;
    my $rows = 0;
    while (my @values = $keywords -> fetchrow_array){
	$rows++;
	my ($kword) = @values;
	$outstr .= "<li>$kword<br>\n";
    }
    $keywords -> finish;
    if ($rows == 0){
        $outstr .= "None\n";
    }
    $outstr .= "</td></tr>\n";
    $outstr .= "<tr bgcolor=#eeeeee valign=top><td align=left width=38%><b>Category:</b></td>\n";
    $outstr .= "<td>$category</td></tr>\n";
    $outstr .= "</table></td></tr></table></td></tr>\n";
    return ($outstr);
}

########################
sub doIssueSourceTable {
########################
    my %args = (
	iid => 0,
	cid => 0,
	@_,
        );
    #my $FullImagePath = "$SYSPathRoot/data/temp/cms/dev/images";
    my $FullImagePath = "$CMSFullImagePath";
    my $outstr;
    my $issueid;
    if ($args{iid}) {
  	$issueid = $args{iid};
    }
    else {
	if ($args{cid}) {
	    my ($issue) = $args{dbh} -> selectrow_array ("select issueid from $args{schema}.commitment where commitmentid=$args{cid}");
	    $issueid = $issue;
	}
    }
    my $imagestr = "select o.name, s.title, to_char(s.documentdate, 'MM/DD/YYYY'), s.sourcedocid, s.accessionnum, i.imageextension, i.page from $args{schema}.organization o, $args{schema}.sourcedoc s, $args{schema}.issue i where i.issueid=$issueid and i.sourcedocid=s.sourcedocid and s.organizationid=o.organizationid";
    my ($orgname, $doctitle, $docdate, $sourceid, $accnum, $ext, $page) = $args{dbh} -> selectrow_array($imagestr);

    if ($page eq "") {
        $page = "Not Available";
    } 
    if (!($accnum)) {
        $accnum = "Not Available";
    }
    if (!($orgname)) {
        $orgname = "Not Available";
    }
    if (!($doctitle)) {
        $doctitle = "Not Available";
    }
    if (!($docdate)) {
        $docdate = "Not Available";
    }
    $outstr .= "<tr><td><b><li>Issue Source Information:<br>\n"; 
    $outstr .= "<table border=1 width=100%><tr><td>\n";
    $outstr .= "<table border=0 cellpadding=0 cellspacing=0 width=100%>\n";
    $outstr .= "<tr bgcolor=#ffffff valign=top><td><b>Accession Number:</b></td><td>$accnum</td></tr>\n";
    $outstr .= "<tr bgcolor=#eeeeee valign=top><td><b>Document Title:</b></td><td>$doctitle</td></tr>\n";
    $outstr .= "<tr bgcolor=#ffffff valign=top><td><b>Document Date:</b></td><td>$docdate</td></tr>\n";
    $outstr .= "<tr bgcolor=#eeeeee valign=top><td><b>Page Number Containing Issue:</b></td><td>$page</td></tr>\n";
    $outstr .= "<tr bgcolor=#ffffff valign=top><td width=38%><b>Originating Organization:</b></td><td>$orgname</td></tr>\n";
    if ($ext ne "") {
        my $image = $FullImagePath . "/issueimage$issueid$ext";
        if (open (OUTFILE, "| ./File_Utilities.pl --command writeFile --protection 0664 --fullFilePath $image")) {
            print OUTFILE get_issue_image($args{dbh}, $issueid);
            close OUTFILE;
        }
        else {
            print "could not open file $image<br>\n";
        }
        $outstr .= "<tr bgcolor=#eeeeee><td><b>Issue Image:</b></td>\n";
        $outstr .= "<td><a href='$CMSImagePath/issueimage$issueid$ext' target=imagewin>Click for the image source file</a>\n";
        $outstr .= "<input name=issuehasimage type=hidden value=-1></td></tr>\n";
    }
    $outstr .= "</table></td></tr>\n";
    $outstr .= "</table></td></tr>\n";
    $outstr .= "<input name=issuehassourcedoc type=hidden value=-1>\n";
    $outstr .= "<input name=page type=hidden value=$page>\n";
    $outstr .= "<input name=sourcedocid type=hidden value=$sourceid>\n";
    $outstr .= "<input name=accessionnum type=hidden value=$accnum>\n";
    $outstr .= "<input name=signer type=hidden value=-1>\n";
    $outstr .= "<input name=emailaddress type=hidden value=-1>\n";
    $outstr .= "<input name=areacode type=hidden value=-1>\n";
    $outstr .= "<input name=phonenumber type=hidden value=-1>\n";
    $outstr .= "<input name=documentdate_month type=hidden value=-1>\n";
    $outstr .= "<input name=documentdate_day type=hidden value=-1>\n";
    $outstr .= "<input name=documentdate_year type=hidden value=-1>\n";
    $outstr .= "<input name=organizationid type=hidden value=-1>\n";

    return ($outstr);
}

#################
sub doHeadTable {
#################
    my %args = (
	cid => 0,
	cidstring => 'No commitment',
	@_,
        );		

    my $path = "/cgi-bin/cms/";
    my $outstring;
    my %chash = get_commitment_info ($args{dbh}, $args{cid});	
    my $primary = $chash{'primarydiscipline'};
    my $level = $chash{'commitmentlevelid'};
    my $wbs = $chash{'controlaccountid'}; 
    my $duedate = $chash{'duedate'}; 
    my $text = $chash{'text'};
    my $closedate = $chash{'closeddate'};
    my $status = $chash{'statusid'};
    my $commitdate = $chash{'commitdate'};
    my $fulfilldate = $chash{'fulfilldate'}; 
    my $extid = $chash{'externalid'};
    my $nrcdate = $chash{'dateduetonrc'};
    my $lleadid = $chash{'lleadid'};
    my $managerid = $chash{'managerid'};
    my $doemanagerid = $chash{'doemanagerid'};

    $text =~ s/\n/<BR>/g;
    my $rmgr = ($managerid) ? $args{dbh} -> selectrow_array ("select firstname || ' ' || lastname from $SCHEMA.responsiblemanager where responsiblemanagerid = $managerid") : "&nbsp;";
    my $doermgr = ($doemanagerid) ? $args{dbh} -> selectrow_array ("select firstname || ' ' || lastname from $SCHEMA.responsiblemanager where responsiblemanagerid = $doemanagerid") : "&nbsp;";
    my $llead = ($lleadid) ? $args{dbh} -> selectrow_array ("select firstname || ' ' || lastname from $SCHEMA.users where usersid = $lleadid") : "&nbsp;";

#    my ($llead, $rmgr) = $args{dbh} -> selectrow_array ("select u.firstname || ' ' || u.lastname, r.firstname || ' ' || r.lastname from $args{schema}.commitment c, $args{schema}.users u, $args{schema}.responsiblemanager r where c.commitmentid = $args{cid} and c.lleadid = u.usersid and c.managerid = r.responsiblemanagerid");
    $outstring .= "<tr><td align=left><b><li>Commitment Information:</b><br>\n";
    $outstring .= "<table width=100% border=1>\n";
    $outstring .= "<tr><td><table width=100% border=0 cellpadding=0 cellspacing=0>\n";
    $outstring .= "<tr bgcolor=#ffffff valign=top><td align=left width=38%><b>Commitment ID:</b></td>\n";
    $outstring .= "<td><b> " . formatID2($args{cid}, 'C') . "</b></td></tr>\n";
    $extid = ($extid) ? $extid : "None";
    $outstring .= "<tr bgcolor=#eeeeee><td><b>External ID:</b></td><td>$extid</td></tr>\n";
    $outstring .= "<tr valign=top bgcolor=#ffffff><td><b>Discipline:</b> </td>\n";
    my ($primarydesc) = $args{dbh} -> selectrow_array ("select description from $args{schema}.discipline where disciplineid = $primary");
    $outstring .= "<td>$primarydesc</td></tr>\n";
    $outstring .= "<tr bgcolor=#eeeeee><td><b>BSC Discipline Lead:</b></td>\n";
    $outstring .= "<td>$llead</td></tr>\n";
    $outstring .= "<tr bgcolor=#ffffff><td><b>BSC Responsible Manager:</b></td>\n";
    $outstring .= "<td>$rmgr</td></tr>\n";
    $outstring .= "<tr bgcolor=#eeeeee><td><b>DOE Responsible Manager:</b></td>\n";
    $outstring .= "<td>$doermgr</td></tr>\n";
    $outstring .= "<tr bgcolor=#ffffff valign=top>";
    $outstring .= "<td><b>Level of Commitment:</b></td>\n";
    my ($leveldesc) = ($level ne "") ? $args{dbh} -> selectrow_array ("select description from $args{schema}.commitmentlevel where commitmentlevelid=$level") : "Not Available";
    $outstring .= "<td>$leveldesc</td></tr>\n";
    $outstring .= "<tr bgcolor=#eeeeee valign=top><td valign=top>\n";
    $outstring .= "<b>Date Due to Commitment Maker:</b></td><td>$duedate</td></tr>\n";
    $outstring .= "<tr bgcolor=#ffffff valign=top><td valign=top>\n";
    if ($status > 2 && $status != 17) {
        $outstring .= "<b>Work Breakdown Structure:</b></td>\n";
        my ($wbsdesc) = ($wbs ne "") ? $args{dbh} -> selectrow_array ("select controlaccountid || ' - ' || description from $args{schema}.workbreakdownstructure where controlaccountid='$wbs'") : "Not Available";
        $outstring .= "<td>$wbsdesc</td></tr>\n";
        $outstring .= "<tr bgcolor=#eeeeee valign=top><td><b>Keywords:</b></td><td>\n";
        my $keywords = $args{dbh} -> prepare ("select k.description from $args{schema}.keyword k, $args{schema}.commitmentkeyword ck where k.keywordid=ck.keywordid and ck.commitmentid=$args{cid} order by k.description");
        $keywords -> execute;
        my $rows =0;
        while (my @values = $keywords -> fetchrow_array){
	    $rows++;
       	    my ($kword) = @values;
	    $outstring .= "<li>$kword<br>\n";
        }
        $keywords -> finish;
        if ($rows == 0){
            $outstring .= "None\n";
        }
        $outstring .= "</td></tr>\n";
	if ($status > 2) {
            $outstring .= "<tr bgcolor=#ffffff valign=top><td>\n";
            $outstring .= "<b>Estimated Fulfillment Date:</b></td><td>$fulfilldate</td></tr>\n";
            if ($status > 5) {
	        $outstring .= "<tr bgcolor=#eeeeee valign=top><td>\n";
	        $outstring .= "<b>Date of Commitment Approval:</b></td><td>$commitdate</td></tr>\n";
                $outstring .= "<tr bgcolor=#ffffff valign=top><td>\n";
 	        $outstring .= " <b>Commitment Text:</b></td><td>$text</td></tr>\n";
		if ($status > 8) {
		    $outstring .= "<tr bgcolor=#eeeeee><td>\n";
                    $outstring .= "<b>Date Due To NRC:</b></td>\n";
                    $outstring .= "<td>$nrcdate&nbsp;</td></tr>\n";
	            if ($status > 14 && $status < 17) {
                        $outstring .= "<tr bgcolor=#ffffff valign=top><td valign=top>\n";
                        $outstring .= "<b>Closure Date:</b></td><td>$closedate</td></tr>\n";
                    }
		}
            }
        }
    }
    if ($status == 17) {
         $outstring .= "<tr bgcolor=#eeeeee valign=top><td>\n";
         $outstring .= " <b>Commitment Text:</b></td><td>$text</td></tr>\n";
    }
    $outstring .= "</table></td></tr>\n";
    $outstring .= "</table></td></tr>\n";
    $outstring .= "<input type=hidden name=id value=>\n";
    $outstring .= "<input type=hidden name=option value=>\n";
    $outstring .= "<input type=hidden name=theinterface value=>\n";
    $outstring .= "<input type=hidden name=interfaceLevel value=>\n";
    $outstring .= "<script language=javascript><!--\n";
    $outstring .= "function browseHistorical(id) {\n";
    $outstring .= "    var script = \'browse\';\n";
    $outstring .= "    window.open (\"\", \"historicalwin\", \"height=350, width=750, status=yes, scrollbars=yes\");\n";
    $outstring .= "    document.editcommitment.target = \'historicalwin\';\n";
    $outstring .= "    document.editcommitment.action = \'$path\' + script + \'.pl\';\n";
    $outstring .= "    document.editcommitment.option.value = \'details\';\n";
    $outstring .= "    document.editcommitment.theinterface.value = \'historical\';\n";
    $outstring .= "    document.editcommitment.interfaceLevel.value = \'historicalid\';\n";
    $outstring .= "    document.editcommitment.id.value = id;\n";
    $outstring .= "    document.editcommitment.submit();\n";
    $outstring .= "}\n";
    $outstring .= "//-->\n</script>\n";
	
    return ($outstring);
}

#####################
sub doResponseTable {
#####################
    my %args = (
	textareawidth => 75,
        cid => 0,
	@_,
        );

    my $outstr = "";
    $outstr .= "<tr><td><b><li>First Response Information:</b>";
    my $responses = $args{dbh} -> prepare ("select responseid, text, to_char (writtendate, 'MM/DD/YYYY'), letterid from $SCHEMA.response where commitmentid = $args{cid} and isfirst = 'T'");
    $responses -> execute;
    while (my ($rid, $rtext, $rdate, $lid) = $responses -> fetchrow_array) {
        $rtext =~ s/\n/<BR>/g;
        $outstr .= "<table width=100% border=1 align=center><tr><td><table width=100% border=0 cellpadding=0 cellspacing=0>";
        $outstr .= "<tr bgcolor=#ffffff valign=top><td width=38%><b>Response ID:</b> </td><td><b>" . formatID2($rid,'R') . "</b></td></tr>";
        $outstr .= "<tr bgcolor=#eeeeee valign=top><td><b>Response Text:</b> </td><td>$rtext</td></tr>";
        $outstr .= "<tr bgcolor=#ffffff valign=top><td><b>Date Response Was Written:</b> </td><td>$rdate</td></tr>";
        $outstr .= "</table></td></tr></table>";
    }
    $responses -> finish;
    $outstr .= "</td></tr>";
    return ($outstr);
}

#########################
sub writeCommitmentText {
#########################
    my %args = (
	potential => 0,
	textareawidth => 75,
	decision => '',
	text => '',
	@_,
	);

    my $outstring .= "<tr><td align=left><b><li>";
    if ($args{potential}) {
        $outstring .= "Potential ";
    }
    $outstring .= "Commitment Text:</b>\n";
    if ($args{decision}){
	$outstring .= "<br>(This should be the exact working of the commitment. This text will be used in the official letter.)\n";
    }
    $outstring .= "<br><textarea name=text cols=$args{textareawidth} rows=5>$args{text}</textarea></td></tr>\n";
    return ($outstring);

}

#######################
sub writeWorkEstimate {
#######################
    my %args = (
	textareawidth => 75,
	estimate => 'Not entered',
	@_,
	);

    my $outstring = "<tr><td align=left><b><li>Work Estimate:</b>\n";
    $outstring .= "<br><textarea name=estimate cols=$args{textareawidth} rows=5>$args{estimate}</textarea></td></tr>\n";
    return ($outstring);

}

#####################
sub writeActionPlan {
#####################
    my %args = (
	textareawidth => 75,
	actionplan => 'Not entered',
	@_,
	);

    my $outstring = "<tr><td align=left><b><li>Action Plan:</b>\n";
    $outstring .= "<br><textarea name=actionplan cols=$args{textareawidth} rows=5>$args{actionplan}</textarea></td></tr>\n";
    return ($outstring);
	
}

########################
sub writeActionSummary {
########################
    my %args = (
	textareawidth => 75,
	actionsummary => '',
	@_,
	);

    my $outstring = "<tr><td align=left><b><li>Action Summary:</b>\n";
    $outstring .= "&nbsp;&nbsp;(brief description of action plan)\n";
    $outstring .= "<br><textarea name=actionsummary cols=$args{textareawidth} rows=5>$args{actionsummary}</textarea></td></tr>\n";
    return ($outstring);
}

######################
sub writeDLRecommend {
######################
    my %args = (
	textareawidth => 75,
	dlrecommend => '',
	@_,
	);

    my $outstring = "<tr><td align=left><b><li>Discipline Lead Recommendation</b>\n"; 
    $outstring .= "&nbsp;&nbsp;(Enter comments and justification for the commitment)\n";
    $outstring .= "<br><textarea name=functionalrecommend cols=$args{textareawidth} rows=5>$args{dlrecommend}</textarea></td></tr>\n";
    return ($outstring);
}

##################
sub writeComment {
##################
    my %args = (
	active => 1,
        textareawidth => 75,
	comment => '',
	@_,
	);

    my $outstring = "<tr><td align=left><b><li>Remarks:</b>\n";
    if ($args{active}) {
        $outstring .= "<br><textarea name=commenttext cols=$args{textareawidth} rows=5>$args{comment}</textarea></td></tr>\n";
    }
    else {
	$outstring .= &ReadOnly ();
        $outstring .= "<br><textarea name=commenttext cols=$args{textareawidth} rows=5 onfocus=blur()>$args{comment}</textarea></td></tr>\n";
    }
return ($outstring);
}

########################
sub writeCMgrRecommend {
########################
    my %args = (
	textareawidth => 75,
	recommend => '',
	@_,
	);

    my $outstring = "<tr><td align=left><b><li>Commitment Manager Recommendation &nbsp;&nbsp;</b>\n";
    $outstring .= "(Enter comments and justification for the commitment)<br>\n";
    $outstring .= "<textarea name=cmrecommendation cols=$args{textareawidth} rows=5>$args{recommend}</textarea></td></tr>\n";
    return ($outstring);
}

#######################
sub writeActionsTaken {
#######################
    my %args = (
        cid => 0,
	textareawidth => 75,
	@_,
	);

    my ($ataken) = $args{dbh} -> selectrow_array ("select actionstaken from $SCHEMA.commitment where commitmentid = $args{cid}");
    $ataken =~ s/\n/<BR>/g;
    my $outstring = "<tr><td align=left><b><li>Actions Taken:</b>\n";
    $outstring .= "<br><textarea name=actionstaken cols=$args{textareawidth} rows=5>$ataken</textarea></td></tr>\n";
    return ($outstring);
	
}

#######################
sub doProcessingTable {
#######################
    my %args = (
        cid => 0,
        @_,
        );
    my %chash = get_commitment_info ($args{dbh}, $args{cid});
    my $estimate = $chash{'estimate'};
    my $aplan = $chash{'actionplan'};
    my $asummary = $chash{'actionsummary'};
    my $dlrec = $chash{'functionalrecommend'};
    my $cmrec = $chash{'cmrecommendation'};
    my $reject = $chash{'rejectionrationale'};
    my $cmakerid = $chash{'approver'};
    my $status = $chash{'statusid'};
    my $ataken = $chash{'actionstaken'};

    my $outstr = "<tr><td><b><li>Processing Information:</b><br>\n";
    $outstr .= "<table width=100% border=1><tr><td>\n";
    $outstr .= "<table width=100% border=0 cellpadding=0 cellspacing=0>\n";
    if ($status > 2) {
        $outstr .= "<tr bgcolor=#ffffff valign=top><td width=38% valign=top><b>Work Estimate:</b></td>\n";
        $estimate =~ s/\n/<BR>/g;        
        $outstr .= "<td valign=top>$estimate</td></tr>\n";
        $outstr .= "<tr bgcolor=#eeeeee><td width=38% valign=top><b>Action Plan:</b></td>\n";
	$aplan =~ s/\n/<br>/g;
        $outstr .= "<td valign=top>$aplan</td></tr>\n";
        if ($status > 3) {
            $outstr .= "<tr bgcolor=#ffffff valign=top><td width=38% valign=top><b>Action Summary:</b></td>\n";
            $asummary =~ s/\n/<BR>/g;        
            $outstr .= "<td valign=top>$asummary</td></tr>\n";
            $outstr .= "<tr bgcolor=#eeeeee><td width=38% valign=top><b>Discipline Lead Recommendation:</b></td>\n";
            $dlrec =~ s/\n/<BR>/g;        
            $outstr .= "<td valign=top>$dlrec</td></tr>\n";
            $outstr .= putProducts (dbh => $args{dbh}, schema => $args{schema}, cid => $args{cid});
            if ($status > 4) {
                $outstr .= "<tr bgcolor=#eeeeee valign=top><td width=38% valign=top><b>Manager&nbspRecommendation:</b></td>\n";
                $cmrec =~ s/\n/<BR>/g;        
                $outstr .= "<td valign=top>$cmrec</td></tr>\n";
                if ($status > 5) {
                    my $cmaker = $args{dbh} -> selectrow_array ("select firstname || ' ' || lastname from $args{schema}.users where usersid = $cmakerid");
                    $outstr .= "<tr bgcolor=#ffffff valign=top><td width=38% valign=top><b>Commitment Maker:</b></td>\n";
                    $outstr .= "<td valign=top>$cmaker</td></tr>\n";
                    if ($reject) {
                        $outstr .= "<tr bgcolor=#eeeeee><td><b>Rejection Rationale:</b></td>\n";
                        $reject =~ s/\n/<br>/g;        
                        $outstr .= "<td>$reject</td></tr>\n";
                    }
                    if ($status > 8) {
                        $outstr .= putCommitted (cid => $args{cid}, dbh => $args{dbh}, schema => $args{schema});
                        if ($status > 9) {
                            $outstr .= "<tr bgcolor=#ffffff valign=top><td align=left valign=top><b>Actions Taken:</b></td>\n";
                            $ataken =~ s/\n/<br>/g;
                            $outstr .= "<td>$ataken</td></tr>\n";
                        }
                    }
                }
            }
        }
    }
    $outstr .= "</table></td></tr></table></td></tr>\n";
}

#################
sub putProducts {
#################
    my %args = (
	cid => 0,
	@_,
	);
    my $outstr = "<tr bgcolor=#ffffff valign=top><td width=38%><b>Products Affected:</b></td><td>\n";
    my $products = "select p.description from $args{schema}.product p, $args{schema}.productaffected a where p.productid = a.productid and a.commitmentid = $args{cid} order by p.description";
    my $csr = $args{dbh} -> prepare ($products);
    $csr -> execute;
    my $rows = 0;
    while (my @values = $csr -> fetchrow_array){
	$rows++;
	my ($productdesc) = @values;
	$outstr .= "<li>$productdesc<br>\n";
    }
    $csr -> finish;
    if ($rows == 0) {
	$outstr .= "None";
    }
    $outstr .= "</td></tr>\n";
    return ($outstr);
}

##################
sub putCommitted {
##################
    my %args = (
	cid => 0,
	@_,
	);
    my $outstr = "<tr valign=top bgcolor=#eeeeee><td width=38%><b>Organizations Committed To:</b></td><td>\n"; 
    my $orgs = "select o.name from $args{schema}.organization o, $args{schema}.committedorg c where c.organizationid = o.organizationid and c.commitmentid = $args{cid} order by o.name";
    my $csr = $args{dbh} -> prepare ($orgs);
    $csr -> execute;
    my $rows = 0;
    while (my @values = $csr -> fetchrow_array){
	$rows++;
	my ($orgdesc) = @values;
	$outstr .= "<li>$orgdesc<br>\n";
    }
    $csr -> finish;
    if ($rows == 0) {
	$outstr .= "None";
    }
    $outstr .= "</td></tr>\n";
    return ($outstr);
}

###################
sub writeResponse {
###################
    my %args = (
	cid => 0,
	rtype => '',
        doc => 0,
        responseid => 0,
	@_,
	);
    my $interface = ($args{doc} == 0) ? "editcommitment" : "DOECMgr_enterresponse";
    my $isfirst = ($args{rtype} eq 'Closing') ? 'F' : 'T';
my $responsepassed = ($args{responseid}) ? " and r.responseid = $args{responseid}" : "";
    my $chooseresponse = "select r.responseid, r.text, to_char(r.writtendate, 'MM/DD/YYYY'), l.letterid, l.accessionnum, to_char(l.sentdate, 'MM/DD/YYYY'), l.addressee, to_char(l.signeddate, 'MM/DD/YYYY'), l.organizationid, l.signer from $SCHEMA.response r, $SCHEMA.letter l where r.commitmentid = $args{cid} and r.isfirst = '$isfirst' and r.letterid = l.letterid $responsepassed";

    my ($rid, $rtext, $writdate, $lid, $laccnum, $lsent, $laddressee, $lsign, $lorgid, $lsignid) = $args{dbh} -> selectrow_array ($chooseresponse);

    my %letterhash = get_lookup_values($args{dbh}, 'letter', "accessionnum || ' - ' || to_char(sentdate, 'MM/DD/YYYY') || ';' || letterid", 'letterid');
    my %orghash = get_lookup_values($args{dbh}, 'organization', "name || ';' || organizationid", 'organizationid');
    my $nodevelopers = '';
    if ($CMSProductionStatus) {
	$nodevelopers = 'usersid < 1000';
    }
    my %usershash = get_lookup_values($args{dbh}, 'users', "lastname || ', ' || firstname || ';' || usersid", 'usersid', "$nodevelopers");
    my $usernamestring;
    my $key;
    my ($text, $statusid) = $args{dbh} -> selectrow_array("select text, statusid from $SCHEMA.commitment where commitmentid = $args{cid}");
    my $outstr;
    $outstr .= "<table summary=\"Response Letter Table\" width=100% cellspacing=10 border=0>\n";
    $outstr .= "<tr><td align=left><b><li>$args{rtype} Text: </b><br>\n";
    if ($args{rtype} eq 'Closing') {
        $outstr .= "(Should be the actual text dealing with the closing of this commitment from the letter indicating closure)<br>\n";
        $rtext = ($rtext) ? $rtext : "";
    }
    elsif ($args{rtype} eq 'First Response') {
        $outstr .= "(The first response is identical to the commitment text by default.  If the commitment is rejected or if the response is different from the commitment text, please enter the text from the response letter).<br>\n";
        $rtext = ($rtext) ? $rtext : $text;
    }
    $outstr .= "<textarea name=responsetext cols=75 rows=5>$rtext</textarea></td></tr>\n";
#    if ($args{rtype} eq 'Closing') {
#        $outstr .= "<tr><td align=left><b><li>$args{rtype} Document Image:</b><br>\n";
#        $outstr .= "<input type=file name=finaldocumentimage size=50 maxlength=256></td></tr>\n";
#    }
    $outstr .= "<tr><td align=left><b><li>Date Response was Written:</b> &nbsp; &nbsp;\n";
    $outstr .= build_date_selection('responsewrittendate', $interface,($writdate) ? $writdate :  'today');
    $outstr .= "<br>(Not necessarily the same as the date the response letter was written.)\n";
    $outstr .= "</td></tr>\n";
    $outstr .= "<input type=hidden name=responseid value=$rid>\n";

    $outstr .= "<tr><td align=left><b><li>$args{rtype} Letter Selection:</b> &nbsp; &nbsp;\n";
    $outstr .= "<select name=letterid onChange=\"checkletter(document.$interface.letterid)\">\n";
    $outstr .= "<option value=\'\'>Select the $args{rtype} Letter\n";
    $outstr .= "<option value=\'NEW\'>New Letter\n";
    foreach $key (sort keys %letterhash) {
        my $selected = ($lid != $letterhash{$key}) ? "" : " selected";
	my $letterdescription = $key;
	$letterdescription =~ s/;$letterhash{$key}//g;
	if (length($letterdescription) > 80) {
	    $letterdescription = substr($letterdescription, 0, 80) . '...';
	}
	$outstr .= "<option value=\"$letterhash{$key}\"$selected>$letterdescription\n";
    }
    $outstr .= "</select></td></tr>\n";
    $outstr .= "<tr><td align=left><b><li>Accession Number: &nbsp; &nbsp;</b>\n";
    $outstr .= "<input name=letteraccessionnum size=17 maxlength=17 value=\"$laccnum\">&nbsp; &nbsp;(optional)</td>\n";
    $outstr .= "<tr><td align=left><b><li>Organization Sent To: &nbsp; &nbsp;</b>\n";
    $outstr .= "<select name=letterorganizationid>\n";
    $outstr .= "<option value=\'\' selected>Select An Organization\n";
    foreach $key (sort keys %orghash) {
        my $selected = ($lorgid != $orghash{$key}) ? "" : " selected";
	my $orgdescription = $key;
	$orgdescription =~ s/;$orghash{$key}//g;
        $outstr .= "<option value=\"$orghash{$key}\"$selected>$orgdescription\n";
    }
    $outstr .= "</select>&nbsp;</td></tr>\n";
    $outstr .= "<tr><td><table width=100% align=center>\n";
    $outstr .= "<tr><td align=left><b>Addressee:</b></td>\n";
    $outstr .= "<td><input name=letteraddressee size=17 maxlength=17 value=\"$laddressee\">&nbsp;</td>\n";
    $outstr .= "<td align=left><b>Sign Date:</b></td><td>\n";
    $outstr .= build_date_selection('lettersigneddate', $interface, ($lsign) ? $lsign : 'today');
    $outstr .= "</td></tr><td align=left><b>Signer: </b></td>\n";
    $outstr .= "<td><select name=lettersigner><option value=NULL selected>Select the Signer\n";
    foreach $key (sort keys %usershash) {
        my $selected = ($lsignid != $usershash{$key}) ? "" : " selected";
	$usernamestring = $key;
	$usernamestring =~ s/;$usershash{$key}//g;
        $outstr .= "<option value=\"$usershash{$key}\"$selected>$usernamestring\n";
    }
    $outstr .= "</select></td><td align=left><b>Sent Date:</b></td><td>\n";
    $outstr .= build_date_selection('lettersentdate', $interface, ($lsent) ? $lsent : 'today');
    $outstr .= "</td></tr></table>\n";
    if ($rid){
        $outstr .= "<input type=hidden name=commitmenthasresponse value=1>\n";
    }
    else {
        $outstr .= "<input type=hidden name=commitmenthasresponse value=0>\n";
    }
    return ($outstr);
}

####################
sub doRemarksTable {
####################
    my %args = (
	cid => 0,
	iid => 0,
        aid => 0,
	@_,
	);
    my $output;
    my $id = 0; 
    my $table = "";
    my $remarks = "";
    my $entryBackground = '#ffdddd'; 
    my $entryForeground = '#000099';
    if ($args{aid} > 0) {
	$id = formatID2($args{cid}, 'CA') . "/" . substr("00$args{aid}",-3);
	$table = "action";
        $remarks = "select usersid, to_char(dateentered, 'MM/DD/YYYY HH:MI:SS AM'), text from $args{schema}.action_remarks where commitmentid = $args{cid} and actionid = $args{aid} order by dateentered desc";
    }
    elsif ($args{cid} > 0) {
	$id = formatID2($args{cid}, 'C');
	$table = "commitment";
        $remarks = "select usersid, to_char(dateentered, 'MM/DD/YYYY HH:MI:SS AM'), text from $args{schema}.commitment_remarks where commitmentid = $args{cid} order by dateentered desc";
    }
    elsif ($args{iid} > 0) {
	$id = formatID2($args{iid}, 'I');
	$table = "issue";
        $remarks = "select usersid, to_char(dateentered, 'MM/DD/YYYY HH:MI:SS AM'), text from $args{schema}.issue_remarks where issueid = $args{iid} order by dateentered desc";
    }
    my $csr = $args{dbh} -> prepare ($remarks);
    $csr -> execute;

    $ONCSHash{'table_row'} = -1;
    $ONCSHash{'table_cur_col'} = 0;
    $ONCSHash{'table_col_type'} = 'standard';

    $output .= "<tr><td><table width=650 align=center border=1 cellpadding=4 cellspacing=0>\n";
    $output .= "<tr><td bgcolor=$entryBackground colspan=3><font color=$entryForeground><b>Remarks on $table $id</b></font></td></tr>\n";

    $output .= "<tr bgcolor=#f0f0f0>\n"; #&add_header_row();
    $output .= "<td width=150><font size=-1><b>Entered By</b></font></td>";
    $output .= "<td width=170><font size=-1><b>Date/Time&nbsp;Entered</b></font></td>\n"; 
    $output .= "<td width=380><font size=-1><b>Text</b></font></td></tr>\n"; 
    my $rows =0;
    while (my @values = $csr -> fetchrow_array){
	$rows++;
	my ($user, $date, $text) = @values;
	$output .= &add_row();
	my ($username) = $args{dbh} -> selectrow_array ("select firstname || ' ' || lastname from $args{schema}.users where usersid=$user");
	$output .= &add_col() . $username;
	$output .= &add_col() . $date;
	$text = ($text && $text ne " ") ? $text : "* BLANK MESSAGE *";
	$text =~ s/\n/<BR>/g;
	$output .= &add_col() . $text;
    }
    $csr -> finish;
    $output .= &end_table();
    if ($rows > 0) {
	my $such = "$output</td></tr>\n<tr><td height=15> </td></tr>\n";
        return ($such);
    }
    else {
	my $nosuch = "<tr><td><b><li>No previous remarks for this $table</b></td></tr>\n<tr><td height=15> </td></tr>\n"; 
        return ($nosuch);
    }
}

######################
sub selectDiscipline {
######################
    my %args = (
	cid => 0,
        update => 0,
	@_,
	);
    my $outstr;
    my ($discid) = $args{dbh} -> selectrow_array ("select primarydiscipline from $args{schema}.commitment where commitmentid = $args{cid}");
    my $key;
    my %disciplinehash = get_lookup_values($args{dbh}, 'discipline', 'description', 'disciplineid', "isactive='T'");
    $outstr .= "<tr><td align=left><b><li>Discipline:&nbsp;&nbsp;</b>\n";
    $outstr .= "<select name=\"discipline\">\n";
    $outstr .= "<option value='' selected>Select a Discipline\n";
    my $selected = ($args{update} && !$discid) ? "selected" : "";
    $outstr .= "<option value=NULL $selected>Not Available\n";
    foreach $key (sort keys %disciplinehash) {
        if ($discid == $disciplinehash{$key}) {
            $outstr .= "<option value=\"$disciplinehash{$key}\" selected>$key\n";

        }
        else {
            $outstr .= "<option value=\"$disciplinehash{$key}\">$key\n";
        }
    }
    $outstr .= "</select></td></tr>\n";
    return ($outstr);
}

#################
sub selectLevel {
#################
    my %args = (
	cid => 0,
        update => 0,
	@_,
	);
    my ($level) = $args{dbh} -> selectrow_array ("select commitmentlevelid from $args{schema}.commitment where commitmentid = $args{cid}");
    my $key;
    my %commitmentlevelhash = get_lookup_values($args{dbh}, 'commitmentlevel', 'description', 'commitmentlevelid', "isactive='T'");
    my $outstr;
    $outstr .= "<tr><td align=left><b><li>Level of Commitment:&nbsp;&nbsp;</b>\n";
    $outstr .= "<select name=commitmentlevelid>\n";
    $outstr .= "<option value='' selected>Select a Level of Commitment\n";
    my $selected = ($args{update} && !$level) ? " selected" : "";
    $outstr .= "<option value=NULL$selected>Not Available\n";
    foreach $key (sort keys %commitmentlevelhash) {
        if ($level == $commitmentlevelhash{$key}) {
            $outstr .= "<option value=\"$commitmentlevelhash{$key}\" selected>$key\n";
        }
        else {
            $outstr .= "<option value=\"$commitmentlevelhash{$key}\">$key\n";
        }
    }
    $outstr .= "</select></td></tr>\n";
    return ($outstr);
}

##################
sub selectSource {
##################
    my %args = (
	@_,
	);
    my $outstr;
    my $key;
    my %orghash = get_lookup_values($args{dbh}, 'organization', "name || ';' || organizationid", 'organizationid');
    my %sourcedochash = get_lookup_values($args{dbh}, 'sourcedoc', "accessionnum || ' - ' || title || ' - ' || to_char(documentdate, 'MM/DD/YYYY') || ';' || sourcedocid", 'sourcedocid');

    $outstr .= "<tr><td align=left><b><li>Source Document: &nbsp; &nbsp;</b>\n";
    $outstr .= "<select name=sourcedocid onChange=\"checkletter(document.newcommitment.sourcedocid)\">\n";
    $outstr .= "<option value=\'\' selected>Select A Source Document\n";
    $outstr .= "<option value=NEW>New Source Document\n";
    foreach $key (sort keys %sourcedochash) {
        my $sourcedocdescription = $key;
        $sourcedocdescription =~ s/;$sourcedochash{$key}//g;
        if (length($sourcedocdescription) > 60) {
            $sourcedocdescription = substr($sourcedocdescription, 0, 60) . '...';
        }
        $outstr .= "<option value=\"$sourcedochash{$key}\">$sourcedocdescription\n";
     }
     $outstr .= "</select>\n";
     $outstr .= "<input name=issuehassourcedoc type=hidden value=0>\n";
     $outstr .= "</td></tr>\n";
     $outstr .= "<tr><td align=left><b><li>Accession Number:</b>&nbsp;&nbsp;\n";
     $outstr .= "<input type=text name=accessionnum size=17 maxlength=17> &nbsp; &nbsp; (optional)</td></tr>\n";
     $outstr .= "<tr><td align=left><b><li>Document&nbsp;Title:&nbsp;&nbsp;</b>\n";
     $outstr .= "<input type=text name=title size=60 max=1000 onblur=\"if(document.newcommitment.title.value.length > 1000){alert(\'Only 1000 characters allowed in a title\');document.newcommitment.title.focus();}\"></td></tr>\n";
     $outstr .= "<tr><td align=left><b><li>Signer:&nbsp;&nbsp;</b>\n";
     $outstr .= "<input type=text name=signer size=30 maxlength=30></td></tr>\n";
     $outstr .= "<tr><td align=left><b><li>Signer's Email Address:&nbsp;&nbsp;</b>\n";
     $outstr .= "<input type=text name=emailaddress size=50 maxlength=50>\n";
     $outstr .= "<br> (Leave blank if not available)</td></tr>\n";
     $outstr .= "<tr><td align=left><b><li>Area Code:</b>&nbsp;&nbsp;\n";
     $outstr .= "(<input type=text name=areacode size=3 maxlength=3>)\n";
     $outstr .= "&nbsp;&nbsp;&nbsp;<b>Phone Number:&nbsp;&nbsp;</b>\n";
     $outstr .= "<input type=text name=phonenumber size=7 maxlength=7>  (no hyphens)\n";
     $outstr .= "&nbsp; &nbsp; (Leave blank if not available)</td></tr>\n";
     $outstr .= "<tr><td align=left><b><li>Document Date:&nbsp;&nbsp;</b>\n";
     $outstr .= build_date_selection('documentdate', 'newcommitment');
     $outstr .= "&nbsp; &nbsp; (Enter 1st if not available)</td></tr>\n";
     $outstr .= "<tr><td align=left><b><li>Originator Organization:&nbsp;&nbsp;</b>\n";
     $outstr .= "<select name=organizationid>\n";
     $outstr .= "<option value=\'\' selected>Select An Organization\n";
     foreach $key (sort keys %orghash) {
         my $orgdescription = $key;
         $orgdescription =~ s/;$orghash{$key}//g;
         $outstr .= "<option value=\"$orghash{$key}\">$orgdescription\n";
     }
     $outstr .= "</select></td></tr>\n";
     return ($outstr);
}

###############
sub selectWBS {
###############
    my %args = (
	cid => 0,
        update => 0,
	@_,
	);
    my $outstr;
    my ($wbs) = $args{dbh} -> selectrow_array ("select controlaccountid from $args{schema}.commitment where commitmentid = $args{cid}");
    my $key;
    my %wbshash = get_lookup_values($args{dbh}, 'workbreakdownstructure', "controlaccountid", "controlaccountid || ' - ' || description");
    $outstr .= "<tr><td align=left><b><li>WBS: &nbsp;&nbsp;</b>\n";
    $outstr .= "<select name=workbreakdownstructure>\n";
    $outstr .= "<option value=''>Select a Work Breakdown Structure\n";
    my $selected = ($args{update} && !$wbs) ? " selected" : "";
    $outstr .= "<option value=NULL$selected>Not Available\n";
    foreach $key (sort keys %wbshash) {
	my $optiondisplay = getDisplayString($wbshash{$key}, 80);
	if ($wbs eq $key){
	    $outstr .= "<option value=\"$key\" selected>$optiondisplay\n";
	}
	else {
	    $outstr .= "<option value=\"$key\">$optiondisplay\n";
	}
    }
    $outstr .= "</select></td></tr>\n";
    return ($outstr);
}

####################
sub selectKeywords {
####################
    my %args = (
	cid => 0,
        update => 0,
	@_,
	);
    my $document;
    if ($args{update}) {
        $document = "commitmentupdate";
    }
    else {
        $document = "editcommitment";
    }
    my $outstr;
    my $key;
    my %keywordhash = get_lookup_values($args{dbh}, 'keyword', 'description', 'keywordid', "isactive='T'");
my %commitmentkeyword = get_lookup_values($args{dbh}, "commitmentkeyword", "keywordid", "'True'", "commitmentid=$args{cid}");
    $outstr .= "<tr><td align=left><b><li>Keywords:&nbsp;&nbsp;</b>\n";
    $outstr .= "(optional, do not select any if not available)<br>\n";
    $outstr .= "<table border=0 summary=\"Keyword Selection\" align=center>\n";
    $outstr .= "<tr align=Center><td><b>Keyword List</b></td>\n";
    $outstr .= "<td>&nbsp;</td>\n";
    $outstr .= "<td><b>Keywords Selected</b></td></tr><tr><td>\n";
    $outstr .= "<select name=allkeywordlist size=5 multiple ondblclick=\"process_multiple_dual_select_option(document.$document.allkeywordlist, document.$document.keywords, 'move')\">\n";
    my $word;
    my $value='';
    foreach $key (sort keys %keywordhash) {
	if ($commitmentkeyword{$keywordhash{$key}} ne 'True') {
	    $word=$key;
	    $word =~ s/;$keywordhash{$key}//g;
	    $outstr .= "<option value=\"$keywordhash{$key}\">$word\n";
	}
    }
    $outstr .= "<option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp</select></td><td>\n";
    $outstr .= "<input name=keywordrightarrow title=\"Click to select the keyword(s)\" value=\"-->\" type=button onclick=\"process_multiple_dual_select_option(document.$document.allkeywordlist, document.$document.keywords, 'move')\"><br>\n";
    $outstr .= "<input name=keywordleftarrow title=\"Click to remove the selected keyword(s)\" value=\"<--\" type=button onclick=\"process_multiple_dual_select_option(document.$document.keywords, document.$document.allkeywordlist, 'move')\"></td><td>\n";
    $outstr .= "<select name=keywords size=5 multiple ondblclick=\"process_multiple_dual_select_option(document.$document.keywords, document.$document.allkeywordlist, 'move')\">\n";
    foreach $key (sort keys %keywordhash) {
	if ($commitmentkeyword{$keywordhash{$key}} eq 'True') {
	    my $word=$key;
	    $word =~ s/;$keywordhash{$key}//g;
	    $outstr .= "<option value=\"$keywordhash{$key}\">$word\n";
	}
    }
    $outstr .= "<option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp</select></td></tr></table></td></tr>\n";

    return ($outstr);
}

####################
sub selectProducts {
####################
    my %args = (
	cid => 0,
        update => 0,
	@_,
	);
    my $document = ($args{update}) ? "commitmentupdate" : "editcommitment";
    my $outstr;
    my %productshash = get_lookup_values($args{dbh}, 'product', 'description', 'productid', "isactive='T'");
    my %productsaffectedhash = get_lookup_values($args{dbh}, "productaffected", "productid", "'True'", "commitmentid = $args{cid}");
    my $key;

    $outstr .= "<tr><td align=left><b><li>Products Affected:&nbsp;&nbsp;</b>\n";
    $outstr .= "(Optional, if no products are affected, leave blank.)<br>\n";
    $outstr .= "<table border=0 align=center summary=\"Product Data\">\n";
    $outstr .= "<tr align=center><td><b>Product List</b></td><td>&nbsp;</td>\n";
    $outstr .= "<td><b>Products Affected</b></td></tr><tr><td>\n";
    $outstr .= "<select name=allproductslist size=5 multiple ondblclick=\"process_multiple_dual_select_option(document.$document.allproductslist, document.$document.productsaffected, 'movehist', document.$document.prodhist)\">\n";
    foreach $key (sort keys %productshash) {
        if ($productsaffectedhash{$productshash{$key}} ne 'True') {
            $outstr .= "<option value=\"$productshash{$key}\">$key\n";
        }
    }
    $outstr .= "<option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp</select></td><td>\n";
    $outstr .= "<input name=prodrightarrow title=\"click to commit to the selected product(s)\" value=\"-->\" type=button onclick=\"process_multiple_dual_select_option(document.$document.allproductslist, document.$document.productsaffected, 'movehist', document.$document.prodhist)\">\n";
    $outstr .= "<br>\n";
    $outstr .= "<input name=prodleftarrow title=\"click to remove the selected product(s)\" value=\"<--\" type=button onclick=\"process_multiple_dual_select_option(document.$document.productsaffected, document.$document.allproductslist, 'movehist', document.$document.prodhist)\">\n";
    $outstr .= "<input name=prodhist type=hidden></td><td>\n";
    $outstr .= "<select name=productsaffected size=5 multiple ondblclick=\"process_multiple_dual_select_option(document.$document.productsaffected, document.$document.allproductslist, 'movehist', document.document.prodhist)\">\n";
    foreach $key (sort keys %productshash) {
        if ($productsaffectedhash{$productshash{$key}} eq 'True') {
            $outstr .= "<option value=\"$productshash{$key}\">$key\n";
        }
    }
    $outstr .= "<option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp\n";
    $outstr .= "</select></td></tr>\n";
    $outstr .= "</table>\n";
    $outstr .= "<center>Hold the Control key while clicking to select more than one.</center>\n";
    $outstr .= "</td></tr>\n";

    return ($outstr);
}

##################
sub selectCMaker {
##################
    my %args = (
	cid => 0,
	@_,
	);
    my $outstr;
    my ($approvedby, $site) = $args{dbh} -> selectrow_array ("select approver, siteid from $args{schema}.commitment where commitmentid = $args{cid}");
    my %approvedbyhash;
    my $nodevelopers = '';
    if ($CMSProductionStatus) {
        $nodevelopers = ' and srole.usersid < 1000';
    }
    %approvedbyhash = get_lookup_values ($args{dbh}, "users, $args{schema}.defaultsiterole srole", "users.lastname || ', ' || users.firstname || ';' || users.usersid", 'users.usersid', "srole.usersid=users.usersid and srole.roleid=5 and users.isactive='T' and srole.siteid=$site $nodevelopers");
    my $key;
    $outstr .= "<tr><td align=left><b><li>Commitment Maker:</b> &nbsp; &nbsp;\n";
    $outstr .= "<select name=approvedby>\n";
    $outstr .= "<option value=NULL selected>Select A Commitment Maker\n";

    foreach $key (sort keys %approvedbyhash) {
	my $usernamestring = $key;
	my $selectedstring = ($approvedbyhash{$key} == $approvedby) ? " selected" : "";
	$usernamestring =~ s/;$approvedbyhash{$key}//g;
	$outstr .= "<option value=\"$approvedbyhash{$key}\"$selectedstring>$usernamestring\n";
    }

    $outstr .= "</select></td></tr>\n";
    return ($outstr);
}

#########################
sub selectOrganizations {
#########################
    my %args = (
	cid => 0,
        update => 0,
	@_,
	);
    my $document = ($args{update}) ? "commitmentupdate" : "editcommitment";
    my $outstr;
    my $key;
    my %organizationhash = get_lookup_values($args{dbh}, 'organization', 'organizationid', 'name');
    my %orghash = get_lookup_values($args{dbh}, 'organization', "name || ';' || organizationid", 'organizationid');
    my %committedtohash = get_lookup_values($args{dbh}, "committedorg", "organizationid", "'True'", "commitmentid = $args{cid}");
    $outstr .= "<tr><td align=left><b><li>Organizations Commitment Made To:</b><br>\n";
    $outstr .= "<table border=0 align=center summary=\"Organizations Commitment Made To\">\n";
    $outstr .= "<tr align=Center><td><b>Organization List</b></td>\n";
    $outstr .= "<td>&nbsp;</td>\n";
    $outstr .= "<td><b>Committed To</b></td></tr>\n";
    $outstr .= "<tr><td>\n";
    $outstr .= "<select name=allorganizationlist size=5 multiple ondblclick=\"process_multiple_dual_select_option(document.$document.allorganizationlist, document.$document.committedto, 'movehist', document.$document.orghist)\">\n";
    foreach $key (sort keys %orghash) {
        if ($committedtohash{$orghash{$key}} ne 'True') {
	    my $orgdescription = $key;
	    $orgdescription =~ s/;$orghash{$key}//g;
	    $outstr .= "<option value=\"$orghash{$key}\">$orgdescription\n";
	}
    }
    $outstr .= "<option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp</select></td>\n";
    $outstr .= "<td><input name=rightarrow title=\"click to commit to the selected organization(s)\" value=\"-->\" type=button onclick=\"process_multiple_dual_select_option(document.$document.allorganizationlist, document.$document.committedto, 'movehist', document.$document.orghist)\"><br>\n";
    $outstr .= "<input name=leftarrow title=\"click to remove the selected organization(s)\" value=\"<--\" type=button onclick=\"process_multiple_dual_select_option(document.$document.committedto, document.$document.allorganizationlist, 'movehist', document.$document.orghist)\">\n";
    $outstr .= "<input name=orghist type=hidden></td>\n";
    $outstr .= "<td><select name=committedto size=5 multiple ondblclick=\"process_multiple_dual_select_option(document.$document.committedto, document.$document.allorganizationlist, 'movehist', document.$document.orghist)\">\n";
    foreach $key (sort keys %orghash) {
        if ($committedtohash{$orghash{$key}} eq 'True') {
	    my $orgdescription = $key;
	    $orgdescription =~ s/;$orghash{$key}//g;
	    $outstr .= "<option value=\"$orghash{$key}\">$orgdescription\n";
	}
    }
    $outstr .= "<option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp</select></td></tr>\n";
    $outstr .= "</table></td></tr>\n";
    return ($outstr);
}

################
sub fillLetter {
################
    my %args = (
        letterid => 0,
        doc => 0,
	@_,
	);

    my $interface;
    if ($args{doc} == 2) {
        $interface = "parent.workspace.DOECMgr_enterresponse";
    }
    if ($args{doc} == 1) {
        $interface = "parent.workspace.responseupdate";
    }
    if ($args{doc} == 0) {
        $interface = "parent.workspace.editcommitment";
    }

    my %letterinfo;
    my $accessionnum = "";
    my $sentdate = "";
    my $addressee = "";
    my $signeddate = "";
    my $organizationid = 0;
    my $signer = 0;
    my $sentmonth = "";
    my $sentday = 0;
    my $sentyear = 0;
    my $signedmonth = "";
    my $signedday = 0;
    my $signedyear = 0;
    if ($args{letterid}) {
        %letterinfo = lookup_letter_information ($args{dbh}, $args{letterid});
        $accessionnum = $letterinfo{'accessionnum'};
        $sentdate = $letterinfo{'sentdate'};
        $addressee = $letterinfo{'addressee'};
        $signeddate = $letterinfo{'signeddate'};
        $organizationid = $letterinfo{'organizationid'};
        $signer = $letterinfo{'signer'};
        ($sentmonth, $sentday, $sentyear) = split /\//, $sentdate;
        ($signedmonth, $signedday, $signedyear) = split /\//, $signeddate;
    }
    my $outstr = "";
    $outstr .= "<script language=\"JavaScript\" type=\"text/javascript\"><!--\n";
    $outstr .= "$interface.letteraccessionnum.value=\'$accessionnum\';\n";
    $outstr .= "$interface.lettersentdate.value='$sentdate';\n";
    $outstr .= "$interface.lettersentdate_month.value=$sentmonth;\n";
    $outstr .= "$interface.lettersentdate_day.value=$sentday;\n";
    $outstr .= "$interface.lettersentdate_year.value=$sentyear;\n";
    $outstr .= "$interface.letteraddressee.value=\'$addressee\';\n";
    $outstr .= "$interface.lettersigneddate.value='$signeddate';\n";
    $outstr .= "$interface.lettersigneddate_month.value=$signedmonth;\n";
    $outstr .= "$interface.lettersigneddate_day.value=$signedday;\n";
    $outstr .= "$interface.lettersigneddate_year.value=$signedyear;\n";
    $outstr .= "$interface.letterorganizationid.value=$organizationid;\n";
    $outstr .= "$interface.lettersigner.value=$signer;\n";
    $outstr .= "//-->\n";
    $outstr .= "</script>\n";
    $outstr .= "</head>\n<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n</body>\n</html>\n";

    return ($outstr);
}

##############
sub ReadOnly {
##############
    return (print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp <b>(<font size=-1><i> READ ONLY </i></font>)</b>\n");
}


###############
sub selectRSS {
###############
    my %args = (
	cid => 0,
        update => 0,
	@_,
	);
    my ($rss) = $args{dbh} -> selectrow_array ("select rssfactorid from $args{schema}.commitment where commitmentid = $args{cid}");
    my $key;
    my %rsshash = get_lookup_values($args{dbh}, 'rssfactor', 'description', 'rssfactorid', "isactive='T'");
    my $outstr;
    $outstr .= "<tr><td align=left><b><li>RSS Factor:&nbsp;&nbsp;</b>\n";
    $outstr .= "<select name=rssfactor>\n";
    $outstr .= "<option value='' selected>Select an RSS Factor\n";
    my $selected = ($args{update} && !$rss) ? " selected" : "";
    $outstr .= "<option value=NULL$selected>Not Available\n";
    foreach $key (sort keys %rsshash) {
        if ($rss == $rsshash{$key}) {
            $outstr .= "<option value=\"$rsshash{$key}\" selected>$key\n";
        }
        else {
            $outstr .= "<option value=\"$rsshash{$key}\">$key\n";
        }
    }
    $outstr .= "</select></td></tr>\n";
    return ($outstr);
}

##############
sub selectLL {
##############
    my %args = (
        cid => 0,
        update => 0,
	@_,
	);
    my ($ll) = $args{dbh} -> selectrow_array ("select lleadid from $args{schema}.commitment where commitmentid = $args{cid}");
    my $key;
    my $lleads = "select u.usersid, u.firstname || ' ' || u.lastname, u.lastname from $args{schema}.users u, $args{schema}.defaultsiterole d where d.roleid=7 and u.usersid=d.usersid order by u.lastname";
    my $csr = $args{dbh} -> prepare ($lleads);
    $csr -> execute;
    my $outstr;
    my $selected = ($args{update} && !$ll) ? " selected" : "";
    $outstr .= "<tr><td align=left><b><li>BSC Licensing Lead:&nbsp;&nbsp;</b>\n";
    $outstr .= "<select name=licensinglead>\n";
    $outstr .= "<option value='' selected>Select a Licensing Lead\n";
    $outstr .= "<option value=NULL$selected>Not Available\n";
    while (my ($lid, $lname) = $csr -> fetchrow_array) {
        if ($ll == $lid) {
            $outstr .= "<option value=$lid selected>$lname\n";
        }
        else {
            $outstr .= "<option value=$lid>$lname\n";
        }
    }
    $outstr .= "</select></td></tr>\n";
    return ($outstr);
}

##############
sub selectRM {
##############
    my %args = (
        cid => 0,
	mgrtype => 0,
        update => 0,
	@_,
	);
    my $header = ($args{mgrtype} == 1) ? "BSC" : "DOE";
    my ($rm, $doerm) = $args{dbh} -> selectrow_array ("select managerid, doemanagerid from $args{schema}.commitment where commitmentid = $args{cid}");
    my $key;
    my %rmhash = get_lookup_values($args{dbh}, 'responsiblemanager', "lastname || ', ' || firstname", 'responsiblemanagerid', "managertypeid = $args{mgrtype}");
    my $outstr;
    $outstr .= "<tr><td align=left><b><li>$header Responsible Manager:&nbsp;&nbsp;</b>\n";
    my $selectname = "$header" . "responsiblemanager";
    $outstr .= "<select name=$selectname>\n";
    $outstr .= "<option value='' selected>Select $header Responsible Manager\n";
    my $selected = ($args{update} && !$rm) ? " selected" : "";
    $outstr .= "<option value=NULL$selected>Not Available\n";
    foreach $key (sort keys %rmhash) {
        if ($rm == $rmhash{$key} || $doerm == $rmhash{$key}) {
            $outstr .= "<option value=\"$rmhash{$key}\" selected>$key\n";
        }
        else {
            $outstr .= "<option value=\"$rmhash{$key}\">$key\n";
        }
    }
    $outstr .= "</select></td></tr>\n";
    return ($outstr);
}

#################
sub selectBSCDL {
#################
    my %args = (
        cid => 0,
        update => 0,
	@_,
	);
    my ($dl) = $args{dbh} -> selectrow_array ("select lleadid from $args{schema}.commitment where commitmentid = $args{cid}");
    my $key;
    my $dleads = "select u.usersid, u.firstname || ' ' || u.lastname, u.lastname from $args{schema}.users u, $args{schema}.defaultsiterole d where d.roleid=2 and u.usersid=d.usersid order by u.lastname";
    my $csr = $args{dbh} -> prepare ($dleads);
    $csr -> execute;
    my $outstr;
    my $selected = ($args{update} && !$dl) ? " selected" : "";
    $outstr .= "<tr><td align=left><b><li>BSC Discipline Lead:&nbsp;&nbsp;</b>\n";
    $outstr .= "<select name=disciplinelead>\n";
    $outstr .= "<option value='' selected>Select a Discipline Lead\n";
    $outstr .= "<option value=NULL$selected>Not Available\n";
    while (my ($did, $lname) = $csr -> fetchrow_array) {
        if ($dl == $did) {
            $outstr .= "<option value=$did selected>$lname\n";
        }
        else {
            $outstr .= "<option value=$did>$lname\n";
        }
    }
    $outstr .= "</select></td></tr>\n";
    return ($outstr);
}

####################
sub doActionsTable {
####################
    my %args = (
        cid => 0,
        aid => 0,
        header => 0,
        view => 0,
        @_,
        );

    my ($text, $date, $dl, $ll, $rm, $stat, $actionstaken) = 
        $args{dbh} -> selectrow_array (
        "select a.text, to_char(a.duedate, 'MM/DD/YYYY'), 
                u.firstname || ' ' || u.lastname, 
                u2.firstname || ' ' || u2.lastname, 
                r.firstname || ' ' || r.lastname, 
                a.status, a.actionstaken 
         from $args{schema}.action a, $args{schema}.users u, 
              $args{schema}.users u2, $args{schema}.responsiblemanager r 
         where a.commitmentid=$args{cid} and a.actionid=$args{aid} and 
               a.dleadid=u.usersid and a.lleadid=u2.usersid and 
               a.managerid=r.responsiblemanagerid");
    my $outstr;
    my $header = ($args{header}) ? "<li><b>Action Information</b><br>" : "";
    $outstr .= "<tr><td>$header<table width=100% border=1><tr><td>\n"; 
    $outstr .= "<table width=100% cellspacing=0 cellpadding=0>\n"; 
    $outstr .= "<tr bgcolor=#ffffff><td width=38%><b>Action ID:</b></td><td><b>" . formatID2($args{cid}, 'CA') . "/" . substr("00$args{aid}",-3) . "</b></td></tr>\n"; 
    $outstr .= "<tr bgcolor=#eeeeee><td valign=top><b>Action Text:</b></td><td>$text</td></tr>\n"; 
    $outstr .= "<tr bgcolor=#ffffff><td><b>Due Date:</b></td><td>$date</td></tr>\n"; 
    $outstr .= "<tr bgcolor=#eeeeee><td><b>BSC Discipline Lead:</b></td><td>$dl</td></tr>\n"; 
    $outstr .= "<tr bgcolor=#ffffff><td><b>BSC Licensing Lead:</b></td><td>$ll</td></tr>\n"; 
    $outstr .= "<tr bgcolor=#eeeeee><td><b>BSC Responsible Manager:</b></td><td>$rm</td></tr>\n"; 
    if ($stat eq "CO" || $stat eq "FO") {
        $outstr .= "<tr bgcolor=#ffffff><td valign=top><b>Fulfillment Information:</b></td><td>$actionstaken</td></tr>\n"; 
    }
    if ($args{view}) {
        my $bgcol = ($stat eq "CO" || $stat eq "FO") ? "#eeeeee" : "#ffffff";
        $outstr .= "<tr bgcolor=$bgcol><td><b>Status:</b></td><td>$stat</td></tr>\n";
    }
    $outstr .= "</table>\n"; 
    $outstr .= "</td></tr></table></td></tr>\n"; 

    return ($outstr);
}

################
sub getHeading {
################
    my %args = (
        lookup => "",
        @_,
    );
    my $heading = $args{dbh} -> selectrow_array ("select text from $args{schema}.heading where lookup = '$args{lookup}'");
    return ($heading);
}


############################
1;

