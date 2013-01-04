# UI Login functions
#
# $Source: /data/dev/rcs/mms/perl/RCS/UILogin.pm,v $
#
# $Revision: 1.3 $
#
# $Date: 2004/06/24 22:18:52 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UILogin.pm,v $
# Revision 1.3  2004/06/24 22:18:52  atchleyb
# minor change to failed login loging.
#
# Revision 1.2  2004/06/24 21:36:43  atchleyb
# updated to log failed access attempts
#
# Revision 1.1  2003/11/12 20:33:38  atchleyb
# Initial revision
#
#
#
#
#

package UILogin;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use DBLogin qw(:Functions);
use Tie::IxHash;
use Sessions qw(:Functions);
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
      &getTitle               &doFrameSet           &doLoginForm
      &doValidateLogin        &testHTTPS
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getInitialValues       &doHeader             &doFooter
      &getTitle               &doFrameSet           &doLoginForm
      &doValidateLogin        &testHTTPS
    )]
);

my $mycgi = new CGI;


###################################################################################################################################
sub getTitle {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $title = "$SYSTitle";
   if ($args{command} eq "makeform") {
      $title = "Login";
   } elsif ($args{command} eq "login_action") {
      $title = "Login";
   }
   return ($title);
}


###################################################################################################################################
sub testHTTPS {
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = '';
    if (!defined($ENV{HTTPS}) || lc($ENV{HTTPS}) ne "on") {
#        $output = "Location: https://$ENV{SERVER_NAME}$1$args{redirectTo}\n\n";
        $output .= &writeHTTPHeader;
        $output .= "<script>\n";
        $ENV{SCRIPT_NAME} =~ m%^(.*/)%;
        $output .= "location='https://$ENV{SERVER_NAME}$1" . "login.pl';\n";
        $output .= "</script>\n";
    }
    return ($output);
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
       loginusername => (defined($mycgi->param("loginusername"))) ? $mycgi->param("loginusername") : "None",
       password => (defined($mycgi->param("password"))) ? $mycgi->param("password") : "",
    ));
    $valueHash{title} = &getTitle(command => $valueHash{command});
    if ($valueHash{loginusername} ne 'None') {$valueHash{username} = $valueHash{loginusername};}
    
    return (%valueHash);
}


###################################################################################################################################
sub doHeader {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        dbh => '',
        schema => $ENV{SCHEMA},
        title => "$SYSType Login Functions",
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
    function submitFormStatus(script, command) {
        document.$form.command.value = command;
        document.$form.target = 'status';
        document.$form.action = '$path' + script + '.pl';
        document.$form.submit();
    }
    function submitFormHeader(script, command) {
        document.$form.command.value = command;
        document.$form.target = 'header';
        document.$form.action = '$path' + script + '.pl';
        document.$form.submit();
    }


END_OF_BLOCK
    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'F', includeJSWidgets => 'F');
    
    $output .= "<input type=hidden name=title value=''>\n";
    $output .= "<input type=hidden name=passwordflag value=''>\n";
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
sub doFrameSet {  # routine to generate html frame set
###################################################################################################################################
    my %args = (
        title => "$SYSType",
        ieOnly => 'T',
        form => "",
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    
    $output .= $mycgi->header('text/html');
    $output .= "<html>\n<head>\n<title>$args{title}</title>\n";
    if ($args{ieOnly} eq 'T') {
        $output .= <<end;
        <script language=javascript><!--
            function browserNotExplorer() {
                return(navigator.appName.indexOf('Internet Explorer') == -1);
            }
            function browserLessThanFour() {
                var mozilla = "Mozilla/";
                return((navigator.userAgent.charAt(navigator.userAgent.indexOf(mozilla) + mozilla.length)) < 4);
            }
            if (browserNotExplorer() || browserLessThanFour()) {
                alert('Internet Explorer version 4.0 or greater is required to access the database.');
                window.location.href = (document.referrer != "") ? document.referrer : '/default.htm';        
            };
        //-->
        </script>
end
    }
    $output .= "<frameset rows=115,60,*," . (($SYSDebug) ? "20" : "1") ." border=0 framespacing=0>\n";
    #$output .= "<frameset rows=115,*," . (($SYSDebug) ? "20" : "1") ." border=0 framespacing=0>\n";
    ##$output .= "   <frame src=" . $args{path} . "header.pl?command=header&username=$settings{username}&userid=$settings{userid}&schema=$settings{schema} name=header frameborder=no scrolling=no noresize marginwidth=0 marginheight=0>\n";
    $output .= "   <frame src=" . $args{path} . "header.pl?command=header name=header frameborder=no scrolling=no noresize marginwidth=0 marginheight=0>\n";
    ##$output .= "   <frame src=" . $args{path} . "header.pl?command=title&title=Login name=status frameborder=no scrolling=no noresize marginwidth=0 marginheight=0>\n";
    ##$output .= "   <frame src=" . $args{path} . "title_bar.pl?title=Login&username=$settings{username}&userid=$settings{userid}&schema=$settings{schema} name=status frameborder=no scrolling=no noresize marginwidth=0 marginheight=0>\n";
    $output .= "   <frame src=" . $args{path} . "title_bar.pl?title=Login&username=$settings{username}&userid=$settings{userid}&schema=None name=status frameborder=no scrolling=no noresize marginwidth=0 marginheight=0>\n";
    $output .= "   <frame src=" . $args{path} . "$args{form}.pl?command=makeform&schema=$settings{schema} name=main frameborder=no noresize marginwidth=0 marginheight=0>\n";
    ##$output .= "   <frame src=" . $args{path} . "browse.pl?schema=$settings{schema}&username=$settings{username}&userid=$settings{userid} name=main frameborder=no noresize marginwidth=0 marginheight=0>\n";
    $output .= "   <frame src=" . $args{path} . "blank.pl name=cgiresults frameborder=no scrolling=yes noresize marginwidth=0 marginheight=0>\n";
    $output .= "</frameset>\n";
    $output .= "</html>\n";

    return($output);
}


###################################################################################################################################
sub doLoginForm {  # routine to generate the login form
###################################################################################################################################
    my %args = (
        form => "",
        @_,
    );
    my $output = "";
    
    $output .= "<table border=0 cellpadding=6 cellspacing=3 align=center><tr><td><font size=4>Username:</font></td><td><input type=text name=loginusername size=10 maxlength=20></td></tr>\n";
    $output .= "<tr><td><font size=4>Password:</font></td><td><input type=password name=password size=15 maxlength=15></td></tr>\n";
    $output .= "<tr><td align=center colspan=2><input type=submit name=submitbutton value='Login'></td></tr></table>\n";
    $output .= "<script language=javascript><!--\n";
    $output .= "document.$args{form}.target='cgiresults';\n";
    $output .= "document.$args{form}.command.value='login_action';\n";
    $output .= "document.$args{form}.loginusername.focus();\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doValidateLogin {  # routine to validate login
###################################################################################################################################
    my %args = (
        form => "",
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $username = uc($settings{username});
    
    my $status = &validateUser(dbh => $args{dbh}, schema => $args{schema}, userName => $settings{username}, password => $settings{password});
    if ($status != 1) {
        $output .= doAlertBox(text => "Invalid username or password");
        my $message = "Failed login attempt by '$settings{username}' from $ENV{REMOTE_HOST}/$ENV{REMOTE_ADDR}.";
        &logError(dbh => $args{dbh}, schema => $args{schema}, userID=>0, logMessage=>$message);
    } else {
        my $userid = &getUserID(dbh => $args{dbh}, schema => $args{schema}, userName => $username);
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $userid, logMessage => "user $username logged in", type => 1);
        my $sessionID = (($SYSUseSessions eq 'T') ? &sessionCreate(dbh => $args{dbh}, schema => $args{schema}, userID => $userid, application => $SYSType, timeout => $SYSTimeout) : 0);
        $output .= "<script language=javascript><!--\n";
        $output .= "document.$args{form}.username.value='$username';\n";
        $output .= "document.$args{form}.userid.value=$userid;\n";
        $output .= "document.$args{form}.title.value='home';\n";
        $output .= "document.$args{form}.sessionid.value='$sessionID';\n";
        $output .= "submitFormStatus('title_bar','none');\n";
        my ($PEdateTime, $dateTime, $daysRemaining) = &getPasswordExpiration(dbh => $args{dbh}, schema => $args{schema}, userID => $userid);
        #if (db_encrypt_password($settings{password}) ne db_encrypt_password($DefPassword)) {
        if ($dateTime lt $PEdateTime) {
            $output .= "submitFormHeader('header','header');\n";
            $output .= "submitFormStatus('title_bar','none');\n";
            if ($daysRemaining < $SYSPasswordExpireWarn) {
                my $expMessage = "in $daysRemaining day" . (($daysRemaining != 1) ? "s" : "");
                if ($daysRemaining == 0) {$expMessage = "today";}
                $output .= "alert('Your password will expire $expMessage!\\n Please change it.');\n";
            }
            #if (&doesUserHavePriv(dbh => $args{dbh}, schema => $args{schema}, userid => $userid, privList => [-1])) {
                $output .= "submitFormStatus('title_bar','none');\n";
                $output .= "submitForm('home','');\n";
            #} else {
            #    $output .= "document.$args{form}.title.value='browse';\n";
            #    $output .= "submitFormStatus('title_bar','none');\n";
            #    $output .= "submitForm('browse','');\n";
            #}
        } else { # must change password
            $output .= "alert('Your password has expired!\\n Please change it.');\n";
            $output .= "document.$args{form}.passwordflag.value='T';\n";
            $output .= "submitForm('users','changepasswordform');\n";
        }
        $output .= "document.location = 'blank.pl';\n";
        $output .= "//--></script>\n";
    }

    return($output);
}


###################################################################################################################################
###################################################################################################################################



1; #return true
