sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Welcome, $name! If there is a sketch you are looking for, you should be able to find it here.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
