# ABSTRACT: TUIs (full-screen Terminal UIs) for MUGS, including App and game UIs

unit module MUGS::UI::TUI:auth<zef:japhb>:ver<0.1.3>;

use Terminal::Widgets::Simple;

use MUGS::Core;
use MUGS::Client;
use MUGS::UI;


# Base class for TUIs
class Game is MUGS::UI::Game is TopLevel {
    has $.ui-controller = Supplier.new;
    has $.ui-control    = $!ui-controller.Supply;

    method ui-type() { 'TUI' }
}


=begin pod

=head1 NAME

MUGS::UI::TUI - Fullscreen Terminal UI for MUGS, including App and game UIs


=head1 SYNOPSIS

  # Set up a full-stack MUGS-UI-TUI development environment
  mkdir MUGS
  cd MUGS
  git clone git@github.com:Raku-MUGS/MUGS-Core.git
  git clone git@github.com:Raku-MUGS/MUGS-Games.git
  git clone git@github.com:Raku-MUGS/MUGS-UI-TUI.git

  cd MUGS-Core
  zef install --exclude="pq:ver<5>:from<native>" .
  mugs-admin create-universe

  cd ../MUGS-Games
  zef install .

  cd ../MUGS-UI-TUI
  zef install --deps-only .  # Or skip --deps-only if you prefer


  ### LOCAL PLAY

  # Play games using a local TUI UI, using an internal stub server and ephemeral data
  mugs-tui

  # Play games using an internal stub server accessing the long-lived data set
  mugs-tui --universe=<universe-name>  # 'default' if set up as above

  # Log in and play games on a WebSocket server using a local TUI UI
  mugs-tui --server=<host>:<port>


  ### GAME SERVERS

  # Start a TLS WebSocket game server on localhost:10000 using fake certs
  mugs-ws-server

  # Specify a different MUGS identity universe (defaults to "default")
  mugs-ws-server --universe=other-universe

  # Start a TLS WebSocket game server on different host:port
  mugs-ws-server --host=<hostname> --port=<portnumber>

  # Start a TLS WebSocket game server using custom certs
  mugs-ws-server --private-key-file=<path> --certificate-file=<path>

  # Write a Log::Timeline JSON log for the WebSocket server
  LOG_TIMELINE_JSON_LINES=log/mugs-ws-server mugs-ws-server


=head1 DESCRIPTION

B<NOTE: See the L<top-level MUGS repo|https://github.com/Raku-MUGS/MUGS> for more info.>

MUGS::UI::TUI is a TUI (Terminal UI) app (`mugs-tui`) and a growing set of UI
plugins to play games in
L<MUGS-Core|https://github.com/Raku-MUGS/MUGS-Core> and
L<MUGS-Games|https://github.com/Raku-MUGS/MUGS-Games> via the TUI.

B<This early version only contains very limited modules and plugins, is missing
significant functionality, and should not be considered "fully released" in the
same way that the CLI and WebSimple UIs are.>


=head1 ROADMAP

MUGS is still in its infancy, at the beginning of a long and hopefully very
enjoyable journey.  There is a
L<draft roadmap for the first few major releases|https://github.com/Raku-MUGS/MUGS/tree/main/docs/todo/release-roadmap.md>
but I don't plan to do it all myself -- I'm looking for contributions of all
sorts to help make it a reality.


=head1 CONTRIBUTING

Please do!  :-)

In all seriousness, check out L<the CONTRIBUTING doc|docs/CONTRIBUTING.md>
(identical in each repo) for details on how to contribute, as well as
L<the Coding Standards doc|https://github.com/Raku-MUGS/MUGS/tree/main/docs/design/coding-standards.md>
for guidelines/standards/rules that apply to code contributions in particular.

The MUGS project has a matching GitHub org,
L<Raku-MUGS|https://github.com/Raku-MUGS>, where you will find all related
repositories and issue trackers, as well as formal meta-discussion.

More informal discussion can be found on IRC in
L<Libera.Chat #mugs|ircs://irc.libera.chat:6697/mugs>.


=head1 AUTHOR

Geoffrey Broadwell <gjb@sonic.net> (japhb on GitHub and Libera.Chat)


=head1 COPYRIGHT AND LICENSE

Copyright 2021 Geoffrey Broadwell

MUGS is free software; you can redistribute it and/or modify it under the
Artistic License 2.0.

=end pod
