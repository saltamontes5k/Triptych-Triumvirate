sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Feel the rage of our master!");
	}
}

sub EVENT_SLAY {
	quest::say("One less foe to trouble our lord and master!");
}

sub EVENT_DEATH_COMPLETE {
	quest::say("This is no victory for you! Your hate grows with every kill!");
}
