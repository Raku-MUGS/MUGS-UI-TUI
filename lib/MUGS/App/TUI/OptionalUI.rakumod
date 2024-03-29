# ABSTRACT: Optional UI Elements form in UI Preferences

use Terminal::Widgets::I18N::Translation;
use Terminal::Widgets::Simple;

use MUGS::UI::TUI::Layout::StandardScreen;


#| Optional UI elements form
class OptionalUI does MUGS::UI::TUI::Layout::StandardForm {
    has Str:D  $.grid-name   = 'optional-ui';
    has        $.breadcrumb  = 'optional-ui' ¢¿ 'Optional Elements';
    has        $.title       = 'optional-ui' ¢¿ 'Optional UI Elements | MUGS';
    has Form:D $.form       .= new;

    has @.hints; # XXXX: Just to satisfy role requirements for now

    method form-layout($builder, $max-width, $max-height) {
        ¢'optional-ui';

        # Subsection styling
        my %subsection = :minimize-h, margin-width => (0, 0, 1, 0);

        # Helper subs for state-retaining checkboxes and radio button groups
        # XXXX: Allow specifying style info?
        my sub checkbox($id, $label) {
            my $terminal = self.terminal;
            $builder.checkbox(:$.form, :$id, :$label,
                              state => $terminal.ui-prefs{$id}
                                    // $terminal.app.ui-default($id))
        }

        my sub radio-group($group, *@pairs) {
            my $current = self.terminal.ui-prefs{$group};
            @pairs.map: {
                $builder.radio-button(:$.form, :$group, id => .key, label => .value,
                                      state => .key eq $current)
            }
        }

        # Actually build layout and form settings
        with $builder {
            # XXXX: Set up field hints
            # XXXX: Translate plain text fields
            # XXXX: Make into proper (semantic) subsections
            # XXXX: Sections for static elements versus animations
            # XXXX: Wire all fields up to actually change the UI

            .node(:vertical, style => %subsection,
                  .plain-text(text => 'Optional visuals'),
                  checkbox('menu-item-icons',        ¿'Menu item icons'),
                  checkbox('input-activation-flash', ¿'Input activation flash'),
                  checkbox('input-field-hints',      ¿'Input field hints'),
                 ),
            .node(:vertical, style => %subsection,
                  .plain-text(text => 'History navigation'),
                  |radio-group('history-nav',
                               'breadcrumbs-only' => ¿'Breadcrumbs only',
                               'buttons-menus-only' => ¿'Buttons/menu items only',
                               'both-breadcrumbs-buttons' => ¿'Both'),
                 ),
            .node(:vertical, style => %subsection,
                  .plain-text(text => 'Menu headers'),
                  |radio-group('menu-headers',
                               'large-menu-headers' => ¿'Large',
                               'small-menu-headers' => ¿'Small',
                               'no-menu-headers'    => ¿'None'),
                 ),
        }
    }

    method save-changes() {
        # XXXX: Actually save changes to user config!  :-)
        # XXXX: Save for MUGS-UI-TUI, MUGS-Core, or Terminal-Widgets?

        my $ui-prefs = Map.new((
            |self.terminal.ui-prefs,

            # Checkboxes
            menu-item-icons        => %.by-id<menu-item-icons>.state,
            input-activation-flash => %.by-id<input-activation-flash>.state,
            input-field-hints      => %.by-id<input-field-hints>.state,

            # Radio button groups
            history-nav  => self.selected('history-nav'),
            menu-headers => self.selected('menu-headers'),
        ));

        self.terminal.set-ui-prefs($ui-prefs);

        # After setting preferences, start over with a fresh new main menu
        # XXXX: This is a hack to work around set-ui-prefs not doing complete relayout
        my $main-menu-class = self.screen-trail[*-1].WHAT;
        self.goto-screen('main-menu', $main-menu-class, Nil);
    }

    method selected($group) {
        my $button = self.toplevel.group-members($group).first(*.state);
        $button ?? $button.id !! self.terminal.app.ui-default($group)
    }

    method focus-on-content(Bool:D :$redraw = False) {
        self.focus-on(%.by-id<menu-item-icons>, :$redraw);
    }
}
