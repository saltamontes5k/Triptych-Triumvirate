sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("$name, you do not belong here.  Those sharks are not very picky about what they eat.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
