# Snake (sample arcade game, Perl). Arrow keys or WASD steer; the clock moves
# the snake. Best score persists per character and posts to the top-10 board.
# Loaded by plugin::arcade_load("snake").

package plugin;

use strict;
use warnings;

my $SNAKE_COLS = 20;
my $SNAKE_ROWS = 15;
my $SNAKE_CELL = 18;

sub _snake_opposite {
	my ($a, $b) = @_;
	return ($a eq "up" && $b eq "down") || ($a eq "down" && $b eq "up")
		|| ($a eq "left" && $b eq "right") || ($a eq "right" && $b eq "left");
}

sub arcade_game_snake {
	return {
		key    => "snake",
		title  => "Snake",
		width  => $SNAKE_COLS * $SNAKE_CELL + 20,
		height => $SNAKE_ROWS * $SNAKE_CELL + 60,
		style  => "night",

		start => sub {
			my ($g) = @_;
			$g->{body}     = [ { x => 5, y => 7 }, { x => 4, y => 7 }, { x => 3, y => 7 } ];
			$g->{dir}      = "right";
			$g->{next_dir} = undef;
			$g->{alive}    = 1;
			$g->{score}    = 0;
			$g->{best}     = $g->saved("best", 0);
			plugin::_snake_place_food($g);
			$g->{mover} = $g->every(150, sub { my ($gg) = @_; plugin::_snake_step($gg); });
		},

		draw => sub {
			my ($g, $canvas) = @_;
			$canvas->banner(
				$g->{alive} ? ("Score " . $g->{score}) : ("Game over -- " . $g->{score}),
				$g->{alive} ? "white" : "red",
				{ y => 4, size => 18 });

			$canvas->grid(10, 34, $SNAKE_COLS, $SNAKE_ROWS, $SNAKE_CELL, sub {
				my ($col, $row) = @_;
				my $i = 0;
				for my $seg (@{ $g->{body} }) {
					if ($seg->{x} == $col && $seg->{y} == $row) {
						return ($i == 0) ? 0xFF40E060 : 0xFF209040;
					}
					$i++;
				}
				if ($g->{food} && $g->{food}{x} == $col && $g->{food}{y} == $row) {
					return 0xFFE04040;
				}
				return undef;
			}, { action => 0 });

			if (!$g->{alive}) {
				$canvas->banner("press N for a new game", "gold", { y => $SNAKE_ROWS * $SNAKE_CELL + 20, size => 14 });
			}
		},

		buttons => [
			[ "New game", sub { my ($g) = @_; my $f = $g->{start}; $f->($g) if ref($f) eq 'CODE' && !$g->{alive}; },
				enabled => sub { my ($g) = @_; !$g->{alive}; } ],
		],

		keys => {
			up    => sub { my ($g) = @_; $g->{next_dir} = "up"    if $g->{alive}; },
			w     => sub { my ($g) = @_; $g->{next_dir} = "up"    if $g->{alive}; },
			down  => sub { my ($g) = @_; $g->{next_dir} = "down"  if $g->{alive}; },
			s     => sub { my ($g) = @_; $g->{next_dir} = "down"  if $g->{alive}; },
			left  => sub { my ($g) = @_; $g->{next_dir} = "left"  if $g->{alive}; },
			a     => sub { my ($g) = @_; $g->{next_dir} = "left"  if $g->{alive}; },
			right => sub { my ($g) = @_; $g->{next_dir} = "right" if $g->{alive}; },
			d     => sub { my ($g) = @_; $g->{next_dir} = "right" if $g->{alive}; },
			n     => sub { my ($g) = @_; my $f = $g->{start}; $f->($g) if ref($f) eq 'CODE' && !$g->{alive}; },
		},
	};
}

sub _snake_place_food {
	my ($g) = @_;
	for (1 .. 300) {
		my $x = int(rand($SNAKE_COLS));
		my $y = int(rand($SNAKE_ROWS));
		my $taken = 0;
		for my $seg (@{ $g->{body} }) {
			if ($seg->{x} == $x && $seg->{y} == $y) { $taken = 1; last; }
		}
		if (!$taken) {
			$g->{food} = { x => $x, y => $y };
			return;
		}
	}
	$g->{food} = { x => 0, y => 0 };
}

sub _snake_step {
	my ($g) = @_;
	return unless $g->{alive};

	if (defined $g->{next_dir} && !plugin::_snake_opposite($g->{next_dir}, $g->{dir})) {
		$g->{dir} = $g->{next_dir};
	}
	$g->{next_dir} = undef;

	my $head = $g->{body}[0];
	my ($nx, $ny) = ($head->{x}, $head->{y});
	if    ($g->{dir} eq "up")    { $ny--; }
	elsif ($g->{dir} eq "down")  { $ny++; }
	elsif ($g->{dir} eq "left")  { $nx--; }
	elsif ($g->{dir} eq "right") { $nx++; }

	if ($nx < 0 || $ny < 0 || $nx >= $SNAKE_COLS || $ny >= $SNAKE_ROWS) {
		return plugin::_snake_game_over($g);
	}
	for my $i (0 .. $#{ $g->{body} } - 1) {
		if ($g->{body}[$i]{x} == $nx && $g->{body}[$i]{y} == $ny) {
			return plugin::_snake_game_over($g);
		}
	}

	unshift @{ $g->{body} }, { x => $nx, y => $ny };

	if ($g->{food} && $nx == $g->{food}{x} && $ny == $g->{food}{y}) {
		$g->{score} += 10;
		plugin::_snake_place_food($g);
	}
	else {
		pop @{ $g->{body} };
	}
}

sub _snake_game_over {
	my ($g) = @_;
	$g->{alive} = 0;
	$g->stop($g->{mover}) if $g->{mover};
	$g->halt();
	if ($g->{score} > $g->{best}) {
		$g->{best} = $g->{score};
		$g->save("best", $g->{best});
		$g->leaderboard("best", $g->{best});
	}
}

1;
