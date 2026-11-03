# NMS_arcade.pl -- Perl side of the NMS arcade library for EQS.
#
# Port of the NMS arcade manual's game framework onto the local NMSWindow
# engine (zone/nms_window.h + eqgame_dll/nms_window.cpp). Game files live in
# quests/plugins/arcade_game_<name>.pl defining `sub arcade_game_<name>`
# returning the game hash; plugin::arcade_load("<name>") resolves them (every
# plugin file is evaluated into the shared plugin:: package by the engine's
# auto-loader).
#
# Host NPC glue (all three handlers required):
#   sub EVENT_SAY {
#     plugin::arcade_npc($npc, $client, $text, { dice => plugin::arcade_load("dice") });
#   }
#   sub EVENT_TIMER {
#     plugin::arcade_on_timer($npc) if $timer eq "arcade";
#   }
#   sub EVENT_NMS_WINDOW {
#     plugin::arcade_on_window($client, {
#       window_id => $nms_window_id, kind => $nms_kind, action => $nms_action,
#       value => $nms_value, text => $nms_text,
#     });
#   }
#
# Deviations from the NMS manual (documented for the Lua side too): the
# helpers take the quest event context explicitly; game files load from
# plugins/ not quests/arcade_games/; the clock ticks at the quest-timer rate
# (20/s when the zone quest timer runs at 50 ms).
#
# Persistence rides data_buckets via quest::set_data/get_data, mirroring the
# Lua library: "arcade_<game>_<charid>_<name>" per character, and shared
# "arcade_lb_<game>_<board>" top-10 boards.

package plugin;

use strict;
use warnings;
use Time::HiRes qw(time);

my %INSTANCES;      # window_id => game instance
my %BY_NPC_CHAR;    # npc_id:charid => instance
my %CLICK_FNS;      # window_id => {action => fn}
my %GRID_FNS;
my %BUTTON_FNS;     # window_id => {action => fn}
my $TIMER_MS = 50;
my $PIECE_LIMIT = 290;

my %COLORS = (
	white => 0xFFFFFFFF, black => 0x00000000 + 0xFF000000, red => 0xFFC02020,
	green => 0xFF30C030, blue => 0xFF3050C0, gold => 0xFFFFD700,
	yellow => 0xFFFFFF00, orange => 0xFFFFA500, cyan => 0xFF00CED1,
	purple => 0xFF9F30C0, gray => 0xFF909090, grey => 0xFF909090,
	pink => 0xFFFF69B4, none => 0,
);

sub arcade_color {
	my ($c, $default) = @_;
	return $default // 0 unless defined $c;
	return $c if $c =~ /^\d+$/;
	my $lower = lc($c);
	return $COLORS{$lower} if exists $COLORS{$lower};
	$lower =~ s/^#//;
	$lower =~ s/^0x//;
	if ($lower =~ /^[0-9a-fA-F]+$/) {
		my $v = hex($lower);
		$v += 0xFF000000 if length($lower) == 6;
		return $v;
	}
	return $default // 0;
}

sub arcade_commas {
	my ($n) = @_;
	my $s = sprintf("%d", $n);
	1 while $s =~ s/^(-?\d+)(\d{3})/$1,$2/;
	return $s;
}

sub _num { my ($v) = @_; return sprintf("%.0f", $v); }

sub _data_key { my ($g, $cid, $n) = @_; return "arcade_${g}_${cid}_${n}"; }
sub _lb_key { my ($g, $b) = @_; return "arcade_lb_${g}_${b}"; }

# ---------------------------------------------------------------------------
# game instance methods (games call these as methods, per the manual)
# ---------------------------------------------------------------------------
package NMSArcade;

sub saved {
	my ($self, $name, $default) = @_;
	my $client = $self->{you} or return $default;
	my $v = quest::get_data(plugin::_data_key($self->{key}, $client->CharacterID(), $name));
	return $default if !defined $v || $v eq "";
	return $v + 0 if $v =~ /^-?\d+$/;
	return $v;
}

sub save {
	my ($self, $name, $value) = @_;
	my $client = $self->{you} or return;
	quest::set_data(plugin::_data_key($self->{key}, $client->CharacterID(), $name), "$value");
}

sub leaderboard {
	my ($self, $board, $value) = @_;
	my $client = $self->{you} or return;
	return unless defined $value;
	$value = int($value);

	my $k = plugin::_lb_key($self->{key}, $board);
	my %entries;
	my $stored = quest::get_data($k) || "";
	for my $chunk (split /;/, $stored) {
		if ($chunk =~ /^(.*):(-?\d+)$/) { $entries{$1} = $2 + 0; }
	}
	my $me = $client->GetName();
	return if exists $entries{$me} && $entries{$me} >= $value;
	$entries{$me} = $value;

	my @list = map { { name => $_, value => $entries{$_} } } keys %entries;
	@list = sort { $b->{value} <=> $a->{value} } @list;
	my @parts = map { $_->{name} . ":" . $_->{value} } @list[0 .. (scalar(@list) > 10 ? 9 : $#list)];
	quest::set_data($k, join(";", @parts));
}

sub top {
	my ($self, $board, $n) = @_;
	$n //= 10;
	my $stored = quest::get_data(plugin::_lb_key($self->{key}, $board)) || "";
	my @out;
	for my $chunk (split /;/, $stored) {
		if ($chunk =~ /^(.*):(-?\d+)$/) { push @out, { name => $1, value => $2 + 0 }; }
	}
	@out = sort { $b->{value} <=> $a->{value} } @out;
	$#out = $n - 1 if $#out >= $n;
	return \@out;
}

sub client { my ($self) = @_; return $self->{you}; }

sub every {
	my ($self, $ms, $fn) = @_;
	push @{ $self->{_timers} }, { t0 => time(), ms => $ms, fn => $fn, rep => 1 };
}

sub after {
	my ($self, $ms, $fn) = @_;
	push @{ $self->{_timers} }, { t0 => time(), ms => $ms, fn => $fn, rep => 0 };
}

sub stop {
	my ($self, $handle) = @_;
	@{ $self->{_timers} } = grep { $_ != $handle } @{ $self->{_timers} };
}

sub tween {
	my ($self, $obj, $field, $to, $ms, $ease, $done) = @_;
	push @{ $self->{_tweens} }, {
		obj => $obj, field => $field, from => ($obj->{$field} // 0), to => $to,
		t0 => time(), ms => $ms // 250, ease => $ease // "out", done => $done,
	};
}

sub halt {
	my ($self) = @_;
	$self->{_timers} = [];
	$self->{_tweens} = [];
}

sub refresh { my ($self) = @_; $self->{_rebuild} = 1; }

# ---------------------------------------------------------------------------
# canvas object passed to the game's draw
# ---------------------------------------------------------------------------
package NMSArcadeCanvas;

sub _piece {
	my ($self, $spec) = @_;
	$self->{_count}++;
	return if $self->{_count} > plugin::PIECE_LIMIT_GLOBAL();
	$self->{_client}->NMSWindowCanvasPiece($self->{_win_id}, $self->{_widget}, $spec);
}

sub panel {
	my ($self, $x, $y, $w, $h, $opts) = @_;
	$opts //= {};
	$self->_piece(join(",", 1, $x, $y, $w, $h, plugin::_num(plugin::arcade_color($opts->{fill}, 0xFF2A2416)), 0, $opts->{border_px} // 1, 0, ""));
}

sub rect {
	my ($self, $x, $y, $w, $h, $opts) = @_;
	$opts //= {};
	$self->_piece(join(",", 2, $x, $y, $w, $h, plugin::_num(plugin::arcade_color($opts->{fill}, 0xFFFFFFFF)), $opts->{round} // 0, 0, 0, ""));
}

sub grid {
	my ($self, $x, $y, $cols, $rows, $cell, $color_fn, $opts) = @_;
	$opts //= {};
	my @parts;
	for my $row (0 .. $rows - 1) {
		for my $col (0 .. $cols - 1) {
			my $c = $color_fn ? $color_fn->($col, $row) : undef;
			push @parts, ($row * $cols + $col) . "," . plugin::arcade_color($c, 0xFFFFFFFF) if defined $c;
		}
	}
	my $action = $opts->{action} // 0;
	if ($action) {
		# the game receives grid clicks as its on_grid coderef: $fn->($inst, $cell)
		$plugin::GRID_FNS{ $self->{_win_id} } //= {};
		$plugin::GRID_FNS{ $self->{_win_id} }{$action} = sub {
			my ($inst, $cell) = @_;
			my $fn = $inst->{on_grid};
			$fn->($inst, $cell) if ref($fn) eq 'CODE';
		};
	}
	plugin::arcade_grid_piece($self->{_client}, $self->{_win_id}, $self->{_widget},
		join(",", $x, $y, $cols, $rows, $cell, $cell, $action),
		join("\x1f", @parts));
}

sub line {
	my ($self, $x1, $y1, $x2, $y2, $c, $width) = @_;
	$self->_piece(join(",", 4, $x1, $y1, $x2, $y2, plugin::_num(plugin::arcade_color($c, 0xFFFFFFFF)), $width // 1, 0, 0, ""));
}

sub ring {
	my ($self, $cx, $cy, $radius, $c, $width) = @_;
	$self->_piece(join(",", 5, $cx, $cy, $radius, 0, plugin::_num(plugin::arcade_color($c, 0xFFFFFFFF)), $width // 2, 0, 0, ""));
}

sub text {
	my ($self, $x, $y, $s, $opts) = @_;
	$opts //= {};
	$s = "$s";
	$self->_piece(join(",", 6, $x, $y, 0, 0, plugin::_num(plugin::arcade_color($opts->{color}, 0xFFFFFFFF)), $opts->{size} // 14, $opts->{align} // 0, 0, $s));
}

sub banner {
	my ($self, $s, $c, $opts) = @_;
	$opts //= {};
	$s = "$s";
	$self->_piece(join(",", 7, 0, $opts->{y} // 8, 0, 0, plugin::_num(plugin::arcade_color($c, 0xFFFFD700)), $opts->{size} // 24, ($opts->{pulse} ? 1 : 0), 0, $s));
}

sub label {
	my ($self, $x, $y, $s, $c) = @_;
	$s = "$s";
	my $w = length($s) * 8 + 14;
	$w = 24 if $w < 24;
	$self->_piece(join(",", 8, $x, $y, $w, 16, plugin::_num(plugin::arcade_color($c, 0xFF282C3C)), 0, 0, 0, $s));
}

sub clickable {
	my ($self, $x, $y, $w, $h, $fn) = @_;
	$self->{_click_seq} //= 0;
	my $action = 2000 + $self->{_click_seq}++;
	$plugin::CLICK_FNS{ $self->{_win_id} } //= {};
	$plugin::CLICK_FNS{ $self->{_win_id} }{$action} = $fn;
	$self->_piece(join(",", 9, $x, $y, $w, $h, 0, $action, 0, 0, ""));
}

# ready-made pieces ---------------------------------------------------------

sub die {
	my ($self, $x, $y, $n) = @_;
	$self->panel($x, $y, 30, 30, { fill => 0xFFF4F0E4 });
	my %pips = (
		1 => [[15,15]], 2 => [[9,9],[21,21]], 3 => [[9,9],[15,15],[21,21]],
		4 => [[9,9],[21,9],[9,21],[21,21]], 5 => [[9,9],[21,9],[15,15],[9,21],[21,21]],
		6 => [[9,9],[21,9],[9,15],[21,15],[9,21],[21,21]],
	);
	my $set = $pips{$n} // $pips{1};
	for my $pip (@$set) {
		$self->rect($x + $pip->[0] - 2, $y + $pip->[1] - 2, 4, 4, { fill => 0xFF14120C });
	}
}

sub chip {
	my ($self, $x, $y, $value, $opts) = @_;
	$opts //= {};
	my $c = $opts->{dim} ? 0xFF44444C : ($value >= 100 ? 0xFF303030 : 0xFFB03030);
	$self->ring($x + 12, $y + 12, 11, $c, 4);
	$self->rect($x + 5, $y + 5, 15, 15, { fill => 0xFFF0EAD8 });
	$self->text($x + 12, $y + 5, plugin::arcade_commas($value), { size => 11, align => 1, color => 0xFF14120C });
}

sub chip_count {
	my ($self, $x, $y, $n) = @_;
	$self->label($x, $y, plugin::arcade_commas($n) . " chips");
}

sub chip_stack {
	my ($self, $x, $y, $n) = @_;
	my $count = $n > 4 ? 4 : $n;
	for my $i (0 .. $count - 1) {
		$self->ring($x + 12, $y + 12 - $i * 3, 11, ($i == $count - 1 ? 0xFFB03030 : 0xFF702020), 4);
	}
}

sub card {
	my ($self, $x, $y, $card, $opts) = @_;
	$opts //= {};
	if (!defined $card) {
		$self->panel($x, $y, 34, 48, { fill => 0xFF20242E });
		return;
	}
	my $face_up = !exists $opts->{flip} || $opts->{flip} >= 1;
	if (!$face_up) {
		$self->panel($x, $y, 34, 48, { fill => 0xFF203A5E });
		$self->rect($x + 5, $y + 5, 24, 38, { fill => 0xFF2C4E7C });
		return;
	}
	my $red = ($card->{suit} eq "h" || $card->{suit} eq "d") ? 1 : 0;
	my %suits = (h => "\x{2665}", d => "\x{2665}", c => "\x{2663}", s => "\x{2663}");
	$self->panel($x, $y, 34, 48, { fill => 0xFFF4F0E4 });
	$self->text($x + 3, $y + 2, "$card->{rank}", { size => 13, color => ($red ? 0xFFB02020 : 0xFF14120C) });
	$self->text($x + 3, $y + 16, $suits{ $card->{suit} } // "?", { size => 13, color => ($red ? 0xFFB02020 : 0xFF14120C) });
}

sub card_back {
	my ($self, $x, $y) = @_;
	$self->panel($x, $y, 34, 48, { fill => 0xFF203A5E });
	$self->rect($x + 5, $y + 5, 24, 38, { fill => 0xFF2C4E7C });
}

sub token {
	my ($self, $x, $y, $c, $size) = @_;
	$size //= 16;
	$self->ring($x + $size / 2, $y + $size / 2, $size / 2, plugin::arcade_color($c, 0xFFFFD700), 3);
	$self->rect($x + $size / 2 - 2, $y + $size / 2 - 2, 4, 4, { fill => plugin::arcade_color($c, 0xFFFFD700) });
}

# ---------------------------------------------------------------------------
# engine glue
# ---------------------------------------------------------------------------
package plugin;

sub PIECE_LIMIT_GLOBAL { return $PIECE_LIMIT; }

sub arcade_grid_piece {
	my ($client, $win_id, $widget, $spec, $packed) = @_;
	return unless $client;
	$client->NMSWindowCanvasGrid($win_id, $widget, $spec, $packed);
}

sub arcade_load {
	my ($name) = @_;
	# game files define plugin::arcade_game_<name>; resolving a sub by
	# constructed name is a symbolic reference, which needs strict refs off
	no strict 'refs';
	my $fn = "plugin::arcade_game_${name}";
	return &{$fn}() if defined &{$fn};
	return undef;
}

sub arcade_rebuild {
	my ($inst) = @_;
	my $client = $inst->{you};
	my $win = $inst->{win_id};
	return unless $client && $win && $client->NMSWindowIsOpen($win);

	$client->NMSWindowClear($win);
	$client->NMSWindowAddHeader($win, $inst->{title} // $inst->{key}, "gold");
	$inst->{_canvas_widget} = $client->NMSWindowAddCanvas($win, $inst->{width}, $inst->{height});

	$inst->{_status_widget} = -1;
	# games hide the status line with status => 0 / ""
	my $hide_status = exists $inst->{status} && !ref($inst->{status}) && !$inst->{status};
	if (!$hide_status) {
		$inst->{_status_widget} = $client->NMSWindowAddProgress($win, 0, "green", "");
	}

	if ($inst->{buttons}) {
		my $i = 0;
		for my $btn (@{ $inst->{buttons} }) {
			$i++;
			# manual form: ["Label", sub {...}, color => "gold", enabled => sub {...}]
			my ($label_src, $fn, %opts) = @$btn;
			my $enabled = 1;
			if (ref($opts{enabled}) eq 'CODE') { $enabled = $opts{enabled}->($inst) ? 1 : 0; }
			my $label = ref($label_src) eq 'CODE' ? $label_src->($inst) : "$label_src";
			my $action = 1000 + $i;
			$BUTTON_FNS{$win} //= {};
			$BUTTON_FNS{$win}{$action} = $fn;
			my $colorstr = defined $opts{color} ? "$opts{color}" : "";
			my $idx = $client->NMSWindowAddButton($win, $label, $action, $colorstr);
			if ($idx >= 0 && !$enabled) {
				$client->NMSWindowSetButton($win, $idx, $label, $colorstr, 1);
			}
		}
	}

	$client->NMSWindowSend($win);
	$inst->{_rebuild} = 0;
}

sub arcade_draw_frame {
	my ($inst) = @_;
	my $client = $inst->{you};
	my $win = $inst->{win_id};
	return unless $client && $win && $client->NMSWindowIsOpen($win);

	arcade_rebuild($inst) if $inst->{_rebuild};

	if (defined $inst->{_canvas_widget} && $inst->{_canvas_widget} >= 0) {
		$client->NMSWindowCanvasBegin($win, $inst->{_canvas_widget});
		delete $CLICK_FNS{$win};
		my $canvas = bless {
			_client => $client, _win_id => $win, _widget => $inst->{_canvas_widget},
			_count => 0, _click_seq => 0,
		}, 'NMSArcadeCanvas';
		if (ref($inst->{draw}) eq 'CODE') {
			$inst->{draw}->($inst, $canvas);
		}
	}

	if ($inst->{_status_widget} && $inst->{_status_widget} >= 0 && ref($inst->{status}) eq 'CODE') {
		my $txt = $inst->{status}->($inst) // "";
		$client->NMSWindowSetProgress($win, $inst->{_status_widget}, 0, "$txt") if length $txt;
	}

	$client->NMSWindowSend($win);
}

sub arcade_run_tweens {
	my ($inst) = @_;
	my @keep;
	for my $tw (@{ $inst->{_tweens} }) {
		my $t = (time() - $tw->{t0}) * 1000.0;
		my $k = $t / $tw->{ms};
		$k = 1 if $k > 1;
		my $eased = $k;
		$eased = 1 - (1 - $k) * (1 - $k) if $tw->{ease} eq "out";
		$tw->{obj}{ $tw->{field} } = $tw->{from} + ($tw->{to} - $tw->{from}) * $eased;
		if ($k >= 1) {
			$tw->{obj}{ $tw->{field} } = $tw->{to};
			$tw->{done}->($inst) if $tw->{done};
		}
		else {
			push @keep, $tw;
		}
	}
	$inst->{_tweens} = \@keep;
}

sub arcade_run_timers {
	my ($inst) = @_;
	my @keep;
	for my $tm (@{ $inst->{_timers} }) {
		if ((time() - $tm->{t0}) * 1000.0 >= $tm->{ms}) {
			push @keep, $tm if $tm->{rep};
			$tm->{t0} = time() if $tm->{rep};
			$tm->{fn}->($inst);
		}
		else {
			push @keep, $tm;
		}
	}
	$inst->{_timers} = \@keep;
}

sub arcade_on_timer {
	my ($npc) = @_;
	return unless $npc;
	return unless $npc->IsNPC();

	my $npc_id = $npc->GetID();
	my $any = 0;
	my @mine;
	for my $inst (values %INSTANCES) {
		if ($inst->{npc_id} == $npc_id) { $any = 1; push @mine, $inst; }
	}
	quest::settimerMS("arcade", $TIMER_MS, $npc) if $any;

	for my $inst (@mine) {
		my $ok = eval {
			arcade_run_tweens($inst);
			arcade_run_timers($inst);
			arcade_draw_frame($inst);
			1;
		};
		if (!$ok) {
			# a broken game must not spam the error log 20x/second: drop the
			# instance and let its clock lapse (re-arming happens above only
			# while an instance is alive)
			delete $INSTANCES{ $inst->{win_id} };
		}
	}
}

my %KEY_NAMES = (1 => "up", 2 => "down", 3 => "left", 4 => "right", 5 => "space", 6 => "enter", 7 => "escape");

sub arcade_on_window {
	my ($client, $e) = @_;
	return unless $client && $e;

	my $win = $e->{window_id};
	my $inst = $INSTANCES{$win} or return;
	my $kind = $e->{kind};

	if ($kind == 1) {
		my $fn = $BUTTON_FNS{$win}{$e->{action}};
		$fn->($inst) if $fn;
	}
	elsif ($kind == 2) {
		my $name = $KEY_NAMES{ $e->{value} };
		if (!$name && $e->{value} >= 32 && $e->{value} < 127) { $name = chr($e->{value}); }
		if ($name && $inst->{keys} && ref($inst->{keys}{$name}) eq 'CODE') {
			$inst->{keys}{$name}->($inst);
		}
	}
	elsif ($kind == 4) {
		delete $INSTANCES{$win};
		delete $BUTTON_FNS{$win};
		delete $CLICK_FNS{$win};
		delete $GRID_FNS{$win};
		$inst->{on_close}->($inst) if ref($inst->{on_close}) eq 'CODE';
		delete $BY_NPC_CHAR{ $inst->{npc_id} . ":" . $client->CharacterID() };
		delete $inst->{you};
		delete $inst->{win_id};
	}
	elsif ($kind == 5) {
		my $fn = $GRID_FNS{$win}{$e->{action}};
		$fn->($inst, $e->{value}) if $fn;
	}
	elsif ($kind == 6) {
		my $fn = $CLICK_FNS{$win}{$e->{action}};
		$fn->($inst) if $fn;
	}
}

sub arcade_start {
	my ($template, $client, $npc) = @_;
	return undef unless $client;

	unless ($client->NMSWindowIsSupported()) {
		$client->Message(15, "Your client cannot draw arcade windows.");
		return undef;
	}

	my %inst = %{ $template };   # shallow copy; games keep their own state rows
	bless \%inst, 'NMSArcade';
	$inst{you} = $client;
	$inst{npc} = $npc;
	$inst{npc_id} = $npc ? $npc->GetID() : 0;
	$inst{key} = $template->{key} // $template->{title} // "game";
	$inst{title} = $template->{title} // $inst{key};
	$inst{width} = $template->{width} // 320;
	$inst{height} = $template->{height} // 240;
	$inst{_timers} = [];
	$inst{_tweens} = [];
	$inst{_rebuild} = 1;

	my $flags = 1;    # no resize
	$flags += 2 if $template->{keys} && scalar(keys %{ $template->{keys} });
	$flags += 32;     # ticker

	my $win = $client->NMSWindowOpen($inst{key}, $inst{title}, $inst{width}, $inst{height}, $flags);
	if (!$win) {
		$client->Message(15, "You cannot open any more windows.");
		return undef;
	}
	$inst{win_id} = $win;

	if ($template->{style} eq "wood") {
		$client->NMSWindowSetStyle($win, "0xF02A2416", "0xFFC4A860", 0, 1);
	}
	elsif ($template->{style} eq "night") {
		$client->NMSWindowSetStyle($win, "0xF0141420", "0xFF3050C0", 0, 1);
	}

	$INSTANCES{$win} = \%inst;
	$BY_NPC_CHAR{ $inst{npc_id} . ":" . $client->CharacterID() } = \%inst;

	$template->{start}->(\%inst) if ref($template->{start}) eq 'CODE';

	quest::settimerMS("arcade", $TIMER_MS, $npc) if $npc && $npc->IsNPC();

	arcade_draw_frame(\%inst);
	return \%inst;
}

sub arcade_npc {
	my ($npc, $client, $text, $games) = @_;
	return unless $npc && $client && $games;

	for my $name (keys %$games) {
		if (lc($text) eq lc($name)) {
			arcade_start($games->{$name}, $client, $npc);
			return;
		}
	}

	$npc->Say("Welcome to the arcade, " . $client->GetName() . ". Pick a game:");
	for my $name (sort keys %$games) {
		$client->Message(15, quest::saylink($name, 0, $name));
	}
	$client->Message(15, "Click a game to play. Say 'games' to see this list again.");
}

1;
