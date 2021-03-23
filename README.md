NAME
====

MUGS::UI::TUI - Fullscreen Terminal UI for MUGS, including App and game UIs

SYNOPSIS
========

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

DESCRIPTION
===========

**NOTE: See the [top-level MUGS repo](https://github.com/Raku-MUGS/MUGS) for more info.**

MUGS::UI::TUI is a TUI (Terminal UI) app (`mugs-tui`) and a growing set of UI plugins to play games in [MUGS-Core](https://github.com/Raku-MUGS/MUGS-Core) and [MUGS-Games](https://github.com/Raku-MUGS/MUGS-Games) via the TUI.

**This early version only contains very limited modules and plugins, is missing significant functionality, and should not be considered "fully released" in the same way that the CLI and WebSimple UIs are.**

AUTHOR
======

Geoffrey Broadwell <gjb@sonic.net>

COPYRIGHT AND LICENSE
=====================

Copyright 2021 Geoffrey Broadwell

MUGS is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

