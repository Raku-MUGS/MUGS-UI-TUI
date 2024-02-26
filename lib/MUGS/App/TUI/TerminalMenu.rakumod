# ABSTRACT: Terminal Menu UI

use Terminal::Widgets::I18N::Translation;

use MUGS::UI::TUI::Layout::PrimaryMenu;


sub terminal-menu-items() {
    ¢'terminal-menu';

    # XXXX: Translation of hotkeys
    my @menu =
        {
            id      =>  'colors',
            title   => ¿'Color Support',
            hint    => ¿'Set color and attribute capabilities for this terminal',
            hotkeys => < c C >,
        },
        {
            id      =>  'symbols',
            title   => ¿'Symbol Support',
            hint    => ¿'Set symbol set support level for this terminal',
            hotkeys => < s S >,
        },
        {
            id      =>  'line-drawing',
            title   => ¿'Line Drawing Support',
            hint    => ¿'Set line drawing support level for this terminal',
            hotkeys => < l L >,
        },
        {
            id      =>  'help',
            title   => ¿'HELP!',
            hint    => ¿'View help info related to terminal settings',
            hotkeys => < h H ? ¿ ; >,
        },
        {
            id      =>  'back',
            title   => ¿'Back to Settings Menu',
            hint    => ¿'Return to previous menu level (Settings)',
            hotkeys => < b B s S CursorLeft Escape Ctrl-C >,
        };
}


#| Terminal settings menu
class TerminalMenu does MUGS::UI::TUI::Layout::PrimaryMenu {
    has Str:D $.icon-name  = 'terminal';
    has Str:D $.grid-name  = 'terminal-menu';
    has       $.breadcrumb = 'terminal-menu' ¢¿ 'Terminal';
    has       $.title      = 'terminal-menu' ¢¿ 'Terminal Settings | MUGS';
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
