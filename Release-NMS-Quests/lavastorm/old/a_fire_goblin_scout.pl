sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::emote("narrows its eyes which glow with an inner heat.");
	}
}

sub EVENT_DEATH_COMPLETE {
	quest::emote("falls and begins to smolder.");
}
