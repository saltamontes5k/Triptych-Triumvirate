sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Eeeaiiiiiiiiiiiiiieeeee!");
	}
}

sub EVENT_SLAY {
	quest::emote("shivers in anticipation of its next meal.");
}

sub EVENT_DEATH_COMPLETE {
	quest::emote("spurts foul smelling blood, and is still.");
}
