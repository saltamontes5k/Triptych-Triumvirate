sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Only a fool causes trouble in the militia bar!");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
	quest::say("Your name shall be added to the most wanted list of the Freeport Militia!");
}
