#!/usr/local/bin/newperl -w
#	
# CMS sections set-up
#
# $Source: /data/dev/cirs/perl/RCS/Sections.pm,v $
# $Revision: 1.3 $
# $Date: 2001/05/11 21:50:28 $
# $Author: naydenoa $
# $Locker:  $
# $Log: Sections.pm,v $
# Revision 1.3  2001/05/11 21:50:28  naydenoa
# Removed references to privilege
#
# Revision 1.2  2000/09/28 18:21:30  naydenoa
# Functionality update -- added subs, code clean-up
#

package Sections;
use strict;
use ONCS_Header;
use ONCS_specific;
use Tie::IxHash;
use vars qw(@ISA @EXPORT);
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(&sectionIsActive 	&sectionIsOpen 
	     &sectionImageTag 	&sectionHeadTags 
	     &sectionBodyTags 	&setupSections);

$| = 1;

tie my %sections, "Tie::IxHash"; 

# Returns true if the section is selected, false otherwise.  
# Parameter is section identifier.
#####################
sub sectionIsActive {
#####################
   return (${$sections{$_[0]}}{'active'});
}

# Returns true if the section is open, false otherwise.  
# Parameter is section identifier.
###################
sub sectionIsOpen {
###################
   return (${$sections{$_[0]}}{'open'});
}

# Generates the html image tag for the section.  
# Parameter is section identifier.
#####################
sub sectionImageTag {
#####################
   my $image = (${$sections{$_[0]}}{'open'}) ? 'arrow_open' : 'arrow_close';
   $image = 'dot' if (${$sections{$_[0]}}{'locked'});
   my $map = (${$sections{$_[0]}}{'locked'}) ? '' : "usemap=#${$sections{$_[0]}}{'position'}"; 
  return("<img src=$_[1]/$image.gif width=17 height=17 border=0 $map>");
}

# Generates the necessary head tags.  Call just before writing 
# the head close tag.  Parameter is form name.
#####################
sub sectionHeadTags {
#####################
   my $output = "   <script language=javascript><!--\n";
   $output .= "      function redraw(section) {\n";
   $output .= "         document.$_[0].arrowPressed.value = section;\n";
   $output .= "         $_[1];\n" if (defined($_[1]));
   $output .= "         document.$_[0].submit();\n";
   $output .= "      }\n";
   $output .= "   //-->\n";
   $output .= "   </script>\n";
   return ($output);
}

# Generates the necessary body tags.  Call after writing body tag 
# but before writing form end tag.
#####################
sub sectionBodyTags {
#####################
   my $output;
   foreach my $ref (values (%sections)) {
      $output .= "<map name=$$ref{'position'}><area shape=rect coords=0,0,16,16 href=javascript:redraw($$ref{'position'})></map>\n" if $$ref{'active'};
   }
   $output .= "<input type=hidden name=arrowPressed value=0>\n";
   return ($output);
}

# Initialize configuration settings in section hash based on user roles and 
# defaults.  Then get configuration value from PAGE_SECTION_CONFIGURATION 
# table for this user/script. If it exists, parse individual section 
# open/closed settings from configuration value and store them in the hash.  
# If script invoked due to arrow button press, modify settings accordingly, 
# construct corresponding configuration value, update 
# PAGE_SECTION_CONFIGURATION table.
###################
sub setupSections {
###################
   $ENV{SCRIPT_NAME} =~ m%.*/(.*)$%;
   my $scriptName = $1;
   my $dbh = $_[0];
   %sections = %{$_[1]};
   my $userid = $_[2];
   my $schema = $_[3];
   my $pageNum = $_[4];
   my $arrowPressed = $_[5];
   my $position = 1;
   foreach my $ref (values (%sections)) {
      if ($$ref{'all'}) {
	  $$ref{'active'} = 1;
      }
      else {
          $$ref{'active'} = (&does_user_have_role($dbh, $schema, $userid, @{$$ref{'role'}}) && $$ref{'enabled'}) ? 1 : 0;
       }
          $$ref{'open'} = ($$ref{'active'} && ($$ref{'locked'} || $$ref{'defaultOpen'})) ? 1 : 0;
      $$ref{'position'} = $position++;
   }
   my @row = $dbh->selectrow_array ("select configuration from $schema.page_section_configuration where userid = $userid and scriptname = '$scriptName' and pagenum = $pageNum");
   if (defined ($row[0])) {
      foreach my $ref (values (%sections)) {
         $$ref{'open'} = ($row[0] & (2 ** ($$ref{'position'} - 1))) ? 1 : 0;
      }
   }
   if ($arrowPressed) {
      foreach my $ref (values (%sections)) {
         if ($$ref{'position'} == $arrowPressed) {
            $$ref{'open'} = ($$ref{'open'}) ? 0 : 1;
            last;
         }
      }
      my $config = 0;
      foreach my $ref (values (%sections)) {
         $config += 2 ** ($$ref{'position'} - 1) if ($$ref{'open'});
      }
      my $rc = (defined ($row[0]))
         ? $dbh->do ("update $schema.page_section_configuration set configuration = $config where userid = $userid and scriptname = '$scriptName' and pagenum = $pageNum")
         : $dbh->do ("insert into $schema.page_section_configuration (userid, scriptname, pagenum, configuration) values ($userid, '$scriptName', $pageNum, $config)");
   }
}

# routine to see if a user of the DB system has a specific role
#########################
sub does_user_have_role {
#########################
    my $dbh = $_[0];
    my $schema = $_[1];
    my $userid = $_[2];
    my $role = $_[3];
    my $test_role = $role;
    $test_role =~ s/-//;
    my $roletype = "number";
    if ($test_role =~ /\D/) {
        $roletype = "text";
    }
    my $status;
    my $sqlquery;
    my $sqlquery2;
    my $sqlquery3;
    my @values;
    my $rolelist = "(";
    for (my $i=3; $i<=$#_; $i++) {
        if ($roletype eq "number") {
            $rolelist .= "$_[$i], ";
        } 
    }
    chop ($rolelist);
    chop ($rolelist);
    $rolelist .= ")";
    my @rolelistarray = eval ($rolelist);
    if ($roletype eq "number") {
        $sqlquery = "SELECT distinct roleid FROM $schema.defaultcategoryrole where usersid=$userid and roleid IN $rolelist";

	$sqlquery2 ="SELECT distinct roleid FROM $schema.defaultdisciplinerole where usersid=$userid and roleid IN $rolelist";

	$sqlquery3 = "select distinct roleid from $schema.defaultsiterole WHERE (usersid =$userid) and (roleid IN $rolelist)";
    } 
    my $csr = $dbh->prepare ($sqlquery);
    $csr->execute;
    my $csr2 = $dbh->prepare ($sqlquery2);
    $csr2->execute;
    my $csr3 = $dbh->prepare ($sqlquery3);
    $csr3->execute;
    $status = 0;
    while(@values = $csr->fetchrow_array) {
        $test_role = $values[0];
        for (my $i=0; $i<=$#rolelistarray; $i++) {
            if ($roletype eq "number") {
                if ($rolelistarray[$i] == $test_role) {
                    $status = 1;
                }
            } 
        }	
    }	
    while(@values = $csr2->fetchrow_array) {
        $test_role = $values[0];
        for (my $i=0; $i<=$#rolelistarray; $i++) {
            if ($roletype eq "number") {
                if ($rolelistarray[$i] == $test_role) {
                    $status = 1;
                }
            } 
        }	
    }	
    while(@values = $csr3->fetchrow_array) {
        $test_role = $values[0];
        for (my $i=0; $i<=$#rolelistarray; $i++) {
            if ($roletype eq "number") {
                if ($rolelistarray[$i] == $test_role) {
                    $status = 1;
                }
            } 
        }	
    }	
    $csr->finish;
    $csr2 -> finish;
    $csr3 -> finish;
    return ($status);
}

1;




