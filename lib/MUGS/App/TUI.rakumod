# ABSTRACT: Core logic to set up and run a TUI game

use Terminal::Capabilities;
use Terminal::Widgets::Terminal;
use Terminal::Widgets::Simple::App;

use Text::MiscUtils::Layout;
use Terminal::Widgets::Widget;
use Terminal::Widgets::Progress::Tracker;

use MUGS::Core;
use MUGS::App::TUI::MainMenu;
use MUGS::App::LocalUI;
use MUGS::UI::TUI;


# Use subcommand MAIN args
PROCESS::<%SUB-MAIN-OPTS> := :named-anywhere;


#| A left-to-right colored progress bar
class ProgressBar is Terminal::Widgets::Widget
 does Terminal::Widgets::Progress::Tracker {
    has $.terminal   is required;
    has $.completed  = 'blue';
    has $.remaining  = 'red';
    has $.text-color = 'white';
    has $.text       = '';

    #| Initialize the progress bar beyond simply setting attributes
    submethod TWEAK() {
        # Render initial text
        my @lines = $!text.lines;
        my $top = (self.h - @lines) div 2;
        for @lines.kv -> $i, $line {
            self.grid.set-span-text((self.w - duospace-width($line)) div 2,
                                    $top + $i, $line);
        }

        self.Terminal::Widgets::Progress::Tracker::TWEAK;
    }

    #| Make sure current progress level is sane and update the screen
    method !update-progress($p) {
        my $t0 = now;

        # Compute length of completed portion of bar
        $!progress    = 0 max ($!max min $p);
        my $completed = floor $.w * $!progress / $!max;

        # Loop over bar thickness (height) setting color spans
        $.grid.set-span-color(0, $completed - 1,   $_, "$!text-color on_$!completed") for ^$.h;
        $.grid.set-span-color($completed, $.w - 1, $_, "$!text-color on_$!remaining") for ^$.h;

        # Update screen immediately
        self.composite(:print);
    }
}


#| TUI App
class MUGS::App::TUI is MUGS::App::LocalUI
   is Terminal::Widgets::Simple::App {
    has Str:D  $.symbols     = 'Full';
    has Bool:D $.vt100-boxes = True;

    has Terminal::Widgets::Terminal $.terminal;

    method ui-type() { 'TUI' }

    #| Use full screen for games
    method game-ui-opts() {
        %( :$.terminal, :w($.terminal.w), :h($.terminal.h), :x(0), :y(0) )
    }

    #| Initialize the terminal and overall MUGS client app
    method initialize(*@loading-tasks) {
        self.bootup;
        $!terminal.initialize;
        self.loading-screen($!terminal, @loading-tasks);
    }

    #| Basic boot-time (before alternate screen switch) initialization
    method boot-init() {
        self.MUGS::App::LocalUI::initialize;
        $!terminal = self.add-terminal(:$.symbols, :$.vt100-boxes);
    }

    #| Make a simple progress bar for the loading screen
    method make-progress-tracker($terminal) {
        # Smallish centered bar, 3/4 of the way down the screen
        my $w = $terminal.w min 50;
        my $h = 1;
        my $x = ($terminal.w - $w) div 2;
        my $y = floor $terminal.h * .75;

        ProgressBar.new(:$terminal, :$w, :$h, :$x, :$y);
    }

    #| Load plugins in loading screen, tracking progress
    method loading-promises($tracker, @loading-tasks) {
        my $tasks = 3 + @loading-tasks;
        my \Δ     = ($tracker.max - $tracker.progress) / $tasks;

        start {
            # Just getting to this point is part of "loading", both in reality
            # because of the overhead of `use` statements and more importantly
            # *from the point of view of the user* because we must have been
            # doing *something* for the last few hundred milliseconds, so
            # acknowledge that by bumping the progress tracker even before
            # doing explicit side-thread plugin loads.  Otherwise to the user
            # it feels like the program is starting over from scratch and
            # hasn't actually done anything useful so far.

            $tracker.add-progress(Δ);

            self.load-client-plugins;
            $tracker.add-progress(Δ);

            self.load-ui-plugins;
            $tracker.add-progress(Δ);

            for @loading-tasks {
                $_();
                $tracker.add-progress(Δ);
            }
        }
    }

    #| Shut down the overall MUGS client app (as cleanly as possible)
    method shutdown() {
        callsame;

        if $.terminal.has-initialized {
            $.terminal.quit;
            await $.terminal.has-shutdown;
        }
    }

    #| Connect to server and authenticate as a valid user
    method ensure-authenticated-session(Str $server, Str $universe) {
        my $decoded = self.decode-and-connect($server, $universe);
        my ($username, $password) = self.initial-userpass($decoded);

        # XXXX: Should allow player to correct errors and retry or exit
        await $.session.authenticate(:$username, :$password);
    }

    #| Create and initialize a new game UI for a given game type and client
    method launch-game-ui(Str:D :$game-type, MUGS::Client::Game:D :$client, *%ui-opts) {
        $.terminal.set-toplevel(callsame);
    }

    #| Start actively playing current game UI
    method play-current-game() {
        $.terminal.current-toplevel.?start-ticker;
        # XXXX: May need to move this back to ensure-authenticated-session
        $.terminal.start;
    }
}


#| Boot TUI and jump directly to main menu
sub main-menu(Bool :$debug, *%ui-options) {
    # Configure debugging and create app-ui object
    my $*DEBUG = $debug // ?%*ENV<MUGS_DEBUG>;
    my $app-ui = MUGS::App::TUI.new(|%ui-options);

    # Prepare to build main menu offscreen, during app-ui init
    my $menu-ui;
    my sub make-main-menu() {
        $menu-ui = MainMenu.new(|$app-ui.game-ui-opts, :title('Main Menu | MUGS'));
        $menu-ui.build-layout;
    }

    # Actually initialize app UI; should exit with message on error
    $app-ui.initialize(&make-main-menu);

    # Set main menu as new toplevel, triggering draw and compose
    $app-ui.terminal.set-toplevel($menu-ui);

    # Start the terminal event reactor (and thus interaction with the menu);
    # when this exits, the user has quit the MUGS TUI.
    $app-ui.terminal.start;

    # Clean up
    $app-ui.shutdown;
}


#| Common options that work for all subcommands
my $common-args = :(Str :$server, Str :$universe, Str :$symbols,
                    Bool :$vt100-boxes, Bool :$debug);

#| Add description of common arguments/options to standard USAGE
sub GENERATE-USAGE(&main, |capture) is export {
    &*GENERATE-USAGE(&main, |capture).subst(' <options>', '', :g)
    ~ q:to/OPTIONS/.trim-trailing;


        Common options for all commands:
          --server=<Str>    Specify an external server (defaults to internal)
          --universe=<Str>  Specify a local universe (internal server only)
          --symbols=<Str>   Set terminal/font symbol set (defaults to full)
          --vt100-boxes     Enable use of VT100 box drawing symbols
          --debug           Enable debug output

        Known symbol sets:
          ascii    7-bit ASCII printables only (most compatible)
          latin1   Latin-1 / ISO-8859-1
          cp1252   CP1252 / Windows-1252
          w1g      W1G-compatible subset of WGL4
          wgl4     Full WGL4 / Windows Glyph List 4
          mes2     MES-2 / Multilingual European Subset No. 2
          uni1     Unicode 1.1
          uni7     Unicode 7.0 + Emoji 0.7
          full     Full modern Unicode support (most features)
        OPTIONS
}


#| Show the main MUGS TUI menu
multi MAIN(|options where $common-args) is export {
    main-menu(|options)
}


#| Play a requested TUI game
multi MAIN($game-type, :$game-id = 0, |options where $common-args) is export {
    play-via-local-ui(MUGS::App::TUI, :$game-type, :$game-id, |options)
}
