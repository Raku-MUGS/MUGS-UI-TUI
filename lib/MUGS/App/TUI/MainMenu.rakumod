# ABSTRACT: Main Menu UI

use MUGS::UI::TUI::Layout::PrimaryMenu;
use MUGS::UI::TUI::Logo;
use MUGS::App::TUI::SettingsMenu;


sub main-menu-items() {
    my constant @menu =
        {
            id      => 'network',
            title   => 'Network Play',
            hotkeys => < n N >,
            hint    => 'Join a network server and play worldwide',
        },
        {
            id      => 'local',
            title   => 'Local Play',
            hotkeys => < l L >,
            hint    => 'Play locally in solo, turns, or multi-controller modes',
        },
        {
            id      => 'settings',
            title   => 'Settings',
            hotkeys => < s S >,
            hint    => 'Configure settings and preferences',
        },
        {
            id      => 'help',
            title   => 'HELP!',
            hotkeys => < h H ? ¿ ; >,
            hint    => 'View documentation and other help info',
        },
        {
            id      => 'exit',
            title   => 'Exit MUGS',
            hotkeys => < e E q Q x X Escape Ctrl-C Ctrl-D >,
            hint    => 'Disconnect from all games and servers and quit MUGS',
        };
}


#| Main menu with logo above menu items
class MainMenu does MUGS::UI::TUI::Layout::PrimaryMenu {
    has Str:D $.grid-name   = 'main-menu';
    has Str:D $.breadcrumb  = 'Main';
    has Str:D $.breadcrumbs = '';  # Intentional override to silence
    has Str:D $.title       = 'Main Menu | MUGS';
    has       $.items       =  main-menu-items;
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
