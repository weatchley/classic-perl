#
# $Source: /data/dev/rcs/mms/perl/RCS/PDF.pm,v $
#
# $Revision: 1.4 $ 
#
# $Date: 2006/01/31 23:16:56 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: PDF.pm,v $
# Revision 1.4  2006/01/31 23:16:56  atchleyb
# removed debug code that wrote to the log
#
# Revision 1.3  2005/08/18 18:35:31  atchleyb
# CR00015 - updated to allow shaded rows in headers and footers
#
# Revision 1.2  2004/12/07 18:34:55  atchleyb
# fixed minor bugs
#
# Revision 1.1  2003/11/12 20:29:39  atchleyb
# Initial revision
#
#
#
# Library of routines for interfacing with the PDFlib and generating a PDF file
#
package PDF;
use pdflib_pl;
use Image::Info qw(image_info dim html_dim);
use strict;
use Carp;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw ();

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(&new);
%EXPORT_TAGS =(
    Functions => [qw() ]
);

my $warn = $^W;
$^W = 0;
my %objHash = {
        'someValue' => "",
    };
$^W = $warn;

my $dpi = 72;
my $sizeMod = 1.3;

my %fontList;
my %paperSize;

# standard page sizes from PDFlib sec 4.9
$paperSize{'letter'} = [612,792];
$paperSize{'leagal'} = [612,1008];
$paperSize{'11x17'} = [792,1224];
$paperSize{'tabloid'} = [792,1224];

my @headers;
my @footers;
my @images;


################
sub doPageGrid {
################
    my ($self, @param) = @_;

    PDF_setlinewidth($self->{pdf}, .002);
    PDF_setfont($self->{pdf}, $self->{font}, 8.0);
    for (my $i=0; $i<=$self->{width}; $i += 10) {
        PDF_moveto($self->{pdf}, $i, 0);
        PDF_lineto($self->{pdf}, $i, $self->{height});
    }
    for (my $i=0; $i<=$self->{height}; $i += 10) {
        PDF_moveto($self->{pdf}, 0, $i);
        PDF_lineto($self->{pdf}, $self->{width}, $i);
    }
    PDF_closepath($self->{pdf});
    PDF_stroke($self->{pdf});
    for (my $i=0; $i<=$self->{width}; $i += 20) {
        PDF_set_text_pos($self->{pdf}, $i, 10);
        PDF_show($self->{pdf}, "$i");
    }
    for (my $i=0; $i<=$self->{height}; $i += 20) {
        PDF_set_text_pos($self->{pdf}, 10, $i);
        PDF_show($self->{pdf}, "$i");
    }
    
    return (1);

}


###############
sub addHeader {
###############
    my ($self, @param) = @_;
    my $warn = $^W;
    $^W = 0;
    my %args = {
        text => 'PDF Header',
        alignment => 'center',
        fontSize => $self->{fontSize},
        sameLine => 'F',
    };
    $^W = $warn;
    for (my $i=0; $i<=$#param;$i += 2) {$args{$param[$i]} = $param[$i+1];}
    
    my $i = @headers;
    
    $headers[$i]{type} = 'text';
    $headers[$i]{text} = $args{text};
    $headers[$i]{alignment} = $args{alignment};
    $headers[$i]{font} = $self->{font};
    $headers[$i]{size} = $args{fontSize};
    $headers[$i]{sameLine} = $args{sameLine};
    
    return (1);

}


##################
sub addHeaderRow {
##################
    my ($self, @param) = @_;
    my $warn = $^W;
    $^W = 0;
    my %args = {
        fontSize => $self->{fontSize},
        sameLine => 'F',
        colCount => 0,
        colWidths => 0,
        colAlign => 0,
        border => 1,
        row => "",
        rowColor => 1.0,
        fontID => $self->{font},
    };
    $^W = $warn;
    for (my $i=0; $i<=$#param;$i += 2) {$args{$param[$i]} = $param[$i+1];}
    
    my $i = @headers;
    
    $headers[$i]{type} = 'row';
    $headers[$i]{alignment} = $args{alignment};
    $headers[$i]{font} = $args{fontID};
    $headers[$i]{size} = $args{fontSize};
    $headers[$i]{sameLine} = 'F';
    $headers[$i]{border} = $args{border};
    $headers[$i]{rowColor} = $args{rowColor};
    $headers[$i]{colCount} = $args{colCount};
    for (my $j=0; $j<$args{colCount}; $j++) {
        $headers[$i]{colWidths}[$j] = $args{colWidths}[$j];
    }
    for (my $j=0; $j<$args{colCount}; $j++) {
        $headers[$i]{colAlign}[$j] = $args{colAlign}[$j];
    }
    for (my $j=0; $j<$args{colCount}; $j++) {
        $headers[$i]{row}[$j] = $args{row}[$j];
    }
    
    return (1);

}


##################
sub clearHeaders {
##################
    my ($self, @param) = @_;
    my $warn = $^W;
    $^W = 0;
    my %args = {
    };
    $^W = $warn;
    for (my $i=0; $i<=$#param;$i += 2) {$args{$param[$i]} = $param[$i+1];}
    
    @headers = ();
    
    return (1);

}


###############
sub addFooter {
###############
    my ($self, @param) = @_;
    my $warn = $^W;
    $^W = 0;
    my %args = {
        text => 'PDF Footer',
        alignment => 'center',
        fontSize => $self->{fontSize},
        sameLine => 'T',
    };
    $^W = $warn;
    for (my $i=0; $i<=$#param;$i += 2) {$args{$param[$i]} = $param[$i+1];}
    
    my $i = @footers;
    
    $footers[$i]{type} = 'text';
    $footers[$i]{text} = $args{text};
    $footers[$i]{alignment} = $args{alignment};
    $footers[$i]{font} = $self->{font};
    $footers[$i]{size} = $args{fontSize};
    $footers[$i]{sameLine} = $args{sameLine};
    
    return (1);

}


##################
sub addFooterRow {
##################
    my ($self, @param) = @_;
    my $warn = $^W;
    $^W = 0;
    my %args = {
        fontSize => $self->{fontSize},
        sameLine => 'F',
        colCount => 0,
        colWidths => 0,
        colAlign => 0,
        border => 1,
        row => "",
        rowColor => 1.0,
        fontID => $self->{font},
    };
    $^W = $warn;
    for (my $i=0; $i<=$#param;$i += 2) {$args{$param[$i]} = $param[$i+1];}
    
    my $i = @footers;
    
    $footers[$i]{type} = 'row';
    $footers[$i]{alignment} = $args{alignment};
    $footers[$i]{font} = $args{fontID};
    $footers[$i]{size} = $args{fontSize};
    $footers[$i]{sameLine} = 'F';
    $footers[$i]{border} = $args{border};
    $footers[$i]{rowColor} = $args{rowColor};
    $footers[$i]{colCount} = $args{colCount};
    for (my $j=0; $j<$args{colCount}; $j++) {
        $footers[$i]{colWidths}[$j] = $args{colWidths}[$j];
    }
    for (my $j=0; $j<$args{colCount}; $j++) {
        $footers[$i]{colAlign}[$j] = $args{colAlign}[$j];
    }
    for (my $j=0; $j<$args{colCount}; $j++) {
        $footers[$i]{row}[$j] = $args{row}[$j];
    }
    
    return (1);

}


##################
sub clearFooters {
##################
    my ($self, @param) = @_;
    my $warn = $^W;
    $^W = 0;
    my %args = {
    };
    $^W = $warn;
    for (my $i=0; $i<=$#param;$i += 2) {$args{$param[$i]} = $param[$i+1];}
    
    @footers = ();
    
    return (1);

}


################
sub _parseText {
################
    my ($self, $text) = @_;
    $text =~ s/<page>/$self->{'pageNumber'}/g;
    $text = $text;
    
    return ($text);
}


###################
sub _doPageHeader {
###################
    my ($self, @param) = @_;
    
    my $top = $self->{'lastLine'};
    
    for (my $i=0; $i<=$#headers; $i++) {
        if ($headers[$i]{type} eq 'text') {
            PDF_setfont($self->{pdf}, $headers[$i]{font}, $headers[$i]{size});
            if ($headers[$i]{sameLine} ne 'T') {
                $top = $self->{lastLine};
            }
            my $text = _parseText($self, $headers[$i]{text});
            my $height = $headers[$i]{size} * $sizeMod;
            while (0 < PDF_show_boxed($self->{pdf}, $text, $self->{left}, ($top - $height), ($self->{right} - $self->{left}), $height, $headers[$i]{alignment}, "blind") ) {
                $height += $headers[$i]{size} * $sizeMod;
            }
            my $charCount = PDF_show_boxed($self->{pdf}, $text, $self->{left}, ($top - $height), ($self->{right} - $self->{left}), $height, $headers[$i]{alignment}, "");
            if ($self->{lastLine} > ($top - $height)) {
                $self->{lastLine} = $top - $height;
            }
        } elsif ($headers[$i]{type} eq 'row') {
            PDF_setfont($self->{pdf}, $headers[$i]{font}, $headers[$i]{size});
            $self->{font} = $headers[$i]{font};
            $self->{lastLine} = tableRow($self, fontSize => $headers[$i]{size},
                  colCount => $headers[$i]{colCount}, colWidths => $headers[$i]{colWidths}, colAlign => $headers[$i]{colAlign}, row => $headers[$i]{row},
                  border => $headers[$i]{border}, rowColor => $headers[$i]{rowColor});
        } elsif ($headers[$i]{type} eq 'image') {
            PDF_place_image($self->{pdf}, $images[$headers[$i]{image}]{image}, $headers[$i]{x}, $headers[$i]{y}, $headers[$i]{scale});
        }
    
    }
    for (my $i=0; $i<=$#headers; $i++) {
        if ($headers[$i]{type} eq 'image') {
            if ($self->{lastLine} > $headers[$i]{y}) {
                $self->{lastLine} = $headers[$i]{y};
            }
        }
    }

    return ($self->{lastLine});

}


###################
sub _doPageFooter {  # needs lots of work 
###################
    my ($self, @param) = @_;
    my $warn = $^W;
    $^W = 0;
    my %args = (
    );
    $^W = $warn;
    for (my $i=0; $i<=$#param; $i += 2) {$args{$param[$i]} = $param[$i+1];}
    
    # get total size of footers
    my $footerHeight = 0;
    my $lasthight = 0;
    my $bottom = 0;
    my $footerRowHeight = 0;
    for (my $i=0; $i<=$#footers; $i++) {
        if ($footers[$i]{type} eq 'text') {
            if (($footers[$i]{size} * $sizeMod) > $footerHeight) {
                $footerHeight = ($footers[$i]{size} * $sizeMod);
            }
        } elsif ($footers[$i]{type} eq 'row') {
            PDF_setfont($self->{pdf}, $footers[$i]{font}, $footers[$i]{size});
            $self->{font} = $footers[$i]{font};
            my $rowSize = tableRowSize($self, fontSize => $footers[$i]{size},
                  colCount => $footers[$i]{colCount}, colWidths => $footers[$i]{colWidths}, colAlign => $footers[$i]{colAlign}, row => $footers[$i]{row},
                  border => $footers[$i]{border});
            $footerRowHeight += $self->{lastLine} - $rowSize;
        }
    }
    
    $bottom = $self->{pageBottom};

    my $saveLastLine = $self->{lastLine};
    my $lastLineFooter = $bottom + $footerRowHeight + $footerHeight + 30;
    
    for (my $i=0; $i<=$#footers; $i++) {
        if ($footers[$i]{type} eq 'text') {
            PDF_setfont($self->{pdf}, $footers[$i]{font}, $footers[$i]{size});
            my $text = _parseText($self, $footers[$i]{text});
            my $height = $footers[$i]{size} * $sizeMod;
            my $charCount = PDF_show_boxed($self->{pdf}, $text, $self->{left}, ($bottom + $height), ($self->{right} - $self->{left}), $height, $footers[$i]{alignment}, "");
        } elsif ($footers[$i]{type} eq 'row') {
            $self->{lastLine} = $lastLineFooter;
            PDF_setfont($self->{pdf}, $footers[$i]{font}, $footers[$i]{size});
            $self->{font} = $footers[$i]{font};
            $lastLineFooter = tableRow($self, fontSize => $footers[$i]{size},
                  colCount => $footers[$i]{colCount}, colWidths => $footers[$i]{colWidths}, colAlign => $footers[$i]{colAlign}, row => $footers[$i]{row},
                  border => $footers[$i]{border}, rowColor => $footers[$i]{rowColor});
            $self->{lastLine} = $saveLastLine;
        }
    }
    $self->{pageBottom} = $bottom + $footerRowHeight + $footerHeight;
    
    return ($self->{pageBottom});

}


##############
sub tableRow {
##############
    my ($self, @param) = @_;
    my $warn = $^W;
    $^W = 0;
    my %args = (
      colCount => 0,
      colWidths => 0,
      colAlign => 0,
      fontSize => 10.0,
      border => 1,
      rowColor => 1.0,
      row => "",
    );
    $^W = $warn;
    for (my $i=0; $i<=$#param; $i += 2) {$args{$param[$i]} = $param[$i+1];}

    my @textRow;
    my @textRowRemaining;
    my $split = 'F';
    
    my $tableWidth = 0;
    for (my $i=0; $i<$args{colCount}; $i++) {
        $tableWidth += $args{colWidths}[$i] + ($self->{cellPadding} * 2);
    }
    my $tableLeft = ($self->{width} - $tableWidth) / 2;
    my $tableRight = $tableLeft + $self->{width} + $tableWidth;
    my $colHeight = $args{fontSize} * $sizeMod;
    my $colLeft = $tableLeft;
    my $colBottom = $self->{lastLine} - $colHeight;
    
    $warn = $^W;
    $^W = 0;
    PDF_setfont($self->{pdf}, $self->{font}, $args{fontSize});
    $^W = $warn;
    
# determine column height
    for (my $i=0; $i<$args{colCount}; $i++) {
        $textRow[$i] = _parseText($self, $args{row}[$i]);
        my $remChars = PDF_show_boxed($self->{pdf}, $textRow[$i], $colLeft, $colBottom, $args{colWidths}[$i], $colHeight, $args{colAlign}[$i], "blind");
        my $prevRemChars = 0;
        while (0 < $remChars && $remChars != $prevRemChars) {
            $colHeight += $args{fontSize} * $sizeMod;
            $prevRemChars = $remChars;
            $remChars = PDF_show_boxed($self->{pdf}, $textRow[$i], $colLeft, $colBottom, $args{colWidths}[$i], $colHeight, $args{colAlign}[$i], "blind");
# handle wrapping for long strings with no white space
            if ($remChars == $prevRemChars) {
                my $len = length($textRow[$i]);
                my $j = $len - 1;
                my $temp = $textRow[$i];
                while ($j > 0 && $remChars >= $prevRemChars) {
                    $temp = $textRow[$i];
                    $temp = substr($temp, 0, $j-1) . " " . substr($temp, $j-1);
                    $remChars = PDF_show_boxed($self->{pdf}, $temp, $colLeft, $colBottom, $args{colWidths}[$i], $colHeight, $args{colAlign}[$i], "blind");
                    $j--;
                }
                $textRow[$i] = $temp;
            }
        }
        $colBottom = $self->{lastLine} - $colHeight;
    }

# check for new page
    #if (($colBottom - ($colHeight)) <= $self->{pageBottom}) {
    while (($colBottom - ($args{fontSize} * $sizeMod)) <= $self->{pageBottom}){
#
        if (($self->{lastLine} <= $self->{pageBottom}) || (($self->{lastLine} - ($args{fontSize} * $sizeMod) - $self->{pageBottom}) <= ($args{fontSize}*$sizeMod*3)) || ($colHeight <= ($args{fontSize}*$sizeMod*5))) {
            my $saveFont = $self->{font};
            my $saveFontSize = $self->{fontSize};
            newPage($self);
            $colBottom = $self->{lastLine} - $colHeight;
            $self->{font} = $saveFont;
            $self->{fontSize} = $saveFontSize;
        } else {
# split record if needed
            $colHeight = $args{fontSize} * $sizeMod;
            while (($colHeight + $args{fontSize} * $sizeMod * 2) <= ($self->{lastLine} - $self->{pageBottom})) {
                $colHeight += $args{fontSize} * $sizeMod;
            }
            $colBottom = $self->{lastLine} - $colHeight;
            for (my $i=0; $i<$args{colCount}; $i++) {
                $split = 'T';
                my $charCount = PDF_show_boxed($self->{pdf}, $textRow[$i], $colLeft, $colBottom, $args{colWidths}[$i], ($colHeight - ($args{fontSize} * $sizeMod)), $args{colAlign}[$i], "blind");
                if ($charCount > 0) {
                    $textRowRemaining[$i] = substr($textRow[$i], ($charCount * (-1)) );
                    $textRow[$i] = substr($textRow[$i], 0, (length($textRow[$i]) - $charCount) );
                } else {
                    $textRowRemaining[$i] = '';
                }
            }
        }
    }
    
# print row
    $warn = $^W;
    $^W = 0;
    PDF_setfont($self->{pdf}, $self->{font}, $args{fontSize});
    $^W = $warn;
    for (my $i=0; $i<$args{colCount}; $i++) {
        if ($args{border} != 0) {
            PDF_setlinewidth($self->{pdf}, $args{border});
#print STDERR "rowColor: $args{rowColor}\n";
            if (defined ($args{rowColor}) && $args{rowColor} < 1.0) {
                PDF_setcolor($self->{pdf}, "fill", "gray", $args{rowColor}, 0, 0, 0);
                PDF_rect($self->{pdf}, ($colLeft - $self->{cellPadding}), $colBottom, ($args{colWidths}[$i] + ($self->{cellPadding} * 2)), $colHeight);
                PDF_fill_stroke($self->{pdf});
                PDF_setcolor($self->{pdf}, "fill", "gray", 0.0, 0, 0, 0);
            } else {
                PDF_rect($self->{pdf}, ($colLeft - $self->{cellPadding}), $colBottom, ($args{colWidths}[$i] + ($self->{cellPadding} * 2)), $colHeight);
                PDF_stroke($self->{pdf});
            }
        }
        PDF_show_boxed($self->{pdf}, $textRow[$i], $colLeft, $colBottom, $args{colWidths}[$i], $colHeight, $args{colAlign}[$i], "");
        $colLeft += $args{colWidths}[$i] + ($self->{cellPadding} * 2);
    }
 
    $self->{lastLine} = $colBottom;

# print split row
    if ($split eq 'T') {
        my $saveFont = $self->{font};
        my $saveFontSize = $self->{fontSize};
        $self->{lastLine} = $self->{height};
        newPage($self);
        $self->{font} = $saveFont;
        $self->{fontSize} = $saveFontSize;
        $self->{lastLine} = tableRow($self, fontSize => $args{fontSize}, border=>$args{border},
              colCount => $args{colCount}, colWidths => $args{colWidths}, colAlign => $args{colAlign}, row => \@textRowRemaining );
    }
    
    return ($self->{lastLine});

}


##############
sub tableRowSize {
##############
    my ($self, @param) = @_;
    my $warn = $^W;
    $^W = 0;
    my %args = (
      colCount => 0,
      colWidths => 0,
      colAlign => 0,
      fontSize => 10.0,
      border => 1,
      rowColor => 1.0,
      row => "",
    );
    $^W = $warn;
    for (my $i=0; $i<=$#param; $i += 2) {$args{$param[$i]} = $param[$i+1];}

    my @textRow;
    my @textRowRemaining;
    my $split = 'F';
    
    my $tableWidth = 0;
    for (my $i=0; $i<$args{colCount}; $i++) {
        $tableWidth += $args{colWidths}[$i] + ($self->{cellPadding} * 2);
    }
    my $tableLeft = ($self->{width} - $tableWidth) / 2;
    my $tableRight = $tableLeft + $self->{width} + $tableWidth;
    my $colHeight = $args{fontSize} * $sizeMod;
    my $colLeft = $tableLeft;
    my $colBottom = $self->{lastLine} - $colHeight;
    
    $warn = $^W;
    $^W = 0;
    PDF_setfont($self->{pdf}, $self->{font}, $args{fontSize});
    $^W = $warn;
    
# determine column height
    for (my $i=0; $i<$args{colCount}; $i++) {
        $textRow[$i] = _parseText($self, $args{row}[$i]);
        my $remChars = PDF_show_boxed($self->{pdf}, $textRow[$i], $colLeft, $colBottom, $args{colWidths}[$i], $colHeight, $args{colAlign}[$i], "blind");
        my $prevRemChars = 0;
        while (0 < $remChars && $remChars != $prevRemChars) {
            $colHeight += $args{fontSize} * $sizeMod;
            $prevRemChars = $remChars;
            $remChars = PDF_show_boxed($self->{pdf}, $textRow[$i], $colLeft, $colBottom, $args{colWidths}[$i], $colHeight, $args{colAlign}[$i], "blind");
# handle wrapping for long strings with no white space
            if ($remChars == $prevRemChars) {
                my $len = length($textRow[$i]);
                my $j = $len - 1;
                my $temp = $textRow[$i];
                while ($j > 0 && $remChars >= $prevRemChars) {
                    $temp = $textRow[$i];
                    $temp = substr($temp, 0, $j-1) . " " . substr($temp, $j-1);
                    $remChars = PDF_show_boxed($self->{pdf}, $temp, $colLeft, $colBottom, $args{colWidths}[$i], $colHeight, $args{colAlign}[$i], "blind");
                    $j--;
                }
                $textRow[$i] = $temp;
            }
        }
        $colBottom = $self->{lastLine} - $colHeight;
    }

    
    return ($colBottom);

}


#############
sub setFont {
#############
    my ($self, @param) = @_;
    my $warn = $^W;
    $^W = 0;
    my %args = (
      font => "times-roman",
      size => 10.0,
    );
    $^W = $warn;
    for (my $i=0; $i<=$#param; $i += 2) {$args{$param[$i]} = $param[$i+1];}
    
    $self->{font} = $fontList{lc($args{'font'})};
    $self->{fontSize} = $args{fontSize};
    
    return ($self->{font});

}


############
sub finish {
############
    my ($self, @param) = @_;
    my $warn = $^W;
    $^W = 0;
    my %args = (
    );
    $^W = $warn;
    for (my $i=0; $i<=$#param; $i += 2) {$args{$param[$i]} = $param[$i+1];}
    
    PDF_end_page($self->{pdf});
    PDF_close($self->{pdf});
    
    my $pdfBuff = PDF_get_buffer($self->{pdf});
    
    PDF_delete($self->{pdf});

    return ($pdfBuff);

}


#############
sub newPage {
#############
    my ($self, @param) = @_;
    my $warn = $^W;
    $^W = 0;
    my %args = (
#        paperSize => 'letter',
#        orientation => 'portrait',
        cellPadding => $self->{'cellPadding'},
    );
    $^W = $warn;
    for (my $i=0; $i<=$#param;$i += 2) {$args{$param[$i]} = $param[$i+1];}
   
    if ($self->{pageNumber} > 0) {PDF_end_page($self->{pdf});}
    $self->{pageNumber}++;
    
    $self->{'paperSize'} = ((defined($args{'paperSize'})) ? $args{'paperSize'} : $self->{'paperSize'});
    $self->{'orientation'} = ((defined($args{'orientation'})) ? $args{'orientation'} : $self->{'orientation'});
    $self->{'width'} = (($self->{'orientation'} eq 'portrait') ? $paperSize{$self->{'paperSize'}}[0] : $paperSize{$self->{'paperSize'}}[1]);
    $self->{'height'} = (($self->{'orientation'} eq 'portrait') ? $paperSize{$self->{'paperSize'}}[1] : $paperSize{$self->{'paperSize'}}[0]);
    $self->{'font'} = $fontList{lc($args{'font'})};
    $self->{'cellPadding'} = $args{cellPadding};
    $self->{'reportType'} = 'table';
    $self->{'fontSize'} = ((defined($args{fontSize})) ? $args{fontSize} : $self->{'fontSize'});
    $self->{'useGrid'} = ((defined($args{useGrid})) ? $args{useGrid} : $self->{'useGrid'});
    $self->{'leftMargin'} = ((defined($args{leftMargin})) ? $args{leftMargin} : $self->{'leftMargin'});
    $self->{'rightMargin'} = ((defined($args{rightMargin})) ? $args{rightMargin} : $self->{'rightMargin'});
    $self->{'topMargin'} = ((defined($args{topMargin})) ? $args{topMargin} : $self->{'topMargin'});
    $self->{'bottomMargin'} = ((defined($args{bottomMargin})) ? $args{bottomMargin} : $self->{'bottomMargin'});
    $self->{'lastLine'} = $self->{height} - ($self->{topMargin} * $dpi);
    $self->{'left'} = 0 + ($self->{leftMargin} * $dpi);
    $self->{'right'} = $self->{width} - ($self->{rightMargin} * $dpi);
    $self->{'pageBottom'} = 0 + ($self->{bottomMargin} * $dpi);
    
    PDF_begin_page($self->{pdf}, $self->{width}, $self->{height});
    
    $self->{lastLine} = _doPageHeader($self);
    $self->{pageBottom} = _doPageFooter($self);
    if ($self->{useGrid} eq 'T') {
        doPageGrid($self);
    }

    return (1);

}


#############
sub addImage {
#############
    my ($self, @param) = @_;
    my $warn = $^W;
    $^W = 0;
    my %args = (
        type => 'jpeg',
        source => 'memory',
        fileName => '',
        data => '',
        @param,
    );
    $^W = $warn;

    my $id = @images;
    
    $images[$id]{type} = $args{imageType};
    PDF_set_parameter($self->{'pdf'}, "imagewarning", "true");
    if ($args{source} eq 'file') {
        $images[$id]{image} = PDF_open_image_file($self->{'pdf'}, $args{type}, $args{fileName}, "", 0);
    } elsif ($args{source} eq 'memory') {
        my $temp = $args{data};
        my $info = image_info(\$temp);
        my $type = (($info->{file_ext} ne 'jpg') ? $info->{file_ext} : "jpeg");
        if ($type eq "jpeg") {
            $images[$id]{image} = PDF_open_image($self->{'pdf'},$type,"memory",$args{data}, length($args{data}),
                  $info->{width},$info->{height},$info->{SamplesPerPixel},$info->{BitsPerSample}[0],"");
        } else {
            my $fileName = $ENV{REMOTE_HOST};
            my $path = "$ENV{SYSFullDocPath}/images";
            $fileName =~ s/\.//g;
            $fileName .= "-$id.$type";
            if (open (FH1, "| ./File_Utilities.pl --command=writeFile --fullFilePath=$path/$fileName --protection=0777")) {
                print FH1 $args{data};
                close (FH1);
            } else {
                die "\nCould not open output file $path/$fileName\n";
            }
            $images[$id]{image} = PDF_open_image_file($self->{'pdf'}, $type, "$path/$fileName", "", 0);
            if (open (FH1, "./File_Utilities.pl --command=deleteFile --fullFilePath=$path/$fileName |")) {
                my $tempRead = <FH1>;
                close (FH1);
            } else {
                die "\nCould not delete file $path/$fileName\n";
            }
            
        }
        #die ('Can not yet handle in memory images');
    } else {
        die "Bad image source: $args{source}\n";
    }
   

    return ($id);

}


#############
sub placeImage {
#############
    my ($self, @param) = @_;
    my $warn = $^W;
    $^W = 0;
    my %args = (
        image => -1,
        x => 0.0,
        y => 0.0,
        scale => 1.0,
        fitInPage => 'T',
        @param,
    );
    $^W = $warn;
    
    my $scaleFit = 1.0;
    if ($args{fitInPage} eq 'T') {
        # scale image if needed
        my $scaleFitX = 1.0;
        my $scaleFitY = 1.0;
        my $imageHeight = (PDF_get_value($self->{pdf}, "imageheight", $args{image}) * $args{scale});
        if ($imageHeight > ($self->{height} - ($self->{topMargin} * $dpi) - $args{y})) {
            $scaleFitY = ($self->{height} - ($self->{topMargin} * $dpi) - $args{y}) / $imageHeight;
        }
        my $imageWidth = (PDF_get_value($self->{pdf}, "imagewidth", $args{image}) * $args{scale});
        if ($imageWidth > ($self->{right} - $args{x})) {
            $scaleFitX = ($self->{right} - $args{x}) / $imageWidth;
        }
        $scaleFit = ($scaleFitX < $scaleFitY) ? $scaleFitX : $scaleFitY;
    }


    PDF_place_image($self->{pdf}, $images[$args{image}]{image}, $args{x}, $args{y}, ($args{scale} * $scaleFit));

    return (1);

}


#############
sub placeHeaderImage {
#############
    my ($self, @param) = @_;
    my $warn = $^W;
    $^W = 0;
    my %args = (
        image => -1,
        alignment => "left",
        scale => 1.0,
        xOffset => 0,
        yOffset => 0,
        @param,
    );
    $^W = $warn;
    my $i = @headers;
    
    $headers[$i]{type} = 'image';
    $headers[$i]{alignment} = $args{alignment};
    $headers[$i]{image} = $args{image};
    $headers[$i]{scale} = $args{scale};
    $headers[$i]{y} = $self->{height} - ($self->{topMargin} * $dpi) - (PDF_get_value($self->{pdf}, "imageheight", $args{image}) * $args{scale}) + $args{yOffset};
    if ($args{alignment} eq 'left') {
        $headers[$i]{x} = $self->{left} + $args{xOffset};
    } elsif ($args{alignment} eq 'right') {
        $headers[$i]{x} = $self->{right} - (PDF_get_value($self->{pdf}, "imagewidth", $args{image}) * $args{scale}) + $args{xOffset};
    } else {
        $headers[$i]{x} = ($self->{right} - $self->{left}) / 2 - ((PDF_get_value($self->{pdf}, "imagewidth", $args{image}) * $args{scale}) / 2) + $self->{left} + $args{xOffset};
    }
 
    return (1);

}


#####################
sub generateListing {
#####################
    my ($self, @param) = @_;
    my $warn = $^W;
    $^W = 0;
    my %args = (
        font => "Courier",
        fontSize => 8,
        orientation => "portrait", 
        useGrid => 'F', 
        leftMargin => .5, 
        rightMargin => .5, 
        topMargin => .5, 
        bottomMargin => .5,
        colWidth => "540",
        colAlign => "left",
        lineNumbering => 'F',
        useTable => 'T',
        addMimeHeader => 'F',
        fileName => "file.pdf",
        usePageNumbers => 'T',
    );
    $^W = $warn;
    for (my $i=0; $i<=$#param; $i += 2) {$args{$param[$i]} = $param[$i+1];}
    
    my $output = "";
    
    if ($args{addMimeHeader} eq 'T') {
        $output .= "Content-type: application/pdf\n";
        $output .= "Content-disposition: inline; filename=$args{fileName}\n\n";
    }
    $self->setup(orientation => $args{orientation}, useGrid => $args{useGrid}, leftMargin => $args{leftMargin}, 
        rightMargin => $args{rightMargin}, 
        topMargin => $args{topMargin}, bottomMargin => $args{bottomMargin},
        font => $args{font}, fontSize => $args{fontSize});
    if ($args{usePageNumbers} eq 'T') {
        $self->addFooter(fontSize => 8.0, text => "Page <page>", alignment => "center");
    }
    $self->newPage();
    my @rowList;
    my @colWidths = ($args{colWidth});
    my @colAlign = ($args{colAlign});
    my $lineCount = 1;
    if ($args{useTable} eq 'T') {
        foreach my $row (@{$args{text}}) {
            @rowList = (($args{lineNumbering} eq 'T') ? "$lineCount " : "") . $row;
            my $lastLine = $self->tableRow(fontSize => $args{fontSize},
                colCount => 1, 
                colWidths => \@colWidths, 
                colAlign => \@colAlign, 
                row => \@rowList, 
                border => 0);
            $lineCount++;
        }
    } else {
        my $text = '';
        foreach my $row (@{$args{text}}) {
            $text .= (($args{lineNumbering} eq 'T') ? "$lineCount " : "") . $row . "\n";
            $lineCount++;
        }
        @rowList = ($text);
        my $lastLine = $self->tableRow(fontSize => $args{fontSize}, colCount => 1, colWidths => \@colWidths, 
                colAlign => \@colAlign, row => \@rowList, border => 0);
    }
    $output .= $self->finish;
    
    return ($output);

}


##############
# setup object
sub setup {
###########
    my ($self, @param) = @_;
    my $warn = $^W;
    $^W = 0;
    my %args = {
        title => 'PDF Document',
        creator => 'PDFlib',
        author => 'RSIS',
        paperSize => 'letter',
        orientation => 'portrait',
        font => 'times-roman',
        cellPadding => $self->{'cellPadding'},
    };
    $^W = $warn;
    for (my $i=0; $i<=$#param;$i += 2) {$args{$param[$i]} = $param[$i+1];}

    PDF_set_info($self->{pdf}, "creator", "PDF.pm");
    PDF_set_info($self->{pdf}, "Author", "John Doe");
    PDF_set_info($self->{pdf}, "Title", "Test PDF Report");

    $self->{'title'} = $args{'title'};
    $self->{'creator'} = $args{'creator'};
    $self->{'author'} = $args{'author'};
    
    $self->{'pageNumber'} = 0;
    $self->{'paperSize'} = ((defined($args{'paperSize'})) ? $args{'paperSize'} : $self->{'paperSize'});
    $self->{'orientation'} = ((defined($args{'orientation'})) ? $args{'orientation'} : $self->{'orientation'});
    $self->{'width'} = (($self->{'orientation'} eq 'portrait') ? $paperSize{$self->{'paperSize'}}[0] : $paperSize{$self->{'paperSize'}}[1]);
    $self->{'height'} = (($self->{'orientation'} eq 'portrait') ? $paperSize{$self->{'paperSize'}}[1] : $paperSize{$self->{'paperSize'}}[0]);
    $self->{'font'} = $fontList{lc($args{'font'})};
    $self->{'cellPadding'} = $args{cellPadding};
    $self->{'reportType'} = 'table';
    $self->{'fontSize'} = 10.0;
    $self->{'useGrid'} = ((defined($args{useGrid})) ? $args{useGrid} : 'F');
    $self->{'leftMargin'} = ((defined($args{'leftMargin'})) ? $args{'leftMargin'} : $self->{'leftMargin'});
    $self->{'rightMargin'} = ((defined($args{'rightMargin'})) ? $args{'rightMargin'} : $self->{'rightMargin'});
    $self->{'topMargin'} = ((defined($args{'topMargin'})) ? $args{'topMargin'} : $self->{'topMargin'});
    $self->{'bottomMargin'} = ((defined($args{'bottomMargin'})) ? $args{'bottomMargin'} : $self->{'bottomMargin'});
    $self->{'lastLine'} = $self->{height} - ($self->{topMargin} * $dpi);
    $self->{'left'} = 0 + ($self->{leftMargin} * $dpi);
    $self->{'right'} = $self->{width} - ($self->{rightMargin} * $dpi);
    $self->{'pageBottom'} = 0 + ($self->{bottomMargin} * $dpi);
    
    #$self->{''} = '';
    
    return (1);
}


###################
# initialize object
sub _initObject {
#################
    my ($self, @param) = @_;
    
    my $p = PDF_new();
    $self->{'pdf'} = $p;
    PDF_open_file($p, "");
    
    $fontList{'cuourier'} = PDF_findfont($self->{pdf}, "Courier", "host", 0);
    $fontList{'courier-bold'} = PDF_findfont($self->{pdf}, "Courier-Bold", "host", 0);
    $fontList{'courier-oblique'} = PDF_findfont($self->{pdf}, "Courier-Oblique", "host", 0);
    $fontList{'courier-boldoblique'} = PDF_findfont($self->{pdf}, "Courier-BoldOblique", "host", 0);
    $fontList{'times-roman'} = PDF_findfont($self->{pdf}, "Times-Roman", "host", 0);
    $fontList{'times-bold'} = PDF_findfont($self->{pdf}, "Times-Bold", "host", 0);
    $fontList{'times-italic'} = PDF_findfont($self->{pdf}, "Times-Italic", "host", 0);
    $fontList{'times-boldeitalic'} = PDF_findfont($self->{pdf}, "Times-BoldItalic", "host", 0);
    $fontList{'helvetica'} = PDF_findfont($self->{pdf}, "Helvetica", "host", 0);
    $fontList{'helvetica-bold'} = PDF_findfont($self->{pdf}, "Helvetica-Bold", "host", 0);
    $fontList{'helvetica-oblique'} = PDF_findfont($self->{pdf}, "Helvetica-Oblique", "host", 0);
    $fontList{'helvetica-boldoblique'} = PDF_findfont($self->{pdf}, "Helvetica-BoldOblique", "host", 0);
    #$fontList{'symbol'} = PDF_findfont($self->{pdf}, "Symbol", "host", 0);
    #$fontList{'zapfdingbats'} = PDF_findfont($self->{pdf}, "ZapfDingbats", "host", 0);
    
    $self->{'pageNumber'} = 0;
    $self->{'paperSize'} = 'letter';
    $self->{'orientation'} = 'portrait';
    $self->{'width'} = (($self->{'orientation'} eq 'portrait') ? $paperSize{$self->{'paperSize'}}[0] : $paperSize{$self->{'paperSize'}}[1]);
    $self->{'height'} = (($self->{'orientation'} eq 'portrait') ? $paperSize{$self->{'paperSize'}}[1] : $paperSize{$self->{'paperSize'}}[0]);
    $self->{'font'} = $fontList{'times-roman'};
    $self->{'cellPadding'} = 4;
    $self->{'reportType'} = 'table';
    $self->{'fontSize'} = 10.0;
    $self->{'useGrid'} = 'F';
    $self->{'leftMargin'} = 1;
    $self->{'rightMargin'} = 1;
    $self->{'topMargin'} = 1;
    $self->{'bottomMargin'} = 1;
    $self->{'lastLine'} = $self->{height} - ($self->{topMargin} * $dpi);
    $self->{'left'} = 0 + ($self->{leftMargin} * $dpi);
    $self->{'right'} = $self->{width} - ($self->{rightMargin} * $dpi);
    $self->{'pageBottom'} = 0 + ($self->{bottomMargin} * $dpi);

    
    return $self;
}


###################
# create new object
sub new {
#########
    my $self = {};
    $self = { %objHash };
    bless $self;
    &_initObject($self);
    
    
    return $self;
}

################################
# proccess variable name methods
sub AUTOLOAD {
##############
    my $self = shift;
    my $type = ref($self) || croak "$self is not an object";
    my $name = $AUTOLOAD;
    $name =~ s/.*://; # strip fully-qualified portion
    unless (exists $self->{$name} ) {
        croak "Can't Access '$name' field in object of class $type";
    }
    if (@_) {
        return $self->{$name} = shift;
    } else {
        return $self->{$name};
    }
}

###############
sub DESTROY { }
###############

1; #return true
