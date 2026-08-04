sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::emote("snaps at you.");
	}
}

sub EVENT_DEATH_COMPLETE {
	quest::emote("screeches and lays broken before you.");
}
