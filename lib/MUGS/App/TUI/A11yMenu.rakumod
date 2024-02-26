# ABSTRACT: Accessibility Menu UI

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


#| Accessibility menu
class A11yMenu does MUGS::UI::TUI::Layout::PrimaryMenu {
    has Str:D $.icon-name  = 'a11y';
    has Str:D $.grid-name  = 'a11y-menu';
    has       $.breadcrumb = 'a11y-menu' ¢¿ 'Accessibility';
    has       $.title      = 'a11y-menu' ¢¿ 'Accessibility | MUGS';
    has       $.items      =  a11y-menu-items;

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
