sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Hold still, this will only hurt for an eternity!");
	}
}

sub EVENT_SLAY {
	quest::say("Don't you just hate when that happens?");
}
