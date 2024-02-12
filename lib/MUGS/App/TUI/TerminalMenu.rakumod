# ABSTRACT: Terminal Menu UI

use MUGS::UI::TUI::Layout::PrimaryMenu;


sub terminal-menu-items() {
    my constant @menu =
        {
            id      => 'colors',
            title   => 'Colors',
            hotkeys => < c C >,
            hint    => 'Set color and attribute capabilities for this terminal',
        },
        {
            id      => 'symbols',
            title   => 'Symbols',
            hotkeys => < s S >,
            hint    => 'Set symbol set support level for this terminal',
        },
        {
            id      => 'line-drawing',
            title   => 'Line Drawing',
            hotkeys => < l L >,
            hint    => 'Set line drawing support level for this terminal',
        },
        {
            id      => 'help',
            title   => 'HELP!',
            hotkeys => < h H ? ¿ ; >,
            hint    => 'View help info related to terminal settings',
        },
        {
            id      => 'back',
            title   => 'Back to Settings Menu',
            hotkeys => < b B s S CursorLeft Escape Ctrl-C >,
            hint    => 'Return to previous menu level (settings)',
        };
}


#| Terminal settings menu
class TerminalMenu does MUGS::UI::TUI::Layout::PrimaryMenu {
    has Str:D $.grid-name  = 'terminal-menu';
    has Str:D $.breadcrumb = 'Terminal';
    has Str:D $.title      = 'Terminal Settings | MUGS';
    has       $.items      =  terminal-menu-items;

    #| Process menu selections
    method process-selection($menu) {
        with $menu.items[$menu.selected] {
            given .<id> {
                when 'colors'       { }
                when 'symbols'      { }
                when 'line-drawing' { }
                when 'help'         { self.goto-help }
                when 'back'         { self.goto-prev-screen }
            }
        }
    }
}
