# ABSTRACT: Main Menu UI

use Terminal::Widgets::I18N::Translation;

use MUGS::UI::TUI::Logo;
use MUGS::UI::TUI::Layout::PrimaryMenu;
use MUGS::App::TUI::SettingsMenu;
use MUGS::App::TUI::AvailableGames;


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


#| Main menu with logo above menu items
class MainMenu does MUGS::UI::TUI::Layout::PrimaryMenu {
    has Str:D $.grid-name   = 'main-menu';
    has Str:D $.breadcrumbs = '';  # Intentional override to silence
    has       $.breadcrumb  = 'main-menu' ¢¿ 'Main';
    has       $.title       = 'main-menu' ¢¿ 'Main Menu | MUGS';
    has       $.items       =  main-menu-items;

    # Menu header variants
    method menu-header-large() { mugs-logo(self.terminal.caps) }
    method menu-header-small() { mugs-logo-small(self.terminal.caps) }

    #| Process menu selections
    method process-selection($menu) {
        with $menu.items[$menu.selected] {
            given .<id> {
                when 'local'    { self.goto-screen('available-games', AvailableGames) }
                when 'network'  { }
                when 'settings' { self.goto-submenu('settings-menu', SettingsMenu) }
                when 'help'     { self.goto-help }
                when 'exit'     { $.terminal.quit }
            }
        }
    }
}
