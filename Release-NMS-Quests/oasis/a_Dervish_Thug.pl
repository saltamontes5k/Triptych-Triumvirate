sub EVENT_COMBAT {
	#:: Combat state 1 is entered combat
	if ($combat_state == 1) {
		quest::say("Time to die $name!");
	}
}
