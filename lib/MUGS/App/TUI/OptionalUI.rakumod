# ABSTRACT: Optional UI Elements form in UI Preferences

use Terminal::Widgets::I18N::Translation;
use Terminal::Widgets::Simple;

use MUGS::UI::TUI::Layout::StandardScreen;


#| Optional UI elements form
class OptionalUI does MUGS::UI::TUI::Layout::StandardScreen {
    has Str:D  $.grid-name   = 'optional-ui';
    has        $.breadcrumb  = 'optional-ui' ¢¿ 'Optional Elements';
    has        $.title       = 'optional-ui' ¢¿ 'Optional UI Elements | MUGS';
    has Form:D $.form       .= new;

    has @.hints; # XXXX: Just to satisfy role requirements for now

    method content-layout($builder, $max-width, $max-height) {
        ¢'optional-ui';

        # Subsection and button pad styling
        my %subsection = :minimize-h, margin-width => (0, 0, 1, 0);
        my %right-pad  = padding-width => (0, 1, 0, 0),;

        with $builder {
            # Center vertically
            .node(),

            # XXXX: Set up field hints
            # XXXX: Translate plain text fields
            # XXXX: Make into proper (semantic) subsections
            # XXXX: Sections for static elements versus animations
            # XXXX: Wire all fields up to actually change the UI

            .node(:vertical, style => %subsection,
                  .plain-text(text => 'Optional visuals'),
                  .checkbox(:$.form, id => 'menu-item-icons', :state,
                            label => ¿'Menu item icons'),
                  .checkbox(:$.form, id => 'input-activation-flash', :state,
                            label => ¿'Input activation flash'),
                  .checkbox(:$.form, id => 'input-field-hints', :state,
                            label => ¿'Input field hints'),
                 ),
            .node(:vertical, style => %subsection,
                  .plain-text(text => 'History navigation'),
                  .radio-button(:$.form, group => 'history-nav',
                                id    =>  'breadcrumbs-only',
                                label => ¿'Breadcrumbs only'),
                  .radio-button(:$.form, group => 'history-nav',
                                id    =>  'buttons-menus-only',
                                label => ¿'Buttons/menu items only'),
                  .radio-button(:$.form, group => 'history-nav', :state,
                                id    =>  'both-breadcrumbs-buttons',
                                label => ¿'Both'),
                 ),
            .node(:vertical, style => %subsection,
                  .plain-text(text => 'Menu headers'),
                  .radio-button(:$.form, group => 'menu-headers',
                                id    =>  'large-menu-headers',
                                label => ¿'Large'),
                  .radio-button(:$.form, group => 'menu-headers',
                                id    =>  'small-menu-headers',
                                label => ¿'Small'),
                  .radio-button(:$.form, group => 'menu-headers', :state,
                                id    =>  'no-menu-headers',
                                label => ¿'None'),
                 ),

            # XXXX: Split out into help/save/cancel helper routine
            .divider(line-style => 'light1', style => %( set-h => 1, ), ),
            .node(style => %( :minimize-h, ),
                  .button(:$.form, id => 'help', style => %right-pad,
                          label => ¿'HELP!',
                          process-input => { self.goto-help }),
                  .button(:$.form, id => 'save', style => %right-pad,
                          label => ¿'Save Changes',
                          process-input => { self.save-changes }),
                  .button(:$.form, id => 'cancel',
                          label => ¿'Cancel and Go Back',
                          process-input => { self.goto-prev-screen }),
                  .node(),
                 ),
            .node(),
        }
    }

    method save-changes() {
        # XXXX: Actually save changes!  :-)
        # XXXX: Save for MUGS-UI-TUI, MUGS-Core, or Terminal-Widgets?

        self.goto-prev-screen;
    }

    method focus-on-content(Bool:D :$redraw = False) {
        self.focus-on(%.by-id<menu-item-icons>, :$redraw);
    }
}
