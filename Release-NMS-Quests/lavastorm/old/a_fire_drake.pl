sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::emote("screeches as it spots potential prey.");
	}
}

sub EVENT_DEATH_COMPLETE {
	quest::emote("falls to the ground as its wings give out.");
}
