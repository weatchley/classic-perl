#
# Text Menus file
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
#
#
#
package Text_Menus;
use strict;
use Carp;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw ();

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(&new &addMenu &addItem &buildMenus);
%EXPORT_TAGS =(
    Functions => [qw() ]
);

my $warn = $^W;
$^W = 0;
my %objHash = {
        'menuList' => [],
    };
$^W = $warn;

###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
# Initialze menu system
sub _menuInitialize {
###################################################################################################################################
    my ($self, $menuName, $type) = @_;
    my $outputstring = "";
    $outputstring .= "<script language=\"javascript\">\n";
    $outputstring .= "<!--\n";
    $outputstring .= "var " . $menuName . "menuList = new Array();\n";
    for (my $i = 0; $i <= $#{ $self->{menuList} }; $i++) {
        my $name = $self->{menuList}[$i]{name};
        $outputstring .= $menuName . "menuList[$i] = '$name';\n";
    }
    $outputstring .= "function showHide" . $menuName . "Menu(what,canHide) {\n";
    $outputstring .= "  if (arguments.length != 2) {canHide = 'T'}\n";
    $outputstring .= "  if (what.style.display=='none') {\n";
    $outputstring .= "      for (var i =0; i< " . $menuName . "menuList.length; i++) {\n";
    $outputstring .= "          eval(" . $menuName . "menuList[i] + \"MenuOutline.style.display='none'\");\n";
    $outputstring .= "      }\n";
    $outputstring .= "      what.style.display='';\n";
    #if ($type eq 'tabs') {
    #    $outputstring .= "      showHide" . $menuName . "TabUnderline(what);\n";
    #}
    $outputstring .= "  } else {\n";
    $outputstring .= "      if (canHide == 'T') {\n";
    $outputstring .= "          what.style.display='none';\n";
    $outputstring .= "      }\n";
    $outputstring .= "  }\n";
    $outputstring .= "}\n";
    #if ($type eq 'tabs') {
    #    $outputstring .= "function showHide" . $menuName . "TabUnderline(what) {\n";
    #    $outputstring .= "  var testName = '';\n";
    #    $outputstring .= "  for (var i =0; i< " . $menuName . "menuList.length; i++) {\n";
    #    $outputstring .= "      testName = 'document.' + " . $menuName . "menuList[i] + 'TabBottom';\n";
    #    $outputstring .= "      eval(testName + \".src='" . $self->{imageSource} . $self->{tabBottom} . "'\");\n";
    #    $outputstring .= "  }\n";
    #    $outputstring .= "  what.src='" . $self->{imageSource} . $self->{tabBottomLight} . "';\n";
    #    $outputstring .= "}\n";
    #}
    $outputstring .= "-->\n";
    $outputstring .= "</script>\n";
    
    return ($outputstring);

}

###################################################################################################################################
# Add menu
sub addMenu {
###################################################################################################################################
    my ($self, @param) = @_;
    my $warn = $^W;
    $^W = 0;
    my %args = {
        status => 'closed',
        contents => ' ',
        title => ' ',
    };
    $^W = $warn;
    for (my $i=0; $i<=$#param;$i += 2) {$args{$param[$i]} = $param[$i+1];}
    $args{status} = ((defined($args{status})) ? $args{status} : "");
    $args{title} = ((defined($args{title})) ? $args{title} : "");
    
    push @{ $self->{menuList} }, { name => $args{name}, label => $args{label}, status => $args{status}, contents => $args{contents}, title => $args{title} };
print "<!-- add menu:  $args{name},$args{label}, $args{status}, $args{title} -->\n";
}

###################################################################################################################################
# Build Menus
sub buildMenus {
###################################################################################################################################
    my ($self, @p) = @_;
    my $warn = $^W;
    $^W = 0;
    my %args = {
        type => 'table',
        name => 'MyMenu',
        linkStyle => 'none',
    };
    $args{linkStyle} = ((defined($args{linkStyle})) ? $args{linkStyle} : 'none'); # should not have to do this
    $^W = $warn;
    for (my $i=0; $i<=$#p;$i += 2) {$args{$p[$i]} = $p[$i+1];}
print "<!-- build Menu: $args{name}, $args{type} -->\n";
    
    my $menuName = $args{name};
    print "<a name=$menuName></a>";
  
    my $outputstring = "";
    $outputstring .= _menuInitialize($self,$menuName,$args{type});
    if ($args{type} eq 'table') {
# Table Menu
        $outputstring .= "<table border=0 align=center cellspacing=10><tr>\n";
        for (my $i = 0; $i <= $#{ $self->{menuList} }; $i++) {
            my $name = $self->{menuList}[$i]{name};
            my $label = $self->{menuList}[$i]{label};
            my $prompt = "Click here to for $label";
            if (substr($self->{menuList}[$i]{contents},0,11) ne 'javascript:') {
                $outputstring .= "<td align=center vaglin=bottom><a href=\"javascript:showHide" . $menuName . "Menu(" . $name . "MenuOutline);\" style=\"text-decoration:$args{linkStyle}\" title='$prompt'><b>" . $label . "</b></a></td>\n";
            } else {
                $outputstring .= "<td align=center vaglin=bottom><a href=\"javascript:showHide" . $menuName . "Menu(" . $name . "MenuOutline);" . substr($self->{menuList}[$i]{contents},11) . "\" style=\"text-decoration:$args{linkStyle}\" title='$prompt'><b>" . $label . "</b></a></td>\n";
            }
        }
        $outputstring .= "</tr></table>\n";
    } elsif ($args{type} eq 'tabs') {
# Tabs Menu
        $outputstring .= "<table border=0 align=center cellpadding=0 cellspacing=0><tr><td colspan=3 align=center>\n";
        $outputstring .= "<table border=0 align=center cellpadding=0 cellspacing=0><tr>\n";
        my $last = $#{ $self->{menuList} };
        my $count = 0;
        for (my $i = 0; $i <= $#{ $self->{menuList} }; $i++) {
            my $name = $self->{menuList}[$i]{name};
            my $label = $self->{menuList}[$i]{label};
            if ($count >= 5) {
                $count = 0;
                $outputstring .= "</tr><tr>\n";
            }
            $count++;
            my $prompt = "Click here to for $label";
            if ($self->{imageSource} gt ' ') {
                if (substr($self->{menuList}[$i]{contents},0,11) ne 'javascript:') {
                    $outputstring .= "<td align=center vaglin=bottom><table cellpadding=0 cellspacing=0 border=0><tr><td width=7><img src='" . $self->{imageSource} . $self->{tabLeftLight} . "'></td><td bgcolor=" . $self->{'tabLightColor'} . " width=136 align=center><a href=\"javascript:showHide" . $menuName . "Menu(" . $name . "MenuOutline,'F');//showHide" . $menuName . "TabUnderline(" . $name ."tabbottom);\" id=\"$name" . "Link\" style=\"text-decoration:$args{linkStyle}\" title='$prompt'><b><font size=-1>" . $label . "</font></b></a></td><td width=7><img src='" . $self->{imageSource} . $self->{tabRightLight} . "'></td></tr><tr><td colspan=3><img src='" . $self->{imageSource} . $self->{tabBottom} . "' id='" . $name ."TabBottom' name='" . $name ."TabBottom'></td></tr></table></td>\n";
                } else {
                    $outputstring .= "<td align=center vaglin=bottom><table cellpadding=0 cellspacing=0 border=0><tr><td width=7><img src='" . $self->{imageSource} . $self->{tabLeftLight} . "'></td><td bgcolor=" . $self->{'tabLightColor'} . " width=136 align=center><a href=\"javascript:showHide" . $menuName . "Menu(" . $name . "MenuOutline,'F');//showHide" . $menuName . "TabUnderline(" . $name ."tabbottom);" . substr($self->{menuList}[$i]{contents},11) . "\" id=\"$name" . "Link\" style=\"text-decoration:$args{linkStyle}\" title='$prompt'><b><font size=-1>" . $label . "</font></b></a></td><td width=7><img src='" . $self->{imageSource} . $self->{tabRightLight} . "'></td></tr><tr><td colspan=3><img src='" . $self->{imageSource} . $self->{tabBottom} . "' id='" . $name ."TabBottom' name='" . $name ."TabBottom'></td></tr></table></td>\n";
                }
            } else {
                if (substr($self->{menuList}[$i]{contents},0,11) ne 'javascript:') {
                    $outputstring .= "<td align=center><a href=\"javascript:showHide" . $menuName . "Menu(" . $name . "MenuOutline);\" id=\"$name" . "Link\" style=\"text-decoration:$args{linkStyle}\" title='$prompt'><b>" . $label . "</b></a></td>\n";
                } else {
                    $outputstring .= "<td align=center><a href=\"javascript:showHide" . $menuName . "Menu(" . $name . "MenuOutline);" . substr($self->{menuList}[$i]{contents},11) . "\" id=\"$name" . "Link\" style=\"text-decoration:$args{linkStyle}\" title='$prompt'><b>" . $label . "</b></a></td>\n";
                }
                if ($i != $last) {
                    $outputstring .= "<td>";
                    foreach my $j (1 .. 10) {$outputstring .= "&nbsp;";}
                    $outputstring .= "</td>\n";
                }
            }
        }
        for (my $i = $count; $i<5; $i++) {
            if ($self->{imageSource} gt ' ') {
                #$outputstring .= "<td align=center vaglin=bottom><table cellpadding=0 cellspacing=0 border=0><tr><td width=7><img src='" . $self->{imageSource} . $self->{tabLeftLight} . "'></td><td bgcolor=" . $self->{'tabLightColor'} . " width=136 align=center>&nbsp;</td><td width=7><img src='" . $self->{imageSource} . $self->{tabRightLight} . "'></td></tr><tr><td colspan=3><img src='" . $self->{imageSource} . $self->{tabBottom} . "'></td></tr></table></td>\n";
                $outputstring .= "<td align=center vaglin=bottom><img src='" . $self->{imageSource} . $self->{tabInactive} . "'></td></td>\n";
            #} else {
            #        $outputstring .= "<td align=center>&nbsp;</td>\n";
            }
        }
        $outputstring .= "</tr></table>\n";
        $outputstring .= "</td></tr><tr><td bgcolor=" . $self->{'tabLightColor'} . " rowspan=2><img src='" . $self->{imageSource} . "black.gif' width=1 height=100%></td><td bgcolor=" . $self->{'tabLightColor'} . " align=center>\n";
    } elsif ($args{type} eq 'list') {
# List Menu
        $outputstring .= "<table border=0 align=center cellpadding=10><tr><td align=center>\n";
        my $last = $#{ $self->{menuList} };
        for (my $i = 0; $i <= $last; $i++) {
            my $name = $self->{menuList}[$i]{name};
            my $label = $self->{menuList}[$i]{label};
            $label =~ s/ /&nbsp;/g;
#print STDERR "Text_Menus - menuName: $menuName, name: $name, label: $label, linkStyle: $args{linkStyle}\n";
            my $prompt = "Click here for $label";
            if (substr($self->{menuList}[$i]{contents},0,11) ne 'javascript:') {
                $outputstring .= "<a href=\"javascript:showHide" . $menuName . "Menu(" . $name . "MenuOutline);\" style=\"text-decoration:$args{linkStyle}\" title='$prompt'><b>" . $label . "</b></a>\n";
            } else {
                $outputstring .= "<a href=\"javascript:showHide" . $menuName . "Menu(" . $name . "MenuOutline);" . substr($self->{menuList}[$i]{contents},11) . "\" style=\"text-decoration:$args{linkStyle}\" title='$prompt'><b>" . $label . "</b></a>\n";
            }
            if ($i != $last) {
                foreach my $j (1 .. 10) {$outputstring .= "&nbsp;";}
            }
        }
        $outputstring .= "</td></tr></table>\n";
    } elsif ($args{type} eq 'buttons') {
# Buttons Menu
        $outputstring .= "<table border=0 align=center width=100%><tr><td align=center>\n";
        for (my $i = 0; $i <= $#{ $self->{menuList} }; $i++) {
            my $name = $self->{menuList}[$i]{name};
            my $label = $self->{menuList}[$i]{label};
            if (substr($self->{menuList}[$i]{contents},0,11) ne 'javascript:') {
                $outputstring .= "<input type=button onClick=\"showHide" . $menuName . "Menu(" . $name . "MenuOutline);\" name=$name value=\"" . $label . "\">\n";
            } else {
                $outputstring .= "<input type=button onClick=\"showHide" . $menuName . "Menu(" . $name . "MenuOutline);" . substr($self->{menuList}[$i]{contents},11) . "\" name=$name value=\"" . $label . "\">\n";
            }
        }
        $outputstring .= "</td></tr></table>\n";
    } elsif ($args{type} eq 'bullets') {
# Bullets Menu
        $outputstring .= "<table border=0><tr><td valign=top>\n";
        $outputstring .= "<ul>\n";
        my $size=0;
        my $newColumn = 'F';
        $size = $#{ $self->{menuList} } + 1;
        if ($size > 3) {
            $newColumn = 'T';
        }
        my $count = 0;
        for (my $i = 0; $i <= $#{ $self->{menuList} }; $i++) {
            my $name = $self->{menuList}[$i]{name};
            my $label = $self->{menuList}[$i]{label};
            $count++;
            if ($newColumn eq 'T' && $count > ($size/2 + 0.5)) {
                $outputstring .= "</ul></td><td valign=top><ul>\n";
                $newColumn = 'F';
            }
            my $prompt = "Click here to for $label";
            if (substr($self->{menuList}[$i]{contents},0,11) ne 'javascript:') {
                $outputstring .= "<li><a href=\"javascript:showHide" . $menuName . "Menu(" . $name . "MenuOutline);\" title='$prompt'>" . $self->{menuList}[$i]{label} . "</a><br>\n";
            } else {
                $outputstring .= "<li><a href=\"javascript:showHide" . $menuName . "Menu(" . $name . "MenuOutline);" . substr($self->{menuList}[$i]{contents},11) . "\" title='$prompt'>" . $self->{menuList}[$i]{label} . "</a><br>\n";
            }
        }
        
        $outputstring .= "</ul>\n";
        $outputstring .= "</td></tr></table>\n";
        
    }

#
    for (my $i = 0; $i <= $#{ $self->{menuList} }; $i++) {
        $outputstring .= "<div id=\"" . $self->{menuList}[$i]{name} . "MenuOutline\" style=\"display:'none'\">\n";
        if ($self->{menuList}[$i]{title} gt ' ') {
            $outputstring .= "<center><font size=+1><b>" . $self->{menuList}[$i]{title} . "</b></font></center><br>\n";
        }
        if (substr($self->{menuList}[$i]{contents},0,11) ne 'javascript:') {
            $outputstring .= $self->{menuList}[$i]{contents};
        } else {
            #$outputstring .= "&nbsp;\n";
        }
        $outputstring .= "</div>\n";
    }
    
    $outputstring .= "<div id=\"emptySectionFor$menuName\" style=\"display:'none'\">\n";
    $outputstring .= "&nbsp;\n";
    $outputstring .= "</div>\n";
    if ($args{type} eq 'tabs') {
        $outputstring .= "</td><td bgcolor=" . $self->{'tabLightColor'} . " rowspan=2>&nbsp;</td></tr>\n";
        $outputstring .= "<tr><td bgcolor=" . $self->{'tabLightColor'} . ">&nbsp;</td></tr>";
        $outputstring .= "<tr><td colspan=3>";
        foreach my $i (1..5) {
            $outputstring .= "<img src='" . $self->{imageSource} . $self->{tabBottom} . "'>"
        }
        $outputstring .= "</td></table>\n";
    }
  
    for (my $i = 0; $i <= $#{ $self->{menuList} }; $i++) {
        if ($self->{menuList}[$i]{status} eq 'open') {
            $outputstring .= "<script language=\"javascript\">\n<!--\nshowHide" . $menuName . "Menu(" . $self->{menuList}[$i]{name} . "MenuOutline);\n-->\n</script>\n";
        }
    }

    return ($outputstring);
}

###################################################################################################################################
# initialize object
sub _initObject {
###################################################################################################################################
    my $self = shift;
    $self->{'imageSource'} = '';
    $self->{'tabBottom'} = 'tab_bottom.gif';
    $self->{'tabBottomLight'} = 'tab_bottom_light.gif';
    $self->{'tabLeftLight'} = 'tab_left_light.gif';
    $self->{'tabRightLight'} = 'tab_right_light.gif';
    $self->{'tabLightColor'} = 'c8ffc8';
    $self->{'tabInactive'} = 'tabinactive.gif';
    return $self;
}

###################################################################################################################################
# create new object
sub new {
###################################################################################################################################
    my $type = shift;
    my $self = {};
    $self = { %objHash };
    bless $self, $type;
    &_initObject($self);
    return $self;
}

###################################################################################################################################
# proccess variable name methods
sub AUTOLOAD {
###################################################################################################################################
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

sub DESTROY { }

1; #return true
