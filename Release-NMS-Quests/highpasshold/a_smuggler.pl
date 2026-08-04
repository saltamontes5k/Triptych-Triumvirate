sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Time to die $name!");
	}
}

sub EVENT_DEATH_COMPLETE {
	quest::say("My comrades will avenge my death.");
}
