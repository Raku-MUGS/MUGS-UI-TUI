# ABSTRACT: "Test language" translations for App::TUI

unit module MUGS::App::TUI::Translations::Test;


#| All expected app contexts for translating words and phrases, with
#| context descriptions to assist translators
sub translation-contexts() is export {
    constant @contexts =
        { moniker => 'main-menu',
          desc    => 'Main Menu entries, hints, titles, and breadcrumbs' },
        { moniker => 'settings-menu',
          desc    => 'Settings Menu entries, hints, titles, and breadcrumbs' },
        { moniker => 'a11y-menu',
          desc    => 'Accessibility Menu entries, hints, titles, and breadcrumbs' },
        { moniker => 'ui-prefs-menu',
          desc    => 'UI Preferences Menu entries, hints, titles, and breadcrumbs' },
        { moniker => 'terminal-menu',
          desc    => 'Terminal Settings Menu entries, hints, titles, and breadcrumbs' },
        { moniker => 'available-games',
          desc    => 'Available Games screen elements' },
        { moniker => 'optional-ui',
          desc    => 'Optional UI form elements' },
    ;
}


#| Translation table for pig ("Pig Latin")
#  Easy to notice, and tests widening every screen element
sub trans-pig() {
    constant %trans =
        main-menu => {
            # Breadcrumbs / title
            'Main'                     => 'Ainmay',
            'Main Menu | MUGS'         => 'Ainmay EnuMay | UGSMAY',

            # Menu entries
            'Local Play'               => 'Ocallay Ayplay',
            'Network Play'             => 'Etworknay Ayplay',
            'Settings'                 => 'Ettingsay',
            'HELP!'                    => 'ELPHAY!',
            'Exit MUGS'                => 'Exitway UGSMAY',

            # Menu entry hints
            'Play locally in solo, turns, or multi-controller modes'
            => 'Ayplay ocallylay inway olosay, urnstay, orway ultimay-ontrollercay odesmay',

            'Join a network server and play worldwide'
            => 'Oinjay away etworknay erversay andway ayplay orldwideway',

            'Configure settings and preferences'
            => 'Onfigurecay ettingsay andway eferencespray',

            'View documentation and other help info'
            => 'Iewvay ocumentationday andway otherway elphay infoway',

            'Disconnect from all games and servers and quit MUGS'
            => 'Isconnectday omfray allway amesgay andway erverssay andway itquay UGSMAY',
        },
        settings-menu => {
            # Breadcrumbs / title
            'Settings'                 => 'Ettingsay',
            'Settings Menu | MUGS'     => 'Ettingsay EnuMay | UGSMAY',

            # Menu entries
            'Accessibility'            => 'Accessibilityway',
            'UI Preferences'           => 'UIWAY Eferencespray',
            'Terminal'                 => 'Erminaltay',
            'HELP!'                    => 'ELPHAY!',
            'Back to Main Menu'        => 'Ackbay otay Ainmay Enumay',

            # Menu entry hints
            'Configure accessibility features and assistive technologies'
            => 'Onfigurecay accessibilityway eaturesfay andway assistiveway echnologiestay',

            'Adjust UI preferences such as locale, themes, and animation'
            => 'Adjustway UIWAY eferencespray uchsay asway ocalelay, emesthay, andway animationway',

            'Adjust terminal settings such as standards and font support'
            => 'Adjustway erminaltay ettingsay uchsay asway andardsstay andway ontfay upportsay',

            'View help info related to settings'
            => 'Iewvay elphay infoway elatedray otay ettingssay',

            'Return to top level main menu'
            => 'Eturnway otay optay evellay ainmay enumay',
        },
        a11y-menu => {
            # Breadcrumbs / title
            'Accessibility'            => 'Accessibilityway',
            'Accessibility | MUGS'     => 'Accessibilityway | UGSMAY',

            # Menu entries
            'HELP!'                    => 'ELPHAY!',
            'Back to Settings Menu'    => 'Ackbay otay Ettingssay Enumay',

            # Menu entry hints
            'View help info related to accessibility settings'
            => 'Iewvay elphay infoway elatedray otay accessibilityway ettingssay',

            'Return to previous menu level (Settings)'
            => 'Eturnray otay eviouspray enumay evellay (Ettingsay)',
        },
        ui-prefs-menu => {
            # Breadcrumbs / title
            'UI Preferences'           => 'UIWAY Eferencespray',
            'UI Preferences | MUGS'    => 'UIWAY Eferencespray | UGSMAY',

            # Menu entries
            'Locale'                   => 'Ocalelay',
            'Optional Elements'        => 'Optionalway Elementsway',
            'HELP!'                    => 'ELPHAY!',
            'Back to Settings Menu'    => 'Ackbay otay Ettingssay Enumay',

            # Menu entry hints
            'Tweak or override system locale settings'
            => 'Eaktway orway overrideway ystemsay ocalelay ettingssay',

            'Show or hide optional UI elements'
            => 'Owshay orway idehay optionalway UIWAY elementsway',

            'View help info related to UI preferences'
            => 'Iewvay elphay infoway elatedray otay UIWAY eferencespray',

            'Return to previous menu level (Settings)'
            => 'Eturnray otay eviouspray enumay evellay (Ettingsay)',
        },
        terminal-menu => {
            # Breadcrumbs / title
            'Terminal'                 => 'Erminaltay',
            'Terminal Settings | MUGS' => 'Erminaltay Ettingssay | UGSMAY',

            # Menu entries
            'Color Support'            => 'Olorcay Upportsay',
            'Symbol Support'           => 'Ymbolsay Upportsay',
            'Line Drawing Support'     => 'Inelay Awingdray Upportsay',
            'HELP!'                    => 'ELPHAY!',
            'Back to Settings Menu'    => 'Ackbay otay Ettingssay Enumay',

            # Menu entry hints
            'Set color and attribute capabilities for this terminal'
            => 'Etsay olorcay andway attributeway apabilitiescay orfay isthay erminaltay',

            'Set symbol set support level for this terminal'
            => 'Etsay ymbolsay etsay upportsay evellay orfay isthay erminaltay',

            'Set line drawing support level for this terminal'
            => 'Etsay inelay awingdray upportsay evellay orfay isthay erminaltay',

            'View help info related to terminal settings'
            => 'Iewvay elphay infoway elatedray otay erminaltay ettingsay',

            'Return to previous menu level (Settings)'
            => 'Eturnray otay eviouspray enumay evellay (Ettingsay)',
        },
        available-games => {
            # Breadcrumbs / title
            'Available Games'          => 'Availableway Amesgay',
            'Available Games | MUGS'   => 'Availableway Amesgay | UGSMAY',

            # Buttons
            'HELP!'                    => 'ELPHAY!',
            'Back to Main Menu'        => 'Ackbay otay Ainmay Enumay',

            # Misc text
            'Searching'                 => 'Earchingsay',
            'No compatible games found' => 'Onay ompatiblecay amesgay oundfay',

            # Button hints
            'View help info related to available games'
            => 'Iewvay elphay infoway elatedray otay availableway amesgay',

            'Return to top level main menu'
            => 'Eturnway otay optay evellay ainmay enumay',
        },
        optional-ui => {
            # Breadcrumbs / title
            'Optional Elements'           => 'Optionalway Elementsway',
            'Optional UI Elements | MUGS' => 'Optionalway UIWAY Elementsway | UGSMAY',

            # Form options
            'Optional visuals'            => 'Optionalway isualsway',
            'Menu item icons'             => 'Enumay itemway iconsway',
            'Input activation flash'      => 'Inputway activationway ashflay',
            'Input field hints'           => 'Inputway ieldfay intshay',

            'History navigation'          => 'Istoryhay avigationnay',
            'Breadcrumbs only'            => 'Eadcrumbsbray onlyway',
            'Buttons/menu items only'     => 'Uttonsbay/enumay itemsway onlyway',
            'Both'                        => 'Othbay',

            'Menu headers'                => 'Enumay eadershay',
            'Large'                       => 'Argelay',
            'Small'                       => 'Allsmay',
            'None'                        => 'Onenay',

            # Buttons
            'HELP!'                       => 'ELPHAY!',
            'Save Changes'                => 'Avesay Angeschay',
            'Cancel and Go Back'          => 'Ancelcay andway Ogay Ackbay',

            # Form element hints
            # XXXX: FILL IN

            'View help info related to optional UI elements'
            => 'Iewvay elphay infoway elatedray otay optionalway UIWAY elementsway',
        },
    ;
}


#| Generated translation table for en (English)
sub trans-en() {
    constant %trans = trans-pig().map({.key => .value.map({.key => .key}).hash});
}


#| Generated translation table for double (doubled glyphs)
sub trans-double() {
    my sub double-pair($s) { $s => $s.comb.map(* x 2).join }
    constant %trans = trans-pig().map({.key => .value.keys.map(&double-pair).hash});
}


#| All provided translation languages, with ISO or test code, language name
#| in English, language name in its own language, and translation loader
#| routine for each
sub translation-languages() is export {
    constant @languages =
        { iso-code => 'en',
          english  => 'English',
          native   => 'English',
          loader   => &trans-en },
        { iso-code => 'pig',
          english  => 'Pig Latin',
          native   => 'Igpay Atinlay',
          loader   => &trans-pig },
        { iso-code => 'double',
          english  => 'Doubled',
          native   => 'DDoouubblleedd',
          loader   => &trans-double },
    ;
}
