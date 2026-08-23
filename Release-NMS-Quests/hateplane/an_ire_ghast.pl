sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Uninvited guests to our master's home must be shown the way out!");
	}
}

sub EVENT_SLAY {
	quest::say("If you are lucky, you will stay dead. If you are not lucky, you will become as we are!");
}

sub EVENT_DEATH_COMPLETE {
	quest::say("Perhaps this death will release my soul from this accursed place.");
}
