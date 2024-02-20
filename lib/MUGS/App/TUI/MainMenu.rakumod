# ABSTRACT: Main Menu UI

use Terminal::Widgets::I18N::Translation;

use MUGS::UI::TUI::Layout::PrimaryMenu;
use MUGS::UI::TUI::Logo;
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


#| Main menu with logo above menu items
class MainMenu does MUGS::UI::TUI::Layout::PrimaryMenu {
    has Str:D $.grid-name   =  'main-menu';
    has Str:D $.breadcrumbs =  '';  # Intentional override to silence
    has       $.breadcrumb  = ¿'Main';
    has       $.title       = ¿'Main Menu | MUGS';
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
