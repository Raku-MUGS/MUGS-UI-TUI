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
    method icons() {
        my $enabled = self.terminal.ui-prefs<menu-item-icons>;
        $enabled ?? main-ui-icons(self.terminal.caps) !! {}
    }

    #| Whether to add "Back to Previous Menu" items to menu lists
    method show-back() {
        my $history-nav = self.terminal.ui-prefs<history-nav> // '';
        # $history-nav ne 'breadcrumbs-only'
        True
    }

    #| Return an array of all possible hints for this screen
    method hints() { @.items.map(*<hint> // '') }

    #| Define initial layout for header section of menu page
    method menu-header-layout($builder, $max-width, $max-height) {
        # XXXX: Turn into an enum?
        my $headers = self.terminal.ui-prefs<menu-headers>;
        my $logo = do given $headers {
            when 'large-menu-headers' { self.menu-header-large }
            when 'small-menu-headers' { self.menu-header-small }
            default                   { '' }
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

        my $use-hints = self.terminal.ui-prefs<input-field-hints>;

        with $builder {
            .node(),

            |self.menu-header-layout($builder, $max-width, $max-height),

            .menu(id => 'menu', :@.items, :%.icons, :&process-input,
                  hint-target => $use-hints ?? 'hint' !! '',
                  color => %( focused => '', ),
                  style => %( :minimize-h, )),

            .node(),
        }
    }

    #| Focus on the first active content (the menu widget)
    method focus-on-content(Bool:D :$redraw = False) {
        self.focus-on(%.by-id<menu>, :$redraw);
    }
}
