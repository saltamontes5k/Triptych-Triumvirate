# My Stats -- a non-game info window (sample arcade game, Perl).
# Shows the window API doing plain widgets: no input, just a portrait of the
# player and a couple of arcade numbers pulled from the other games.
# Loaded by plugin::arcade_load("my_stats").

package plugin;

use strict;
use warnings;

my %STAT_CLASSES = (
	1 => "Warrior", 2 => "Cleric", 3 => "Paladin", 4 => "Ranger",
	5 => "Shadow Knight", 6 => "Druid", 7 => "Monk", 8 => "Bard",
	9 => "Rogue", 10 => "Shaman", 11 => "Necromancer", 12 => "Wizard",
	13 => "Magician", 14 => "Enchanter", 15 => "Beastlord", 16 => "Berserker",
);

sub arcade_game_my_stats {
	return {
		key    => "my_stats",
		title  => "My Stats",
		width  => 320,
		height => 260,
		style  => "night",

		start => sub { },

		draw => sub {
			my ($g, $canvas) = @_;
			my $c = $g->client() or return;

			$canvas->banner($c->GetName(), "gold", { y => 6, size => 22 });
			$canvas->line(60, 44, 260, 44, "gray", 1);

			my $class_name = $STAT_CLASSES{ $c->GetClassID() } // "Adventurer";
			$canvas->text(16, 56, "Level " . $c->GetLevel() . " " . $class_name, { size => 14 });

			my ($hp, $max_hp) = ($c->GetHP(), $c->GetMaxHP());
			$canvas->text(16, 78, "Hit points", { size => 12, color => "gray" });
			$canvas->rect(110, 80, 180, 12, { fill => 0xFF20222E });
			my $frac = $max_hp > 0 ? $hp / $max_hp : 0;
			$frac = 0 if $frac < 0; $frac = 1 if $frac > 1;
			$canvas->rect(110, 80, int(180 * $frac), 12, { fill => 0xFF30C030 });
			$canvas->text(16, 96, "$hp / $max_hp", { size => 12 });

			$canvas->text(16, 122, "Arcade record", { size => 12, color => "gray" });
			$canvas->text(16, 138, "Coin Flip chips: " . plugin::arcade_commas($g->saved("chips", 100)), { size => 13 });
			$canvas->text(16, 156, "Tic-Tac-Toe wins: " . plugin::arcade_commas($g->saved("wins", 0)), { size => 13 });
			$canvas->text(16, 174, "Snake best: " . plugin::arcade_commas($g->saved("best", 0)), { size => 13 });

			$canvas->label(16, 210, "Say 'games' to the host for more");
		},
	};
}

1;
