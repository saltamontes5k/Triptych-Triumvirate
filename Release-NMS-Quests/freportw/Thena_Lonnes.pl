sub EVENT_SPAWN {
	#:: Set a timer "spar2" that loops every 3 seconds
	quest::settimer("spar2", 3);
}

sub EVENT_TIMER {
	#:: Match timer "spar2"
	if ($timer eq "spar2") {
		quest::doanim(quest::ChooseRandom(1, 5, 6, 7, 11, 30, 45, 46, 47));
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
