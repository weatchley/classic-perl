#!/usr/local/bin/perl -w
#
# UI title bar for SCM
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/pcl/perl/RCS/UI_title_bar.pm,v $
# $Revision: 1.3 $
# $Date: 2008/10/16 20:42:39 $
# $Author: atchleyb $
# $Locker:  $
# $Log: UI_title_bar.pm,v $
# Revision 1.3  2008/10/16 20:42:39  atchleyb
# WR103, ACR0810_001 - Alter title bar frame to use text instead of images for the title
#
# Revision 1.2  2003/02/03 21:39:40  atchleyb
# removed refs to SCM
#
# Revision 1.1  2002/09/17 21:33:14  starkeyj
# Initial revision
#
#

package UI_title_bar;
# get all required libraries and modules
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use Carp;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);

use CGI;
use strict;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw (&displayPage);
@EXPORT_OK = qw(&displayPage);
%EXPORT_TAGS =(
    Functions => [qw(&displayPage) ]
);

sub displayPage {
   my %args = (
      schema => "",
      title => "",
      username => "",
      userid => "",
      includeScriptTags => 'T',
      @_,
   );
   my $output = "";
   my $mycgi = new CGI;

# tell the browser that this is an html page using the header method
   print $mycgi->header('text/html');

   $ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
   my $path = $1;
   my $form = $2;

#   if ((!defined($args{userid})) || ($args{userid} eq "") || (!defined($args{username})) || ($args{username} eq ""))
#     {
#     print <<openloginpage;
#     <script type="text/javascript">
#     <!--
#     parent.location='$SYSCGIDir/login.pl';
#     //-->
#     </script>
#   openloginpage
#     exit 1;
#     }

   my $DBSCHEMA = (($args{username} eq 'None') ? 'None' : uc($args{schema}));
   
   my $SchemaColor = (($DBSCHEMA ne 'None') ? (($SYSProductionStatus == 1) ? $SYSFontColor : "#990000") : "#ff0000");
   my $UserColor = (($args{username} ne 'None') ? $SYSFontColor : "#ff0000");
   
   # output page header
   my $titlepath = $path . "text_labels.pl?width=390&size=15&parsetitle=T";
   print <<ENDOFBLOCK;
<html>
<head>
<title>SYS Title</title>
<script language="JavaScript" type="text/javascript">
<!--
//if (parent == self) // not in frames
//  {
//  location = '$path/login.pl';
//  }

function SetImageLabel(name) {
    var name2 = name;
    var name3 = name2.replace(/_/g,"+");
    name2 = name3.replace(/ /g,"+");
    //alert(name2);
    var temp = name.replace(/\\//g,"_");
    var temp2 = temp.replace(/ /g,"_");
    var file = temp2.toLowerCase();
    //document.imagelabel.src= '$SYSImagePath/' + file + '.gif';
    //document.titleimage.src= '$titlepath&text=' + name2;
    document.all.titletext.innerHTML = name2;
}
//-->
</script>
</head>

<body background=$SYSImagePath/background.gif text=$SYSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>
<table border=0 cellspacing=0 cellpadding=0 width=750><tr>
<td align=center colspan=3><img src=$SYSImagePath/separator.gif width=750 height=14 border=0></td></tr>
<tr><td width=24% align=left><table cellpadding=3 cellspacing=0 border=1><tr><td><b><font size=2 color=#003000>User/ID:&nbsp;&nbsp;</font>
<font size=2 color=$UserColor>$args{username}</font>
<font size=2 color=#003000> / </font>
<font size=2 color=$UserColor>$args{userid}</font>
</b></td></tr></table></td>
<!--td align=center><img src='$titlepath&text=$args{title}' name=titleimage width=390 height=25></td-->
<td align=center width=390 height=25><b><p id=titletext style="color: #000099; font-size:24px;">$args{title}</p></b></td>
<td width=24% align=right><table cellpadding=3 cellspacing=0 border=1><tr><td><b>
<font size=2 color=#003000>DB:&nbsp&nbsp;</font>
<font size=2 color=$SchemaColor>$DBSCHEMA</font>
</b></td></tr></table></td></tr>
<tr><td align=center colspan=3><img src=$SYSImagePath/separator.gif width=750 height=14 border=0></td>
</tr></table></center>
</body>
</html>
ENDOFBLOCK

    return ($output);
}

1; #return true
