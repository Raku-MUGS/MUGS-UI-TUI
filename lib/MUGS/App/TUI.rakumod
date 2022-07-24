# ABSTRACT: Core logic to set up and run a TUI game

use Terminal::Widgets::Terminal;

use MUGS::Core;
use MUGS::App::LocalUI;
use MUGS::UI::TUI;


# Use subcommand MAIN args
%PROCESS::SUB-MAIN-OPTS = :named-anywhere;


#| TUI App
class MUGS::App::TUI is MUGS::App::LocalUI {
    has Terminal::Widgets::Terminal:D $.terminal .= new;

    method ui-type() { 'TUI' }

    #| Use full screen for games
    method game-ui-opts() {
        %( :$.terminal, :w($.terminal.w), :h($.terminal.h), :x(0), :y(0) )
    }

    #| Initialize the overall MUGS client app
    method initialize() {
        callsame;
        $.terminal.initialize;
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


#| Common options that work for all subcommands
my $common-args = :(Str :$server, Str :$universe, Bool :$debug);

#| Add description of common arguments/options to standard USAGE
sub GENERATE-USAGE(&main, |capture) is export {
    &*GENERATE-USAGE(&main, |capture).subst(' <options>', '', :g)
    ~ q:to/OPTIONS/.trim-trailing;


        Common options for all commands:
          --server=<Str>    Specify an external server (defaults to internal)
          --universe=<Str>  Specify a local universe (internal server only)
          --debug           Enable debug output
        OPTIONS
}


#| Play a requested TUI game
multi MAIN($game-type, :$game-id = 0, |options where $common-args) is export {
    play-via-local-ui(MUGS::App::TUI, :$game-type, :$game-id, |options)
}
