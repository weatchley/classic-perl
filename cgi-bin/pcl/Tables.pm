#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/scm/perl/RCS/Tables.pm,v $
#
# $Revision: 1.3 $
#
# $Date: 2002/10/28 18:59:13 $
#
# $Author: mccartym $
#
# $Locker:  $
#
# $Log: Tables.pm,v $
# Revision 1.3  2002/10/28 18:59:13  mccartym
# Created exportable makeLink() function for constructing a URL.
# Added optional valign argument to addCol().
#
# Revision 1.2  2002/09/25 19:18:35  mccartym
# add rowspan parameter to addCol function
#
# Revision 1.1  2002/09/17 22:14:15  starkeyj
# Initial revision
#
#
#

package Tables;
use strict;
use integer;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $AUTOLOAD);
use Exporter;
@ISA = qw(Exporter);

@EXPORT = qw(
   &startTable &endTable &startRow &endRow &addSpacerRow &addCol &makeLink
);
@EXPORT_OK = qw(
   &startTable &endTable &startRow &endRow &addSpacerRow &addCol &makeLink
);
%EXPORT_TAGS = (Functions => [qw(
   &startTable &endTable &startRow &endRow &addSpacerRow &addCol &makeLink
)]);

###################################################################################################################################
sub startTable {                                                                                                                  #
###################################################################################################################################
   my %args = (
      padding => 4,
	  spacing => 0,
      border => 1,
      align => "center",
      titleBackground => "#a0e0c0", 
	  titleForeground => "#000099",
      @_,
   );
   my $padding = " cellpadding=$args{padding}";
   my $spacing = " cellspacing=$args{spacing}";
   my $border = " border=$args{border}";
   my $align = " align=$args{align}";
   my $width = ($args{width}) ? " width=$args{width}" : "";
   my $out = "<table$padding$spacing$border$align$width>\n";
   $out .= &startRow (bgColor => $args{titleBackground});
   $out .= &addCol (colspan => $args{columns}, fgColor => $args{titleForeground}, fontSize => 3, isBold => 1, value => $args{title});
   $out .= &endRow();
   return($out);
}

###################################################################################################################################
sub endTable {                                                                                                                    #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "</table>\n";
   return ($out);
}

###################################################################################################################################
sub startRow {                                                                                                                    #
###################################################################################################################################
   my %args = (
      bgColor => "#ffffff",
      @_,
   );
   my $out .= "   <tr bgcolor=$args{bgColor}>\n";
   return ($out);
}

###################################################################################################################################
sub endRow {                                                                                                                      #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "   </tr>\n";
   return ($out);
}

###################################################################################################################################
sub addSpacerRow {                                                                                                                #
###################################################################################################################################
   my %args = (
      height => 4,
      spacerBackground => "#ffffff",
      @_,
   );
   my $out = "";
   $out .= &startRow (bgColor => $args{spacerBackground});
   $out .= &addCol(height => $args{height}, colspan => $args{columns}, value => "");
   $out .= &endRow();
   return($out);
}

###################################################################################################################################
sub makeLink {                                                                                                                    #
###################################################################################################################################
   my %args = (
      prompt => "",
      @_,
   );
   my $prompt = ($args{prompt}) ? " title=\"$args{prompt}\"" : "";
   my $out = "<a href=\"$args{url}\"$prompt>$args{value}</a>";
   return ($out);
}

###################################################################################################################################
sub addCol {                                                                                                                      #
###################################################################################################################################
   my %args = (
      rowspan => 1,
      colspan => 1,
      fgColor => "#000099",
      fontSize => 2,
      isBold => 0,
      url => "",
      prompt => "",
      @_,
   );
   my $align = ($args{align}) ? " align=$args{align}" : "";
   my $valign = ($args{valign}) ? " valign=$args{valign}" : "";
   my $width = ($args{width}) ? " width=$args{width}" : "";
   my $height = ($args{height}) ? " height=$args{height}" : "";
   my $rowspan = ($args{rowspan} != 1) ? " rowspan=$args{rowspan}" : "";
   my $colspan = ($args{colspan} != 1) ? " colspan=$args{colspan}" : "";
   my $fgColor = " color=$args{fgColor}";
   my $fontSize = " size=$args{fontSize}";
   my $startBold = ($args{isBold}) ? "<b>" : "";
   my $endBold = ($args{isBold}) ? "</b>" : "";
   my $value = ($args{url}) ? &makeLink(url => $args{url}, value => $args{value}, prompt => $args{prompt}) : $args{value};
   my $out .= "      <td$rowspan$colspan$align$valign$width$height><font$fgColor$fontSize>$startBold$value$endBold</font></td>\n";
   return($out);
}

1;