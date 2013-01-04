#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/pcl/perl/RCS/UI_SCR.pm,v $
# $Revision: 1.12 $
# $Date: 2003/02/14 00:21:29 $
# $Author: naydenoa $
# $Locker:  $
# $Log: UI_SCR.pm,v $
# Revision 1.12  2003/02/14 00:21:29  naydenoa
# Changed configuration manager to project manager as part of the
# condition for CR retrieval in listSCRs
#
# Revision 1.11  2003/02/12 18:54:34  atchleyb
# added session management
#
# Revision 1.10  2003/02/11 20:09:11  naydenoa
# Changed module and variable names to new standard ones. SMSHeader to SharedHeader, etc...
#
# Revision 1.9  2002/12/31 20:39:44  naydenoa
# Updated all references to software change requests (SCR's) to read
# change requests (CR's). Corrected reference to new PCL path in listSCRs
#
# Revision 1.8  2002/12/30 21:42:10  naydenoa
# Replaced hardcoded directory path with SCMHeader variable.
#
# Revision 1.7  2002/12/04 22:36:07  naydenoa
# Added SCR browse filters to function drawResults
#
# Revision 1.6  2002/11/25 21:11:12  naydenoa
# Added function drawResults to display browse SCR results (moved from scrbrowse)
# Added valign option to calls to addCol
#
# Revision 1.5  2002/11/20 23:55:17  naydenoa
# Updated code handling SCR type to refer to name instead of description
#
# Revision 1.4  2002/11/07 19:03:30  naydenoa
# Added use DB_scm
#
# Revision 1.3  2002/11/05 23:52:28  naydenoa
# Changed "dateapproved" to "dateaccepted"
#
# Revision 1.2  2002/10/31 19:37:40  naydenoa
# Cleaned up code, added/removed functions
#
# Revision 1.1  2002/10/07 16:29:59  naydenoa
# Initial revision
#
#

package UI_SCR;
use integer;
use strict;
use SharedHeader qw(:Constants);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use Tables;
use DB_SCR qw(:Functions);
use DBDocuments qw(:Functions);
use CGI qw(param);
use Tie::IxHash;
use Carp;
use DBI;
use DBD::Oracle qw(:ora_types);
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw (
	&doRemarksTable  &doDisplayTable  &displayField &doReqTable &doSection
	&listSCRs        &doRadioButton
);
@EXPORT_OK = qw(
	&doRemarksTable  &doDisplayTable  &displayField &doReqTable &doSection
	&listSCRs        &doRadioButton   &drawResults
);
%EXPORT_TAGS =( Functions => [qw(
	&doRemarksTable  &doDisplayTable  &displayField &doReqTable &doSection
	&listSCRs        &doRadioButton   &drawResults
)]);


####################
sub doRemarksTable {
####################
    my %args = (
        cid => 0,
        iid => 0,
        @_,
                );
    my $output;
    my $id = 0;
    my $table = "request";
    my $remarks = "";
    my $entryBackground = '#ffdddd';
    my $entryForeground = '#000099';
    $id = formatID('CREQ',5,$args{cid});

    $output .= &startTable (width => 650, padding => 2, title => "Remarks on $table $id", columns => 3);
    $output .= &startRow (bgColor => "#eeeeee");
    $output .= &addCol (width => 100, value => "Entered By", isBold => 1);
    $output .= &addCol (width => 150, value => "Date/Time&nbsp;Entered", isBold => 1);
    $output .= &addCol (value => "Text", isBold => 1);
    $output .= &endRow;
    $output .= &addSpacerRow (columns => 3);
    my $rows =0;
    $remarks = "select userid, to_char(dateentered, 'MM/DD/YYYY HH:MI:SS AM'), text from $args{schema}.scrremarks where requestid = $args{cid} and product = $args{iid} order by dateentered desc";
    my $csr = $args{dbh} -> prepare ($remarks);
    $csr -> execute;
    while (my @values = $csr -> fetchrow_array){
        $rows++;
        my ($user, $date, $text) = @values;
        $output .= &startRow;
        my ($username) = singleValueLookup (dbh => $args{dbh}, schema => $args{schema}, table => "users", column => "firstname || ' ' || lastname", lookupid => $user);
        $output .= &addCol(value => $username, valign => "top");
        $output .= &addCol(value => $date, valign => "top");
        $text = ($text && $text ne " ") ? $text : "* BLANK MESSAGE *";
        $text =~ s/\n/<br>/g;
        $output .= &addCol(value => $text);
    }
    $csr -> finish;
    $output .= &endTable();
    if ($rows > 0) {
        my $such = "$output\n";
        return ($such);
    }
    else {
        my $nosuch = "<b><li>No previous remarks for this $table</b>\n";
        return ($nosuch);
    }
}

####################
sub doDisplayTable {
####################
    my %args = (
                rid => 0,
		productid => 0,
                browsedetails => 0,
                @_,
                );
    my $dbh = $args{dbh};
    my $schema = $args{schema};
    my $outstr = "";
    my %requesthash = getSCRInfo (dbh => $dbh, schema => $schema, rid => $args{rid}, pid => $args{productid});
    my $desc = $requesthash{'description'};
    my $rat = $requesthash{'rationale'};
    my $stat = $requesthash{'status'};
    my $pri = $requesthash{'priority'};
    my $date = $requesthash{'datesubmitted'};
    my $uid = $requesthash{'submittedby'};
    my $rejrat = $requesthash{'rejectionrationale'};
    my $dev = $requesthash{'developer'};
    my $act = $requesthash{'actualcost'};
    my $actions = $requesthash{'actionstaken'};
    my $est = $requesthash{'estimatedcost'};
    my $analysis = $requesthash{'analysis'};
    my $apri = $requesthash{'assignedpriority'};
    my $duedate = $requesthash{'datedue'};
    my $accdate = $requesthash{'dateaccepted'};
    my $comdate = $requesthash{'datecompleted'};
    my $update = $requesthash{'lastupdated'};
    my $upby = $requesthash{'updatedby'};
    my $tplan = $requesthash{'testplan'};
    my $type = $requesthash{'type'};
    my $closedate = $requesthash{'dateclosed'};

    $desc =~ s/\n/<br>/g;
    $rat =~ s/\n/<br>/g;
    $rejrat = ($rejrat) ? $rejrat : "";
    $rejrat =~ s/\n/<br>/g;
    $act = ($act) ? $act : "";
    $act =~ s/\n/<br>/g;
    $actions = ($actions) ? $actions : "";
    $actions =~ s/\n/<br>/g;
    $est = ($est) ? $est : "";		
    $est =~ s/\n/<br>/g;
    $analysis = ($analysis) ? $analysis : "";
    $analysis =~ s/\n/<br>/g;
    $tplan = ($tplan) ? $tplan : "";
    $tplan =~ s/\n/<br>/g;
    $dev = ($dev) ? $dev : "";
    my $rpriority = singleValueLookup (dbh => $dbh, schema => $schema, table =>"scrpriority", lookupid => $pri);
    my $apriority = ($apri) ? singleValueLookup (dbh => $dbh, schema => $schema, table => "scrpriority", lookupid => $apri) : $rpriority;
    my $typedesc = singleValueLookup (dbh => $dbh, schema => $schema, table => "scrtype", lookupid => $type, column => "name");
    my ($enteredby) = singleValueLookup (dbh => $dbh, schema => $schema, table => "users", lookupid => $uid, column => "firstname || ' ' || lastname");
    my ($updatedby) = singleValueLookup (dbh => $dbh, schema => $schema, table => "users", lookupid => $upby, column => "firstname || ' ' || lastname") if $upby;
    my ($status) = singleValueLookup (dbh => $dbh, schema => $schema, table =>"scrstatus", lookupid => $stat);
    my ($product) = singleValueLookup (dbh => $dbh, schema => $schema, table =>"product", lookupid => $args{productid}, column => "name");
    $outstr .= &startTable (width => 650, title => formatID('CREQ', 5, $args{rid}) . " for $product", columns => 2);
    $outstr .= &addSpacerRow (columns => 2);
    if ($args{browsedetails}) {
        $outstr .= &displayField (header => "ID", value => formatID('CREQ',5,$args{rid}), bold => 1);
        $outstr .= &displayField (header => "Product", value => "$product");
    }
    $outstr .= &displayField (header => "Status", value => $status);
    $outstr .= &displayField (header => "Date Entered", value => "$date");
    $outstr .= &displayField (header => "Entered By", value => $enteredby);
    $outstr .= &displayField (header => "Description", value => $desc);
    $outstr .= &displayField (header => "Rationale for Request", value => $rat);
    $outstr .= &displayField (header => "Requested Priority", value => $rpriority);
    my ($thedeveloper) = ($dev) ?  singleValueLookup (dbh => $dbh, schema => $schema, table => "users", column => "firstname || ' ' || lastname", lookupid => $dev) : " ";
    if (($stat > 2 && $stat != 11) || $args{browsedetails}) {
        $outstr .= &displayField (header => "Assigned Priority", value => "$apriority&nbsp;");
        $outstr .= &displayField (header => "Type", value => "$typedesc&nbsp;");
	my $apre = "Accepted";
	$apre = "Rejected" if ($stat == 6);
	$apre = "Withdrawn" if ($stat == 7);
	$apre = "Tabled" if ($stat == 11);
	$apre = "Reviewed by SCCB" if ($stat == 8);
        $outstr .= &displayField (header => "Date $apre", value => "$accdate&nbsp;");
        $outstr .= &displayField (header => "Due Date", value => "$duedate&nbsp;");
        $outstr .= &displayField (header => "Primary Developer", value => "$thedeveloper&nbsp;");
        $outstr .= &displayField (header => "Estimated Cost (work hours)", value => "$est&nbsp;");
        $outstr .= &displayField (header => "Analysis Notes", value => "$analysis&nbsp;");
        if ($stat > 3 || $args{browsedetails}) {
	    $outstr .= &displayField (header => "Date Completed", value => "$comdate&nbsp;");
            $outstr .= &displayField (header => "Actions Taken", value => "$actions&nbsp;");
            $outstr .= &displayField (header => "Actual Cost (work hours)", value => "$act&nbsp;");
        }
    }
    if ($args{browsedetails}) {
	my $rere = "Decision";
	$rere = "Rejection" if ($stat == 6);
	$rere = "Rework" if ($stat == 14);
	$rejrat = ($rejrat) ? $rejrat : "Not Applicable";
	$outstr .= &displayField (header => "$rere Rationale", value => "$rejrat&nbsp;");
        $outstr .= &displayField (header => "Date Closed", value => "$closedate&nbsp;");
        $outstr .= &displayField (header => "Last Updated", value => "$update&nbsp;");
        $outstr .= &displayField (header => "Updated By", value => "$updatedby&nbsp;");
    }
    $outstr .= &endTable;

    return ($outstr);
}

##################
sub displayField {
##################
    my %args = (
            bg => "#ffffff",
            header => '',
            value => '',
            bold => 0,
            @_,
            );
    my $outstr = "";
    $outstr .= &startRow (bgColor => $args{bg});
    $outstr .= &addCol (value => $args{header}, width => 160, isBold => 1, valign => "top");
    $outstr .= &addCol (value => $args{value}, isBold => $args{bold}, valign => "top");
    $outstr .= &endRow;
    return ($outstr);
}

##############
sub listSCRs {
##############
    my %args = (
	 uid => 0,
         uname => '',
         form => 'home',
         path => $SYSCGIDir,
         sessionID => 0,
         @_,
    );
    my $outstr = "";
     $outstr .= "<form name=$args{form} method=post target=main>";
    $outstr .= "<script language=\"JavaScript\" type=\"text/javascript\">\n";
    $outstr .= "<!--\n";
    $outstr .= "function submitFormID(script, command, id, productid) {\n";
    $outstr .= "    document.$args{form}.command.value = command;\n";
    $outstr .= "    document.$args{form}.action = '$args{path}/' + script + '.pl';\n";
    $outstr .= "    document.$args{form}.requestid.value = id;\n";
    $outstr .= "    document.$args{form}.productid.value = productid;\n";
    $outstr .= "    document.$args{form}.target = 'main';\n";
    $outstr .= "    document.$args{form}.submit();\n";
    $outstr .= "}\n";
    $outstr .= "//-->\n";
    $outstr .= "</script>\n";
    $outstr .= "<input type=hidden name=command value=>\n";
    $outstr .= "<input type=hidden name=requestid value=>\n";
    $outstr .= "<input type=hidden name=productid value=>\n";
    $outstr .= "<input type=hidden name=userid value=$args{uid}>\n";
    $outstr .= "<input type=hidden name=username value=$args{uname}>\n";
    $outstr .= "<input type=hidden name=schema value=$args{schema}>\n";
    $outstr .= "<input type=hidden name=sessionid value='$args{sessionID}'>\n";
    my $howmanyprojects = getCount (dbh => $args{dbh}, schema => $args{schema}, table => "project", where => "configuration_manager_id = $args{uid}");
    if ($howmanyprojects) {
        $outstr .= "<table cellpadding=0 cellspacing=0 border=0 align=center width=775>\n";
	my $prodlist = "(";
	my $usersprojects = $args{dbh} -> prepare ("select id, name, acronym from $args{schema}.project where project_manager_id = $args{uid}");
	$usersprojects -> execute;
	while (my ($projectid, $projectname, $projectacronym) = $usersprojects -> fetchrow_array) {
	    my $howmanyproducts = getCount (dbh => $args{dbh}, schema => $args{schema}, table => "product", where => "project_id=$projectid");
	    if ($howmanyproducts) {
		my $getprods = $args{dbh} -> prepare ("select id from $args{schema}.product where project_id = $projectid");
		$getprods -> execute;
		while (my ($pid) = $getprods -> fetchrow_array) {
		    $prodlist .= "$pid, ";
		}
		$getprods -> finish;
	    }
	}
	$usersprojects -> finish;
	if ($prodlist ne "(") {
	    chop ($prodlist);
	    chop ($prodlist);
	    $prodlist .= ")";
	    $outstr .= doSection (productlist => $prodlist, dbh => $args{dbh}, schema => $args{schema}, uid => $args{uid});
	}
	$outstr .= "</table>\n</center>\n</font>\n<br><br>\n</form>\n";
    }
    return ($outstr);
}

###############
sub doSection {
###############
    my %args = (
            productlist => '',
	    uid => 0,
            @_,
            );
    my $outstr = "";
    my $entryBackground = '#ffc0ff';
    my $entryForeground = '#000099';
    my $where = "";
    if ($args{productlist}) {
	$where .= "r.product in $args{productlist} and ";
    }
    my $where2 = "r.developer=$args{uid} and ";
    $outstr .= "<tr><td>" . &doReqTable (status => 1, where => $where, due => 0, dbh => $args{dbh}, schema => $args{schema}) . "</td></tr>\n";
    $outstr .= "<tr><td>" . &doReqTable (status => 3, where => $where2, dbh => $args{dbh}, schema => $args{schema}) . "</td></tr>\n";
    $outstr .= "<tr><td>" . &doReqTable (status => 4, where => $where, dbh => $args{dbh}, schema => $args{schema}) . "</td></tr>\n";
    return ($outstr);
}

################
sub doReqTable {
################
    my %args = (
                status => 0,
                where => '',
                header => '',
                script => 'scrreview',
		due => 1,
                @_,
                );
    $args{dbh} -> {LongReadLen} = 10000000;

    my $script = "$args{script}";
    my $str = "";
    my $where = "$args{where}";
    my $getstatus;
    if ($args{status} == 1) {
	$getstatus = "(r.status = $args{status} or r.status = 11)";
    }
    elsif ($args{status} == 3) {
	$getstatus = "(r.status = $args{status} or r.status = 14)";
    }
    else {
	$getstatus = "r.status = $args{status}" ;
    }
    $where .= $getstatus;
    my $total = getCount (dbh => $args{dbh}, schema => $args{schema}, table => "scrrequest r", where => $where);
    my ($statusname) = singleValueLookup (dbh => $args{dbh}, schema => $args{schema}, table => "scrstatus", lookupid => $args{status});
    my $cols = ($args{due}) ? 6 : 4;
    $str .= &startTable (width => 750, columns => $cols, title => "CR Status: $statusname $args{header} ($total total)");
    if ($total > 0) {
        $str .= &startRow (bgColor => "#eeeeee"); 
        $str .= &addCol (width => 60, value => "Product", isBold => 1);
	$str .= &addCol (width => 60, value => "ID", isBold => 1);
	$str .= &addCol (width => 50, value => "Due Date", isBold => 1) if ($args{due});
        $str .= &addCol (value => "Description", isBold => 1); 
	$str .= &addCol (width => 75, value => "Type", isBold => 1) if $args{due};
	$str .= &addCol (width => 40, value => "Priority", isBold => 1);
	$str .= &endRow;
	$str .= &addSpacerRow(columns => $cols);
	my ($rows, @resultArray) = &getSCRRequests (dbh => $args{dbh}, schema => $args{schema}, where => $where, due => $args{due});
	for (my $i=0; $i<$rows; $i++) {
	    my $rid = $resultArray[$i][0];
	    my $desc = $resultArray[$i][1];
	    my $rpri = $resultArray[$i][2];
	    my $pro = $resultArray[$i][3];
	    my $pid = $resultArray[$i][4];
	    my $apri = $resultArray[$i][5];
	    my $duedate = $resultArray[$i][6];
	    my $statusid = $resultArray[$i][7];
	    my $type = $resultArray[$i][8];

	    my $pri = ($apri) ? $apri : $rpri;
	    my $formattedid = formatID('CREQ',5,$rid);
	    $desc = "<b>Tabled:</b> $desc" if ($statusid == 11);
	    $desc = "<b>Rework:</b> $desc" if ($statusid == 14);
	    $str .= &startRow;
	    $str .= &addCol (value => "$pro", valign => "top");
            $str .= &addCol (value => "<a href=javascript:submitFormID('$args{script}','write_request',$rid,$pid) title=\"Click here to enter information about $formattedid for $pro\">" . $formattedid . "</a>", valign => "top");
    	    $duedate = ($duedate) ? $duedate : "N/A";
	    $str .= &addCol (value => "$duedate", valign => "top") if ($args{due});
	    my $numchar = ($args{due}) ? 70 : 100;
	    $str .= &addCol (value => getDisplayString($desc, $numchar));
	    $str .= &addCol (value => "$type", valign => "top") if $args{due};
	    $apri = ($apri) ? $apri : $pri;
	    $str .= &addCol (value => "$apri", valign => "top");
        }
    }
    $str .= &endTable;
    $str .= "<br>\n";
    return ($str);
}

###################
sub doRadioButton {
###################
    my %args = (
		name => '',
		howmany => 0,
		values => 0,
		strings => 0,
		@_,
		);
    my $outstr = "<ul>\n";
    for (my $i = 0; $i < $args{howmany}; $i++) {
	my $checked = ($i == 0) ? " checked" : ""; 
	$outstr .= "<input type=radio name=$args{name} value=$args{values}[$i]$checked>$args{strings}[$i]<br>\n";
    }
    $outstr .= "</ul>\n";
    return ($outstr);
}

#################
sub drawResults {
#################
my %args = (
            pid => 0,
            pname => "",
	    filterid => 0,
	    filter => "",
            @_,
            );
    my $total = 0;
    my $outstr = "";
    my $pn = $args{pname};
    $pn =~ s/ //g; ;

    $outstr .= "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    $outstr .= "<INPUT TYPE=HIDDEN NAME=pid VALUE=>\n";
    $outstr .= "<CENTER><br>\n";
    $outstr .= "<a name=$pn></a>";
    if ($args{filter} eq "product") {
        $total = &getCount(dbh => $args{dbh}, schema => $args{schema}, table => "scrrequest", where => "product = $args{pid}");
	$outstr .= &startTable (width => 750, columns => 6, title => "$args{pname}:&nbsp;&nbsp;All Software Change Requests ($total total)");
    }
    elsif ($args{filter} eq "status") {
	my $sname = &singleValueLookup (dbh => $args{dbh}, schema => $args{schema}, table => "scrstatus", lookupid => $args{filterid});
        $total = &getCount(dbh => $args{dbh}, schema => $args{schema}, table => "scrrequest", where => "status = $args{filterid} and product = $args{pid}");
	$outstr .= &startTable (width => 750, columns => 6, title => "$args{pname}:&nbsp;&nbsp;Software Change Requests in Status \"$sname\" ($total total)");
    }
    elsif ($args{filter} eq "type") {
	my $tname = &singleValueLookup (dbh => $args{dbh}, schema => $args{schema}, table => "scrtype", lookupid => $args{filterid}, column => "name");
        $total = &getCount(dbh => $args{dbh}, schema => $args{schema}, table => "scrrequest", where => "type = $args{filterid} and product = $args{pid}");
	$outstr .= &startTable (width => 750, columns => 6, title => "$args{pname}:&nbsp;&nbsp;Software Change Requests of Type \"$tname\" ($total total)");
    }
    if ($total) {
        $outstr .= &startRow (bgColor => "#eeeeee");
        $outstr .= &addCol (value => "ID", isBold => 1);
        $outstr .= &addCol (value => "Request Description", isBold => 1);
        $outstr .= &addCol (value => "Status", isBold => 1);
        $outstr .= &addCol (value => "Status Description", isBold => 1);
        $outstr .= &addCol (value => "Entered By", isBold => 1);
        $outstr .= &addCol (value => "Date Entered", isBold => 1);
        $outstr .= &endRow;
        $outstr .= &addSpacerRow;
        my ($rows, @resultArray) = &getSCRBrowseResults (dbh => $args{dbh}, schema => $args{schema}, pid => $args{pid}, filterid => $args{filterid}, filter => $args{filter});
        for (my $i=0; $i<$rows; $i++) {
	    my $rid = $resultArray[$i][0];
	    my $sid = $resultArray[$i][1];
	    my $status = $resultArray[$i][2];
	    my $uid = $resultArray[$i][3];
	    my $user = $resultArray[$i][4];
	    my $desc = $resultArray[$i][5];
	    my $date = $resultArray[$i][6];
	    my $priority = $resultArray[$i][7];
	    my $product = $resultArray[$i][8];
	    my $isopen = $resultArray[$i][9];

            my $clop = ($isopen eq 'T') ? "Open" : "Closed";
            my $formattedid = formatID('CREQ',5,$rid);
            $outstr .= &startRow;
            $outstr .= &addCol (value => "<A HREF=\"javascript:browseDetails($rid,$args{pid});\" title=\"Click here to browse $formattedid for $product\">$formattedid</a>", valign => "top");
            $outstr .= &addCol (value => getDisplayString ($desc, 30), valign => "top");
            $outstr .= &addCol (value => "$clop", valign => "top");
            $outstr .= &addCol (value => "$status", valign => "top");
#            $outstr .= &addCol (value => "<a href=javascript:displayUser($uid) title=\"Click here to browse information for $user\">$user</a>", valign => "top");
            $outstr .= &addCol (value => "$user", valign => "top");
            $outstr .= &addCol (value => "$date", valign => "top");
            $outstr .= &endRow;
        } 
    }
    $outstr .= &endTable;
    return ($outstr);
}

##################
1;


