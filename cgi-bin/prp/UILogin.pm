# UI Login functions
#
# $Source: /usr/local/homes/gilmored/rcs/prp/perl/RCS/UILogin.pm,v $
# $Revision: 1.6 $
# $Date: 2009/02/06 19:55:47 $
# $Author: gilmored $
# $Locker: gilmored $
#
# $Log: UILogin.pm,v $
# Revision 1.6  2009/02/06 19:55:47  gilmored
# Added getCGI() to clean up getInitialValues() code
# Added global schema to perl calls to frame src builders
#
# Revision 1.5  2005/10/06 15:54:40  naydenoa
# CREQ00065 - tweaked login functionality - no privs check, no intermediate
# redirect; goes directly to browse now.
#
# Revision 1.4  2005/09/28 23:09:20  naydenoa
# Phase 3 implementation
# Added help button
# Redirect all users to browse on login
#
# Revision 1.3  2004/09/17 16:49:50  naydenoa
# Post-login redirect to "Reports" screen for read-only users - CREQ00021
#
# Revision 1.2  2004/06/16 21:17:45  naydenoa
# Resrist access to home screen to users with edit privilege
#
# Revision 1.1  2004/04/22 20:39:34  naydenoa
# Initial revision
#
#

package UILogin;

# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use DBLogin qw(:Functions);
use UIUsers qw(&writeUserTable);
use Tie::IxHash;
use Sessions qw(:Functions);
use Tables;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
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


##############
sub getTitle {
##############
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

###############
sub testHTTPS {
###############
    my %args = (
        @_,
    );
    my $outstr = '';
    if (!defined($ENV{HTTPS}) || lc($ENV{HTTPS}) ne "on") {
        $outstr .= &writeHTTPHeader;
        $outstr .= "<script>\n";
        $ENV{SCRIPT_NAME} =~ m%^(.*/)%;
        $outstr .= "location='https://$ENV{SERVER_NAME}$1" . "login.pl';\n";
        $outstr .= "</script>\n";
    }
    return ($outstr);
}

#####################
sub getCGI {		# Fetch a CGI parm with default
#####################
    my %args = ( @_, );
    my $key = $args{key};
    my $something = (defined ($mycgi -> param($key)) ? $mycgi -> param($key) : $args{dflt});
    return ($something);
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
       command => getCGI(key => "command", dflt => "browse"),
       loginusername => getCGI(key => "loginusername", dflt => "None"),
       password => getCGI(key => "password", dflt => ""),
       username => getCGI(key => "username", dflt => "GUEST"),
       userid => getCGI(key => "userid", dflt => "0"),
       schema => getCGI(key => "schema", dflt => "prp"),
    ));
    $valueHash{title} = &getTitle(command => $valueHash{command});
    if ($valueHash{loginusername} ne 'None') { $valueHash{username} = $valueHash{loginusername}; }
    return (%valueHash);
}

##############
sub doHeader {  # routine to generate html page headers
##############
    my %args = (
        dbh => '',
        schema => $ENV{SCHEMA},
        title => "$SYSType Login Functions",
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

    $outstr .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'F', includeJSWidgets => 'F');
    
    $outstr .= "<input type=hidden name=title value=''>\n";
    $outstr .= "<input type=hidden name=passwordflag value=''>\n";
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
sub doFrameSet {  # routine to generate html frame set
################
    my %args = (
        title => "$SYSType",
        ieOnly => "$IEOnly",
        form => "",
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $outstr = "";
    
    $outstr .= $mycgi->header('text/html');
    $outstr .= "<html>\n<head>\n<title>$args{title}</title>\n";
    if ($args{ieOnly} eq 'T') {
        $outstr .= <<end;
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
#    $outstr .= "<frameset rows=115,60,*," . (($SYSDebug) ? "20" : "1") ." border=0 framespacing=0>\n";
    $outstr .= "<frameset rows=75,50,*," . (($SYSDebug) ? "20" : "1") ." border=0 framespacing=0>\n";
    $outstr .= "   <frame src=" . $args{path} . "header.pl?command=header&username=$settings{username}&userid=$settings{userid}&schema=$settings{schema} name=header frameborder=no scrolling=no noresize marginwidth=0 marginheight=0>\n";
    $outstr .= "   <frame src=" . $args{path} . "title_bar.pl?title=Login&username=$settings{username}&userid=$settings{userid}&schema=$settings{schema} name=status frameborder=no scrolling=no noresize marginwidth=0 marginheight=0>\n";
#    $outstr .= "   <frame src=" . $args{path} . "$args{form}.pl?command=makeform&schema=$settings{schema} name=main frameborder=no noresize marginwidth=0 marginheight=0>\n";
    $outstr .= "   <frame src=" . $args{path} . "home.pl?command=makeform&schema=$settings{schema} name=main frameborder=no noresize marginwidth=0 marginheight=0>\n";
    $outstr .= "   <frame src=" . $args{path} . "blank.pl name=cgiresults frameborder=no scrolling=yes noresize marginwidth=0 marginheight=0>\n";
    $outstr .= "</frameset>\n";
    $outstr .= "</html>\n";

    return($outstr);
}

#################
sub doLoginForm {  # routine to generate the login form
#################
    my %args = (
        form => "",
        @_,
    );
    my $outstr = "";
    
    $outstr .= "<table border=0 cellpadding=6 cellspacing=3 align=center><tr><td><font size=4>Username:</font></td><td><input type=text name=loginusername size=8 maxlength=12></td></tr>\n";
    $outstr .= "<tr><td><font size=4>Password:</font></td><td><input type=password name=password size=15 maxlength=15></td></tr>\n";
    $outstr .= "<tr><td align=center colspan=2><input type=submit name=submitbutton value='Login'></td></tr></table>\n";


     $outstr .= "<br><br>\n";
     $outstr .= &writeUserTable (dbh => $args{dbh}, schema => $args{schema}, privilege => 10, title => "Contact a System Administrator for database access", from => "login", columns => 4);


    $outstr .= "<script language=javascript><!--\n";
    $outstr .= "document.$args{form}.target='cgiresults';\n";
    $outstr .= "document.$args{form}.command.value='login_action';\n";
    $outstr .= "document.$args{form}.loginusername.focus();\n";
    $outstr .= "//--></script>\n";

    return($outstr);
}

#####################
sub doValidateLogin {  # routine to validate login
#####################
    my %args = (
        form => "",
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $outstr = "";
    my $username = uc($settings{username});
    
    my $status = &validateUser(dbh => $args{dbh}, schema => $args{schema}, userName => $settings{username}, password => $settings{password});
    if ($status != 1) {
        $outstr .= doAlertBox(text => "Invalid username or password");
    } 
    else {
        my $userid = &getUserID(dbh => $args{dbh}, schema => $args{schema}, userName => $username);
        my $userpriv = &doesUserHavePriv (dbh => $args{dbh}, schema => $args{schema}, userid => $userid, privList => [3, 4, 5, 6, 7, -1]);
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $userid, logMessage => "user $username logged in", type => 1);
        my $sessionID = (($SYSUseSessions eq 'T') ? &sessionCreate(dbh => $args{dbh}, schema => $args{schema}, userID => $userid, application => $SYSType, timeout => $SYSTimeout) : 0);
        $outstr .= "<script language=javascript><!--\n";
        $outstr .= "document.$args{form}.username.value='$username';\n";
        $outstr .= "document.$args{form}.userid.value=$userid;\n";
#        $outstr .= ($userpriv) ? "document.$args{form}.title.value='home';\n" : "document.$args{form}.title.value='reports';\n";
#        $outstr .= ($userpriv) ? "document.$args{form}.title.value='home';\n" : "document.$args{form}.title.value='browse';\n";
        $outstr .= "document.$args{form}.sessionid.value='$sessionID';\n";
        $outstr .= "submitFormStatus('title_bar','none');\n";
        my ($PEdateTime, $dateTime, $daysRemaining) = &getPasswordExpiration(dbh => $args{dbh}, schema => $args{schema}, userID => $userid);
        if ($dateTime lt $PEdateTime) {
            $outstr .= "submitFormHeader('header','header');\n";
            $outstr .= "submitFormStatus('title_bar','none');\n";
            if ($daysRemaining < $SYSPasswordExpireWarn) {
                my $expMessage = "in $daysRemaining day" . (($daysRemaining != 1) ? "s" : "");
                if ($daysRemaining == 0) {$expMessage = "today";}
                $outstr .= "alert('Your password will expire $expMessage!\\n Please change it.');\n";
            }
            $outstr .= "submitFormStatus('title_bar','none');\n";
            $outstr .= "submitForm('browse','');\n";
#            $outstr .= ($userpriv) ? "submitForm('home','');\n" : "submitForm('reports','');\n";
#            $outstr .= ($userpriv) ? "submitForm('home','');\n" : "submitForm('browse','');\n";
        } 
        else { # must change password
            $outstr .= "alert('Your password has expired!\\n Please change it.');\n";
            $outstr .= "document.$args{form}.passwordflag.value='T';\n";
            $outstr .= "submitForm('users','changepasswordform');\n";
        }
        $outstr .= "document.location = 'blank.pl';\n";
        $outstr .= "//--></script>\n";
    }
    return($outstr);
}

###############
1; #return true
