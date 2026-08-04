sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Pardon me. Is that my dagger in your back!!");
	}
}

sub EVENT_DEATH_COMPLETE {
	quest::say("You shall soon feel the daggers of the Butcherblock Bandits upon your back!!");
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
