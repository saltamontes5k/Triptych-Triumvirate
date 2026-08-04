sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Spirits and elders, guide my hand. This tasty fool has invaded our land!");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
	quest::say("Omens and portents, the entrails were true. I would meet my fate to someone like you.");
}
