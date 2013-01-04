#!/usr/local/bin/perl
#
# $Source: /home/atchleyb/rcs/mms/perl/RCS/text_labels.pl,v $
# $Revision: 1.1 $
# $Date: 2003/11/12 20:42:06 $
# $Author: atchleyb $
# $Locker:  $
# $Log: text_labels.pl,v $
# Revision 1.1  2003/11/12 20:42:06  atchleyb
# Initial revision
#
#
#

use strict;
use GD;
use CGI;

#calculated variables
use vars qw(@colors);
use vars qw(%colorhash);

# set AutoFlush for buffers.
$| = 1;

# init_colors specifies 22 colors for use in the PNG output file.
# It also returns a hash of colors that can be used in the code.
sub init_colors
  {
  my %args = (image => '',
              @_);

  # test for valid parameter.  If the parameter is not valid we cannot proceed so we die.
  if ( (!defined($args{"image"})) || ($args{"image"} eq '') ) {die ("image was not passed so initialization cannot be done\n")};

  my $trans     = $args{"image"}->colorAllocate(0xFF, 0xFF, 0xFC);
  my $white     = $args{"image"}->colorAllocate(0xFF, 0xFF, 0xFF);
  my $black     = $args{"image"}->colorAllocate(0x00, 0x00, 0x00);
  my $blue      = $args{"image"}->colorAllocate(0x00, 0x00, 0x99);
  my $red       = $args{"image"}->colorAllocate(0xFF, 0x99, 0x99);
  my $green     = $args{"image"}->colorAllocate(0x00, 0xFF, 0x00);
  my $magenta   = $args{"image"}->colorAllocate(0xFF, 0x66, 0xFF);
  my $turquoise = $args{"image"}->colorAllocate(0xCC, 0xFF, 0xFF);
  my $tan       = $args{"image"}->colorAllocate(0xFF, 0xCC, 0x99);
  my $grey      = $args{"image"}->colorAllocate(0xCC, 0xCC, 0xCC);
  my $yellow    = $args{"image"}->colorAllocate(0xFF, 0xFF, 0x00);
  my $orchid    = $args{"image"}->colorAllocate(0xFF, 0x93, 0xFF);
  my $orange    = $args{"image"}->colorAllocate(0xFF, 0x6F, 0x00);
  my $cyan      = $args{"image"}->colorAllocate(0x00, 0xFF, 0xFF);
  my $ltgreen   = $args{"image"}->colorAllocate(0x6F, 0xFF, 0x6F);
  my $ltred     = $args{"image"}->colorAllocate(0xFF, 0x6F, 0x6F);
  my $ltwood    = $args{"image"}->colorAllocate(0xE9, 0xC2, 0xA6);
  my $gldnrod   = $args{"image"}->colorAllocate(0xDB, 0xDB, 0x70);
  my $firebrick = $args{"image"}->colorAllocate(0x8E, 0x23, 0x23);
  my $limegreen = $args{"image"}->colorAllocate(0x32, 0xCD, 0x32);
  my $neonblue  = $args{"image"}->colorAllocate(0x4D, 0x4D, 0xFF);
  my $mdorchid  = $args{"image"}->colorAllocate(0x93, 0x70, 0xDB);

  my %returnhash = (white => $white, black => $black, blue => $blue, red => $red, green => $green,
                    magenta => $magenta, turquoise => $turquoise, tan => $tan, grey => $grey,
                    yellow => $yellow, orchid => $orchid, orange => $orange, cyan => $cyan,
                    ltgreen => $ltgreen, ltred => $ltred, ltwood => $ltwood, gldnrod => $gldnrod, 
                    firebrick => $firebrick, limegreen => $limegreen, neonblue => $neonblue, 
                    mdorchid => $mdorchid, trans => $trans);
  return (%returnhash);
  };

# Build Text adds the text to the image.
sub build_text {
  my %args = (image => '',
              width => 450,
              height => 25,
              font => 'TimesNewRoman',
              size => 18,
              text => '',
              color => 'black',
              @_);

  # test to see if required parameters have been passed.
  if ( (!defined($args{image})) || ($args{image} eq '') ) {die ("Image was not passed so we cannot build the label\n")};
  
  my $testimage = new GD::Image($args{width}+20, $args{height}+20);
  
  #$args{"image"}->string($args{font}, $x, 2, $args{text}, $colorhash{$args{color}});
  
  my $fontpath = "/usr/openwin/lib/X11/fonts/TrueType";
  my $fontname = "$fontpath/$args{font}.ttf";
  
  #my @bounds = $testimage->stringTTF($colorhash{$args{color}}, $fontname, $args{size}, 0, 2, 17, $args{text});
  my @bounds = GD::Image->stringTTF($colorhash{$args{color}}, $fontname, $args{size}, 0, 2, 17, $args{text});
  my $x = ($args{width} / 2) - (($bounds[2] - $bounds[0]) / 2);
  
  @bounds = GD::Image->stringTTF($colorhash{$args{color}}, $fontname, $args{size}, 0, 2, 17, $args{text} . "Try");
  my $fontheight = ($bounds[1] - $bounds[5]) - (($bounds[1] - $bounds[5])/($args{size}));
  my $y = $fontheight +2;
  
  $args{"image"}->stringTTF($colorhash{$args{color}}, $fontname, $args{size}, 0, $x, $y, $args{text});
  

};


#############################
#    MAIN BODY OF PROGRAM   #
#############################

# declare CGI object and set up the output page header.
my $GDCgi = new CGI;
print $GDCgi->header('image/png');

# retrieve all CGI parameters
my $text = ((defined($GDCgi->param('text'))) ? $GDCgi->param('text') : "This is a test");
my $textcolor = ((defined($GDCgi->param('color'))) ? $GDCgi->param('color') : "blue");
my $textsize = ((defined($GDCgi->param('size'))) ? $GDCgi->param('size') : "16");
my $parseTitle = ((defined($GDCgi->param('parsetitle'))) ? $GDCgi->param('parsetitle') : "F");
if ($parseTitle eq 'T') {
    $text =~ s/_/ /g;
    if (!($text =~ m/[A-Z]/)) {
        $text =~ s/(\w+)/\u\L$1/g;
    }
}

# set up image parameters and declare the image object
my $imgheight = ((defined($GDCgi->param('height'))) ? $GDCgi->param('height') : 25);
my $imgwidth = ((defined($GDCgi->param('width'))) ? $GDCgi->param('width') : 450);

my $image = new GD::Image($imgwidth, $imgheight);

# set up the colors
%colorhash = init_colors(image => $image);
@colors = ($colorhash{"blue"}, $colorhash{"red"}, $colorhash{"green"}, $colorhash{"magenta"},
           $colorhash{"turquoise"}, $colorhash{"tan"}, $colorhash{"grey"}, $colorhash{"yellow"},
           $colorhash{"orchid"}, $colorhash{"orange"}, $colorhash{"cyan"}, $colorhash{"ltgreen"},
           $colorhash{"ltred"}, $colorhash{"ltwood"}, $colorhash{"gldnrod"}, $colorhash{"firebrick"}, 
           $colorhash{"limegreen"}, $colorhash{"neonblue"}, $colorhash{"mdorchid"});

# give the image a transparent background
$image->fill(0,0,$colorhash{"trans"});
#$image->fill(0,0,$colorhash{"grey"});
$image->transparent($colorhash{"trans"});

&build_text (image => $image, width => $imgwidth, height => $imgheight, font => 'TimesNewRoman-Bold', size => $textsize, color => $textcolor,
             text => $text);

print  $image->png;
