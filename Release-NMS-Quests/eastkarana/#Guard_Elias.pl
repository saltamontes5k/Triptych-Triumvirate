sub EVENT_WAYPOINT_ARRIVE {
	#:: Match waypoint 2
	if ($wp == 2) {
		quest::say("Hello, Milea. It is unfortunate for you that your friends have led me right to you. Soon you will join Nerissa in the afterlife. Do you have any last words?");
		#:: Send a signal "1" to Eastern Plains of Karana >> Milea_Clothspinner (15055) with a 4 second delay
		quest::signalwith(15055, 1, 4);
	}
}

sub EVENT_SIGNAL {
	#:: Match a signal "1" from /eastkarana/Milea_Clothspinner.pl
	if ($signal == 1) {
		quest::say("I thought you would never ask.");
		#:: Attack Eastern Plains of Karana >> Milea_Clothspinner (15055)
		quest::attacknpctype(15055);
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
