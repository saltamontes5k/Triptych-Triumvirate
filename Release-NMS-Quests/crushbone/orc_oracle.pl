sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Let me show you the high power of the Crushbone oracles!!");
	}
}

sub EVENT_DEATH_COMPLETE {
	quest::say("You shall have all the Crushbone orc legions on your tail for my death!");
}
