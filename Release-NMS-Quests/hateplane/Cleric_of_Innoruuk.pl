sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("None shall defile the realm of our master!");
	}
}

sub EVENT_SLAY {
	quest::say("Embrace our lord before your soul departs, and perhaps he shall grant you the boon of eternal life in his service!");
}

sub EVENT_DEATH_COMPLETE {
	quest::say("Innoruuk, I have failed you!");
}
