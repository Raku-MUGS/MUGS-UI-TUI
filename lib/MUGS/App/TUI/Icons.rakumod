# ABSTRACT: UI and menu icons (centralized to ensure consistency)

use Terminal::Capabilities;
use Text::MiscUtils::Emojify;


sub main-ui-icons(Terminal::Capabilities:D $caps) is export {
    my constant %icons =
        ASCII => {
            # Common
            help         => '',  # ?
            back         => '',  # ^

            # Main Menu
            local        => '',  # .
            network      => '',  # @
            settings     => '',  # *
            exit         => '',  # ^

            # Settings Menu
            a11y         => '',
            ui-prefs     => '',
            terminal     => '',

            # Accessibility Menu

            # UI Preferences Menu
            locale       => '',
            optional-ui  => '',

            # Terminal Menu
            colors       => '',
            symbols      => '',
            line-drawing => '',
        },
        WGL4R => {
            # Common
            help         => '?',
            back         => '▲',  # ←

            # Main Menu
            local        => '•',
            network      => '↔',
            settings     => '*',
            exit         => '▲',  # ←

            # Settings Menu
            a11y         => '♥',
            ui-prefs     => '┼',
            terminal     => '□',  # ■ ⌧  ▭

            # Accessibility Menu

            # UI Preferences Menu
            locale       => '¥',  # ¥ ¿ ö
            optional-ui  => '√',

            # Terminal Menu
            colors       => '▒',
            symbols      => '§',
            line-drawing => '╠',
        },
        WGL4 => {
            # Common
            help         => '?',
            back         => '◄',

            # Main Menu
            local        => '•',
            network      => '↔',
            settings     => '*',
            exit         => '◄',

            # Settings Menu
            a11y         => '☻',  # ☼ ♥
            ui-prefs     => '┼',
            terminal     => '□',  # ■ ⌧  ▭

            # Accessibility Menu

            # UI Preferences Menu
            locale       => '¥',  # ¥ ¿ ö
            optional-ui  => '√',

            # Terminal Menu
            colors       => '▒',
            symbols      => '§',
            line-drawing => '╠',
        },
        Uni1 => {
            # Common
            help         => '?',
            back         => '◀',

            # Main Menu
            local        => '◎',  # • (BULLET)  ⌨ (KEYBOARD)
            network      => '⇄',  # ┯┷  ¤  ‡  ↔  ⇋  ⇌
            settings     => '✔',  # ☑ ☒ ✓ ↕
            exit         => '◀',

            # Settings Menu
            a11y         => '☻',  # ☼ ♥ ❤
            ui-prefs     => '┿',  # ┼ ┿ ╂
            terminal     => '▢',  # ⌧ ▭

            # Accessibility Menu

            # UI Preferences Menu
            locale       => '¥',  # ¥ ¿ ö
            optional-ui  => '☑',

            # Terminal Menu
            colors       => '▒',
            symbols      => '§',
            line-drawing => '╠',
        },
        Uni7 => {
            # Common
            help         => emojify('❓'),  # ⁇
            back         => emojify('⬅'),  # 🡄

            # Main Menu
            local        => emojify('💻'),  # 🞋
            network      => emojify('🖧'),
            settings     => emojify('⚙'),
            exit         => emojify('⬅'),  # 🡄

            # Settings Menu
            a11y         => emojify('♿'),
            ui-prefs     => emojify('🎚'),
            terminal     => emojify('🖵'),

            # Accessibility Menu

            # UI Preferences Menu
            locale       => emojify('🌍'),
            optional-ui  => emojify('☑'),   # 🗹

            # Terminal Menu
            colors       => emojify('🎨'),
            symbols      => emojify('🔣'),
            line-drawing => '╠═',  # ╭╌  ╟─  ╠═  ╔╗  ┌┐  ┬┴
        },
    ;

    $caps.best-symbol-choice(%icons)
}
