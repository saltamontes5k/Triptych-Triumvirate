sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Hssst. Foolish mortal! You can not kill the dead!");
	}
}

sub EVENT_SLAY {
	quest::say("Die!");
}
