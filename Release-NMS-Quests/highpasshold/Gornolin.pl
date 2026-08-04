sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greeting my fellow traveler. I am Gornolin Zot, travelling merchant of fine wares. Please. Take a look at what I have to offer.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
