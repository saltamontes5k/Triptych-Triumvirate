sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::emote("slithers towards its prey, ready to attack.");
	}
}

sub EVENT_DEATH_COMPLETE {
	quest::emote("sinks to the ground, its scales dripping with rivulets of blood.");
}
