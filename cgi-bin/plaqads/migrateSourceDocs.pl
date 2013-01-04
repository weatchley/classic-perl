#!/usr/local/bin/perl -w

# Migrate Source Documents
#
# $Source: /data/dev/rcs/plaqads/perl/RCS/migrateSourceDocs.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2004/08/10 15:26:31 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: migrateSourceDocs.pl,v $
# Revision 1.1  2004/08/10 15:26:31  atchleyb
# Initial revision
#
#
#
#
#
#

$| = 1;

use strict;
#use integer;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UI_Widgets qw(:Functions);
use UIShared qw(:Functions);
use DBD::Oracle qw(:ora_types);
use CGI;

my $mycgi = new CGI;


$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $dbh;
$dbh = &db_connect();
my %settings = getInitialValues(dbh => $dbh);

my $schema = $settings{schema};
my $command = $settings{command};
my $username = $settings{username};
my $userid = $settings{userid};
my $title = $settings{title};
my $error = "";
#&checkLogin(cgi => $cgi);
#&checkLogin ($username, $userid, $schema);
my $errorstr = "";

#! test for invalid or timed out session
#&validateCurrentSession(dbh => $dbh, schema => $schema, userID => $userid, sessionID => $settings{sessionID});


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub getTitle {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $title = "Migrate Update";
   if ($args{command} eq "view_errors") {
      $title = "Error Log";
   } elsif ($args{command} eq "view_activity") {
      $title = "Activity Log";
   }
   return ($title);
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
       id => (defined($mycgi->param("id"))) ? $mycgi->param("id") : "",
       type => (defined($mycgi->param("type"))) ? $mycgi->param("type") : "",
       projectID => (defined($mycgi->param("projectID"))) ? $mycgi->param("projectID") : "",
       logOption => (defined($mycgi->param("logOption"))) ? $mycgi->param("logOption") : "today",
       logactivity => (defined($mycgi->param("logactivity"))) ? $mycgi->param("logactivity") : "all",
       selecteduser => (defined($mycgi->param("selecteduser"))) ? $mycgi -> param ("selecteduser") : -1,
    ));
    $valueHash{title} = &getTitle(command => $valueHash{command});
    
    return (%valueHash);
}


###################################################################################################################################
sub doHeader {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        dbh => '',
        schema => $ENV{SCHEMA},
        title => "$SYSType User Functions",
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
    function doBrowse(script) {
      	$form.command.value = 'browse';
       	$form.action = '$path' + script + '.pl';
        $form.submit();
    }
    function submitForm3(script, command, type) {
        document.$form.command.value = command;
        document.$form.type.value = type;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }


END_OF_BLOCK
    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'F', includeJSWidgets => 'F');
    
    $output .= "<input type=hidden name=type value=0>\n";
    $output .= "<input type=hidden name=project value=0>\n";
    $output .= "<input type=hidden name=projectID value=0>\n";
    #$output .= "<input type=hidden name=server value=$Server>\n";
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
sub getFileMap {  # routine to get document source map
###################################################################################################################################
    my %args = (
        @_,
    );
    my $i=0;
    my @list;
    open (FH, "</data/apps/" . lc($SYSType) . "/sourceDocMap.txt");
    while (my $in = <FH>) {
        chop $in;
        ($list[$i]{id}, $list[$i]{name}) = split("\t",$in);
        $i++;
#print "$in, ";
    }
    close FH;

    return(@list);
}




###################################################################################################################################
#
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print "<h1 align=center>Data Migration Update</h1>\n";
        print "<h2 align=center>Working</h2>\n";
        print "<h3 align=center>Using schema: $schema</h3>\n";
        
        $| = 1;
        my @list = &getFileMap();
        my $sCount = 0;
        my $fCount = 0;
        for (my $i=0; $i<$#list; $i++) {
            #print "$list[$i]{id} - $list[$i]{name}<br>\n";
            my $name = $list[$i]{name};
            $name =~ s/\s$//g;
            $name =~ s/anon\///;
            #print ".htm:" . index($name,".htm") . " .doc:" . index($name, ".doc") . " - ";
            if (index($name, ".htm") > 0 && index($name, ".doc") == -1) {
                $name .= ".doc";
            }
            if (open (FH, "</data/apps/" . lc($SYSType) . "/data/" . $name)) {
                my $sqlcode = "UPDATE $schema.document_versions SET sourcefile = ?, filename='$name' where documentid = $list[$i]{id}";
                my $val = "";
                my $rc = read(FH, $val, 100000000);
                close FH1;
                my $csr = $dbh->prepare($sqlcode);
                $csr->bind_param(1, $val, { ora_type=>ORA_BLOB, ora_field=>'sourcefile'});
                $csr->execute;
                $dbh->commit;
                close FH;
                $sCount++;
            } else {
                print "Error opening $list[$i]{id} - $list[$i]{name}<br>\n";
                #print ".htm:" . index($name,".htm") . " .doc:" . index($name, ".doc") . " - ";
                #print "$list[$i]{name}<br>\n";
                #print "$name<br>\n";
                $fCount++;
            }
        }
        print "<br>Opened: $sCount, Failed: $fCount<br>\n";
        print "<br><h2 align=center>Done</h2>\n";
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, 0, $schema, "Migration Update in $form", $@));
    }
    print &doFooter;


&db_disconnect($dbh);
exit();
