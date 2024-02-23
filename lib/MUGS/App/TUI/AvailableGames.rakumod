# ABSTRACT: UI to list and select available games

use Text::MiscUtils::Emojify;
use Terminal::Capabilities;
use Terminal::Widgets::I18N::Translation;

use MUGS::UI::TUI::Layout::StandardScreen;

sub available-games-icons(Terminal::Capabilities:D $caps) {
    my constant %icons =
        ASCII => {
            searching    => '...',
            help         => '?',
            back         => "\x3c",  # ^
        },
        WGL4R => {
            searching    => '...',
            help         => '?',
            back         => '▲',  # ←
        },
        WGL4 => {
            searching    => '...',
            help         => '?',
            back         => '◄',
        },
        Uni1 => {
            searching    => '…',
            help         => '?',
            back         => '◀',
        },
        Uni7 => {
            searching    => emojify('🔎'),
            help         => emojify('❓'),  # ⁇
            back         => emojify('⬅'),  # 🡄
        },
    ;

    $caps.best-symbol-choice(%icons)
}

#| Available games UI
class AvailableGames does MUGS::UI::TUI::Layout::StandardScreen {
    has Str:D $.grid-name  = 'available-games';
    has       $.breadcrumb = 'available-games' ¢¿ 'Available Games';
    has       $.title      = 'available-games' ¢¿ 'Available Games | MUGS';
    has       $.icons      =  available-games-icons(self.terminal.caps);

    #| Return an array of all possible hints for this screen
    # XXXX: Replace with game type descriptions
    method hints() { Empty }

    #| Define the initial content layout constraints
    method content-layout($builder, $max-width, $max-height) {
        ¢'available-games';

        with $builder {
            # Vertical stack with spaces between
            .node(),
            .plain-text(id => 'games', style => %( :minimize-h, ),
                        text => $.icons<searching>),
            .node(),
            # Buttons left justified in content stack, with a small gap between
            .node(style => %( :minimize-h, ),
                  .button(id => 'help', style => %( padding-width => (0, 1, 0, 0), ),
                          label => ¿'HELP!',
                          process-input => { self.goto-help }),
                  .button(id => 'back',
                          # XXXX: Fix for other previous
                          label => ¿'Back to Main Menu',
                          process-input => { self.goto-prev-screen }),
                  .node()),
            .node(),
        }
    }

    #| Focus on the first active content (the game selection widget)
    method focus-on-content(Bool:D :$redraw = False) {
        self.focus-on(%.by-id<games>, :$redraw);
    }
}
