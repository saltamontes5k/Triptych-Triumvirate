# Blackjack (sample arcade game, Perl). Ten-chip bets, 3:2 blackjack, dealer
# stands on 17. The hole card flips on a tween when you stand.
# Loaded by plugin::arcade_load("blackjack").

package plugin;

use strict;
use warnings;

my @BJ_SUITS = ("h", "d", "c", "s");

sub _bj_rank_value {
	my ($rank) = @_;
	return 11 if $rank eq "A";
	return 10 if $rank eq "J" || $rank eq "Q" || $rank eq "K";
	return $rank;
}

# aces drop from 11 to 1 as needed; $hide_hole skips index 1 (the hole card)
sub _bj_hand_value {
	my ($hand, $hide_hole) = @_;
	my ($total, $aces) = (0, 0);
	my $i = 0;
	for my $card (@$hand) {
		if (!($hide_hole && $i == 1)) {
			$total += plugin::_bj_rank_value($card->{rank});
			$aces++ if $card->{rank} eq "A";
		}
		$i++;
	}
	while ($total > 21 && $aces > 0) {
		$total -= 10;
		$aces--;
	}
	return $total;
}

sub _bj_new_deck {
	my @deck;
	for my $suit (@BJ_SUITS) {
		for my $rank (2 .. 10) {
			push @deck, { rank => $rank, suit => $suit };
		}
		for my $face ("J", "Q", "K", "A") {
			push @deck, { rank => $face, suit => $suit };
		}
	}
	for my $i (reverse 1 .. $#deck) {
		my $j = int(rand($i + 1));
		@deck[ $i, $j ] = @deck[ $j, $i ];
	}
	return \@deck;
}

sub arcade_game_blackjack {
	return {
		key    => "blackjack",
		title  => "Blackjack",
		width  => 460,
		height => 320,
		style  => "wood",

		start => sub {
			my ($g) = @_;
			$g->{phase} = "bet";
			$g->{msg}   = "Ten chips a hand. Deal when ready.";
			$g->{ph}    = [];
			$g->{dh}    = [];
			$g->{deck}  = undef;
			$g->refresh();
		},

		draw => sub {
			my ($g, $canvas) = @_;
			$canvas->banner("Blackjack", "gold", { y => 4, size => 22 });

			# dealer row
			$canvas->text(16, 40, "Dealer", { size => 12, color => "gray" });
			my $i = 0;
			for my $card (@{ $g->{dh} }) {
				if ($i == 1 && ($card->{flip} // 0) < 1) {
					$canvas->card(120 + $i * 44, 58, undef, {});
				}
				else {
					$canvas->card(120 + $i * 44, 58, $card);
				}
				$i++;
			}
			if (scalar @{ $g->{dh} }) {
				my $hide = ($g->{phase} ne "done" && $g->{phase} ne "dealer") ? 1 : 0;
				$canvas->text(400, 62, plugin::_bj_hand_value($g->{dh}, $hide), { size => 14, color => "gray" });
			}

			# player row
			$canvas->text(16, 130, "You (" . plugin::_bj_hand_value($g->{ph}) . ")", { size => 12, color => "gray" });
			$i = 0;
			for my $card (@{ $g->{ph} }) {
				$canvas->card(120 + $i * 44, 148, $card);
				$i++;
			}

			$canvas->text(230, 240, $g->{msg}, { size => 14, align => 1 });
			$canvas->chip_count(230, 262, $g->saved("chips", 100));
			$canvas->chip_stack(60, 250, int($g->saved("chips", 100) / 100));
		},

		buttons => [
			[ "Deal",     sub { my ($g) = @_; plugin::_bj_deal($g); },
				enabled => sub { my ($g) = @_; $g->{phase} eq "bet" || $g->{phase} eq "done"; }, color => "green" ],
			[ "Hit",      sub { my ($g) = @_; plugin::_bj_hit($g); },
				enabled => sub { my ($g) = @_; $g->{phase} eq "player"; } ],
			[ "Stand",    sub { my ($g) = @_; plugin::_bj_stand($g); },
				enabled => sub { my ($g) = @_; $g->{phase} eq "player"; }, color => "red" ],
			[ "New hand", sub { my ($g) = @_; my $f = $g->{start}; $f->($g) if ref($f) eq 'CODE'; },
				enabled => sub { my ($g) = @_; $g->{phase} eq "done"; } ],
		],

		keys => {
			h => sub { my ($g) = @_; plugin::_bj_hit($g); },
			s => sub { my ($g) = @_; plugin::_bj_stand($g); },
			d => sub { my ($g) = @_; plugin::_bj_deal($g); },
		},
	};
}

sub _bj_deal {
	my ($g) = @_;
	return if $g->{phase} ne "bet" && $g->{phase} ne "done";
	if ($g->saved("chips", 100) < 10) {
		$g->{msg} = "You need 10 chips for a hand.";
		return;
	}

	$g->{deck} = plugin::_bj_new_deck();
	$g->{ph}   = [];
	$g->{dh}   = [];
	$g->{phase} = "dealing";
	$g->{msg}   = "";

	push @{ $g->{ph} }, pop @{ $g->{deck} };
	push @{ $g->{dh} }, pop @{ $g->{deck} };
	push @{ $g->{ph} }, pop @{ $g->{deck} };
	push @{ $g->{dh} }, pop @{ $g->{deck} };   # hole card
	$g->{dh}[1]{flip} = 0;

	$g->after(500, sub {
		my ($gg) = @_;
		my $pv = plugin::_bj_hand_value($gg->{ph});
		my $dv = plugin::_bj_hand_value($gg->{dh}, 1);
		if ($pv == 21 || $dv == 21) {
			plugin::_bj_reveal($gg, 1);
		}
		else {
			$gg->{phase} = "player";
			$gg->{msg}   = "Hit or stand?";
		}
	});
}

sub _bj_hit {
	my ($g) = @_;
	return if $g->{phase} ne "player";
	push @{ $g->{ph} }, pop @{ $g->{deck} };
	my $v = plugin::_bj_hand_value($g->{ph});
	if ($v > 21) {
		plugin::_bj_reveal($g, 0, "bust");
	}
	elsif ($v == 21) {
		plugin::_bj_stand($g, 1);
	}
}

sub _bj_stand {
	my ($g, $auto) = @_;
	return if $g->{phase} ne "player" && !$auto;
	$g->{phase} = "dealer";

	# reveal the hole card with a flip tween, then the dealer draws to 17
	$g->tween($g->{dh}[1], "flip", 1, 400, "linear", sub {
		my ($gg) = @_;
		my $draw_more;
		$draw_more = sub {
			my ($dg) = @_;
			my $v = plugin::_bj_hand_value($dg->{dh});
			if ($v < 17) {
				push @{ $dg->{dh} }, pop @{ $dg->{deck} };
				$dg->after(350, $draw_more);
			}
			else {
				plugin::_bj_settle($dg);
			}
		};
		$draw_more->($gg);
	});
}

sub _bj_reveal {
	my ($g, $natural, $how) = @_;
	$g->{phase} = "done";
	$g->tween($g->{dh}[1], "flip", 1, 400, "linear", sub {
		my ($gg) = @_;
		if ($natural) {
			my $pv = plugin::_bj_hand_value($gg->{ph});
			my $dv = plugin::_bj_hand_value($gg->{dh});
			plugin::_bj_settle($gg, ($pv == 21 && $dv == 21) ? "push" : "blackjack");
		}
		elsif (defined $how && $how eq "bust") {
			plugin::_bj_settle($gg, "bust");
		}
		else {
			plugin::_bj_settle($gg);
		}
	});
}

sub _bj_settle {
	my ($g, $how) = @_;
	$g->{phase} = "done";

	if (!defined $how) {
		my $pv = plugin::_bj_hand_value($g->{ph});
		my $dv = plugin::_bj_hand_value($g->{dh});
		if ($dv > 21)        { $how = "dealer_bust"; }
		elsif ($pv > $dv)    { $how = "win"; }
		elsif ($pv < $dv)    { $how = "lose"; }
		else                 { $how = "push"; }
	}

	my $c = $g->saved("chips", 100);
	if ($how eq "win" || $how eq "dealer_bust") {
		$g->save("chips", $c + 10);
		$g->{msg} = "You win +10 chips!";
	}
	elsif ($how eq "blackjack") {
		$g->save("chips", $c + 25);
		$g->{msg} = "Blackjack! +25 chips.";
	}
	elsif ($how eq "push") {
		$g->{msg} = "Push -- bet returned.";
	}
	else {
		$g->save("chips", $c - 10);
		$g->{msg} = $how eq "bust" ? "Bust. -10 chips." : "Dealer wins. -10 chips.";
	}

	$g->leaderboard("chips", $g->saved("chips", 100));
	$g->refresh();
}

1;
