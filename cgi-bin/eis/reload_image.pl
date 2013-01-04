#!/usr/local/bin/newperl -w

# reload an image into the CRD
#
# $Source$
#
# $Revision$
#
# $Date$
#
# $Author$
#
# $Locker$
#
# $Log$
#
#
use strict;
use integer;
use CRD_Header qw(:Constants);
use CGI;
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);

my $crdcgi = new CGI;
my $username = $crdcgi->param("username");
my $userid = $crdcgi->param("userid");
my $schema = $crdcgi->param("schema");
# Set server parameter
my $Server = $crdcgi->param("server");
if (!(defined($Server))) {$Server=$CRDServer;}

&checkLogin($username,$userid,$schema);

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $command = defined($crdcgi->param("command")) ? $crdcgi->param("command") : "";
my $message;
my $instructionsColor = $CRDFontColor;
my $title = "Reload CRD Image";
#if ($command eq "view_errors") {
#   $title = "Error Log";
#} elsif ($command eq "view_activity") {
#   $title = "Activity Log";
#} elsif ($command eq "reset_commentsentered") {
#   $title = "Reopen Document for Comment Entry";
#}
my $dbh = db_connect();

print $crdcgi->header('text/html');
print <<end;
<html>
<head>
   <meta http-equiv=expires content=now>
   <script src=$CRDJavaScriptPath/utilities.js></script>
   <script src=$CRDJavaScriptPath/widgets.js></script>
   <script language=javascript><!--
      function submitForm(script, command) {
         document.$form.command.value = command;
         document.$form.action = '$path' + script + '.pl';
         document.$form.submit();
      }

      function submitFormMain(script, command) {
          document.$form.target = 'main';
         document.$form.command.value = command;
         document.$form.action = '$path' + script + '.pl';
         document.$form.submit();
      }

      function submitFormCGIResults(script, command) {
          var old_command = document.$form.command.value;
          var old_action = document.$form.action;
          var old_target = document.$form.target;
          document.$form.command.value = command;
          document.$form.action = '$path' + script + '.pl';
          document.$form.target = 'cgiresults';
          document.$form.submit();
          document.$form.command.value = old_command;
          document.$form.action = old_action;
          document.$form.target = old_target;
      }
      
      function display_user(id) {
         document.$form.id.value = id;
         submitForm('user_functions', 'displayuser');
      }
//-->
</script>
end
print "\n</head>\n";
print "<body background=$CRDImagePath/background.gif text=$CRDFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => $title);
print "<font face=$CRDFontFace color=$CRDFontColor>\n";
print "<br><center>\n";
print "<table border=0 width=750><tr><td>\n";
print "<form name=$form method=post onSubmit=false>\n";
print "<input type=hidden name=command value=$command>\n";
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=server value=$Server>\n";
print "<input type=hidden name=id value=0>\n";
print "<center>\n";

if ($command eq 'reload_image') {
    # reload bracketed image file from file server ---------------------------------------------------------------------------------------------
    eval {
        my $documentid = ((defined($crdcgi->param(documentid))) ? $crdcgi->param(documentid) : '');
        my $id = ((defined($crdcgi->param('id'))) ? $crdcgi->param('id') : -1);
        
        if ($document eq '' || !($document =~ /\S/)) {
            $document = '';
        } elsif ($document gt '' && $document =~ /\D/) {
            print "<script language=javascript><!--\n";
            print "   alert('Only positive numbers my be entered.');\n";
            print "//--></script>\n";
            $document = '';
        } elsif ($document gt '' && $document > 0) {
            my $sqlcode = '';
            my $csr;
            my @values;
            my $status;
            
            print "\n\n<!-- $command - Document ID $document -->\n\n";
            
            $sqlcode = "SELECT count(*) FROM $schema.document WHERE id = $document";
            @values = $dbh->selectrow_array($sqlcode);
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"reload CRD image.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$message');\n";
        print "//--></script>\n";
    }
}
print "</center>\n</form>\n</td></tr></table></center>\n</font>\n";
print $crdcgi->end_html;
&db_disconnect($dbh);
exit();
