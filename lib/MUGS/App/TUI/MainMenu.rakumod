# ABSTRACT: Main Menu UI

use Text::MiscUtils::Emojify;
use Terminal::Capabilities;
use Terminal::Widgets::I18N::Translation;

use MUGS::UI::TUI::Logo;
use MUGS::UI::TUI::Layout::PrimaryMenu;
use MUGS::App::TUI::SettingsMenu;


sub main-menu-items() {
    ¢'main-menu';

    # XXXX: Translation of hotkeys
    my @menu =
        {
            id      =>  'local',
            title   => ¿'Local Play',
            hint    => ¿'Play locally in solo, turns, or multi-controller modes',
            hotkeys => < l L >,
        },
        {
            id      =>  'network',
            title   => ¿'Network Play',
            hint    => ¿'Join a network server and play worldwide',
            hotkeys => < n N >,
        },
        {
            id      =>  'settings',
            title   => ¿'Settings',
            hint    => ¿'Configure settings and preferences',
            hotkeys => < s S >,
        },
        {
            id      =>  'help',
            title   => ¿'HELP!',
            hint    => ¿'View documentation and other help info',
            hotkeys => < h H ? ¿ ; >,
        },
        {
            id      =>  'exit',
            title   => ¿'Exit MUGS',
            hint    => ¿'Disconnect from all games and servers and quit MUGS',
            hotkeys => < e E q Q x X Escape Ctrl-C Ctrl-D >,
        };
}

sub main-menu-icons(Terminal::Capabilities:D $caps) {
    my constant %icons =
        ASCII => {
            local    => '.',
            network  => '@',
            settings => '*',
            help     => '?',
            exit     => "\x3c",  # ^
        },
        WGL4R => {
            local    => '•',
            network  => '↔',
            settings => '*',
            help     => '?',
            exit     => '▲',  # ←
        },
        WGL4 => {
            local    => '•',
            network  => '↔',
            settings => '*',
            help     => '?',
            exit     => '◄',
        },
        Uni1 => {
            local    => '◎',  # • (BULLET)  ⌨ (KEYBOARD)
            network  => '⇄',  # ┯┷  ¤  ‡  ↔  ⇋  ⇌
            settings => '✔',  # ☑ ☒ ✓ ↕
            help     => '?',
            exit     => '◀',
        },
        Uni7 => {
            local    => emojify('💻'),  # 🞋
            network  => emojify('🖧'),
            settings => emojify('⚙'),
            help     => emojify('❓'),  # ⁇
            exit     => emojify('⬅'),  # 🡄
        },
    ;

    $caps.best-symbol-choice(%icons)
}


#| Main menu with logo above menu items
class MainMenu does MUGS::UI::TUI::Layout::PrimaryMenu {
    has Str:D $.grid-name   = 'main-menu';
    has Str:D $.breadcrumbs = '';  # Intentional override to silence
    has       $.breadcrumb  = 'main-menu' ¢¿ 'Main';
    has       $.title       = 'main-menu' ¢¿ 'Main Menu | MUGS';
    has       $.items       =  main-menu-items;
    has       $.icons       =  main-menu-icons(self.terminal.caps);
    has       $.logo-text   =  mugs-logo(self.terminal.caps);

    #| Define initial layout for header section of menu page
    method menu-header-layout($builder, $max-width, $max-height) {
        # Space above height-minimized logo
        with $builder {
            .node(),
            .plain-text(id => 'logo', text => $.logo-text,
                        style => %( :minimize-h, ))
        }
    }

    #| Process menu selections
    method process-selection($menu) {
        with $menu.items[$menu.selected] {
            given .<id> {
                when 'network'  { }
                when 'local'    { }
                when 'settings' { self.goto-submenu('settings-menu', SettingsMenu) }
                when 'help'     { self.goto-help }
                when 'exit'     { $.terminal.quit }
            }
        }
    }
}
