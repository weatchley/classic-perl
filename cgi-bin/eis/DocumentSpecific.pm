#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/crd/perl/RCS/DocumentSpecific.pm,v $
#
# $Revision: 1.23 $
#
# $Date: 2009/03/12 22:46:15 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DocumentSpecific.pm,v $
# Revision 1.23  2009/03/12 22:46:15  atchleyb
# ACR0903_001 - Add new CRD SSS
#
# Revision 1.22  2008/04/01 16:50:28  atchleyb
# CR0053, updates for new workflow to allow the skipping of the proofread step for SCR's
#
# Revision 1.21  2004/05/18 15:36:55  atchleyb
# changed name of mpcrd
#
# Revision 1.20  2003/03/14 19:06:50  atchleyb
# added MPCRD
#
# Revision 1.19  2002/02/05 00:20:41  atchleyb
# updated document mapping for SR
#
# Revision 1.18  2002/01/11 22:20:04  atchleyb
# updated to handle second SR comment period
#
# Revision 1.17  2001/12/12 18:02:42  atchleyb
# updated document to section mapping
#
# Revision 1.16  2001/12/07 00:13:12  atchleyb
# updated document mapping and added configuration to FinalCRDSectionSource
#
# Revision 1.15  2001/12/04 20:24:02  atchleyb
# added function showFinalCRDIndex4 so that index report would only show up in EIS
#
# Revision 1.14  2001/11/29 02:25:48  mccartym
# turn off tech edit for SR
#
# Revision 1.13  2001/11/28 21:04:45  atchleyb
# added function FinalCRDSectionSource to handle document id source as well as bin source
# added option to sort by commentor
#
# Revision 1.12  2001/10/23 00:00:42  atchleyb
# updated the report notes for SR/evaluation factor report
#
# Revision 1.11  2001/10/09 20:13:55  atchleyb
# updated evaluationFactorReportSubText to use a smaller font size and to gid rid of text for EIS
#
# Revision 1.10  2001/10/05 21:47:22  atchleyb
# This adds the function EvaluationFactorReportSubText as required for the new evaluation factors report
# This is part of the fullfillment of SCR31
#
# Revision 1.9  2001/09/18 22:31:59  atchleyb
# added functions to support the new weekly status report
#
# Revision 1.8  2001/08/01 22:12:37  mccartym
# add requireResponseSource function
#
# Revision 1.7  2001/07/03 23:13:15  mccartym
# turn on tech edit step for SR
#
# Revision 1.6  2001/06/22 18:33:15  atchleyb
# merged the ESI and SR versions into one module.
#
# Revision 1.5  2001/06/21 20:33:49  atchleyb
# removed doFinalCRD
#
# Revision 1.4  2001/05/18 00:18:25  mccartym
# turn off tesh edit step for EIS
#
# Revision 1.3  2001/05/17 15:56:19  atchleyb
# Added RelatedCRDText function
# added other functions to export tags
#
# Revision 1.2  2001/05/17 15:21:07  mccartym
# add functions for review names
#
# Revision 1.1  2001/04/14 05:11:23  mccartym
# Initial revision
#
#
package DocumentSpecific;
use strict;
use integer;
use CRD_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use CGI qw(param);
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $AUTOLOAD);
use Exporter;
@ISA = qw(Exporter);

@EXPORT = qw(&doTechEdit &doFinalCRD &FirstReviewName &SecondReviewName &RelatedCRDText &requireResponseSource
    &doWeeklyStatus &HighProfileIDs &OtherIDs &EvaluationFactorReportSubText &FinalCRDSectionSource &showFinalCRDIndex4 &doSCRProofRead);
@EXPORT_OK = qw(&doTechEdit &doFinalCRD &FirstReviewName &SecondReviewName &RelatedCRDText &requireResponseSource
    &doWeeklyStatus &HighProfileIDs &OtherIDs &EvaluationFactorReportSubText &FinalCRDSectionSource &showFinalCRDIndex4 &doSCRProofRead);
%EXPORT_TAGS = (Functions => [qw(&doTechEdit &doFinalCRD &FirstReviewName &SecondReviewName &RelatedCRDText &requireResponseSource
    &doWeeklyStatus &HighProfileIDs &OtherIDs &EvaluationFactorReportSubText &FinalCRDSectionSource &showFinalCRDIndex4 &doSCRProofRead)]);

my ($crdcgi, $path, $form, $instructionsColor);
BEGIN {
   $crdcgi = new CGI;
   $ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
   $path = $1;
   $form = $2;
   $instructionsColor = $CRDFontColor;
}

###################################################################################################################################
sub requireResponseSource {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $requireResponseSource;
   if ($CRDType eq 'EIS') {
       $requireResponseSource = 0;
   } elsif ($CRDType eq 'SR') {
       $requireResponseSource = 1;
   } elsif ($CRDType eq 'MPCRD') {
       $requireResponseSource = 0;
   } elsif ($CRDType eq 'SEIS') {
       $requireResponseSource = 0;
   } elsif ($CRDType eq 'RRR') {
       $requireResponseSource = 0;
   } elsif ($CRDType eq 'SSS') {
       $requireResponseSource = 0;
   }
   return ($requireResponseSource);
}

###################################################################################################################################
sub doTechEdit {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $doTechEdit = 0;
   if ($CRDType eq 'EIS') {
       $doTechEdit = 0;
   } elsif ($CRDType eq 'SR') {
       $doTechEdit = 0;
   } elsif ($CRDType eq 'MPCRD') {
       $doTechEdit = 0;
   } elsif ($CRDType eq 'SEIS') {
       $doTechEdit = 0;
   } elsif ($CRDType eq 'RRR') {
       $doTechEdit = 1;
   } elsif ($CRDType eq 'SSS') {
       $doTechEdit = 1;
   }
   return ($doTechEdit);
}

###################################################################################################################################
sub doSCRProofRead {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $doSCRProofRead = 1;
   if ($CRDType eq 'EIS') {
       $doSCRProofRead = 1;
   } elsif ($CRDType eq 'SR') {
       $doSCRProofRead = 1;
   } elsif ($CRDType eq 'MPCRD') {
       $doSCRProofRead = 1;
   } elsif ($CRDType eq 'SEIS') {
       $doSCRProofRead = 1;
   } elsif ($CRDType eq 'RRR') {
       $doSCRProofRead = 0;
   } elsif ($CRDType eq 'SSS') {
       $doSCRProofRead = 0;
   }
   return ($doSCRProofRead);
}

###################################################################################################################################
sub FirstReviewName {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $name = "";
   if ($CRDType eq 'EIS') {
       $name = "NEPA";
   } elsif ($CRDType eq 'SR') {
       $name = "MRT";
   } elsif ($CRDType eq 'MPCRD') {
       $name = "NEPA";
   } elsif ($CRDType eq 'SEIS') {
       $name = "NEPA";
   } elsif ($CRDType eq 'RRR') {
       $name = "NEPA";
   } elsif ($CRDType eq 'SSS') {
       $name = "NEPA";
   }
   return ($name);
}

###################################################################################################################################
sub SecondReviewName {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $name = "DOE";
   if ($CRDType eq 'EIS') {
       $name = "DOE";
   } elsif ($CRDType eq 'SR') {
       $name = "Final";
   } elsif ($CRDType eq 'MPCRD') {
       $name = "DOE";
   } elsif ($CRDType eq 'SEIS') {
       $name = "DOE";
   } elsif ($CRDType eq 'RRR') {
       $name = "DOE";
   } elsif ($CRDType eq 'SSS') {
       $name = "DOE";
   }
   return ($name);
}

###################################################################################################################################
sub RelatedCRDText {
###################################################################################################################################
   my %args = (
      short => 'F',
      @_,
   );
   my $text;
   if ($CRDType eq 'EIS') {
       $text = (($args{short} eq 'T') ? 'SR' : 'Site Recommendation');
   } elsif ($CRDType eq 'SR') {
       $text = (($args{short} eq 'T') ? 'EIS' : 'Environmental Impact Statement');
   } elsif ($CRDType eq 'MPCRD') {
       $text = (($args{short} eq 'T') ? 'RA' : 'Rail Alignment EIS');
   } elsif ($CRDType eq 'SEIS') {
       $text = (($args{short} eq 'T') ? 'SEIS' : 'Supplement to the FEIS');
   } elsif ($CRDType eq 'RRR') {
       $text = (($args{short} eq 'T') ? 'RRR' : 'Repository SEIS & Rail Corridor/Alignment EIS');
   } elsif ($CRDType eq 'SSS') {
       $text = (($args{short} eq 'T') ? 'SSS' : 'Supplemental EIS III');
   }
   return ($text);
}


###################################################################################################################################
sub doWeeklyStatus {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $doWeeklyStatus = 0;
   if ($CRDType eq 'EIS') {
       if ($CRDProductionStatus == 1) {
           $doWeeklyStatus = 0;
       } else {
           $doWeeklyStatus = 1;
       }
   } elsif ($CRDType eq 'SR') {
       $doWeeklyStatus = 1;
   } elsif ($CRDType eq 'MPCRD') {
       if ($CRDProductionStatus == 1) {
           $doWeeklyStatus = 0;
       } else {
           $doWeeklyStatus = 1;
       }
   } elsif ($CRDType eq 'SEIS') {
       if ($CRDProductionStatus == 1) {
           $doWeeklyStatus = 0;
       } else {
           $doWeeklyStatus = 1;
       }
   } elsif ($CRDType eq 'RRR') {
       if ($CRDProductionStatus == 1) {
           $doWeeklyStatus = 0;
       } else {
           $doWeeklyStatus = 1;
       }
   } elsif ($CRDType eq 'SSS') {
       if ($CRDProductionStatus == 1) {
           $doWeeklyStatus = 0;
       } else {
           $doWeeklyStatus = 1;
       }
   }
   return ($doWeeklyStatus);
}


###################################################################################################################################
sub showFinalCRDIndex4 {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $showFinalCRDIndex4 = 0;
   if ($CRDType eq 'EIS') {
       $showFinalCRDIndex4 = 1;
   } elsif ($CRDType eq 'SR') {
       $showFinalCRDIndex4 = 0;
   } elsif ($CRDType eq 'MPCRD') {
       $showFinalCRDIndex4 = 1;
   } elsif ($CRDType eq 'SEIS') {
       $showFinalCRDIndex4 = 1;
   } elsif ($CRDType eq 'RRR') {
       $showFinalCRDIndex4 = 1;
   } elsif ($CRDType eq 'SSS') {
       $showFinalCRDIndex4 = 1;
   }
   return ($showFinalCRDIndex4);
}


###################################################################################################################################
sub HighProfileIDs {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $IDStart;
   my $IDEnd;
   if ($CRDType eq 'EIS') {
       $IDStart = '000000';
       $IDEnd = '000999';
   } elsif ($CRDType eq 'SR') {
       $IDStart = '220000';
       $IDEnd = '229999';
   } elsif ($CRDType eq 'MPCRD') {
       $IDStart = '000000';
       $IDEnd = '000999';
   } elsif ($CRDType eq 'SEIS') {
       $IDStart = '000000';
       $IDEnd = '000999';
   } elsif ($CRDType eq 'RRR') {
       $IDStart = '000000';
       $IDEnd = '000999';
   } elsif ($CRDType eq 'SSS') {
       $IDStart = '000000';
       $IDEnd = '000999';
   }
   return ($IDStart,$IDEnd);
}


###################################################################################################################################
sub EvaluationFactorReportSubText {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $outputstring = '';
   my @todayTime = localtime(time);
   my $today = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")[$todayTime[4]] . " " . $todayTime[3] . ", " . ($todayTime[5] + 1900);
   if ($CRDType eq 'EIS') {
   } elsif ($CRDType eq 'SR') {
        $outputstring .= "<tr><td><font size=-2><br><ul>\n";
        $outputstring .= "<li>This tabulation reflects all comment documents received since the inception of the Site Recommendation Comment Period, May 4, 2001, through September 27, 2001 from all available public sources as provided in the Federal Register Notices (i.e. - U.S. mail, e-mail, hearing transcripts, FAX, personal appearances, etc) that have been marked with a qualitative ranking in the system.";
        $outputstring .= "<li>Multiple Comment Documents received from the same individual/organization are included in the above data.";
        $outputstring .= "<li>Qualitative ratings of the commenter's postion on the YMP SR were performed by project personnel.";
        $outputstring .= "<li>No attempt was made to clarify commenter's stated position on the YMP, the authenticity of letterheads or commenter's stated title and/or credentials.";
        $outputstring .= "</ul></font></td></tr>\n";
   } elsif ($CRDType eq 'MPCRD') {
   } elsif ($CRDType eq 'SEIS') {
   } elsif ($CRDType eq 'RRR') {
   } elsif ($CRDType eq 'SSS') {
   }
   return ($outputstring);
}


###################################################################################################################################
sub FinalCRDSectionSource {
###################################################################################################################################
   my %args = (
      schema => '',
      section => '',
      CRDPeriod => 1,
      @_,
   );
   my $source;
   my $showCommentors;
   my $fromVal;
   my $whereVal;
   my $sortVal;
   my $subFiles;
   my $excludeVal = '';
   my $SCRRange = '';
   if ($CRDType eq 'EIS') {
       $source = 'bins';
       $showCommentors = 'default';
       $whereVal = '';
       $fromVal = '';
       $sortVal = '';
       $subFiles = 'F';
       $excludeVal = '';
       $SCRRange = '';
   } elsif ($CRDType eq 'SR') {
       if ($args{section} == 0) {
           $source = 'bins-exclude';
           $showCommentors = 'default';
           $fromVal = '';
           $whereVal = "";
           $sortVal = '';
           $subFiles = 'F';
           if ($args{CRDPeriod} == 1) {
               $excludeVal = " AND NOT ((doc.id >= 200000 AND doc.id <= 209999) OR (doc.id >= 300000 AND doc.id <= 309999) OR (doc.id >= 500000 AND doc.id <= 509999))";
           } elsif ($args{CRDPeriod} == 2) {
               $excludeVal = " AND NOT ((doc.id >= 220000 AND doc.id <= 229999) OR (doc.id >= 330000 AND doc.id <= 339999) OR (doc.id >= 550000 AND doc.id <= 559999) OR (doc.id >= 10000 AND doc.id <= 10999))";
           } elsif ($args{CRDPeriod} == 0) {
               $excludeVal = '';
           }
           $SCRRange = '';
       } elsif ($args{section} == 4) {
           $source = 'bins-exclude';
           $showCommentors = 'false';
           $fromVal = '';
           $whereVal = "";
           $sortVal = '';
           $subFiles = 'T';
           if ($args{CRDPeriod} == 1) {
               $excludeVal = " AND NOT ((com.document >= 200000 AND com.document <= 209999) OR (com.document >= 300000 AND com.document <= 309999) OR (com.document >= 500000 AND com.document <= 509999))";
               $excludeVal .= " AND NOT ((com.document >= 220000 AND com.document <= 229999) OR (com.document >= 330000 AND com.document <= 339999))";
           } elsif ($args{CRDPeriod} == 2) {
               $excludeVal = " AND NOT ((com.document >= 220000 AND com.document <= 229999) OR (com.document >= 330000 AND com.document <= 339999) OR (com.document >= 550000 AND com.document <= 559999) OR (com.document >= 10000 AND com.document <= 10999))";
               $excludeVal .= " AND NOT ((com.document >= 200000 AND com.document <= 209999) OR (com.document >= 300000 AND com.document <= 309999))";
           } elsif ($args{CRDPeriod} == 0) {
               $excludeVal = " AND NOT ((com.document >= 200000 AND com.document <= 209999) OR (com.document >= 300000 AND com.document <= 309999))";
               $excludeVal .= " AND NOT ((com.document >= 220000 AND com.document <= 229999) OR (com.document >= 330000 AND com.document <= 339999))";
           }
           #$SCRRange = '';
           if ($args{CRDPeriod} == 1) {
               $SCRRange = " AND id >= 1 AND id <= 1999";
           } elsif ($args{CRDPeriod} == 2) {
               $SCRRange = " AND id >= 2000 AND id <= 2999";
           } elsif ($args{CRDPeriod} == 0) {
               $SCRRange = "";
           }
       } else {
           $source = 'list';
           $showCommentors = 'true';
           $fromVal = ", $args{schema}.document doc, $args{schema}.commentor cmtr";
           $whereVal = " AND com.document=doc.id AND doc.commentor=cmtr.id(+)";
           $sortVal = "cmtr.lastname,cmtr.firstname,";
           $subFiles = 'T';
           $excludeVal = '';
           if ($args{CRDPeriod} == 1) {
               $SCRRange = " AND id >= 1 AND id <= 1999";
           } elsif ($args{CRDPeriod} == 2) {
               $SCRRange = " AND id >= 2000 AND id <= 2999";
           } elsif ($args{CRDPeriod} == 0) {
               $SCRRange = "";
           }
       }
   } elsif ($CRDType eq 'MPCRD') {
       $source = 'bins';
       $showCommentors = 'default';
       $whereVal = '';
       $fromVal = '';
       $sortVal = '';
       $subFiles = 'F';
       $excludeVal = '';
       $SCRRange = '';
   } elsif ($CRDType eq 'SEIS') {
       $source = 'bins';
       $showCommentors = 'default';
       $whereVal = '';
       $fromVal = '';
       $sortVal = '';
       $subFiles = 'F';
       $excludeVal = '';
       $SCRRange = '';
   } elsif ($CRDType eq 'RRR' || $CRDType eq 'RRR') {
       $source = 'bins';
       $showCommentors = 'default';
       $whereVal = '';
       $fromVal = '';
       $sortVal = '';
       $subFiles = 'F';
       $excludeVal = '';
       $SCRRange = '';
   } elsif ($CRDType eq 'SSS') {
       $source = 'bins';
       $showCommentors = 'default';
       $whereVal = '';
       $fromVal = '';
       $sortVal = '';
       $subFiles = 'F';
       $excludeVal = '';
       $SCRRange = '';
   }
   return ($source,$showCommentors,$fromVal,$whereVal,$sortVal,$subFiles, $excludeVal, $SCRRange);
}


1;
