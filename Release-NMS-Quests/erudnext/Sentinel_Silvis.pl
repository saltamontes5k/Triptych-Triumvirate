sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Prepare to die, infidel!");
	}
}

sub EVENT_DEATH_COMPLETE {
	quest::say("Prepare to meet the vengeance of Erud!");
	#:: Spawn a Erudin >> a_water_elemental (24308)
	quest::spawn2(24308, 0, 0, $x, $y, $z, $h);
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::returnUnusedItems();
}
