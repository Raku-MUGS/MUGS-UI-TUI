# ABSTRACT: Core logic to set up and run a TUI game

use Terminal::Capabilities;

use Terminal::Widgets::Widget;
use Terminal::Widgets::Terminal;
use Terminal::Widgets::Simple::App;
use Terminal::Widgets::Progress::Tracker;

use MUGS::Core;
use MUGS::App::LocalUI;


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
        my $locale = $!terminal.locale;
        my @lines  = $locale.plain-text($!text).lines;
        my $top    = (self.h - @lines) div 2;
        for @lines.kv -> $i, $line {
            self.grid.set-span-text((self.w - $locale.width($line)) div 2,
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
    has Str  $.symbols;      #= Terminal/font symbol set
    has Bool $.vt100-boxes;  #= Enable VT100 box drawing symbols
    # XXXX: What about color override?

    has Terminal::Widgets::Terminal $.terminal;

    method ui-type() { 'TUI' }

    #| Use full screen for games
    method game-ui-opts() {
        %( :$.terminal, :w($.terminal.w), :h($.terminal.h), :x(0), :y(0),
           prev-screen => $.terminal.current-toplevel)
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

        my @ui-pref-keys = < menu-item-icons input-activation-flash
                             input-field-hints history-nav menu-headers >;
        my $ui-prefs;

        if $*SAFE {
            $!symbols     //= 'ascii';
            $!vt100-boxes //= False;
            $ui-prefs = @ui-pref-keys.map({ $_ => self.ui-default($_) }).Map;
        }
        else {
            $!symbols     //= self.ui-config('symbols');
            $!vt100-boxes //= self.ui-config('vt100-boxes');
            $ui-prefs = @ui-pref-keys.map({ $_ => self.ui-config($_) }).Map;
        }

        $!terminal = self.add-terminal(:$ui-prefs, :$.symbols, :$.vt100-boxes);
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
        my $debug = $*DEBUG;
        my $tasks = 7 + @loading-tasks;
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

            my $before-clients = now;
            my @clients = self.load-client-plugins;
            if $debug {
                note sprintf "Client plugins: %.3fs", now - $before-clients;
                .raku.indent(2).note for @clients;
            }
            $tracker.add-progress(Δ);

            my $before-requires = now;
            require MUGS::UI::TUI;
            $tracker.add-progress(Δ);
            require MUGS::UI::TUI::Layout::PrimaryMenu;
            $tracker.add-progress(Δ);
            require MUGS::App::TUI::SettingsMenu;
            $tracker.add-progress(Δ);
            require MUGS::App::TUI::MainMenu;
            note sprintf "UI Requires: %.3fs", now - $before-requires if $debug;
            $tracker.add-progress(Δ);

            my $before-uis = now;
            my @uis = self.load-ui-plugins;
            if $debug {
                note sprintf "UI plugins: %.3fs", now - $before-uis;
                # XXXX: For some reason this list doesn't show up if MUGS::UI::TUI
                #       is required above, but time still passes and plugins still
                #       work as normal.
                .raku.indent(2).note for @uis;
            }
            $tracker.add-progress(Δ);

            for @loading-tasks {
                $_();
                $tracker.add-progress(Δ);
            }
        }
    }

    method load-plugins() {
        # Intentionally ignore this path; in this UI, plugin loading is already
        # done in loading-promises as part of the loading screen (itself a part
        # of the app's `initialize` phase).
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
sub main-menu(Bool :$safe, UInt :$debug, *%ui-options) {
    # Configure debugging and create app-ui object
    my $t-start = now;
    my $*SAFE   = $safe  //  ?%*ENV<MUGS_SAFE>;
    my $*DEBUG  = $debug // +(%*ENV<MUGS_DEBUG> // 0);
    my $app-ui  = MUGS::App::TUI.new(|%ui-options);

    # Determine whether to output startup performance debugging info
    my $startup-perf-debug = ?$*DEBUG;

    # Prepare to load translation tables during app-ui init
    my ($t-plugins, $t-load-trans);
    my sub load-translations() {
        # Last of plugins is immediate previous loading screen task
        $t-plugins = now;

        require Terminal::Widgets::I18N::Translation
                < LanguageSelection TranslatableString >;
        require MUGS::App::TUI::Translations::Test
                < &translation-languages &translation-contexts >;

        my @languages := translation-languages;
        my @contexts  := translation-contexts;
        my @iso-codes  = @languages.map(*<iso-code>);
        my $best-lang  = LanguageSelection.best-languages(@iso-codes)[0];

        $app-ui.exit-with-errors("Could not find a matching translation language!", [])
            unless $best-lang;

        my %lang-info := @languages.first(*<iso-code> eq $best-lang);
        # XXXX: Check loader?
        my %trans     := %lang-info<loader>();
        my $terminal   = $app-ui.terminal;
        $terminal.set-locale($terminal.locale.new(string-table => %trans));

        $t-load-trans = now;
    }

    # Prepare to build main menu offscreen, during app-ui init
    my $menu-ui;
    my $t-built;
    my sub make-main-menu() {
        require MUGS::App::TUI::MainMenu;
        $menu-ui = ::('MainMenu').new(|$app-ui.game-ui-opts, prev-screen => Nil);
        $menu-ui.build-layout;
        $t-built = now;
    }

    # Actually initialize app UI; should exit with message on error
    $app-ui.initialize(&load-translations, &make-main-menu);
    my $t-loaded = now;

    # Set main menu as new toplevel, triggering draw and compose
    $app-ui.terminal.set-toplevel($menu-ui);
    my $t-menu-shown = now;

    # Report startup performance in debug stream before going interactive
    if $startup-perf-debug {
        # Note: Does not include `raku -e ''` time, which should be added to
        #       all below.  On my laptop, this changes Message from 3-4 frame
        #       times to 10, and likewise for the following times as well.

        # Note: Message -> Bootup (message appears to message disappears) is
        #       about 412 ms (~25 frame times) on my laptop, most of which is
        #       in Message -> INIT, followed by app.add-terminal.  The screen
        #       switch takes ~1ms, so Bootup -> empty screen appears instant.

        my sub show($title, $instant) {
            note sprintf "  %-10s %6.3fs", $title ~ ':', $instant - $*INIT-INSTANT;
        }

        note "Time to complete each startup phase:";
        show(|$_) for
            ('Message',  $*BM_INSTANT),
            ('INIT',     INIT now),
            ('Start',    $t-start),
            ('Bootup',   $app-ui.bootup-instant),
            ('Plugins',  $t-plugins),
            ('LoadXlat', $t-load-trans),
            ('Built',    $t-built),
            ('Loaded',   $t-loaded),
            ('Menu',     $t-menu-shown)
    }

    # Start the terminal event reactor (and thus interaction with the menu);
    # when this exits, the user has quit the MUGS TUI.
    $app-ui.terminal.start;

    # Clean up
    $app-ui.shutdown;
}


#| Common options that work for all subcommands
my $common-args = :(Str :$server, Str :$universe, Bool :$safe,
                    Str :$symbols, Bool :$vt100-boxes, UInt :$debug);

#| Add description of common arguments/options to standard USAGE
sub GENERATE-USAGE(&main, |capture) is export {
    &*GENERATE-USAGE(&main, |capture).subst(' <options>', '', :g)
    ~ q:to/OPTIONS/.trim-trailing;


        Common options for all commands:
          --server=<Str>    Specify an external server (defaults to internal)
          --universe=<Str>  Specify a local universe (internal server only)
          --symbols=<Str>   Set terminal/font symbol set (defaults to full)
          --vt100-boxes     Enable use of VT100 box drawing symbols
          --safe            Use maximum compatibility defaults
          --debug=<UInt>    Enable debug output and set detail level

        Known symbol sets:
          ascii    7-bit ASCII printables only (most compatible)
          latin1   Latin-1 / ISO-8859-1
          cp1252   CP1252 / Windows-1252
          w1g      W1G-compatible subset of WGL4R
          wgl4r    Required (non-optional) WGL4 glyphs
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
