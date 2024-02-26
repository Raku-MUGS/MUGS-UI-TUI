# ABSTRACT: Basic Layouts: Primary menu page, used for top menu layers

use MUGS::UI::TUI::Layout::StandardScreen;
use MUGS::App::TUI::Icons;


#| A hint bar aware primary menu page with optional header and navigable menu items
role MUGS::UI::TUI::Layout::PrimaryMenu
does MUGS::UI::TUI::Layout::StandardScreen {

    ### Stubbed hooks for subclasses

    method menu-header-large() { self.menu-header-small }
    method process-selection($menu) { }
    method icon-name() { '' }
    method items() { Empty }


    ### Implementation methods

    #| Generate the standard small menu header for this menu
    method menu-header-small() {
        my $icon = self.icons{self.icon-name} // '';

        ("$icon " if $icon)
        ~ self.terminal.locale.translate(self.breadcrumb)
    }

    #| Return main UI icon set for given terminal capabilities
    method icons() { main-ui-icons(self.terminal.caps) }

    #| Return an array of all possible hints for this screen
    method hints() { @.items.map(*<hint> // '') }

    #| Define initial layout for header section of menu page
    method menu-header-layout($builder, $max-width, $max-height) {
        # XXXX: Turn into an enum?
        my $header-size = 'small';
        my $logo = do given $header-size {
            when 'large' { self.menu-header-large }
            when 'small' { self.menu-header-small }
            default      { '' }
        };
        return Empty unless $logo;

        # Space around height-minimized, horizontally-centered logo
        with $builder {
            .node(style => %( :minimize-h, :minimize-w ),
                  .node(),
                  .plain-text(id => 'logo', text => $logo),
                  .node(),
                 ),
            .node(),
        }
    }

    #| Define the initial content layout constraints
    method content-layout($builder, $max-width, $max-height) {
        # XXXX: Is it actually necessary to pass the menu as an argument here?
        my &process-input = { self.process-selection($_) }

        with $builder {
            .node(),

            |self.menu-header-layout($builder, $max-width, $max-height),

            .menu(id => 'menu', :@.items, :%.icons, :&process-input,
                  hint-target => 'hint',
                  color => %( focused => '', ),
                  style => %( :minimize-h, )),

            .node(),
        }
    }

    #| Focus on the first active content (the menu widget)
    method focus-on-content(Bool:D :$redraw = False) {
        self.focus-on(%.by-id<menu>, :$redraw);
    }

    #| Go to a submenu
    method goto-submenu($name, $class) {
        # XXXX: Redundant with goto-screen?
        # XXXX: Cache already-visited submenus?
        # XXXX: Generate submenus at app startup?
        my $submenu = $class.new(:$.x, :$.y, :$.z, :$.w, :$.h, :$.terminal,
                                 prev-screen => self);
        $.terminal.set-toplevel($submenu);
    }
}
