# ABSTRACT: Settings Menu UI

use MUGS::UI::TUI::Layout::PrimaryMenu;


sub settings-menu-items() {
    my constant @menu =
        {
            id      => 'terminal',
            title   => 'Terminal',
            hotkeys => < t T >,
            hint    => 'Adjust terminal settings and preferences',
        },
        {
            id      => 'help',
            title   => 'HELP!',
            hotkeys => < h H ? ¿ ; >,
            hint    => 'View help info related to settings',
        },
        {
            id      => 'back',
            title   => 'Back to Main Menu',
            hotkeys => < b B m M CursorLeft Escape Ctrl-C >,
            hint    => 'Return to top level main menu',
        },
    ;
}


#| Settings menu
# XXXX: Factor out submenu functionality?
class SettingsMenu does MUGS::UI::TUI::Layout::PrimaryMenu {
    has Str:D $.grid-name = 'settings-menu';
    has Str:D $.title     = 'Settings Menu | MUGS';
    has       $.items     =  settings-menu-items;
    has       $.prev-screen is required;

    # XXXX: Multicolor
    # XXXX: Factor out as separate mini-widget
    # XXXX: Clickable 'Main'?
    has Str:D $.breadcrumbs = 'Main > Settings';


    #| Process menu selections
    method process-selection($menu) {
        with $menu.items[$menu.selected] {
            given .<id> {
                when 'terminal' { }
                when 'help'     { }
                when 'back'     { $.terminal.set-toplevel($.prev-screen) }
            }
        }
    }
}
