#!/usr/local/bin/perl -w
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/header.pl,v $
#
# $Revision: 1.2 $
#
# $Date: 2008/10/21 18:07:02 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: header.pl,v $
# Revision 1.2  2008/10/21 18:07:02  atchleyb
# ACR0810_002 - Added non production warning and changed tile to text from image
#
# Revision 1.1  2003/11/12 20:38:47  atchleyb
# Initial revision
#
#
#
#
#
use integer;
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UI_Widgets qw(:Functions);
use CGI;
my $mycgi = new CGI;
my $username = defined($mycgi->param("username")) ? $mycgi->param("username") : "None";
my $userid = defined($mycgi->param("userid")) ? $mycgi->param("userid") : "None";
my $schema = defined($mycgi->param("schema")) ? $mycgi->param("schema") : "None";
my $Server = defined($mycgi->param("server")) ? $mycgi->param("server") : $SYSServer;
my $title = defined($mycgi->param("title")) ? $mycgi->param("title") : "None";
my $sessionID = defined($mycgi->param("sessionid")) ? $mycgi->param("sessionid") : "0";
my $command = $mycgi->param("command");
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

print $mycgi->header('text/html');
print "<html>\n";
my ($head, $body) = ("<head>\n", "<body background=$SYSImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n");
if ($command eq "title") {
   $head .= "<script src=$SYSJavaScriptPath/utilities.js></script>\n";
   $head .= "<script language=javascript><!--\n";
   $head .= "   var o_username = \"\";\n";
   $head .= "   var o_userid = \"\";\n";
   $head .= "   var o_schema = \"\";\n";
   $head .= "//-->\n";
   $head .= "</script>\n";
   $head .= "</head>\n";
   $body .= &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => $title);
   $body .= "</center></body>\n";
} elsif ($command eq "header") {
   my $loggedIn = (($username ne "None") && ($userid ne "None") && ($schema ne "None"));
   #my $loggedIn = 0;
   my $logoRowSpan = ($loggedIn) ? 2 : 1;
   my @buttons;
   if ($username eq 'GUEST') {
       #@buttons = ("login", "browse", "search", "reports");
       @buttons = ("login", "browse", "reports");
       #@buttons = ("login", "browse");
   } else {
       #@buttons = ("home", "browse", "search", "reports", "utilities");
       @buttons = ("home", "browse", "reports", "utilities");
       #@buttons = ("home", "browse", "utilities");
   }
   my %buttonCommand =(
       home => "",
       login => "login",
       browse => "",
       search => "",
       reports => "",
       utilities => ""
   );
   my %buttonText = (
       home => "Home",
       login => "login",
       browse => "Browse",
       search => "Search",
       reports => "Reports",
       utilities => "Utilities"
   );
   $head .= "<script language=javascript><!--\n";
   $head .= "if (document.images) {\n";
   foreach my $button (@buttons) {
      $head .= "   var $button" . "off = new Image();\n";
      $head .= "   $button" . "off.src = \"$SYSImagePath/buttons/$button" . ".gif\"\n";
      $head .= "   var $button" . "on = new Image();\n";
      $head .= "   $button" . "on.src = \"$SYSImagePath/buttons/$button" . "_ovr.gif\"\n";
      $head .= "   var $button" . "press = new Image();\n";
      $head .= "   $button" . "press.src = \"$SYSImagePath/buttons/$button" . "_dwn.gif\"\n";
   }
   $head .= "}\n";
   $head .= "function show(button, state) {\n";
   $head .= "   document[button].src = eval(button + state + '.src');\n";
   $head .= "}\n";
   $head .= "function submitForm(script,command) {\n";
   $head .= "   document.$form.action = '$path' + script + '.pl';\n";
   $head .= "   document.$form.command.value = command;\n";
   $head .= "   document.$form.submit();\n";
   $head .= "}\n";
   $head .= "//-->\n</script>\n</head>\n";
   $body .= "<form name=$form target=main method=post>\n";
   $body .= "<input type=hidden name=username value=$username>\n";
   $body .= "<input type=hidden name=userid value=$userid>\n";
   $body .= "<input type=hidden name=schema value=$schema>\n";
   $body .= "<input type=hidden name=command value=0>\n";
   $body .= "<input type=hidden name=server value=$Server>\n";
   $body .= "<input type=hidden name=sessionid value=$sessionID>\n";
#
   #$body .= "<table border=0 cellspacing=0 cellpadding=0 width=750>\n";
   #$body .= "<tr><td rowspan=3 valign=top width=2><img src=$SYSImagePath/logo.gif width=127 height=108 border=0></td>\n";
   #$body .= "<td valign=top align=center><font size=+3><b>$SYSTitle</b></font></td></tr>\n";
   #if ($loggedIn) {
   #   $body .= "<tr><td valign=top><table border=0 cellpadding=0 cellspacing=1 align=center><tr>\n";
   #   foreach my $button (@buttons) {
   #      $body .= "<td bgcolor=00ff00><a href=javascript:submitForm('$button','$buttonCommand{$button}')>";
   #      $body .= "<b>$buttonText{$button}</b></a></td>\n";
   #   }
   #   $body .= "</tr></table></td></tr>";
   #}
   #my $titlepath = $path . "text_labels.pl?width=390&size=15&parsetitle=T";
   #$body .= "<tr><td valign=top align=center><img src='$titlepath&text=Login' name=titleimage width=390 height=25></td></tr>\n";
   #$body .= "<tr><td colspan=2><hr></td></tr>\n";
   #$body .= "</table>\n";
#
   $body .= "<table border=0><tr><td rowspan=$logoRowSpan><img src=$SYSImagePath/logo.gif width=127 height=108 border=0></td>\n";
   $body .= "<td align=center><img src=$SYSImagePath/title.gif width=425 height=63 border=0></td></tr>\n";
   if ($loggedIn) {
      $body .= "<tr><td align=center><table cellspacing=0 cellpadding=0 border=0><tr>\n";
      foreach my $button (@buttons) {
         $body .= "<td><a href=javascript:submitForm('$button','$buttonCommand{$button}') ";
         $body .= "onMouseOver=show('$button','on') onMouseOut=show('$button','off') onMouseDown=show('$button','press') onMouseUp=show('$button','on')>";
         $body .= "<img src=$SYSImagePath/buttons/$button" . ".gif name=$button border=0></a>&nbsp;</td>\n";
      }
      $body .= "</tr></table></td></tr>";
   }

# display development warning if not on production
   if ($SYSProductionStatus == 0) {
       $body .= <<END_OF_BLOCK;

<!-- begin production status waring ************************************************************************************************ -->
<div id="FloatProdStatusBox" style="position: absolute;
                           width: 180px;
                           hight: 50px;
                           border-width: 0;
                           background-color:#FFFFFF;
                           cursor:pointer;
                           filter:alpha(opacity=50);
                           -moz-opacity:.50;
                           opacity:.50;" onClick="hideFloatProdStatusBox(this)">
<p style="color:#FF0000;font-weight:900;font-size:120%;" align=center>Warning!<br>This is set up for development/review.</p>
</div>
<script>
var hX = -200;
var vY = 10;

/* Portions of this are from: Floating Mail-This-Link Script C.2004 by CodeLifter.com */
/* Used by permission from javascripts.com */
var nn=(navigator.appName.indexOf("Netscape")!=-1);
var dD=document,dH=dD.html,dB=dD.body,px=dD.layers?'':'px';
function floatProdStatusBox(iX,iY,id){
    var L=dD.getElementById?dD.getElementById(id):dD.all?dD.all[id]:dD.layers[id];
    this[id+'O']=L;if(dD.layers)L.style=L;L.nX=L.iX=iX;L.nY=L.iY=iY;
    L.P=function(x,y){this.style.left=x+px;this.style.top=y+px;};L.Fm=function(){var pX, pY;
    pX=(this.iX >=0)?0:nn?innerWidth:nn&&dH.clientWidth?dH.clientWidth:dB.clientWidth;
    pY=nn?pageYOffset:nn&&dH.scrollTop?dH.scrollTop:dB.scrollTop;
    if(this.iY<0)pY+=nn?innerHeight:nn&&dH.clientHeight?dH.clientHeight:dB.clientHeight;
    this.nX+=.1*(pX+this.iX-this.nX);this.nY+=.1*(pY+this.iY-this.nY);this.P(this.nX,this.nY);
    setTimeout(this.id+'O.Fm()',33);};
    return L;
}
function hideFloatProdStatusBox(box) {
    box.style.display='none';
}
floatProdStatusBox(hX,vY,'FloatProdStatusBox').Fm();
</script>
<!-- end production status waring ************************************************************************************************ -->

END_OF_BLOCK

   }

#
   $body .= "</table>\n</center>\n";
   $body .= "</form>\n";
   $body .= "</body>\n";
}
print "$head$body</html>\n";
exit();
