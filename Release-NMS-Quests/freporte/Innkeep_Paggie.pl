sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hello there $name! You'll be happy to see that I am fully stocked with all my usual goods. Have a look around.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
