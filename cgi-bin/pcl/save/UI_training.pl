#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/scm/perl/RCS/UI_training.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2002/09/17 20:16:51 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UI_training.pl,v $
# Revision 1.1  2002/09/17 20:16:51  atchleyb
# Initial revision
#
#
#
#

use strict;
#use integer;
use SCM_Header qw(:Constants);
#use CGI qw(param);
use CGI;
use DB_scm qw(:Functions);
use Documents qw(:Functions);
use UI_Widgets qw(:Functions);
#use Tie::IxHash;
use DBI;
use DBD::Oracle qw(:ora_types);

my $scmcgi = new CGI;
my $schema = (defined($scmcgi->param("schema"))) ? $scmcgi->param("schema") : $ENV{'SCHEMA'};
#print STDERR "$schema\n";
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $command = (defined ($scmcgi -> param("command"))) ? $scmcgi -> param("command") : "browse";
my $username = (defined($scmcgi->param("username"))) ? $scmcgi->param("username") : "";
my $userid = (defined($scmcgi->param("userid"))) ? $scmcgi->param("userid") : "";
my $error = "";

#&checkLogin ($username, $userid, $schema);
my $dbh;
my $errorstr = "";

my $itemType = 12; # Training

$dbh = &db_connect();
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 10000000;

###################################################################################################################################
sub doHeader {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        title => 'Training Management',
        displayTitle => 'T',
        @_,
    );
    my $output = "";
    
    $output .= $scmcgi->header('text/html');
    $output .= "<html>\n<head>\n<title>$args{title}</title>\n";
    $output .= <<END_OF_BLOCK;
    <script language=javascript><!--
       function displayVersions(documentID) {
           $form.command.value = 'browseversion';
           $form.document.value = documentID;
           $form.action = '$path$form.pl';
           $form.target = 'main';
           $form.submit();
       }
       function displayDocument(document,major,minor) {
          var myDate = new Date();
          var winName = myDate.getTime();
          $form.command.value = 'displaydocument';
          $form.document.value = document;
          $form.majorversion.value = major;
          $form.minorversion.value = minor;
          $form.action = '$path$form.pl';
          $form.target = winName;
          var newwin = window.open('',winName);
          newwin.creator = self;
          $form.submit();
       }
       function submitFormCGIResults(script,command) {
           document.$form.command.value = command;
           document.$form.action = '$path' + script + '.pl';
           document.$form.target = 'cgiresults';
           document.$form.submit();
       }
       function submitForm(script,command) {
           document.$form.command.value = command;
           document.$form.action = '$path' + script + '.pl';
           document.$form.target = 'main';
           document.$form.submit();
       }
       function updateVersion(documentID) {
           document.$form.document.value=documentID;
           submitForm('$form','updatedocument');
       }
       function updateDocumentInfoformation(documentID) {
           document.$form.document.value=documentID;
           submitForm('$form','updateinformation');
       }
       function checkOutDocument(document,major,minor) {
          $form.document.value = document;
          $form.majorversion.value = major;
          $form.minorversion.value = minor;
          submitFormCGIResults ('$form', 'checkoutdocument');
       }
       function displayUser(id) {
          $form.id.value = id;
          submitForm ('user_functions', 'displayuser');
       }
       function isblank(s)
       {
           if (s.length == 0) return true;
           for(var i = 0; i < s.length; i++) {
               var c = s.charAt(i);
               if ((c != ' ') && (c != '\\n') && (c != '\\t') && (c !='\\r')) return false;
           }
           return true;
       }
       
       // function that returns true if a string contains only numbers
       function isnumeric(s)
       {
           if (s.length == 0) return false;
           for(var i = 0; i < s.length; i++) {
               var c = s.charAt(i);
               if ((c < '0') || (c > '9')) return false;
           }
       
           return true;
       }

       // funtion to show the properties of an object (used mostly for debuging)
       function show_props(obj, obj_name) {
                 var result = ""
                 var col = 1;
                 for (var i in obj)
                    if (i != 'innerHTML' && i != 'innerText' && i != 'outerHTML' && i != 'outerText') {
                           if (col == 1) {
                               result += obj_name + "." + i + " = " + obj[i];
                               col = col + 1;
                           } else {
                               result += "          " + obj_name + "." + i + " = " + obj[i] + "\\n<br>";
                               col = 1;
                           }
                    }
                 return result
       }

       // funtion to change the location of the main frame
       function changeMainLocation(script) {
           parent.main.location='$path' + script + '.pl?username=$username&userid=$userid&schema=$schema';
       }
    //-->
    </script>
END_OF_BLOCK
    $output .= "</head>\n";
    $output .= "<body text=#000099 background=$SCMImagePath/background.gif>\n";
    $output .=  (($args{displayTitle} eq 'T') ? &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => $args{title}) : "");
    $output .= "<form enctype=\"multipart/form-data\" name=$form method=post target=main action=$path$form.pl>\n";
    $output .= "<input type=hidden name=userid value=$userid>\n";
    $output .= "<input type=hidden name=username value=$username>\n";
    $output .= "<input type=hidden name=schema value=$schema>\n";
    $output .= "<input type=hidden name=command value=''>\n";
    $output .= "<input type=hidden name=document value=''>\n";
    $output .= "<input type=hidden name=id value=''>\n";
    $output .= "<input type=hidden name=majorversion value=''>\n";
    $output .= "<input type=hidden name=minorversion value=''>\n";
    
    return($output);
}


###################################################################################################################################
sub doFooter {  # routine to generate html page footers
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    
    $output .= "</form>\n</body>\n</html>\n";
    
    return($output);
}


###################################################################################################################################
###################################################################################################################################

###################################################################################################################################
#
if ($command eq "browse") {
    print &doHeader(title => 'Browse Training Records');
    eval {
        print &doBrowseDocumentTable(dbh => $dbh, schema => $schema, itemType => $itemType, title => 'Training Records', userID => $userid);
        print "<br><center>Under Construction</center>\n";
    };
    if ($@) {
        print doAlertBox(text => DB_scm::errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "browseversion") {
    print &doHeader(title => 'Browse Training Records');
    eval {
        print &doBrowseDocumentVersions(dbh => $dbh, schema => $schema, itemType => $itemType, document => $scmcgi->param('document'), userID => $userid);
        print "<br><center>Under Construction</center>\n";
    };
    if ($@) {
        print doAlertBox(text => DB_scm::errorMessage($dbh, $username, $userid, $schema, "Browse Version in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "displaydocument") {
    eval {
        print &doDisplayDocument(dbh => $dbh, schema => $schema, itemType => $itemType, document => $scmcgi->param('document'),
                majorVersion => $scmcgi->param('majorversion'), minorVersion => $scmcgi->param('minorversion'));
    };
    if ($@) {
        print &doHeader(displayTitle => 'F');
        print doAlertBox(text => DB_scm::errorMessage($dbh, $username, $userid, $schema, "Browse Version in $form", $@));
        print &doFooter;
    }
###################################################################################################################################
} elsif ($command eq "add") {
    print &doHeader(title => 'Add Training Record');
    eval {
        print &doAddDocumentForm(dbh => $dbh, schema => $schema, itemType => $itemType, title => 'Training Records', form => $form, userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => DB_scm::errorMessage($dbh, $username, $userid, $schema, "Add in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "addprocess") {
    print &doHeader(DisplayTitle => 'F');
    eval {
        my $fileContents = '';
        my $name = $scmcgi->param('documentfile');
        my $buffer = '';
        my $bytesread = 0;
        while ($bytesread=read($name,$buffer,16384)) {
            $fileContents .= $buffer;
        }
#print "File:\n" . length($fileContents) . "\nEnd File\n";
        print &doProcessAddDocument(dbh => $dbh, schema => $schema, itemType => $itemType, title => 'Training Records', form => $form, 
              file => $fileContents, fileName => $name, majorVersion => $scmcgi->param('major'), minorVersion => $scmcgi->param('minor'), 
              description => $scmcgi->param('description'), userID => $userid, userName => $username);
        
    };
    if ($@) {
        print doAlertBox(text => DB_scm::errorMessage($dbh, $username, $userid, $schema, "Add processing in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "update") {
    print &doHeader(title => 'Update Training Record');
    eval {
        print &doBrowseDocumentTable(dbh => $dbh, schema => $schema, itemType => $itemType, title => 'Training Records', update => 'T', userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => DB_scm::errorMessage($dbh, $username, $userid, $schema, "Update in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "updateinformation") {
    print &doHeader(title => 'Update Training Record');
    eval {
        print &doUpdateDocumentInfoForm(dbh => $dbh, schema => $schema, document => $scmcgi->param('document'), 
              title => 'Training Records', form => $form, userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => DB_scm::errorMessage($dbh, $username, $userid, $schema, "Update Information in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "updateinformationprocess") {
    print &doHeader(DisplayTitle => 'F');
    eval {
        print &doProcessUpdateDocumentInfo(dbh => $dbh, schema => $schema, document => $scmcgi->param('itemid'), 
              name => $scmcgi->param('name'), description => $scmcgi->param('description'), title => 'Training Records', form => $form, userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => DB_scm::errorMessage($dbh, $username, $userid, $schema, "Update Information processing in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "checkoutdocument") {
    print &doHeader(DisplayTitle => 'F');
    eval {
        print &doCheckOutDocument(dbh => $dbh, schema => $schema, itemType => $itemType, document => $scmcgi->param('document'),
                majorVersion => $scmcgi->param('majorversion'), minorVersion => $scmcgi->param('minorversion'), userID => $userid, form => $form);
    };
    if ($@) {
        print doAlertBox(text => DB_scm::errorMessage($dbh, $username, $userid, $schema, "Check Out Document in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "updatedocument") {
    print &doHeader(title => 'Update Training Record');
    eval {
        print &doUpdateDocumentForm(dbh => $dbh, schema => $schema, document => $scmcgi->param('document'), 
              itemType => $itemType, title => 'Training Records', form => $form, userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => DB_scm::errorMessage($dbh, $username, $userid, $schema, "Update Document in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "updatedocumentprocess") {
    print &doHeader(DisplayTitle => 'F');
    eval {
        my $fileContents = '';
        my $name = $scmcgi->param('documentfile');
        my $buffer = '';
        my $bytesread = 0;
        while ($bytesread=read($name,$buffer,16384)) {
            $fileContents .= $buffer;
        }
#print "File:\n" . length($fileContents) . "\nEnd File\n";
        print &doProcessUpdateDocument(dbh => $dbh, schema => $schema, itemID => $scmcgi->param('itemid'), title => 'Training Records', form => $form, 
              file => $fileContents, fileName => $name, majorVersion => $scmcgi->param('major'), minorVersion => $scmcgi->param('minor'), 
              description => $scmcgi->param('description'), userID => $userid, userName => $username);
        
    };
    if ($@) {
        print doAlertBox(text => DB_scm::errorMessage($dbh, $username, $userid, $schema, "Update processing in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "checkinnochange") {
    print &doHeader(DisplayTitle => 'F');
    eval {
        my $fileContents = '';
        my $name = $scmcgi->param('documentfile');
        print &doProcessCheckInNoChange(dbh => $dbh, schema => $schema, itemID => $scmcgi->param('itemid'), title => 'Training Records', form => $form, 
              userID => $userid, userName => $username);
        
    };
    if ($@) {
        print doAlertBox(text => DB_scm::errorMessage($dbh, $username, $userid, $schema, "Checkin no change processing in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} else {
    print &doHeader(title => 'Bad Command');
    print "<br><center>Command $command not known</center>\n";
    print &doFooter;
}


&db_disconnect($dbh);
exit();
