# ABSTRACT: Basic Layouts: Centered menu page

use Text::MiscUtils::Layout;

use Terminal::Widgets::Simple::TopLevel;
use Terminal::Widgets::PlainText;
use Terminal::Widgets::Input::Menu;


#| A centered menu screen with header, navigable menu items, and hint bar
class MUGS::UI::TUI::Layout::CenteredMenu
   is Terminal::Widgets::Simple::TopLevel {
    has Terminal::Widgets::PlainText   $.hint;
    has Terminal::Widgets::Input::Menu $.menu;

    ### Stubbed hooks for subclasses

    method header-layout($builder, $max-width, $max-height) { Empty }
    method process-selection($menu) { }
    method items() { Empty }

    #| Compute maximum dimensions of menu item hints
    # XXXX: Items as parameter instead of implicit?
    # XXXX: Cache wrapped versions?
    # XXXX: Translations?
    method hint-max() {
        # Wrap each hint and ensure enough room to display any of them
        my @wrapped    = @.items.map({ text-wrap($.w, .<hint> // '') });
        my $hint-lines = @wrapped.map(*.elems).max;
        my $hint-width = @wrapped.map(*.map(&duospace-width)).flat.max;

        ($hint-width, $hint-lines)
    }

    #| Define the initial layout constraints
    method initial-layout($builder, $max-width, $max-height) {
        my ($hint-w, $hint-h) = self.hint-max;
        my &process-input = { self.process-selection($_) }

        with $builder {
            # Centered horizontally
            .node(
                .node(),
                # Same width, with spaces around if possible
                .node(:vertical, style => %( :minimize-w, ),
                      |self.header-layout($builder, $max-width, $max-height),
                      .node(),
                      .menu(id => 'menu', :@.items, :&process-input,
                            hint-target => 'hint',
                            color => %( focused => '', ),
                            style => %( :minimize-h, )),
                      .node(),
                     ),
                .node(),
            ),
            # Full width, minimum height
            .plain-text(id => 'hint', color => 'italic',
                        style => %( min-w => $hint-w,
                                    min-h => $hint-h,
                                    :minimize-h ))
        }
    }

    #| Refresh the layout tree based on updated info
    method update-layout($layout) {
        # Rewrap hints and ensure enough room to display them
        my ($min-w, $min-h) = self.hint-max;
        $.hint.layout.update-requested(:$min-w, :$min-h);
    }

    #| Lay out main menu UI subwidgets
    method build-layout() {
        # Build layout dynamically based on layout constraints from layout-model
        my $is-rebuild = callsame;

        # Pull subwidgets out of generated widget tree
        $!menu = %.by-id<menu>;
        $!hint = %.by-id<hint>;

        # Focus on the actual active menu
        self.focus-on($!menu, :!redraw);

        # Return is-rebuild for subclasses
        $is-rebuild
    }
}
