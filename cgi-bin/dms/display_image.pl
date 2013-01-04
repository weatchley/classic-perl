#!/usr/local/bin/newperl -w

# CGI for Displaying documents for the DMS
#
# $Source: /data/dev/rcs/dms/perl/RCS/display_image.pl,v $
#
# $Revision: 1.2 $
#
# $Date: 2002/06/26 14:57:11 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: display_image.pl,v $
# Revision 1.2  2002/06/26 14:57:11  atchleyb
# removed crd related code
#
# Revision 1.1  2002/03/15 19:11:55  atchleyb
# Initial revision
#
#
#
#
use strict;
#use integer;
#
$| = 1;
#
# get all required libraries and modules
use DMS_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;

# create cgi object for processing
my $dmscgi = new CGI;

# change any environment variables here
# set schema name
my $schema = $dmscgi->param("schema");

# Get username from the previous form for use later
my $username = $dmscgi->param("username");
my $userid = $dmscgi->param("userid");
&checkLogin ($username, $userid, $schema);

# tell the browser that this is an html page using the header method
print $dmscgi->header('text/html');


###################################################################################################################################
###################################################################################################################################

# output page header
print "<html>\n";
print "<head>\n";
print "<title>DMS Display Document</title>\n";
print "<!-- include external javascript code -->\n";
print "   <script src=$DMSJavaScriptPath/utilities.js></script>\n";
#print "   <script src=$DMSJavaScriptPath/widgets.js></script>\n";
print " \n";
print "<!-- declare javascript functions unique to this form -->\n";
print " \n";
print "</head>\n";
print "<body background=$DMSImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";

# set default font atributes
print "<font face=\"$DMSFontFace\" color=$DMSFontColor>\n";

my $command='';
my $attachmentid='';
my $sqlquery='';
my $csr;
my $status;
my @values;
my $filepath = $DMSFullDocPath;
my $remote_path='';
my $filename='';
my $filedata='';
my $message='';
my $urllocation='';
my @fileStats;

# Connect to the oracle database and generate an object 'handle' to the database
my $dbh = db_connect();

# set up form for whole page
print "<br><center>\n";
print "<table border=0 width=750><tr><td>\n";

# setup form for the page (use filename_form as name of form)
print "<form name=myform action=$ENV{SCRIPT_NAME} method=post>\n";
# use a hidden field to tell the next cgi what to do
print "<input type=hidden name=command value=mycommand>\n";
# use hidden fields to keep track of the user.  Populate them with the username and the userid
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";

$command = $dmscgi->param('command');
$attachmentid = $dmscgi->param('attachmentid');
if (!(defined($command))) { $command='none'; }
#if ($command eq "pdf" || $command eq "redline") {
    # get file from db and save it on the server
    $dbh->{LongReadLen} = 100000000;
    eval {
        $sqlquery = "SELECT attachmentid,decisionid,mimetype,filename,attachment FROM $schema.attachments WHERE attachmentid = $attachmentid";
        #print "<!-- $sqlquery -->\n\n";
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
    };
    if ($status && $#values >=0 && defined($values[0]) && !($@)) {
        # save read file to webserver
        my ($id,$decisionid,$mimetype,$attachmentfilename,$attachment) = @values;
        $filename = $decisionid . "-" . $attachmentfilename;
        $filedata = $attachment;
        if (open (FH2, "| ./File_Utilities.pl --command=writeFile --fullFilePath=$DMSFullDocPath/$filename --protection=0777")) {
            print FH2 $filedata;
            close (FH2);
            @fileStats = stat "$DMSFullDocPath/$filename";
            #$status = chmod 0775, "$DMSFullDocPath/$filename";
            
            # display the file
            $urllocation = "$DMSDocPath/$filename";
        } else {
            $message = errorMessage($dbh,$username,$userid,$schema,"write attachment $filename to server.",$@);
        }
    } else {
        $message = errorMessage($dbh,$username,$userid,$schema,"attachment $filename, not found in database.",$@);
    }


#}

 
#=============================================================================================================

# display any messages generated by the script
print "<script language=javascript><!--\n";
if (defined($message) && $message gt " ") {
    print doAlertBox( text => $message, includeScriptTags => 'F');
}

# send the frame to the requested url
if (defined ($urllocation) && $urllocation gt ' ') {
    # close connection to the oracle database
    db_disconnect($dbh);
    print "   var newurl ='$urllocation';\n";
    print "   var myDate = new Date();\n";
    print "   var winName = myDate.getTime();\n";
    print "   if ($fileStats[7] >= 1048576) {\n";
    print "       if (confirm('Image is " . int($fileStats[7]*100/1048576)/100.0 . "MB, do you wish to display it?')) {\n";
    print "           var newwin = window.open(\"\",winName);\n";
    print "           newwin.creator = self;\n";
    print "           newwin.location=newurl;\n";
    print "       }\n";
    print "   } else {\n";
    print "       var newwin = window.open(\"\",winName);\n";
    print "       newwin.creator = self;\n";
    print "       newwin.location=newurl;\n";
    print "   }\n";

} else {
    db_disconnect($dbh);

    print "   self.close();\n";
}
print "//--></script>\n";

#=============================================================================================================





print "</form>\n";


print "<br><br>\n";

# close table for whole page
print "</td></tr></table></center>\n";

# end font atributes for page
print "</font>\n";

# close connection to the oracle database
db_disconnect($dbh);

print $dmscgi->end_html;