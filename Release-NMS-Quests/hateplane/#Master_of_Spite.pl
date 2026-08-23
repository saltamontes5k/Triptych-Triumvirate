sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("I shall slow your heart and shatter your soul!");
	}
}

sub EVENT_SLAY {
	quest::say("Another soul one step closer to our master's touch!");
}

sub EVENT_DEATH_COMPLETE {
	quest::say("Careful which paths you follow in life, mortals! Fill yourself with hate and you will become a tool of Innoruuk.");
}
