sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail, mighty one! What are you doing in the city?  You should be out slaying beasts. There is nothing to find here in the city.");
	}
	elsif ($text=~/hollish/i) {
		quest::say("I have never heard of this Hollish character you speak of. You must be confusing me for someone else.");
	}
	elsif ($text=~/opal/i) {
		quest::say("Opal is just a friend I have here in Freeport. She works at the Academy of Arcane Science.");
	}
}

sub EVENT_WAYPOINT_ARRIVE{
	#:: Match waypoint 1
	if ($wp == 1) {
		#:: Spawn a 12147 - Hog Key # 2 on the ground
		quest::creategroundobject(12147, -448, -107, -10.870, 0, 90000)
	}
	#:: Match waypoint 7
	elsif ($wp == 7) {
		quest::say("Any mail for room number two?");
		#:: Send a signal "1" to West Freeport >> Swin_Blackeye (9103) with no delay
		quest::signalwith(9103, 1, 0);
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
