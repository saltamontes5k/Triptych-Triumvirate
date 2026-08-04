sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Ugly creature near my feet, me thinks that you'll be good to eat!");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
	quest::say("I wiggled my fingers and waved my hands. But there is no glory in failed last stands!");
}
