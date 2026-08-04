sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("You are almost beneath notice, but our master commands your death.");
	}
}

sub EVENT_SLAY {
	quest::emote("snorts in contempt, not at all surprised at the ease of her victory.");
}

sub EVENT_DEATH_COMPLETE {
	quest::emote("blinks in confusion, obviously surprised that she has met her end at the hands of mere mortals.");
}
