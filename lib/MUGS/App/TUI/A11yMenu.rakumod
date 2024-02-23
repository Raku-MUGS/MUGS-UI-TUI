# ABSTRACT: Accessibility Menu UI

use Text::MiscUtils::Emojify;
use Terminal::Capabilities;
use Terminal::Widgets::I18N::Translation;

use MUGS::UI::TUI::Layout::PrimaryMenu;


sub a11y-menu-items() {
    ¢'a11y-menu';

    # XXXX: Translation of hotkeys
    my @menu =
        {
            id      =>  'help',
            title   => ¿'HELP!',
            hint    => ¿'View help info related to accessibility settings',
            hotkeys => < h H ? ¿ ; >,
        },
        {
            id      =>  'back',
            title   => ¿'Back to Settings Menu',
            hint    => ¿'Return to previous menu level (Settings)',
            hotkeys => < b B s S CursorLeft Escape Ctrl-C >,
        };
}

sub a11y-menu-icons(Terminal::Capabilities:D $caps) {
    my constant %icons =
        ASCII => {
            help     => '',
            back     => '',
        },
        WGL4R => {
            help     => '?',
            back     => '▲',  # ←
        },
        WGL4 => {
            help     => '?',
            back     => '◄',
        },
        Uni1 => {
            help     => '?',
            back     => '◀',
        },
        Uni7 => {
            help     => emojify('❓'),  # ⁇
            back     => emojify('⬅'),  # 🡄
        },
    ;

    $caps.best-symbol-choice(%icons)
}


#| Accessibility menu
class A11yMenu does MUGS::UI::TUI::Layout::PrimaryMenu {
    has Str:D $.grid-name  = 'a11y-menu';
    has       $.breadcrumb = 'a11y-menu' ¢¿ 'Accessibility';
    has       $.title      = 'a11y-menu' ¢¿ 'Accessibility | MUGS';
    has       $.items      =  a11y-menu-items;
    has       $.icons      =  a11y-menu-icons(self.terminal.caps);

    #| Process menu selections
    method process-selection($menu) {
        with $menu.items[$menu.selected] {
            given .<id> {
                when 'help'         { self.goto-help }
                when 'back'         { self.goto-prev-screen }
            }
        }
    }
}
