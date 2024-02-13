# ABSTRACT: Settings Menu UI

use MUGS::UI::TUI::Layout::PrimaryMenu;
use MUGS::App::TUI::A11yMenu;
use MUGS::App::TUI::TerminalMenu;
use MUGS::App::TUI::UIPrefsMenu;


sub settings-menu-items() {
    my constant @menu =
        {
            id      => 'a11y',
            title   => 'Accessibility',
            hotkeys => < a A >,
            hint    => 'Configure accessibility features and assistive technologies',
        },
        {
            id      => 'ui-prefs',
            title   => 'UI Preferences',
            hotkeys => < u U >,
            hint    => 'Adjust UI preferences such as locale, themes, and animation',
        },
        {
            id      => 'terminal',
            title   => 'Terminal',
            hotkeys => < t T >,
            hint    => 'Adjust terminal settings such as standards and font support',
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
        };
}


#| Settings menu
class SettingsMenu does MUGS::UI::TUI::Layout::PrimaryMenu {
    has Str:D $.grid-name  = 'settings-menu';
    has Str:D $.breadcrumb = 'Settings';
    has Str:D $.title      = 'Settings Menu | MUGS';
    has       $.items      =  settings-menu-items;

    #| Process menu selections
    method process-selection($menu) {
        with $menu.items[$menu.selected] {
            given .<id> {
                when 'a11y'     { self.goto-submenu('a11y-menu',     A11yMenu)     }
                when 'ui-prefs' { self.goto-submenu('ui-prefs-menu', UIPrefsMenu)  }
                when 'terminal' { self.goto-submenu('terminal-menu', TerminalMenu) }
                when 'help'     { self.goto-help }
                when 'back'     { self.goto-prev-screen }
            }
        }
    }
}
