# ABSTRACT: Simple TUI for "PFX" particle effect test "game"

use MUGS::Core;
use MUGS::Client::Game::PFX;
use MUGS::UI::TUI;
use MUGS::Util::StructureValidator;

use CBOR::Simple;
use JSON::Fast;
use Terminal::Print::Pixelated;


my class Root is Terminal::Print::Widget does Terminal::Print::Pixelated { }


#| TUI for PFX particle effect test "game"
class MUGS::UI::TUI::Game::PFX is MUGS::UI::TUI::Game {
    has $.grid;
    has $.root-widget;
    has $.update;
    has $.delay-estimate;
    has Lock::Async $!update-lock .= new;

    method game-type() { 'pfx' }

    submethod TWEAK() {
        $!grid        = self.T.current-grid;
        $!root-widget = Root.new-from-grid($!grid);
    }

    method show-initial-state(::?CLASS:D:) {
    }

    method serialization-stats($col, $row, $type, $bytes, $validate, $struct, $codec) {
        my $packets   = ($bytes / 1400).ceiling;
        my $wire-size = ($bytes / 1400).floor * 1542 + $bytes % 1400 + 142;
        my $wire-mbps = 10;
        my $xmit-time = $wire-size * 8 / ($wire-mbps * 1_000_000);

        $!grid.set-span($col, $row,     sprintf('%-12s  %8d', "$type size",
                                                $bytes), '');
        $!grid.set-span($col, $row + 1, sprintf('%-12s  %8d', 'Est. packets',
                                                $packets), '');
        $!grid.set-span($col, $row + 2, sprintf('%-12s  %8d', 'Wire size',
                                                $wire-size), '');
        $!grid.set-span($col, $row + 3, sprintf('%-12s  %6.1fms',
                                                "{$wire-mbps}Mbps time",
                                                $xmit-time * 1000), '');
        $!grid.set-span($col, $row + 4, sprintf('%-12s  %6.1fms', 'Valid time',
                                                $validate * 1000), '');
        $!grid.set-span($col, $row + 5, sprintf('%-12s  %6.1fms', 'Struct time',
                                                $struct * 1000), '');
        $!grid.set-span($col, $row + 6, sprintf('%-12s  %6.1fms', 'Codec time',
                                                $codec * 1000), '');
        $!grid.set-span($col, $row + 7, sprintf('%-12s  %6.1fms', 'Total time',
                                                ($validate + $struct + $codec
                                                 + $xmit-time) * 1000), '');
    }

    method CBOR-stats($col, $row, $message) {
        constant %schema = {
            format         => 'single-array',
            game-id        => GameID,
            character-name => Str,
            update-sent    => Instant(Num),
            game-time      => Duration(Num),
            dt             => Duration(Num),
            effects        => [
                               {
                                   type      => Str,
                                   particles => array[num32],
                               }
                           ],
        };

       VM.request-garbage-collection;
        my $t1 = now;
        my $struct      = $message.to-struct;
        my $msg         = MUGS::Message::Push.from-struct($struct);
        my $ts = now - $t1;

        my $t2 = now;
        my $cbor        = cbor-encode $struct;
        my $cbor-bytes  = $cbor.bytes;
        my $cbor-struct = cbor-decode $cbor;
        my $tc = now - $t2;

        my $t3 = now;
        validate-structure('CBOR', $cbor-struct<data>, %schema);
        my $tv = now - $t3;

        self.serialization-stats($col, $row, 'CBOR', $cbor-bytes, $tv, $ts, $tc);
    }

    method JSON-stats($col, $row, $message) {
        constant %schema = {
            format         => 'single-array',
            game-id        => GameID,
            character-name => Str,
            update-sent    => DateTime(Str),
            game-time      => Duration(Num),
            dt             => Duration(Num),
            effects        => [
                               {
                                   type      => Str,
                                   particles => [ Num ],
                               }
                           ],
        };

        VM.request-garbage-collection;
        my $t1 = now;
        my $struct      = $message.to-struct;
        my $msg         = MUGS::Message::Push.from-struct($struct);
        my $ts = now - $t1;

        my $t2 = now;
        my $json        = to-json $struct, :!pretty;
        my $json-bytes  = $json.encode.bytes;
        my $json-struct = from-json $json;
        my $tj = now - $t2;

        my $t3 = now;
        validate-structure('JSON', $json-struct<data>, %schema);
        my $tv = now - $t3;

        self.serialization-stats($col, $row, 'JSON', $json-bytes, $tv, $ts, $tj);
    }

    method general-stats($col, $row, $message, $validated, $tr, $delay, $wait, $tc) {
        my $count       = $validated<effects>[0]<particles>.elems / 7;
        my $clock-skew  = $message.created - $validated<update-sent>;

        $!grid.set-span($col, $row,     sprintf('%-12s  %8d', 'Particles', $count), '');
        $!grid.set-span($col, $row + 1, sprintf('%-12s  %6.1fm‭s', 'Clock skew',
                                                $clock-skew * 1000), '');
        $!grid.set-span($col, $row + 2, sprintf('%-12s  %6.1fm‭s', 'Est. delay',
                                                $delay * 1000), '');
        $!grid.set-span($col, $row + 3, sprintf('%-12s  %6.1fm‭s', 'Wait time',
                                                $wait * 1000), '');
        $!grid.set-span($col, $row + 4, sprintf('%-12s  %6.1fm‭s', 'Time comp',
                                                $tc * 1000), '');
        $!grid.set-span($col, $row + 5, sprintf('%-12s  %6.1fm‭s', 'Render time',
                                                $tr * 1000), '');
        $!grid.set-span($col, $row + 6, sprintf('%-12s  %6.1fms', 'Δt',
                                                $validated<dt> * 1000), '');
        $!grid.set-span($col, $row + 7, sprintf('%-12s  %8.3f', 'Game time',
                                                $validated<game-time>), '');
    }

    method show-stats($message, $validated, $tr, $delay, $wait, $tc) {
        self.general-stats(0,  0, $message, $validated, $tr, $delay, $wait, $tc);
        # self.CBOR-stats(   0,  9, $message);
        # self.JSON-stats(   0, 18, $message);
    }

    method render-particles($validated, num $tc) {
        my int $w   = $.grid.w;
        # my int $h   = $.grid.h;
        my int $h   = $.grid.h * 2;  # Using Unicode half-height blocks
        my int $cx  = $w div 2;
        my int $cy  = $h div 2;
        my num $r   = (min $cx, $cy).Num;
        my num $tc2 = $tc / 2e0;

        my @colors;
        my $color = 16;
        for @($validated<effects>) -> $effect {
            for @($effect<particles>) -> num $x,  num $y,
                                         num $vx, num $vy,
                                         num $ax, num $ay,
                                         num $tc {
                # Compensate for time waiting for render to begin
                my num $x-comp =  $x + ($vx + $ax * $tc2) * $tc;
                my num $y-comp =  $y + ($vy + $ay * $tc2) * $tc;

                # Scale, flip Y dimension, and recenter to current particle area
                my int $px = ( $x * $r).floor + $cx;
                my int $py = (-$y * $r).floor + $cy;

                # Keep color matching particle number
                $color++;

                # Don't draw particles outside viewport
                next if $px < 0 || $px >= $w
                     || $py < 0 || $py >= $h;

                # Different particle renderers with different performance profiles
                # $!grid.print-string($px, $py, '*');
                # $!grid.change-cell($px, $py, '*');
                $!grid.change-cell($px, $py +> 1, $!grid.cell('*', ~$color));
                # @colors[$py][$px] = ~$color;
            }
        }
        # Only needed if half-height block "pixels" are being computed
        $!root-widget.composite-pixels(@colors) if @colors;
    }


    method render-latest-update() {
        my $update;
        my $delay-estimate;
        $!update-lock.protect: {
            $update         = $!update;
            $delay-estimate = $!delay-estimate;
        }
        return unless $update;

        # Current algorithm:
        # During render, compensate for expected particle motion *only* for
        # delay caused by update waiting for next available render frame, *not*
        # for the time lag + clock skew between the server and client.

        my $update-wait       = now - $update<message>.created;
        my $time-compensation = $update-wait;

        my $t0 = now;
        $!grid.clear;
        self.render-particles($update<validated>, $time-compensation.Num);
        my $tr = now - $t0;

        self.show-stats($update<message>, $update<validated>, $tr,
                        $delay-estimate, $update-wait, $time-compensation);

        print $!grid;
    }

    method validate-and-save-update($message) {
        constant %schema = {
            format         => 'effect-arrays',
            game-id        => GameID,
            character-name => Str,
            update-sent    => Instant(Num),
            game-time      => Duration(Num),
            dt             => Duration(Num),
            effects        => [
                               {
                                   type      => Str,
                                   particles => array[num32],
                               }
                           ],
        };

        my $validated = $message.validated-data(%schema);
        my $delay     = $message.created - $validated<update-sent>;
        my $alpha     = .1e0;

        $!update-lock.protect: {
            $!update = hash(:$message, :$validated);

            # Estimate delivery delay with an EWMA (Exponentially Weighted Moving Average)
            $!delay-estimate //= $delay;
            $!delay-estimate   = (1 - $alpha) * $!delay-estimate + $alpha * $delay;
        }
    }

    method handle-game-event($message) {
        constant %schema = {
            event => {
                event-type => GameEventType(Int),
            }
        };

        my $validated  = $message.validated-data(%schema)<event>;
        my $event-type = GameEventType($validated<event-type>);

        self.show-initial-state if $event-type == GameStarted;
    }

    method handle-server-message($message) {
        given $message.type {
            when 'game-update' {
                self.validate-and-save-update($message);
            }
            when 'game-event'  {
                self.handle-game-event($message);
            }
        }
    }

    method main-loop(::?CLASS:D:) {
        react {
            whenever Supply.interval(.033) {
                self.render-latest-update;
            }
            whenever $.in {
                when 'q' { await $.client.leave; done  }
                when ' ' { $.client.send-pause-request }
            }
            whenever $.ui-control.Channel.Supply {
                when 'exit' { await $.client.leave; done }
            }
        }
    }
}


# Register this class as a valid game UI
MUGS::UI::TUI::Game::PFX.register;
