# ABSTRACT: UI Preferences Menu UI

use Text::MiscUtils::Emojify;
use Terminal::Capabilities;
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

sub ui-prefs-menu-icons(Terminal::Capabilities:D $caps) {
    my constant %icons =
        ASCII => {
            locale      => '',
            optional-ui => '',
            help        => '',
            back        => '',
        },
        WGL4R => {
            locale      => '¥',  # ¥ ¿ ö
            optional-ui => '√',
            help        => '?',
            back        => '▲',  # ←
        },
        WGL4 => {
            locale      => '¥',  # ¥ ¿ ö
            optional-ui => '√',
            help        => '?',
            back        => '◄',
        },
        Uni1 => {
            locale      => '¥',  # ¥ ¿ ö
            optional-ui => '☑',
            help        => '?',
            back        => '◀',
        },
        Uni7 => {
            locale      => emojify('🌍'),
            optional-ui => emojify('☑'),   # 🗹
            help        => emojify('❓'),  # ⁇
            back        => emojify('⬅'),  # 🡄
        },
    ;

    $caps.best-symbol-choice(%icons)
}


#| UI preferences menu
class UIPrefsMenu does MUGS::UI::TUI::Layout::PrimaryMenu {
    has Str:D $.grid-name  = 'ui-prefs-menu';
    has       $.breadcrumb = 'ui-prefs-menu' ¢¿ 'UI Preferences';
    has       $.title      = 'ui-prefs-menu' ¢¿ 'UI Preferences | MUGS';
    has       $.items      =  ui-prefs-menu-items;
    has       $.icons      =  ui-prefs-menu-icons(self.terminal.caps);

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
