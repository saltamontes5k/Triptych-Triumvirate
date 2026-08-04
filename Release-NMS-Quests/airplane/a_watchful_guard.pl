sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Oh! You're in big trouble now! We don't like intruders trying to kill us! Time for you to die!");
	}
}
