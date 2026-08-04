sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hello there, traveler. I hope you weren't planning on doing any fishing here. They don't seem to be biting much lately. What few fish I do happen to catch, I usually sell to my merchant friends in Qeynos. It ain't much, but it's a living.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
