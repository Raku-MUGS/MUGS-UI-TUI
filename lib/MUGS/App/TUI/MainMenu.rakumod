# ABSTRACT: Main Menu UI

use Text::MiscUtils::Layout;

use Terminal::Widgets::Events;
use Terminal::Widgets::Widget;
use Terminal::Widgets::Layout;
use Terminal::Widgets::TopLevel;
use Terminal::Widgets::TerminalCapabilities;
use Terminal::Widgets::StandardWidgetBuilder;


sub mugs-logo(Terminal::Widgets::TerminalCapabilities:D $caps) is export {
    constant $ASCII = q:to/ASCII/;
         __  __ _   _  ____ ____
        |  \/  | | | |/ ___/ ___|
        | |\/| | | | | |  _\___ \
        | |  | | |_| | |_| |___) |
        |_|  |_|\___/ \____|____/
         -----    .    __,   ._
        |o   o|  / \  / * \  | \
        |  o  | /   \ =_,  ) =--)>
        |o   o|(_,^._) /___| |_/
         -----   /_\  [____] '
        ASCII

    constant $VT100 = q:to/VT100/;
        ┌─┐  ┌─┐┌─┐ ┌─┐┌─────┐┌─────┐
        │ └┐┌┘ ││ │ │ ││ ┌───┘│ ────┤
        │ │└┘│ ││ │ │ ││ │ ┌─┐└───┐ │
        │ │  │ │└┐└─┘┌┘│ └─┘ │┌───┘ │
        └─┘  └─┘ └───┘ └─────┘└─────┘
        ┌─────┐    .    ┌──^    ┌─.
        │o   o│   / \   / * \   │  \
        │  o  │  /   \  └─/  )  ┼───)>
        │o   o│ (_,^._) ┌┴───┴┐ │  /
        └─────┘   /_\   └─────┘ └─'
        VT100

    constant $WGL4 = q:to/WGL4/;
        █▄ ▄█  █   █  ▄███▄  ▄███▄
        █▀█▀█  █   █  █   ▀  █▄▄▄
        █   █  █▄ ▄█  █  ▀█   ▀▀▀█
        █   █  ▀███▀  ▀███▀  ▀███▀
        ┌─────┐   .   ┌──^   ┌─.
        │●   ●│  / \  / • \  │  \
        │  ●  │ /   \ └─┘  ) ╪───)►
        │●   ●│(_,^._)┌/───┴┐│  /
        └─────┘  /_\  └─────┘└─´
        WGL4

    constant $Uni1 = q:to/UNI1/;
        █▄ ▄█  █   █  ▄███▄  ▄███▄
        █▀█▀█  █   █  █   ▀  █▄▄▄
        █   █  █▄ ▄█  █  ▀█   ▀▀▀█
        █   █  ▀███▀  ▀███▀  ▀███▀
        ┌─────┐   ∧   ╭──∧   ┌─.
        │●   ●│  ╱ ╲  / • ╲  │  ╲
        │  ●  │ ╱   ╲ ╰─╯  ) ╪───)►
        │●   ●│(_,^._)┌╱───┴┐│  ╱
        └─────┘  ╱_╲  └─────┘└─´
        UNI1


    my %logo = ASCII => $caps.vt100-boxes ?? $VT100 !! $ASCII,
               :$WGL4, :$Uni1;
    $caps.best-symbol-choice(%logo)
}

sub main-menu-items() is export {
    my constant @menu =
        {
            id      => 'network',
            title   => 'Network Play',
            hotkeys => < n N >,
            hint    => 'Join a network server and play worldwide',
        },
        {
            id      => 'local',
            title   => 'Local Play',
            hotkeys => < l L >,
            hint    => 'Play locally in solo, turns, or multi-controller modes',
        },
        {
            id      => 'settings',
            title   => 'Settings',
            hotkeys => < s S >,
            hint    => 'Configure settings and preferences',
        },
        {
            id      => 'help',
            title   => 'HELP!',
            hotkeys => < h H ? ¿ ; >,
            hint    => 'View documentation and other help info',
        },
        {
            id      => 'exit',
            title   => 'Exit MUGS',
            hotkeys => < e E q Q x X Escape Ctrl-C Ctrl-D >,
            hint    => 'Disconnect from all games and servers and quit MUGS',
        };
}


class StaticText is Terminal::Widgets::Widget {
    has $.text;
    has $.color = '';

    method set-text($!text) {
        self.clear-frame;
        self.draw-frame;
        self.composite(:print);
    }

    method draw-frame() {
        my @lines = $.text.lines;
        for @lines.kv -> $y, $line {
            $.grid.set-span(0, $y, $line, $.color);
        }
    }
}


# Typed Layout Widgets
class STLayout is Terminal::Widgets::Layout::Leaf {
    method default-styles(:$text = '') {
        %( min-h => $text.lines.elems,
           min-w => max 0, $text.lines.map(&duospace-width).max )
    }
}


#| Subclass of Terminal::Widgets::Layout::Builder that recognizes new node types
class LayoutBuilder is Terminal::Widgets::Layout::Builder {
    my constant Style = Terminal::Widgets::Layout::Style;
    method static-text(*@children, :$vertical, :%style, *%extra) {
        my $default    = STLayout.default-styles(|%extra);
        STLayout.new:  :@children, :$vertical, :%extra,
                       requested => Style.new(|$default, |%style) }
}


#| A main menu screen with logo, menu items, and hint bar
class MainMenu
   is Terminal::Widgets::StandardWidgetBuilder
 does Terminal::Widgets::TopLevel {
    has Str:D      $.grid-name = 'main-menu';
    has            $.items     =  main-menu-items;
    has            $.logo-text =  mugs-logo(self.terminal.caps);
    has StaticText $.logo;
    has StaticText $.hint;
    has Terminal::Widgets::Input::Menu $.menu;

    #| Compute maximum dimensions of hints
    method hint-max() {
        # Wrap each hint and ensure enough room to display any of them
        my @wrapped    = @.items.map({ text-wrap($.w, .<hint>) });
        my $hint-lines = @wrapped.map(*.elems).max;
        my $hint-width = @wrapped.map(*.map(&duospace-width)).flat.max;

        ($hint-width, $hint-lines)
    }

    #| Define the initial layout constraints
    method layout-model() {
        my ($hint-w, $hint-h) = self.hint-max;
        my &process-input = { self.process-selection($_) }

        do with LayoutBuilder.new {
            .widget(:vertical, style => %( max-w => $.w, max-h => $.h ),
                    # Centered horizontally
                    .node(
                        .node(),
                        # Same width, with spaces around if possible
                        .node(:vertical, style => %( :minimize-w, ),
                              .node(),
                              .static-text(id => 'logo', text => $.logo-text,
                                           style => %( :minimize-h, )),
                              .node(),
                              .menu(id => 'menu', :@.items, :&process-input,
                                    color => %( focused => '', ),
                                    style => %( :minimize-h, )),
                              .node(),
                             ),
                        .node(),
                    ),
                    # Full width, minimum height
                    .static-text(id => 'hint', color => 'italic',
                                 style => %( min-w => $hint-w,
                                             min-h => $hint-h,
                                             :minimize-h )),
                   )
        }
    }

    #| Refresh the layout tree based on updated info
    method updated-layout-model() {
        $.layout.update-requested(:max-w($.w), :max-h($.h));

        # Rewrap hints and ensure enough room to display them
        my ($min-w, $min-h) = self.hint-max;
        $.hint.layout.update-requested(:$min-w, :$min-h);

        $.layout
    }

    #| Build a widget for an individual layout node
    method build-node($node, $geometry) {
        # First try custom widget types, then fall back to standard library
        do given $node {
            # XXXX: Default class and build code for known layout node types?
            when STLayout {
                StaticText.new(|$geometry, |.extra)
            }
            default { Nil }
        } // callsame()
    }

    #| Lay out main menu UI subwidgets
    method build-layout() {
        # Build layout dynamically based on layout constraints from layout-model
        my $is-rebuild  = ?$.layout;
        my $layout-root = self.compute-layout;
        self.set-layout($layout-root);

        # Debug: describe computed layout
        note $layout-root.gist if $*DEBUG;

        # Actually build widgets and recalculate coordinate offsets recursively
        self.build-children($layout-root, self);
        self.recalc-coord-offsets(0, 0, 0);

        # Pull subwidgets out of generated widget tree
        $!logo = %.by-id<logo>;
        $!menu = %.by-id<menu>;
        $!hint = %.by-id<hint>;

        # Focus on the actual active menu
        self.focus-on($!menu, :!redraw);
    }

    #| Process menu selections
    method process-selection($menu) {
        with $menu.items[$menu.selected] {
            given .<id> {
                when 'network'  { }
                when 'local'    { }
                when 'settings' { }
                when 'help'     { }
                when 'exit'     { $.terminal.quit }
            }
        }
    }
}
