# UI Browse functions
#
# $Source: /data/dev/rcs/prp/perl/RCS/UIBrowse.pm,v $
# $Revision: 1.9 $
# $Date: 2005/10/06 15:49:18 $
# $Author: naydenoa $
# $Locker:  $
#
# $Log: UIBrowse.pm,v $
# Revision 1.9  2005/10/06 15:49:18  naydenoa
# CREQ00065 - tweaked wording on main display - pluralizes AQAP revisions
#
# Revision 1.8  2005/09/28 16:18:30  naydenoa
# Phase 3 implementation
# Updated main screen interface
# Split source documents into AQAP and QARD sources
# Changed QARD and AQAP subtypes to Linked and Image-Only
#
# Revision 1.7  2005/04/07 19:15:21  naydenoa
# Rearranged main screen in order of document precedence - CREQ00047
#
# Revision 1.6  2004/12/15 23:07:11  naydenoa
# Updated main browse screen to include QARD table 1a, AQAP, and more
# refined QARD revision separation (CREQ00024, CREQ00025, CREQ00026, phase 2)
#
# Revision 1.5  2004/08/30 21:41:37  naydenoa
# Minor formatting tweak
# (take 2)
#
# Revision 1.4  2004/08/30 21:39:51  naydenoa
# Minor formatting tweak
#
# Revision 1.3  2004/08/30 21:21:53  naydenoa
# CREQ00010 - separate prior and current QARD revisions
#
# Revision 1.2  2004/06/15 23:13:33  naydenoa
# Added QARD browse options - phase 1, cycle 2 requirement
#
# Revision 1.1  2004/04/22 20:38:12  naydenoa
# Initial revision
#
#

package UIBrowse;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBUtilities qw(:Functions);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use Text_Menus;
use Tie::IxHash;
use Tables;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
#use vars qw ();
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      &getInitialValues       &doHeader             &doFooter
      &getTitle               &doMainMenu
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getInitialValues       &doHeader             &doFooter
      &getTitle               &doMainMenu
    )]
);

my $mycgi = new CGI;


##############
sub getTitle {
##############
    my %args = (
        @_,
    );
    my $title = "Browse";
    if ($args{command} eq "?") {
        $title = "Browse";
    } 
    elsif ($args{command} eq "?") {
       $title = "Browse";
    }
    return ($title);
}

######################
sub getInitialValues {  # routine to get initial CGI values and return in hash
######################
    my %args = (
        dbh => "",
        @_,
    );
    
    my %valueHash = (
       &getStandardValues, (
       command => (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "browse",
       id => (defined($mycgi->param("id"))) ? $mycgi->param("id") : "",
    ));
    $valueHash{title} = &getTitle(command => $valueHash{command});
    
    return (%valueHash);
}

##############
sub doHeader {  # routine to generate html page headers
##############
    my %args = (
        dbh => '',
        schema => $ENV{SCHEMA},
        title => "$SYSType User Functions",
        displayTitle => 'T',
        @_,
    );
    my $outstr = "";
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
    function submitBrowseSource (command) {
        var script = 'requirement';
        document.$form.command.value = command;
        if (document.$form.sourceid.value == -1) {
            script = 'source';
        }
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }
    function submitBrowse () {
        var script = 'requirement';
        if (document.$form.what[3].checked == true) { // qard source
            document.$form.command.value = 'browse_detail';
            document.$form.qardtypeid.value = 1;
            if (document.$form.sourceid.value == -1) {
                script = 'source';
            }
        }
        if (document.$form.what[6].checked == true) { // aqap source
            document.$form.command.value = 'browse_detail';
            document.$form.qardtypeid.value = 2;
            if (document.$form.aqapsourceid.value == -1) {
                script = 'source';
            }
        }
        else if (document.$form.what[1].checked == true) { // QARD linked
            document.$form.command.value = 'browse';
            document.$form.qardtypeid.value = 1;
            document.$form.rid.value = document.$form.revid.value;
            script = 'qard';
        }
        else if (document.$form.what[2].checked == true) { // QARD current
            document.$form.command.value = 'browse_reference';
            document.$form.qardtypeid.value = 1;
            document.$form.rid.value = document.$form.crid.value;
            script = 'qard';
        }
//        else if (document.$form.what[3].checked == true) { // QARD prior
//            document.$form.command.value = 'browse_reference';
//            document.$form.qardtypeid.value = 1;
//            document.$form.rid.value = document.$form.prid.value;
//            script = 'qard';
//        }
        else if (document.$form.what[4].checked == true) { // AQAP linked
            document.$form.command.value = 'browse';
            document.$form.qardtypeid.value = 2;
            document.$form.rid.value = document.$form.aqaprid.value;
            script = 'qard';
        }
        else if (document.$form.what[5].checked == true) { // AQAP other
            document.$form.command.value = 'browse_aqap';
            document.$form.qardtypeid.value = 2;
            document.$form.rid.value = document.$form.arid.value;
            script = 'qard';
        }
        else if (document.$form.what[0].checked == true) { // QAMP
            document.$form.command.value = 'browse_qamp';
            document.$form.qardtypeid.value = 3;
            document.$form.rid.value = document.$form.mrid.value;
            script = 'qard';
        }
        else if (document.$form.what[7].checked == true) { // users
            document.$form.command.value = 'browse';
            script = 'users';
        }
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }
    function setRadio(i) {
        document.$form.what[i].checked = true;
    }
    function submitForm3(script, command, type) {
        document.$form.command.value = command;
        document.$form.type.value = type;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }
END_OF_BLOCK

    $outstr .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'F', includeJSWidgets => 'F');
    
    $outstr .= "<input type=hidden name=type value=0>\n";
    $outstr .= "<table border=0 width=750 align=center><tr><td>\n";

    return($outstr);
}

##############
sub doFooter {  # routine to generate html page footers
##############
    my %args = (
        @_,
    );
    my $outstr = "";
    $outstr .= &doStandardFooter();
    return($outstr);
}

################
sub doMainMenu {  # routine to generate main report menu
################
    my %args = (
        @_,
    );
    my $outstr = "";
    my $message = '';
    my $key;

    $outstr .= "<input type=hidden name=qrid value=>\n";
    $outstr .= "<input type=hidden name=rid value=>\n";
    $outstr .= "<input type=hidden name=qardtypeid value=>\n";
#    $outstr .= "<table width=705 align=center>\n";
    $outstr .= "<br><table width=725 align=center border=3 cellpadding=10 cellspacing=5 bordercolor=#aaaaaa>\n";

####  QAMP  ####
    $outstr .= "<tr><td><font face=helvetica size=4><b>QAMP</b></font></td><td>\n";
    $outstr .= "<input type=radio name=what value=0 onFocus=setRadio(0)>&nbsp;&nbsp;<b>Revisions:</b>&nbsp;&nbsp;\n";
    $outstr .= "<select name=mrid onFocus=setRadio(0)><option value=0>All\n";
    my @qamps = getQARDRevs (dbh => $args{dbh}, schema => $args{schema}, where => "isdeleted = 'F' and qardtypeid = 3", orderby => "revid desc");
    for (my $i = 1; $i <= $#qamps; $i++) {
        my $id = $qamps[$i]{id};
        my $revid = $qamps[$i]{revid};
        my $thesection = &getDisplayString ($revid, 49);
        $outstr .= "<option value=$id>$thesection\n";
    }
    $outstr .= "</select></td></tr>\n";
####  end QAMP  ####

####  QARD  ####
    tie my %qardtoc, "Tie::IxHash";
    tie my %toc, "Tie::IxHash";
    $outstr .= "<tr><td valign=top><font face=helvetica size=4><b>QARD</b></font></td><td>\n";
    $outstr .= "<table width=100% border=0>\n";

#--- Linked QARD ---#

    $outstr .= "<tr><td width=180><input type=radio name=what value=1 checked onFocus=setRadio(1)>&nbsp;&nbsp;<b>Linked&nbsp;Revisions:</b>&nbsp;&nbsp;\n";
    $outstr .= "</td><td><select name=revid onChange=selectTOC(this,document.browse.tid); onFocus=selectTOC(this,document.browse.tid);setRadio(1);>\n"; 
    my $thesection = "";
    my @qards = getQARDRevs (dbh => $args{dbh}, schema => $args{schema}, where => "isdeleted = 'F' and iscurrent = 'L' and qardtypeid = 1", orderby => "revid desc");
    for (my $i = 1; $i <= $#qards; $i++) {
        my $id = $qards[$i]{id};
        my $revid = $qards[$i]{revid};
        $thesection = &getDisplayString ($revid, 49);
        $outstr .= "<option value=$id>$thesection\n";
    }
    $outstr .= "</td></tr>\n";
    $outstr .= "<script language=javascript><!--\n";
    $outstr .= "function selectTOC (revid, tid) {\n";
    $outstr .= "    tid.options.length = 0;\n";
    $outstr .= "    tid.disabled = false;\n";

    for (my $j = 1; $j <= $#qards; $j++) {
        %toc = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, idColumn => "id", nameColumn => "tocid || '  ' || title", table => "qardtoc", orderBy => "id", where => "revisionid = $qards[$j]{id} and isdeleted = 'F'", orderBy => "id")};
        my $i = 1;
        $outstr .= "    if (revid.options[revid.selectedIndex].value == $qards[$j]{id}) {\n";
        while (my ($tid, $title) = each (%toc)) {
            $title = &getDisplayString ($title, 40);
            $outstr .= "        tid.options[$i] = new Option('$title','$tid','','');\n";
            $i++;
        }
        if ((keys %toc) < 1) {
            $outstr .= "        tid.options[0] = new Option('No TOC sections associated with this revision','0','','');\n";
            $outstr .= "        tid.disabled = true;\n";
        }
        else {
            $outstr .= "        tid.options[0] = new Option('All','0','','');\n";
        }
        $outstr .= "    }\n";
    }

    $outstr .= "    tid.selectedIndex = 0;\n";
    $outstr .= "}\n";
    $outstr .= "//--></script>\n";

    $outstr .= "<tr><td align=right><b>TOC:</b>&nbsp;&nbsp;</td><td><select name=tid onFocus=setRadio(1)><option value=''>All\n";
    foreach $key (keys %qardtoc) {
        $outstr .= "<option value=$key>" . &getDisplayString ($qardtoc{$key}, 40) . "\n";
    }    
    $outstr .= "</select></td>\n";
    $outstr .= "</tr>\n";

#--- end Linked QARD ---#

    $outstr .= "<tr><td colspan=2>&nbsp;</td></tr>";

#--- Current QARD ---#

    $outstr .= "<tr><td>\n";
    $outstr .= "<input type=radio name=what value=2 onFocus=setRadio(2)>&nbsp;&nbsp;<b>Image-Only&nbsp;Revisions:</b>&nbsp;&nbsp;\n";
    $outstr .= "</td><td>\n";
    $outstr .= "<select name=crid onFocus=setRadio(2)><option value=''>All\n"; 
    my @cqards = getQARDRevs (dbh => $args{dbh}, schema => $args{schema}, where => "isdeleted = 'F' and iscurrent = 'I' and qardtypeid = 1", orderby => "revid desc");
    for (my $i = 1; $i <= $#cqards; $i++) {
        my $id = $cqards[$i]{id};
        my $revid = $cqards[$i]{revid};
        my $thesection = &getDisplayString ($revid, 49);
        $outstr .= "<option value=$id>$thesection\n";
    }
    $outstr .= "</select>\n";
    $outstr .= "</td></tr>\n";

#--- end Current QARD ---#

#--- QARD Sources ---#

    $outstr .= "<tr><td>\n";
    $outstr .= "<input type=radio name=what value=3 onFocus=setRadio(3)>&nbsp;&nbsp;<b>Source&nbsp;Documents:&nbsp;&nbsp;\n";
    $outstr .= "</td><td>\n";
    $outstr .= "<select name=sourceid onFocus=setRadio(3)><option value=-1>All\n";
    tie my %sourcedocs, "Tie::IxHash";
    %sourcedocs = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, idColumn => "s.id", nameColumn => "s.designation || ': ' || s.title", table => "source s, $args{schema}.sourcetype st", orderBy => "s.designation", where => "s.isdeleted = 'F' and s.qardtypeid = 1 and s.typeid = st.id")}; 
    foreach $key (keys %sourcedocs) {
        $outstr .= "<option value=$key>" . &getDisplayString ($sourcedocs{$key}, 49) . "\n";
    }
    $outstr .= "</select>\n";
    $outstr .= "</td><td>\n";

#---  end QARD Sources  ---#

    $outstr .= "</table>\n";
    $outstr .= "</td>\n";
    $outstr .= "</tr>\n";

####  end QARD  ####

####  AQAP  ####
    $outstr .= "<tr><td valign=top><font face=helvetica size=4><b>AQAP</b></font></td><td>\n";

    $outstr .= "<table width=100% border=0>\n";

#--- Linked AQAP ---#

    $outstr .= "<tr><td width=200>\n";
    $outstr .= "<input type=radio name=what value=4 onFocus=setRadio(4)>&nbsp;&nbsp;<b>Linked Revisions:</b>&nbsp;&nbsp;\n";
    $outstr .= "</td><td>\n";
    $outstr .= "<select name=aqaprid onFocus=setRadio(4)>";
    my @aqaps = getQARDRevs (dbh => $args{dbh}, schema => $args{schema}, where => "isdeleted = 'F' and qardtypeid = 2 and iscurrent = 'L'", orderby => "iscurrent desc, revid desc");
    for (my $i = 1; $i <= $#aqaps; $i++) {
        my $id = $aqaps[$i]{id};
        my $revid = $aqaps[$i]{revid};
        my $thesection = &getDisplayString ($revid, 49);
        $outstr .= "<option value=$id>$thesection\n";
    }
    $outstr .= "</select>\n";
    $outstr .= "</td></tr>\n";

#--- end Linked AQAP ---#

#--- Archived AQAP ---#

    $outstr .= "<tr><td>\n";
    $outstr .= "<input type=radio name=what value=5 onFocus=setRadio(5)>&nbsp;&nbsp;<b>Image-Only&nbsp;Revisions:</b>&nbsp;&nbsp;\n";
    $outstr .= "</td><td>\n";
    $outstr .= "<select name=arid onFocus=setRadio(5)><option value=0>All\n";
    @aqaps = getQARDRevs (dbh => $args{dbh}, schema => $args{schema}, where => "isdeleted = 'F' and qardtypeid = 2 and iscurrent = 'I'", orderby => "iscurrent desc, revid desc");
    for (my $i = 1; $i <= $#aqaps; $i++) {
        my $id = $aqaps[$i]{id};
        my $revid = $aqaps[$i]{revid};
        my $thesection = &getDisplayString ($revid, 49);
        $outstr .= "<option value=$id>$thesection\n";
    }
    $outstr .= "</select>\n";
    $outstr .= "</td></tr>\n";

#--- end Archived AQAP ---#

#--- AQAP Sources ---#

    $outstr .= "<tr><td>\n";
    $outstr .= "<input type=radio name=what value=6 onFocus=setRadio(6)>&nbsp;&nbsp;<b>Source&nbsp;Documents:&nbsp;&nbsp;\n";
    $outstr .= "</td><td>\n";
    $outstr .= "<select name=aqapsourceid onFocus=setRadio(6)><option value=-1>All\n";
    %sourcedocs = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, idColumn => "s.id", nameColumn => "s.designation || ': ' || s.title", table => "source s, $args{schema}.sourcetype st", orderBy => "s.designation", where => "s.isdeleted = 'F' and s.qardtypeid = 2 and s.typeid = st.id")}; 
    foreach $key (keys %sourcedocs) {
        $outstr .= "<option value=$key>" . &getDisplayString ($sourcedocs{$key}, 49) . "\n";
    }
    $outstr .= "</select>\n";
    $outstr .= "</td></tr>\n";

#--- end AQAP Sources ---#

    $outstr .= "</table>\n";
    $outstr .= "</td>\n";
    $outstr .= "</tr>\n";

####  end AQAP  ####


    $outstr .= "<tr><td>&nbsp;</td><td><input type=radio name=what value=7 onFocus=setRadio(7)>&nbsp;&nbsp;<b>System Users</b></td></tr>\n";

    $outstr .= "<tr><td align=center colspan=2><input type=submit name=submitbrowse value=Submit onClick=javascript:submitBrowse(); title=\"Click here to display the selected entities\"></td></tr>\n";

    $outstr .= "</table>\n";

    return($outstr);
}

###############
1; #return true


