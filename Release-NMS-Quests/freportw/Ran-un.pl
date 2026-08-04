sub EVENT_SPAWN {
	#:: Create a timer that loops every 5 seconds
	quest::settimer("spar1", 5);
}

sub EVENT_TIMER {
	#:: Match the timer "spar1"
	if ($timer eq "spar1") {
		quest::doanim(quest::ChooseRandom(1, 5, 6, 7, 11, 30, 45, 46, 47));
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
