# ABSTRACT: UI Preferences Menu UI

use Terminal::Widgets::I18N::Translation;

use MUGS::UI::TUI::Layout::PrimaryMenu;
use MUGS::App::TUI::OptionalUI;


sub ui-prefs-menu-items() {
    ¢'ui-prefs-menu';

    # XXXX: Translation of hotkeys
    my @menu =
        {
            id      =>  'locale',
            title   => ¿'Locale',
            hint    => ¿'Tweak or override system locale settings',
            hotkeys => < l L >,
        },
        {
            id      =>  'optional-ui',
            title   => ¿'Optional Elements',
            hint    => ¿'Show or hide optional UI elements',
            hotkeys => < o O >,
        },
        {
            id      =>  'help',
            title   => ¿'HELP!',
            hint    => ¿'View help info related to UI preferences',
            hotkeys => < h H ? ¿ ; >,
        },
        {
            id      =>  'back',
            title   => ¿'Back to Settings Menu',
            hint    => ¿'Return to previous menu level (Settings)',
            hotkeys => < b B s S CursorLeft Escape Ctrl-C >,
        };
}


#| UI preferences menu
class UIPrefsMenu does MUGS::UI::TUI::Layout::PrimaryMenu {
    has Str:D $.icon-name  = 'ui-prefs';
    has Str:D $.grid-name  = 'ui-prefs-menu';
    has       $.breadcrumb = 'ui-prefs-menu' ¢¿ 'UI Preferences';
    has       $.title      = 'ui-prefs-menu' ¢¿ 'UI Preferences | MUGS';
    has       $.items      =  ui-prefs-menu-items;

    #| Process menu selections
    method process-selection($menu) {
        with $menu.items[$menu.selected] {
            given .<id> {
                when 'locale'       { }
                when 'optional-ui'  { self.goto-screen('optional-ui', OptionalUI) }
                when 'help'         { self.goto-help }
                when 'back'         { self.goto-prev-screen }
            }
        }
    }
}
