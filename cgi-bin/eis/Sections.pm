#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/eis/perl/RCS/Sections.pm,v $
#
# $Revision: 1.5 $
#
# $Date: 1999/11/25 01:47:38 $
#
# $Author: mccartym $
#
# $Locker:  $
#
# $Log: Sections.pm,v $
# Revision 1.5  1999/11/25 01:47:38  mccartym
# add second parameter to &sectionHeadTags() for call to enable all form elements
#
# Revision 1.4  1999/11/04 19:40:58  mccartym
# add ability to lock sections open
#
# Revision 1.3  1999/08/02 02:54:18  mccartym
# rewrite
#
#

package Sections;
use strict;
use Tie::IxHash;
use vars qw(@ISA @EXPORT);
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(&sectionIsActive &sectionIsOpen &sectionImageTag &sectionHeadTags &sectionBodyTags &setupSections);
use CRD_Header qw(:Constants);
use DB_Utilities_Lib qw(:Functions);

$| = 1;

tie my %sections, "Tie::IxHash"; 

# Returns true if the section is selected, false otherwise.  Parameter is section identifier.
sub sectionIsActive {
   return (${$sections{$_[0]}}{'active'});
}

# Returns true if the section is open, false otherwise.  Parameter is section identifier.
sub sectionIsOpen {
   return (${$sections{$_[0]}}{'open'});
}

# Generates the html image tag for the section.  Parameter is section identifier.
sub sectionImageTag {
   my $image = (${$sections{$_[0]}}{'open'}) ? 'arrow_open' : 'arrow_close';
   $image = 'dot' if (${$sections{$_[0]}}{'locked'});
   my $map = (${$sections{$_[0]}}{'locked'}) ? '' : "usemap=#${$sections{$_[0]}}{'position'}"; 
   return("<img src=$CRDImagePath/$image.gif width=17 height=17 border=0 $map>");
}

# Generates the necessary head tags.  Call just before writing the head close tag.  Parameter is form name.
sub sectionHeadTags {
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

# Generates the necessary body tags.  Call after writing body tag but before writing form end tag.
sub sectionBodyTags {
   my $output;
   foreach my $ref (values (%sections)) {
      $output .= "<map name=$$ref{'position'}><area shape=rect coords=0,0,16,16 href=javascript:redraw($$ref{'position'})></map>\n" if $$ref{'active'};
   }
   $output .= "<input type=hidden name=arrowPressed value=0>\n";
   return ($output);
}

#  Initialize the configuration settings in the section hash based on user privileges and defaults.  Then get the configuration 
#  value from the PAGE_SECTION_CONFIGURATION table for this user/script.  If it exists, parse individual section open/closed
#  settings from the configuration value and store them in the hash.  If the script was invoked due to an arrow button press, modify
#  the settings accordingly, construct the corresponding configuration value, and update the PAGE_SECTION_CONFIGURATION table.
sub setupSections {
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
      $$ref{'active'} = (does_user_have_priv($dbh, $schema, $userid, @{$$ref{'privilege'}}) && $$ref{'enabled'}) ? 1 : 0;
      $$ref{'open'} = ($$ref{'active'} && ($$ref{'locked'} || $$ref{'defaultOpen'})) ? 1 : 0;
      $$ref{'position'} = $position++;
   }
   my @row = $dbh->selectrow_array ("select configuration from $schema.page_section_configuration where userid = $userid and scriptname = '$scriptName' and pagenum = $pageNum");
   if (defined ($row[0])) {
      foreach my $ref (values (%sections)) {
         $$ref{'open'} = ($$ref{'locked'} || ($row[0] & (2 ** ($$ref{'position'} - 1)))) ? 1 : 0;
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

1;
