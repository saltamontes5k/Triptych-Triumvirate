sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("You are no match for a legionnaire!!");
	}
}

sub EVENT_DEATH_COMPLETE {
	quest::say("You shall have all the Crushbone orc legions on your tail for my death!");
}
