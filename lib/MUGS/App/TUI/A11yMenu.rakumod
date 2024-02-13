# ABSTRACT: Accessibility Menu UI

use MUGS::UI::TUI::Layout::PrimaryMenu;


sub a11y-menu-items() {
    my constant @menu =
        {
            id      => 'help',
            title   => 'HELP!',
            hotkeys => < h H ? ¿ ; >,
            hint    => 'View help info related to accessibility settings',
        },
        {
            id      => 'back',
            title   => 'Back to Settings Menu',
            hotkeys => < b B s S CursorLeft Escape Ctrl-C >,
            hint    => 'Return to previous menu level (Settings)',
        };
}


#| Accessibility menu
class A11yMenu does MUGS::UI::TUI::Layout::PrimaryMenu {
    has Str:D $.grid-name  = 'a11y-menu';
    has Str:D $.breadcrumb = 'Accessibility';
    has Str:D $.title      = 'Accessibility | MUGS';
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
