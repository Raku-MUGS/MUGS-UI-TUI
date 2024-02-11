# ABSTRACT: Basic Layouts: General UI screen overall layout

use Text::MiscUtils::Layout;

use Terminal::Widgets::Simple::TopLevel;


#| A general overall screen layout with header, content, and footer sections
class MUGS::UI::TUI::Layout::ThreeSectionScreen
   is Terminal::Widgets::Simple::TopLevel {

    ### Stubbed hooks for subclasses

    method screen-header-layout( $builder, $max-width, $max-height) { Empty }
    method screen-content-layout($builder, $max-width, $max-height) { Empty }
    method screen-footer-layout( $builder, $max-width, $max-height) { Empty }

    method update-screen-header-layout( $toplevel-layout) { }
    method update-screen-content-layout($toplevel-layout) { }
    method update-screen-footer-layout( $toplevel-layout) { }


    ### Implementation methods

    #| Define the initial screen layout constraints
    method initial-layout($builder, $max-width, $max-height) {
        with $builder {
            |self.screen-header-layout( $builder, $max-width, $max-height),
            |self.screen-content-layout($builder, $max-width, $max-height),
            |self.screen-footer-layout( $builder, $max-width, $max-height),
        }
    }

    #| Refresh the layout tree based on updated info
    method update-layout($toplevel-layout) {
        self.update-screen-header-layout( $toplevel-layout);
        self.update-screen-content-layout($toplevel-layout);
        self.update-screen-footer-layout( $toplevel-layout);
    }
}


#| A header containing navigation controls
role MUGS::UI::TUI::Layout::NavHeader {

    ### Required methods

    #| Format the navigational breadcrumbs for this screen
    method breadcrumbs() { ... }


    ### Implementation methods

    #| Define the initial header layout constraints
    method screen-header-layout($builder, $max-width, $max-height) {
        with $builder {
            # XXXX: Special breadcrumbs input widget?
            .plain-text(id => 'breadcrumbs', style => %( :minimize-h, ),
                        text => self.breadcrumbs),
        }
    }
}


#| A horizontally centered content area
role MUGS::UI::TUI::Layout::CenteredContent {

    ### Stubbed hooks for subclasses

    #| Define the actual content layout
    method content-layout($builder, $max-width, $max-height) { Empty }


    ### Implementation methods

    #| Define the initial content area layout constraints
    method screen-content-layout($builder, $max-width, $max-height) {
        with $builder {
            # Center horizontally
            .node(
                .node(),
                # Common width for all vertically laid out content subsections
                .node(:vertical, style => %( :minimize-w, ),
                      |self.content-layout($builder, $max-width, $max-height)),
                .node(),
            ),
        }
    }
}


#| A footer containing a hints widget
role MUGS::UI::TUI::Layout::HintFooter {

    ### Required methods

    #| Return an array of all possible hints for this screen
    method hints() { ... }


    ### Implementation methods

    #| Compute actual maximum dimensions of width-wrapped text items
    # XXXX: Cache wrapped versions?
    # XXXX: Convert to sub?  (Would need wrap width as param)
    # XXXX: Translations?
    method max-wrapped-dims(@items) {
        # Wrap each text item and ensure enough room to display any of them
        my @wrapped   = @items.map({ text-wrap($.w, $_) });
        my $max-lines = 0 max @wrapped.map(*.elems).max;
        my $max-width = 0 max @wrapped.map(*.map(&duospace-width)).flat.max;

        ($max-width, $max-lines)
    }

    #| Define the initial footer layout constraints
    method screen-footer-layout($builder, $max-width, $max-height) {
        my ($min-w, $min-h) = self.max-wrapped-dims(@.hints);

        with $builder {
            # Full width, minimum height
            # XXXX: Factor out other color and style settings
            .plain-text(id => 'hint', color => 'italic',
                        style => %( :$min-w, :$min-h, :minimize-h )),
        }
    }

    #| Refresh screen footer layout tree based on updated info
    method update-screen-footer-layout($toplevel-layout) {
        # Rewrap hints and ensure enough room to display them
        my ($min-w, $min-h) = self.max-wrapped-dims(@.hints);
        %.by-id<hint>.layout.update-requested(:$min-w, :$min-h);
    }
}


#| A standard MUGS screen with nav header, centered main content, and hint footer
role MUGS::UI::TUI::Layout::StandardScreen
  is MUGS::UI::TUI::Layout::ThreeSectionScreen
does MUGS::UI::TUI::Layout::NavHeader
does MUGS::UI::TUI::Layout::CenteredContent
does MUGS::UI::TUI::Layout::HintFooter {

    ### Required methods

    #| Focus on the first active content
    method focus-on-content(Bool:D :$redraw = False) { ... }


    ### Implementation methods

    #| Layout main subwidgets (and dividers/frames, if any)
    method build-layout() {
        # Build layout dynamically based on layout constraints from layout-model
        my $is-rebuild = callsame;

        # Focus on the content section
        self.focus-on-content;

        # Return is-rebuild for subclasses
        $is-rebuild
    }
}