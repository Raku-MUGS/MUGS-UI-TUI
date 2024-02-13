# ABSTRACT: UI Preferences Menu UI

use MUGS::UI::TUI::Layout::PrimaryMenu;


sub ui-prefs-menu-items() {
    my constant @menu =
        {
            id      => 'locale',
            title   => 'Locale',
            hotkeys => < l L >,
            hint    => 'Tweak or override system locale settings',
        },
        {
            id      => 'optional-ui',
            title   => 'Optional Elements',
            hotkeys => < o O >,
            hint    => 'Show or hide optional UI elements',
        },
        {
            id      => 'help',
            title   => 'HELP!',
            hotkeys => < h H ? ¿ ; >,
            hint    => 'View help info related to UI preferences',
        },
        {
            id      => 'back',
            title   => 'Back to Settings Menu',
            hotkeys => < b B s S CursorLeft Escape Ctrl-C >,
            hint    => 'Return to previous menu level (Settings)',
        };
}


#| UI preferences menu
class UIPrefsMenu does MUGS::UI::TUI::Layout::PrimaryMenu {
    has Str:D $.grid-name  = 'ui-prefs-menu';
    has Str:D $.breadcrumb = 'UI Preferences';
    has Str:D $.title      = 'UI Preferences | MUGS';
    has       $.items      =  ui-prefs-menu-items;

    #| Process menu selections
    method process-selection($menu) {
        with $menu.items[$menu.selected] {
            given .<id> {
                when 'locale'       { }
                when 'optional-ui'  { }
                when 'help'         { self.goto-help }
                when 'back'         { self.goto-prev-screen }
            }
        }
    }
}
