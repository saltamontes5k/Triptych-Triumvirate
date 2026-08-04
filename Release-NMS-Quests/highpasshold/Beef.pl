sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Yu be getting going. Dis here is da boss' table!!");
	}
}

sub EVENT_SIGNAL {
	#:: Match a signal '1' from Highpass Hold >> Bryan_McGee (5056)
	if ($signal == 1) {
		quest::say("Gets moving before me smash yu to pulp!!");
	}
	#:: Match a signal '2' from Highpass Hold >> Bryan_McGee (5056)
	elsif ($signal == 2) {
		quest::say("BWAHAHA HA!! Yoo werk fer Mister Axe now. Hehehe!!");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
