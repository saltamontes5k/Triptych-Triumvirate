sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("You would dare challenge the mighty Ekeros?");
	}
}

sub EVENT_DEATH_COMPLETE {
	quest::say("Mark my...  words... the Burning Dead shall...  soon... rise... aah...  ggain...");
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
