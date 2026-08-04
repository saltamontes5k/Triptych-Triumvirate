sub EVENT_SPAWN {
	my $min = 1;
	my $range = 4;
	my $randomspawn = int(rand($range)) + $min;
	quest::settimer("move",$randomspawn);
}

sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Ugly creature near my feet, me thinks that you'll be good to eat!");
	}
}

sub EVENT_TIMER {
	if ($timer eq "move") {
		plugin::RandomRoam(500, 500, 25);
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
	quest::say("I wiggled my fingers and waved my hands. But there is no glory in failed last stands!");
}
