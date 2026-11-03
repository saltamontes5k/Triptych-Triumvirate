# Coin Flip -- sample arcade game (Perl). Ten chips a flip; the coin spins on
# a tween. Chips persist per character. Loaded by plugin::arcade_load("coin_flip").

package plugin;

use strict;
use warnings;

sub arcade_game_coin_flip {
	my $BET = 10;

	return {
		key    => "coin_flip",
		title  => "Coin Flip",
		width  => 320,
		height => 250,
		style  => "wood",

		start => sub {
			my ($g) = @_;
			$g->{spin} = 0;
			$g->{busy} = 0;
			$g->{msg}  = "Ten chips a flip. Heads or tails?";
		},

		draw => sub {
			my ($g, $canvas) = @_;
			my $c = $g->saved("chips", 100);

			$canvas->banner("Coin Flip", "gold", { y => 8, size => 24 });

			# the coin: width follows |cos| so it appears to turn
			my $w = int(68 * abs(cos($g->{spin} * 3.14159265 * 6)));
			$w = 4 if $w < 4;
			my $x = 126 + int((68 - $w) / 2);
			$canvas->rect($x, 78, $w, 68, { fill => 0xFFF0C040 });
			$canvas->rect($x + 3, 81, ($w - 6 > 1 ? $w - 6 : 1), 62, { fill => 0xFFF8D870 });

			$canvas->text(126, 160, $g->{msg}, { size => 14, align => 1 });
			$canvas->chip_count(126, 184, $c);
		},

		buttons => [
			[ "Heads", sub { my ($g) = @_; plugin::_cf_flip($g, "heads"); }, color => "blue" ],
			[ "Tails", sub { my ($g) = @_; plugin::_cf_flip($g, "tails"); }, color => "red" ],
		],

		keys => {
			h => sub { my ($g) = @_; plugin::_cf_flip($g, "heads"); },
			t => sub { my ($g) = @_; plugin::_cf_flip($g, "tails"); },
		},
	};
}

sub _cf_flip {
	my ($g, $pick) = @_;
	return if $g->{busy};
	my $c = $g->saved("chips", 100);
	if ($c < 10) {
		$g->{msg} = "You need 10 chips to flip.";
		return;
	}

	$g->{busy}   = 1;
	$g->{pick}   = $pick;
	$g->{result} = (int(rand(2)) == 1) ? "heads" : "tails";
	$g->{spin}   = 0;
	$g->tween($g, "spin", 1, 900, "out", sub {
		my ($gg) = @_;
		$gg->{busy} = 0;
		if ($gg->{result} eq $gg->{pick}) {
			$gg->save("chips", $gg->saved("chips", 100) + 10);
			$gg->{msg} = $gg->{result} . "! +10 chips.";
		}
		else {
			$gg->save("chips", $gg->saved("chips", 100) - 10);
			$gg->{msg} = $gg->{result} . ". -10 chips.";
		}
	});
}

1;
