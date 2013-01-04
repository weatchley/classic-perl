#
# Miscellaneous multiple use functions
#
# $Source: /data/dev/rcs/crd/perl/RCS/Miscellaneous.pm,v $
#
# $Revision: 1.5 $
#
# $Date: 2002/02/20 16:22:31 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: Miscellaneous.pm,v $
# Revision 1.5  2002/02/20 16:22:31  atchleyb
# removed depricated function use named parameters and changed the html header
#
# Revision 1.4  2000/06/29 23:36:56  naydenoa
# Made sure module works with reports.pl, ad_hoc_reports.pl, messages.pl
#
#

package Miscellaneous;
use strict;
use integer;
use CRD_Header qw(:Constants);
use UI_Widgets qw (:Functions);
use DB_Utilities_Lib qw (:Functions);
use CGI;
use DBI;
use DBD::Oracle qw(:ora_types);
use Tie::IxHash;
use vars qw (@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $AUTOLOAD);
use Exporter;
@ISA = qw (Exporter);

@EXPORT = qw (
	&build_states
	&build_countries
	&getBinNumber
	&getBinTree
	&getLookupValues
	&getReportDateTime
	&isBinMember
	&processError
	&writeBin
	&writeBrowseCommentLink
	&writeCommentorLink
	&writeControl
	&writeDate
	&writeHTTPHeader
	&writeText
	&writeUser
);

@EXPORT_OK = qw (
	&build_states
	&build_countries
	&getBinNumber
	&getBinTree
	&isBinMember
	&getLookupValues
	&getReportDateTime
	&processError
	&writeBin
	&writeBrowseCommentLink
	&writeCommentorLink
	&writeControl
	&writeDate
	&writeHTTPHeader
	&writeText
	&writeUser
);

%EXPORT_TAGS = (Functions => [qw (
	&build_states
	&build_countries
	&getBinNumber
	&getBinTree
	&getLookupValues
	&getReportDateTime
	&isBinMember
	&processError
	&writeBin
	&writeBrowseCommentLink
	&writeCommentorLink
	&writeControl
	&writeDate
	&writeHTTPHeader
	&writeText
	&writeUser
)]);

#########################################################################
# Content of module consists of multiple-use functions from EIS scripts #
#########################################################################

#######################################################################
sub getBinTree {
#######################################################################
# used by ad_hoc_reports.pl (done 6/27/2000)
#         reports.pl (done 6/27/2000)
# generate a list of bins that have 'root_bin' as a parent, the list is terminated with a 0

    my $hashref = $_[0];
    my %args = %$hashref;
    my $outputstring = '';
    
    my $sqlquery = "SELECT UNIQUE id FROM $args{'schema'}.bin START WITH id = $args{'root_bin'} CONNECT BY PRIOR id = parent";
    my $csr = $args{'dbh'}->prepare($sqlquery);
    my $status = $csr->execute;
    my @values;
    while (@values = $csr->fetchrow_array) {
        $outputstring .= "$values[0],";
    }

    $csr->finish;
    $outputstring = "0," . $outputstring . "0";
    return ($outputstring);
    
}

#################################################################
sub isBinMember {
#################################################################
# used by ad_hoc_reports.pl (done 6/27/2000)
#         report.pl (done 6/27/2000)

    my %args = (
        run_date => &getReportDateTime,
        dbh => '',
        schema => '',
        testUser => 0,
        binList => '0',
        @_,
    );
    my @row;
    my @values;
    my $bincount = 0;

    @row = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.bin WHERE (coordinator=$args{'testUser'} OR nepareviewer=$args{'testUser'}) AND (id IN ($args{'binList'}))");
    @values = $args{'dbh'}->selectrow_array("SELECT UNIQUE count(*) FROM $args{'schema'}.default_tech_reviewer WHERE (reviewer = $args{'testUser'}) AND (bin IN ($args{'binList'})) AND (bin NOT IN (SELECT id FROM $args{'schema'}.bin WHERE coordinator=$args{'testUser'} OR nepareviewer=$args{'testUser'}))");

    $bincount = $row[0] + $values[0];
    
    return ((($bincount >= 1) ? 1 : 0));
}

##########################################################
# Leave alone for now... 6/28/2000
##########################################################
#sub build_states {
##########################################################
# used by comment_documents.pl
#         commentors.pl

# routine to build a selection box of states and set the current state to passed value
#    my %args = (
#	@_,
#	);
#state = ((defined($_[0])) ? $_[0] : "");
#    
#    my $outputstring = qq(
#<select name=state>
#<option value="">(None)<option value="AL">Alabama<option value="AK">Alaska<option value="AZ">Arizona<option value="AR">Arkansas<option value="CA">California<option value="CO">Colorado<option value="CT">Connecticut<option value="DE">Delaware<option value="FL">Florida<option value="GA">Georgia<option value="HI">Hawaii<option value="ID">Idaho<option value="IL">Illinois<option value="IN">Indiana<option value="IA">Iowa<option value="KS">Kansas<option value="KY">Kentucky<option value="LA">Louisiana<option value="ME">Maine<option value="MD">Maryland<option value="MA">Massachusetts<option value="MI">Michigan<option value="MN">Minnesota<option value="MS">Mississippi<option value="MO">Missouri<option value="MT">Montana<option value="NE">Nebraska<option value="NV">Nevada<option value="NH">New Hampshire<option value="NJ">New Jersey<option value="NM">New Mexico<option value="NY">New York<option value="NC">North Carolina<option value="ND">North Dakota<option value="OH">Ohio<option value="OK">Oklahoma<option value="OR">Oregon<option value="PA">Pennsylvania<option value="RI">Rhode Island<option value="SC">South Carolina<option value="SD">South Dakota<option value="TN">Tennessee<option value="TX">Texas<option value="UT">Utah<option value="VT">Vermont<option value="VA">Virginia<option value="WA">Washington<option value="DC">Washington D.C.<option value="WV">West Virginia<option value="WI">Wisconsin<option value="WY">Wyoming
#</SELECT>
#<script language=javascript><!--
#   set_selected_option(document.$args{form.state}, '$args{state}');
#//--></script>
#    );
#    return ($outputstring);
#}

###############################################################
# Leave alone for now... (6/28/2000)
###############################################################
#sub build_countries {
###############################################################
# used by comment_documents.pl
#         commentors.pl
# routine to build a select box of countries and set the default
#
#    my $country = $_[0];
#    
#    my $outputstring = qq(
#
#<select name=country>
#<option value="">(None)<option value="US">United States<option value="CA">Canada<option value="MX">Mexico<option value="JP">Japan<option value="FR">France<option value="GR">Germany
#</select>
#<script language=javascript><!--
#   set_selected_option(document.$form.country, '$country');
#//--></script>
#    );
#    
#    return ($outputstring);
#}

######################################################################
sub getBinNumber {
######################################################################
# used by search.pl
#         summary_comments.pl
#         home.pl
#         comments.pl
#         bins.pl (done week of 6/19)

   my %args = (
      @_,
   );
   $args{binName} =~ m/([0-9].*?)[ ](.*)/;
   return ($1, $2);
}

####################################################################
sub getLookupValues {
####################################################################
# used by comments.pl
#         responses.pl
# need to modify versions found in
#         summary_comments.pl
#         bins.pl ( done; modified call to getLookupValues in browseBinTable 6/23/2000)
#         home.pl

   my %args = (
      @_,
   );
   my %lookupHash = ();
   my $lookup = $args{dbh}->prepare("select id, name from $args{schema}.$args{table}");
   $lookup->execute;
   while (my @values = $lookup->fetchrow_array) {
      $lookupHash{$values[0]} = $values[1];
   }
   $lookup->finish;
   return (\%lookupHash);
}

################################################################
sub getReportDateTime {
################################################################
# used by ad_hoc_reports.pl (done 6/27/2000)
#         final_crd.pl
#         reports.pl (done 6/27/2000)

    my @timedata = localtime(time);
    return(uc(get_date()) . " " . lpadzero($timedata[2],2) . ":" . lpadzero($timedata[1],2) . ":" . lpadzero($timedata[0],2));
}

################################################################
sub processError {
################################################################
# used by ad_hoc_reports.pl (never calls it!? done 6/27/2000)
#         final_crd.pl
#         reports.pl (done 6/27/2000, modified call from CommentorSelectionPage)
#         responses.pl
#         search.pl
#         home.pl
#         comments.pl
#         messages.pl (done 6/28/2000, modified call from processCommand; for now the rollback stmt in this particular one is to be ignored)

   my %args = (
      @_,
   );
   my $error = &errorMessage($args{dbh}, $args{username}, $args{userid}, $args{schema}, $args{activity}, $@);
   $error =  ('_' x 100) . "\n\n" . $error if ($args{errorstr} ne "");
   $error =~ s/\n/\\n/g;
   $error =~ s/'/%27/g;
   $args{errorstr} .= $error;
}

###########################################################################
sub writeBin { 
###########################################################################
# used by sumary_comments.pl
#         search.pl
#         home.pl
# comments.pl uses a different writeBin function

   my %args = (
      writeHeader => 0,
      headerText => "Bin",
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      my $prompt = "Click here to browse bin $args{binName}";
      $out .= "<center><a href=javascript:display_bin($args{binID}) title='$prompt'>";
      $out .= &getBinNumber(binName => $args{binName});
      $out .= "</a></center>";
   }
   return ($out);
}

##########################################################################
sub writeBrowseCommentLink {              
##########################################################################
# used by summary_comments.pl
#         bins.pl (done week of 6/19/2000)

   my %args = (
      writeHeader => 0,
      headerText => "Doc ID /<br>Comment ID",
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      my $formattedID = &formatID($CRDType, 6, $args{document}) . " / " . &formatID("", 4, $args{comment});
      my $prompt = "Click here to browse comment information for $formattedID";
      $out .= "<center><a href=javascript:displayComment($args{document},$args{comment}) title='$prompt'>$formattedID</a></center>";
   }
   return ($out);
}

#####################################################################
sub writeControl { 
#####################################################################
# used by summary_comments.pl
#	  comments.pl
#         home.pl
#         messages.pl (done 6/28/2000)

   my %args = (
      name => 'button',
      useLinks => 1, 
      @_,
   );
   return ($args{useLinks}) ? "<b><a href=javascript:$args{callback}>$args{label}</a></b>" : "<input type=button name=$args{name} value='$args{label}' onClick=javascript:$args{callback}>";
}

######################################################################
sub writeDate { 
######################################################################
# used by summary_comments.pl
#         home.pl

   my %args = (
      writeHeader => 0,
      headerText => "Last<br>Activity",
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      $out .= "<center>$args{date}</center>";
   }
   return ($out);
}

####################################################################
sub writeHTTPHeader {
####################################################################
#used by comments.pl
#        home.pl
#        newlogin.pl
#        responses.pl
#        summary_comments.pl
#        messages.pl (done 6/28/2000)

my %args = (
	@_,
	);

   print $args{crdcgi}->header('text/html');
}

####################################################################
sub writeText {
####################################################################
# used by bins.pl
#         summary_comments.pl

   my %args = (
      writeHeader => 0,
      center => 0,
      text => "",
      textWidth => 50,
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      $out .= "<center>" if ($args{center});
      $out .= &getDisplayString($args{text}, $args{textWidth});
      $out .= "</center>" if ($args{center});
   }
   return ($out);
}


######################################################################
sub writeUser { 
######################################################################
# used by summary_comments.pl
#         bins.pl
# home.pl's looks awfully similar. I think it doesn't make a difference.
#
   my %args = (
      writeHeader => 0,
      center => 0,
      headerText => "Response<br>Writer",
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      my $displayedUserName = &get_fullname($args{dbh}, $args{schema}, $args{userID});
      my $prompt = "Click here to browse information about $displayedUserName";
      $out .= "<center>" if ($args{center});
      $out .= "<a href=javascript:display_user($args{userID}) title='$prompt'>$displayedUserName</a>";
      $out .= "</center>" if ($args{center});
   }
   return ($out);
}

######################################################
# end of possible functions for Miscellaneous module #
######################################################

1;

