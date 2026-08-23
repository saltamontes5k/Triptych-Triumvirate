sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Stand and deliver, fool!!");
	}
}

sub EVENT_DEATH_COMPLETE {
	quest::say("The Karana bandits will find you and avenge my death.");
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
