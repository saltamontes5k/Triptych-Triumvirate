# Tic-Tac-Toe vs the gnome (sample arcade game, Perl).
# Click a square; the gnome answers half a second later. Saves wins and posts
# them to the shared top-10 board. Loaded by plugin::arcade_load("tic_tac_toe").

package plugin;

use strict;
use warnings;

my @TTT_LINES = (
	[1,2,3],[4,5,6],[7,8,9],
	[1,4,7],[2,5,8],[3,6,9],
	[1,5,9],[3,5,7],
);

sub _ttt_winner {
	my ($board) = @_;
	for my $line (@TTT_LINES) {
		my $v = $board->{ $line->[0] };
		if (defined $v && defined $board->{ $line->[1] } && $v eq $board->{ $line->[1] }
			&& defined $board->{ $line->[2] } && $v eq $board->{ $line->[2] }) {
			return ($v, $line);
		}
	}
	for my $i (1 .. 9) {
		return (undef, undef) unless defined $board->{$i};
	}
	return ("draw", undef);
}

sub arcade_game_tic_tac_toe {
	return {
		key    => "tic_tac_toe",
		title  => "Tic-Tac-Toe",
		width  => 300,
		height => 330,
		style  => "wood",

		start => sub {
			my ($g) = @_;
			plugin::_ttt_new_board($g);
		},

		draw => sub {
			my ($g, $canvas) = @_;
			my $headline = "Your move (X)";
			$headline = "Draw!"               if $g->{over} eq "draw";
			$headline = "You win!"            if $g->{over} eq "X";
			$headline = "The gnome wins!"     if $g->{over} eq "O";
			$canvas->banner($headline, "gold", { y => 6, size => 22 });

			$canvas->grid(30, 50, 3, 3, 78, sub {
				my ($col, $row) = @_;
				my $v = $g->{board}{ $row * 3 + $col + 1 };
				return undef unless defined $v;
				return 0xFF24365C if $v eq "X";
				return 0xFF5C2830 if $v eq "O";
				return undef;
			}, { action => 1 });

			for my $i (1 .. 9) {
				next unless defined $g->{board}{$i};
				my $col = ($i - 1) % 3;
				my $row = int(($i - 1) / 3);
				my $c   = ($g->{board}{$i} eq "X") ? 0xFF80A0FF : 0xFFFF9090;
				$canvas->text(30 + $col * 78 + 39, 50 + $row * 78 + 24, $g->{board}{$i},
					{ size => 34, align => 1, color => $c });
			}

			if ($g->{strike}) {
				my @line = @{ $g->{strike} };
				my $c1 = sub { my ($i) = @_; return (30 + (($i - 1) % 3) * 78 + 39, 50 + int(($i - 1) / 3) * 78 + 39); };
				my ($x1, $y1) = $c1->($line[0]);
				my ($x2, $y2) = $c1->($line[2]);
				$canvas->line($x1, $y1, $x2, $y2, "gold", 4);
			}

			$canvas->chip_count(150, 286, $g->saved("wins", 0));
			$canvas->text(150, 286, "wins", { size => 12, align => 1 });
		},

		on_grid => sub {
			my ($g, $cell) = @_;
			$cell += 1;    # engine cell index is 0-based; the board is 1..9
			plugin::_ttt_play($g, $cell);
		},

		buttons => [
			[ "New game", sub { my ($g) = @_; plugin::_ttt_new_board($g); } ],
		],

		keys => {
			n => sub { my ($g) = @_; plugin::_ttt_new_board($g); },
		},
	};
}

sub _ttt_new_board {
	my ($g) = @_;
	$g->{board}  = {};
	$g->{turn}   = "X";
	$g->{over}   = undef;
	$g->{strike} = undef;
	$g->refresh();
}

sub _ttt_play {
	my ($g, $square) = @_;
	return if $g->{over};
	return if $g->{turn} ne "X";
	return if defined $g->{board}{$square};

	$g->{board}{$square} = "X";
	plugin::_ttt_check($g);
	if (!$g->{over}) {
		$g->{turn} = "O";
		$g->after(500, sub { my ($gg) = @_; plugin::_ttt_gnome($gg); });
	}
}

sub _ttt_gnome {
	my ($g) = @_;
	return if $g->{over};

	my @open = grep { !defined $g->{board}{$_} } (1 .. 9);

	my $finds = sub {
		my ($want) = @_;
		for my $line (@TTT_LINES) {
			my ($mine, $other, $spot) = (0, 0, undef);
			for my $i (@$line) {
				my $v = $g->{board}{$i};
				if (defined $v && $v eq $want) { $mine++; }
				elsif (defined $v)             { $other++; }
				else                           { $spot = $i; }
			}
			return $spot if $mine == 2 && $other == 0 && defined $spot;
		}
		return undef;
	};

	my $move = $finds->("O") // $finds->("X");
	if (!defined $move) {
		for my $c (1, 3, 7, 9) {
			if (!defined $g->{board}{$c}) { $move = $c; last; }
		}
	}
	$move = $open[ int(rand(scalar @open)) ] if !defined $move && @open;
	return unless defined $move;

	$g->{board}{$move} = "O";
	plugin::_ttt_check($g);
	$g->{turn} = "X" if !$g->{over};
}

sub _ttt_check {
	my ($g) = @_;
	my ($who, $line) = plugin::_ttt_winner($g->{board});
	if (defined $who && $who eq "X") {
		$g->{over}   = "X";
		$g->{strike} = $line;
		$g->save("wins", $g->saved("wins", 0) + 1);
		$g->leaderboard("wins", $g->saved("wins", 0));
	}
	elsif (defined $who && $who eq "O") {
		$g->{over}   = "O";
		$g->{strike} = $line;
	}
	elsif (defined $who && $who eq "draw") {
		$g->{over} = "draw";
	}
}

1;
