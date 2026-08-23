sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings $name. If you have love and kindness in your heart then seek refuge at the Temple of Marr and the Hall of Honor in North Freeport. There is a growing evil spreading through the city. May Erollisi save us and cleanse this city of the hatred and corruption spread by the vile Dismal Rage.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
