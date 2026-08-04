sub EVENT_DEATH_COMPLETE {
	quest::say("My comrades will avenge my death.");
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
