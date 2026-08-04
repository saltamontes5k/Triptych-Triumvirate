sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::emote("charges ahead with the intent to pummel its victim.");
	}
}

sub EVENT_DEATH_COMPLETE {
	quest::emote("dissipates as it hits the ground.");
}
