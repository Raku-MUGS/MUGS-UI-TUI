# ABSTRACT: Settings Menu UI

use Text::MiscUtils::Emojify;
use Terminal::Capabilities;
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

sub settings-menu-icons(Terminal::Capabilities:D $caps) {
    my constant %icons =
        ASCII => {
            a11y     => '',
            ui-prefs => '',
            terminal => '',
            help     => '',
            back     => '',
        },
        WGL4R => {
            a11y     => '♥',
            ui-prefs => '┼',
            terminal => '□',  # ■ ⌧  ▭
            help     => '?',
            back     => '▲',  # ←
        },
        WGL4 => {
            a11y     => '☻',  # ☼ ♥
            ui-prefs => '┼',
            terminal => '□',  # ■ ⌧  ▭
            help     => '?',
            back     => '◄',
        },
        Uni1 => {
            a11y     => '☻',  # ☼ ♥ ❤
            ui-prefs => '┿',  # ┼ ┿ ╂
            terminal => '▢',  # ⌧ ▭
            help     => '?',
            back     => '◀',
        },
        Uni7 => {
            a11y     => emojify('♿'),
            ui-prefs => emojify('🎚'),
            terminal => emojify('🖵'),
            help     => emojify('❓'),  # ⁇
            back     => emojify('⬅'),  # 🡄
        },
    ;

    $caps.best-symbol-choice(%icons)
}


#| Settings menu
class SettingsMenu does MUGS::UI::TUI::Layout::PrimaryMenu {
    has Str:D $.grid-name  = 'settings-menu';
    has       $.breadcrumb = 'settings-menu' ¢¿ 'Settings';
    has       $.title      = 'settings-menu' ¢¿ 'Settings Menu | MUGS';
    has       $.items      =  settings-menu-items;
    has       $.icons      =  settings-menu-icons(self.terminal.caps);

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
