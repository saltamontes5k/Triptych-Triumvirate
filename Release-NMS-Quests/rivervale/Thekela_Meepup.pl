sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("It is a pleasure to meet you $name. I am Thekela Meepup, one of the highest ranking Clerics in all of Rivervale.");
	}
}
	
sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
