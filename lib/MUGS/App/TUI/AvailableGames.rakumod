# ABSTRACT: UI to list and select available games

use Text::MiscUtils::Emojify;
use Terminal::Capabilities;
use Terminal::Widgets::I18N::Translation;

use MUGS::UI::Game::Lobby;
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
class AvailableGames
 does MUGS::UI::Game::Lobby
 does MUGS::UI::TUI::Layout::StandardScreen {
    has Str:D $.grid-name  = 'available-games';
    has       $.breadcrumb = 'available-games' ¢¿ 'Available Games';
    has       $.title      = 'available-games' ¢¿ 'Available Games | MUGS';
    has       $.icons      =  available-games-icons(self.terminal.caps);
    has       $.client;

    #| Return an array of all possible hints for this screen
    # XXXX: Replace with game type descriptions (and maybe button hints?)
    method hints() { Empty }

    #| Define the initial content layout constraints
    method content-layout($builder, $max-width, $max-height) {
        ¢'available-games';

        with $builder {
            # Vertical stack with spaces between
            .node(),
            .plain-text(id => 'games', :wrap,
                        style => %( :minimize-h, min-h => 10),
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

    #| Launch a selected game UI
    method launch-game-ui($game-type) {
        my $app    = $.terminal.app;
        my $client = $app.new-game-client(:$game-type);

        $app.launch-game-ui(:$game-type, :$client);
        $.terminal.current-toplevel.?start-ticker;
    }

    #| Focus on the first active content (the game selection widget)
    method focus-on-content(Bool:D :$redraw = False) {
        self.grid.clear;
        self.focus-on(%.by-id<games>, :$redraw);
        self.refresh-games;
    }

    #| Filter a game list for compatibility with this UI
    method filter-games-for-ui(@games) {
        @games.grep({ MUGS::UI.ui-exists('TUI', .<game-type>) })
    }

    #| Refresh the available games table
    method refresh-games() {
        # All the heavy lifting is done by the app object
        my $app = self.terminal.app;

        # Make sure the app has a live local session with valid identities
        $app.ensure-authenticated-session(Str, Str) unless $app.session-is-internal;
        $app.choose-identities unless $app.session.default-persona
                                   && $app.session.default-character;

        # Make sure the app has started a lobby client
        $app.start-lobby-client unless $app.lobby-client;
        $!client = $app.lobby-client;

        # Ask lobby client for available games
        my @avail = self.available-game-types;

        # Display available games
        my @sorted = @avail.map(*<game-type>).sort;
        %.by-id<games>.set-text(@sorted.join(', '));
    }
}
