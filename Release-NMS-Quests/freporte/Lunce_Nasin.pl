sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hello! Looking for a room? We have a few still empty.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
