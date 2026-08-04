sub EVENT_WAYPOINT_ARRIVE {
	#::: When NPC arrives at waypoint 1 or 7
	if ($wp == 1 || $wp == 7) {
		quest::SetRunning(1);  #:: Run
	}
	#::: When NPC arrives at waypoint 82 or 10
	if ($wp == 82 || $wp == 10) {
		quest::SetRunning(0);  #:: Walk
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
