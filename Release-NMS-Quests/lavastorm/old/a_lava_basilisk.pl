sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::emote("snarls and attacks.");
	}
}

sub EVENT_DEATH_COMPLETE {
	quest::emote("shudders and collapses.");
}
