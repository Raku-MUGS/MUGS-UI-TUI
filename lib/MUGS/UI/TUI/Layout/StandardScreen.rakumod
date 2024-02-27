# ABSTRACT: Basic Layouts: General UI screen overall layout

use Text::MiscUtils::Layout;

use Terminal::Widgets::Simple::TopLevel;
use Terminal::Widgets::I18N::Translation;


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
        my $history-nav = self.terminal.ui-prefs<history-nav>;
        my $use-breadcrumbs = $history-nav ne 'buttons-menus-only';

        with $builder {
            # XXXX: Special breadcrumbs input widget?
            .plain-text(id => 'breadcrumbs', style => %( :minimize-h, ),
                        text => $use-breadcrumbs ?? self.breadcrumbs !! ''),
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
        my $locale    = $.terminal.locale;
        my @wrapped   = @items.map({ text-wrap($.w, ~$locale.translate($_)) });
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
            .plain-text(id => 'hint', color => 'italic', :wrap,
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

    has MUGS::UI::TUI::Layout::StandardScreen $.prev-screen;


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

    #| Go to a help screen by topic string
    multi method goto-help(Str:D $topic) {
    }

    #| Go to a context help screen for a given screen UI object
    multi method goto-help(MUGS::UI::TUI::Layout::StandardScreen $topic) {
        self.goto-help($topic.^name);
    }

    #| Go to a context help screen for the *current* screen UI object
    multi method goto-help() {
        self.goto-help(self);
    }

    #| Go to a new UI screen
    method goto-screen($name, $class, $prev-screen = self) {
        # XXXX: Cache already-visited screens?
        # XXXX: If yes, need to deal with refill/reformat at goto time
        # XXXX: If no, need to GC old ones
        my $new-screen = $class.new(:$.x, :$.y, :$.z, :$.w, :$.h,
                                    :$.terminal, :$prev-screen);
        $.terminal.set-toplevel($new-screen);
    }

    #| Go to the previous menu or UI screen, if any
    method goto-prev-screen() {
        $.terminal.set-toplevel($.prev-screen) if $.prev-screen;
    }

    #| Return trail of previously visited screens starting with current screen
    method screen-trail() {
        my @trail = self,;
        while @trail[*-1].prev-screen -> $prev {
            @trail.push($prev);
        }
        @trail
    }

    #| Return breadcrumbs to this point
    # XXXX: Multicolor
    # XXXX: Factor out as separate mini-widget
    # XXXX: Clickable previous entries?
    method breadcrumbs() {
        my $locale = $.terminal.locale;
        my @crumbs = self.screen-trail.reverse.map(*.?breadcrumb).grep(?*);

        @crumbs.map({ ~$locale.translate($_) }).join(' > ')
    }
}


#| A standard form with HELP!/Save/Cancel buttons
role MUGS::UI::TUI::Layout::StandardForm
does MUGS::UI::TUI::Layout::StandardScreen {

    ### Required methods

    #| Save changes from the current form
    method save-changes() { ... }

    #| Current form object
    method form() { ... }


    #| Define the overall layout of a standard form
    method content-layout($builder, $max-width, $max-height) {
        ¢'standard-form';

        my %right-pad  = padding-width => (0, 1, 0, 0),;

        with $builder {
            # Center vertically
            .node(),

            # Main form
            |self.form-layout($builder, $max-width, $max-height),

            # HELP!/Save/Cancel buttons
            .divider(line-style => 'light1', style => %( set-h => 1, ), ),
            .node(style => %( :minimize-h, ),
                  .button(:$.form, id => 'help', style => %right-pad,
                          label => ¿'HELP!',
                          process-input => { self.goto-help }),
                  .button(:$.form, id => 'save', style => %right-pad,
                          label => ¿'Save Changes',
                          # XXXX: Confirmation of successful save?
                          process-input => { self.save-changes }),
                  .button(:$.form, id => 'cancel',
                          label => ¿'Cancel and Go Back',
                          process-input => { self.goto-prev-screen }),
                  .node(),
                 ),

            .node(),
        }
    }
}
