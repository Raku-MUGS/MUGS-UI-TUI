# ABSTRACT: Settings Menu UI

use Terminal::Widgets::I18N::Translation;

use MUGS::UI::TUI::Layout::PrimaryMenu;
use MUGS::App::TUI::A11yMenu;
use MUGS::App::TUI::TerminalMenu;
use MUGS::App::TUI::UIPrefsMenu;


sub settings-menu-items() {
    ¢'settings-menu';

    # XXXX: Translation of hotkeys
    my @menu =
        {
            id      =>  'a11y',
            title   => ¿'Accessibility',
            hint    => ¿'Configure accessibility features and assistive technologies',
            hotkeys => < a A >,
        },
        {
            id      =>  'ui-prefs',
            title   => ¿'UI Preferences',
            hint    => ¿'Adjust UI preferences such as locale, themes, and animation',
            hotkeys => < u U >,
        },
        {
            id      =>  'terminal',
            title   => ¿'Terminal',
            hint    => ¿'Adjust terminal settings such as standards and font support',
            hotkeys => < t T >,
        },
        {
            id      =>  'help',
            title   => ¿'HELP!',
            hint    => ¿'View help info related to settings',
            hotkeys => < h H ? ¿ ; >,
        },
        {
            id      =>  'back',
            title   => ¿'Back to Main Menu',
            hint    => ¿'Return to top level main menu',
            hotkeys => < b B m M CursorLeft Escape Ctrl-C >,
        };
}


#| Settings menu
class SettingsMenu does MUGS::UI::TUI::Layout::PrimaryMenu {
    has Str:D $.icon-name  = 'settings';
    has Str:D $.grid-name  = 'settings-menu';
    has       $.breadcrumb = 'settings-menu' ¢¿ 'Settings';
    has       $.title      = 'settings-menu' ¢¿ 'Settings Menu | MUGS';
    has       $.items      =  settings-menu-items;

    #| Process menu selections
    method process-selection($menu) {
        with $menu.items[$menu.selected] {
            given .<id> {
                when 'a11y'     { self.goto-screen('a11y-menu',     A11yMenu)     }
                when 'ui-prefs' { self.goto-screen('ui-prefs-menu', UIPrefsMenu)  }
                when 'terminal' { self.goto-screen('terminal-menu', TerminalMenu) }
                when 'help'     { self.goto-help }
                when 'back'     { self.goto-prev-screen }
            }
        }
    }
}
