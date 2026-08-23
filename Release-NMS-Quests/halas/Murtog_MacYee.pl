sub EVENT_SIGNAL {
	#:: Match a signal '1' from /halas/Holana_Oleary.pl
	if ($signal == 1) {
		quest::say("Dinnae be rude to the customers, Holana.");
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetin's! I've many fine herbs and potions fer sale. Please look around.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
