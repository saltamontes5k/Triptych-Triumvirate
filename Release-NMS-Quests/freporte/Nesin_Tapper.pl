sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("I am not here for you to make fancy with!! Just order something!");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
