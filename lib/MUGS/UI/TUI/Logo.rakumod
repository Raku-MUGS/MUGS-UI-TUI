# ABSTRACT: MUGS logo art tuned for a particular terminal

use Terminal::Capabilities;


#| Return MUGS logo block art tuned for particular terminal capabilities
sub mugs-logo(Terminal::Capabilities:D $caps) is export {
    constant $ASCII = q:to/ASCII/;
         __  __ _   _  ____ ____
        |  \/  | | | |/ ___/ ___|
        | |\/| | | | | |  _\___ \
        | |  | | |_| | |_| |___) |
        |_|  |_|\___/ \____|____/
        ,-----.   .    __,   ._
        |o   o|  / \  / * \  | \
        |  o  | /   \ =_,  ) =--)>
        |o   o|(_,^._) /___| |_/
        '-----'  /_\  [____] '
        ASCII

    constant $VT100 = q:to/VT100/;
        ┌─┐  ┌─┐┌─┐ ┌─┐┌─────┐┌─────┐
        │ └┐┌┘ ││ │ │ ││ ┌───┘│ ────┤
        │ │└┘│ ││ │ │ ││ │ ┌─┐└───┐ │
        │ │  │ │└┐└─┘┌┘│ └─┘ │┌───┘ │
        └─┘  └─┘ └───┘ └─────┘└─────┘
        ┌─────┐    .    ┌──^    ┌─.
        │o   o│   / \   / * \   │  \
        │  o  │  /   \  └─/  )  ┼───)>
        │o   o│ (_,^._) ┌┴───┴┐ │  /
        └─────┘   /_\   └─────┘ └─'
        VT100

    constant $WGL4 = q:to/WGL4/;
        █▄ ▄█  █   █  ▄███▄  ▄███▄
        █▀█▀█  █   █  █   ▀  █▄▄▄
        █   █  █▄ ▄█  █  ▀█   ▀▀▀█
        █   █  ▀███▀  ▀███▀  ▀███▀
        ┌─────┐   .   ┌──^   ┌─.
        │●   ●│  / \  / • \  │  \
        │  ●  │ /   \ └─┘  ) ╪───)►
        │●   ●│(_,^._)┌/───┴┐│  /
        └─────┘  /_\  └─────┘└─´
        WGL4

    constant $Uni1 = q:to/UNI1/;
        █▄ ▄█  █   █  ▄███▄  ▄███▄
        █▀█▀█  █   █  █   ▀  █▄▄▄
        █   █  █▄ ▄█  █  ▀█   ▀▀▀█
        █   █  ▀███▀  ▀███▀  ▀███▀
        ┌─────┐   ∧   ╭──∧   ┌─.
        │●   ●│  ╱ ╲  / • ╲  │  ╲
        │  ●  │ ╱   ╲ ╰─╯  ) ╪───)►
        │●   ●│(_◞⌃◟_)┌╱───┴┐│  ╱
        └─────┘  ╱_╲  └─────┘└─´
        UNI1


    my %logo = ASCII => $caps.vt100-boxes ?? $VT100 !! $ASCII,
               :$WGL4, :$Uni1;
    $caps.best-symbol-choice(%logo)
}
