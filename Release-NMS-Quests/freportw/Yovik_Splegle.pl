sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings $name. Beware the corruption that has infected Freeport. Even the tower of the Arcane Scientists is not safe from the slimy hands of the Dismal Rage. I fear Opal Darkbriar is not what she seems and is darkening the minds of her apprentices.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
