# ABSTRACT: Basic Layouts: Primary menu page, used for top menu layers

use MUGS::UI::TUI::Layout::StandardScreen;


#| A hint bar aware primary menu page with optional header and navigable menu items
role MUGS::UI::TUI::Layout::PrimaryMenu
does MUGS::UI::TUI::Layout::StandardScreen {

    ### Stubbed hooks for subclasses

    method menu-header-layout($builder, $max-width, $max-height) { Empty }
    method process-selection($menu) { }
    method items() { Empty }


    ### Implementation methods

    #| Return an array of all possible hints for this screen
    method hints() { @.items.map(*<hint> // '') }

    #| Define the initial content layout constraints
    method content-layout($builder, $max-width, $max-height) {
        # XXXX: Is it actually necessary to pass the menu as an argument here?
        my &process-input = { self.process-selection($_) }

        with $builder {
            # Vertical stack with spaces between
            |self.menu-header-layout($builder, $max-width, $max-height),
            .node(),
            .menu(id => 'menu', :@.items, :&process-input,
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
}
