sub EVENT_WAYPOINT_ARRIVE {
	#:: Match waypoint 1 or 6
	if ($wp == 1 || $wp == 6) {
		#:: Set running true (run)
		quest::SetRunning(1);
	}
	#:: Match waypoint 4 or 7
	elsif ($wp == 4 || $wp == 7) {
		#:: Set running false (walk)
		quest::SetRunning(0);
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
