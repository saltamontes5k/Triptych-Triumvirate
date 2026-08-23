sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("What do you want? I don't have any spare change.");
	}
}

sub EVENT_SIGNAL {
	#:: Match a signal '1' from /freporte/Trolon_Lightleer.pl
	if ($signal == 1) {
		quest::say("Sir Lucan is only a human. He is weak. I can smash him.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
