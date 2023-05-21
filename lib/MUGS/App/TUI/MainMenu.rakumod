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

    method set-text($!text) {
        self.clear-frame;
        self.draw-frame;
        self.composite(:print);
    }

    method draw-frame() {
        my @lines = $.text.lines;
        for @lines.kv -> $y, $line {
            $.grid.set-span(0, $y, $line, '');
        }
    }
}

class SimpleMenu does Terminal::Widgets::Input {
    has UInt:D $.selected = 0;
    has        $.items;
    has        %!hotkey;

    #| Do basic input TWEAK, then compute hotkey hash and set selected hint
    submethod TWEAK() {
        self.Terminal::Widgets::Input::TWEAK;
        for $!items.kv -> $i, $item {
            %!hotkey{$_} = $i for $item<hotkeys>.words;
        }
    }

    #| Refresh the whole input
    method full-refresh(Bool:D :$print = True) {
        self.set-selected($!selected);
        my $base-color = self.current-color;
        $.grid.clear;
        for @.items.kv -> $i, $item {
            my $title     = $item<title>;
            my $extra     = max 1, $.w - duospace-width($title);
            my $formatted = " $title" ~ ' ' x $extra;
            my $color     = $i == $!selected ?? %.color<highlight> !! $base-color;
            $.grid.set-span(0, $i, $formatted, $color);
        }
        self.composite(:$print);
    }

    #| Set an item as selected
    method set-selected(Int:D $selected) {
        if 0 <= $selected <= @.items.end {
            $!selected = $selected;
            self.toplevel.hint.set-text(@.items[$!selected]<hint> // '');
        }
    }

    #| Process a select event
    method select(UInt $i?, Bool:D :$print = True) {
        if $i.defined {
            return unless 0 <= $i <= @.items.end;
            self.set-selected($i);
        }

        $!active = True;
        self.refresh-value(:$print);

        $_(self) with &.process-input;

        $!active = False;
        self.refresh-value(:$print);
    }

    #| Process a prev-item event
    method prev-item(Bool:D :$print = True) {
        self.set-selected($!selected - 1);
        self.refresh-value(:$print);
    }

    #| Process a next-item event
    method next-item(Bool:D :$print = True) {
        self.set-selected($!selected + 1);
        self.refresh-value(:$print);
    }

    #| Handle keyboard events
    multi method handle-event(Terminal::Widgets::Events::KeyboardEvent:D
                              $event where *.key.defined, AtTarget) {
        my constant %keymap =
            ' '          => 'select',
            Ctrl-M       => 'select',  # CR/Enter
            KeypadEnter  => 'select',

            CursorUp     => 'prev-item',
            CursorDown   => 'next-item',

            Ctrl-I       => 'next-input',    # Tab
            ShiftTab     => 'prev-input',    # Shift-Tab is weird and special
            ;

        my $keyname = $event.keyname;
        with %keymap{$keyname} {
            when 'select'     { self.select }
            when 'prev-item'  { self.prev-item }
            when 'next-item'  { self.next-item }
            when 'next-input' { self.focus-next-input }
            when 'prev-input' { self.focus-prev-input }
        }
        orwith %!hotkey{$keyname} {
            self.select($_)
        }
    }

    #| Handle mouse events
    multi method handle-event(Terminal::Widgets::Events::MouseEvent:D
                              $event where !*.mouse.pressed, AtTarget) {
        self.toplevel.focus-on(self);
        self.select($event.relative-to(self)[1]);
    }
}


# Typed Layout Widgets
class STLayout is Terminal::Widgets::Layout::Leaf {
    method default-styles(:$text = '') {
        %( min-h => $text.lines.elems,
           min-w => max 0, $text.lines.map(&duospace-width).max )
    }
}

class SMLayout is Terminal::Widgets::Layout::Widget {
    method default-styles(:@items) {
        %( min-h => @items.elems,
           min-w => max 0, @items.map({ duospace-width(.<title>) }).max )
    }
}


#| Subclass of Terminal::Widgets::Layout::Builder that recognizes new node types
class LayoutBuilder is Terminal::Widgets::Layout::Builder {
    my constant Style = Terminal::Widgets::Layout::Style;
    method static-text(*@children, :$vertical, :%style, *%extra) {
        my $default    = STLayout.default-styles(|%extra);
        STLayout.new:  :@children, :$vertical, :%extra,
                       requested => Style.new(|$default, |%style) }
    method simple-menu(*@children, :$vertical, :%style, *%extra) {
        my $default    = SMLayout.default-styles(|%extra);
        SMLayout.new:  :@children, :$vertical, :%extra,
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
    has SimpleMenu $.menu;
    has StaticText $.hint;

    #| Define the initial layout constraints
    method layout-model() {
        # Wrap each hint and ensure enough room to display any of them
        my $hint-lines = @.items.map({ text-wrap($.w, .<hint>).elems }).max;
        my &process-input = { self.process-selection($_) }

        do with LayoutBuilder.new {
            .widget(:vertical, style => %( max-w => $.w, max-h => $.h ),
                    .static-text(id => 'logo', text => $.logo-text),
                    .simple-menu(id => 'menu', :@.items, :&process-input),
                    # XXXX: Should be dynamic text?
                    .static-text(id => 'hint', style => %( min-h => $hint-lines, )),
                   )
        }
    }

    #| Refresh the layout tree based on updated info
    method updated-layout-model() {
        $.layout.update-requested(:max-w($.w), :max-h($.h));

        # Rewrap hints and ensure enough room to display them
        my $hint-lines = @.items.map({ text-wrap($.w, .<hint>).elems }).max;
        $.hint.layout.update-requested(:min-h($hint-lines));

        $.layout
    }

    #| Build a widget for an individual layout node
    method build-node($node, $geometry) {
        # First try custom widget types, then fall back to standard library
        do given $node {
            when STLayout {
                StaticText.new(|$geometry, |.extra)
            }
            when SMLayout {
                SimpleMenu.new(|$geometry, |.extra)
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
        # note $layout-root.gist;

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
