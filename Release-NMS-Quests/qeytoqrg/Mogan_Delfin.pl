sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Time to die $name!");
	}
}

sub EVENT_SIGNAL {
	#:: Match a signal '1' from /qeytoqrg/Guard_Cheslin.pl
	if ($signal == 1) {
		quest::say("Oh, great. I feel safe already.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
