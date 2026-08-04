sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Welcome to Halas! Home of the Wolves of the North.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
