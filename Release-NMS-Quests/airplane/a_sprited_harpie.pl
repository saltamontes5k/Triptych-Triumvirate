sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("How dare you! You attack us after we allow you to enter our domain in peace? Time for you to die!");
	}
}
