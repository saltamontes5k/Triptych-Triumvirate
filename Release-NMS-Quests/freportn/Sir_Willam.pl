sub EVENT_WAYPOINT_ARRIVE {
	#::: When NPC arrives at waypoint 170
	if ($wp == 170) {
		quest::SetRunning(1); #:: Run
	}
	#::: When NPC arrives at waypoint 186
	if ($wp == 186) {
		quest::SetRunning(0); #:: Walk
	}
}
