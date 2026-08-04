sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::emote("flaps its wings and charges.");
	}
}

sub EVENT_DEATH_COMPLETE {
	quest::emote("falls backward, clutching its wounds.");
}
