sub EVENT_SPAWN {
	my $min = 1;
	my $range = 4;
	my $randomspawn = int(rand($range)) + $min;
	quest::settimer("move",$randomspawn);
}

sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Natural selection at work.");
	}
}

sub EVENT_TIMER {
	if ($timer eq "move") {
		plugin::RandomRoam(500, 500, 25);
	}
}

sub EVENT_SAY {
	#:: Missing Text - Based on Holly Windstalker
	if ($text=~/hail/i) {
		quest::say("Well met, $name.  I am Cros Treewind, Protector of the Pine.  What brings you out to the Qeynos Hills?  Not hunting, I hope. These stains on my staff are all that is left of the last adventurer I caught harming my bear and wolf friends.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
	quest::say("My comrades will avenge my death.");
}
