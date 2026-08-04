sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("All hail Prime Healer. Prime Healer good.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
