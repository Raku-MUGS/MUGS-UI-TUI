# Visual Settings for MUGS-UI-TUI

## Overview

Visual settings will be modifiable from the top-level Settings menu.  Each
setting will be represented by a slider of visual fidelity ("better" at the
"end" of each line, according to bidi rules).  As each slider is moved, the
screen will update to reflect the new setting in a sample pattern, allowing
the player to confirm that the setting will work for them.


## Compatibility

### Symbol Repertoire

While there are intermediate glyph repertoires and additional nuance exists,
this slider represents a simplified view with only the following options:

* ASCII - Pure ASCII printables
* VT100 - ASCII + VT100 box drawing (**Default**)
* WGL4  - Windows Glyph List 4
* UNI1  - Unicode 1.1

The "samples" for this slider will be the icon row from the MUGS logo as
represented in each character set, as follows.

ASCII:

```
 -----    .    __,   ._
|o   o|  / \  / * \  | \
|  o  | /   \ =_,  ) =--)>
|o   o|(_,^._) /___| |_/
 -----   /_\  [____] '
```

VT100 (**Default**):

```
┌─────┐   .   ┌──^   ┌─.
│o   o│  / \  / * \  │  \
│  o  │ /   \ └─/  ) ┼───)>
│o   o│(_,^._)┌┴───┴┐│  /
└─────┘  /_\  └─────┘└─'
```

WGL4:

```
┌─────┐   .   ┌──^   ┌─.
│●   ●│  / \  / • \  │  \
│  ●  │ /   \ └─┘  ) ╪───)►
│●   ●│(_,^._)┌/───┴┐│  /
└─────┘  /_\  └─────┘└─´
```

UNI1:

```
┌─────┐   ∧   ╭──∧   ┌─.
│●   ●│  ╱ ╲  / • ╲  │  ╲
│  ●  │ ╱   ╲ ╰─╯  ) ╪───)►
│●   ●│(_,^._)┌╱───┴┐│  ╱
└─────┘  ╱_╲  └─────┘└─´
```

XXXX: Idea for higher Unicodes: decompose each of the four base icons into
      arrays of individual Unicode icons and emoji (dice faces, card suits,
      chess pieces, weapons and objects).

UNI3 (Unicode 3.2):

```
┌─────┐   ♠   ╭──∧   ┌─.
│⚀   ⚁│  ╱♤╲  / • ╲  │  ╲
│  ⚂  │ ╱♧♢♡╲ ╰─╯  ) ╪───)►
│⚃   ⚄│♥_,♦._♣┌╱───┴┐│  ╱
└─────┘   ☗   └─────┘└─´
```


### Color Support

It is assumed that ANSI attribute escapes are available, and that the support
for additional escapes is monotonic:

* Mono  - Monochrome attributes (bold, italic, inverse, underline)
* 4bit  - 4-Bit color (8 colors + "bright" foreground variants)
* 8bit  - 8-Bit color (6x6x6 color cube + 24-value greyscale) (**Default**)
* 24bit - 24-bit RGB color

Sample patterns for color support will be taken from the patterns/swatches used
by `Terminal::Tests`.

XXXX: May need to individually check for support of mono attributes; support
      for these is rather spotty, unfortunately.
