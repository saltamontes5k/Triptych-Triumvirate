sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Good to see new visitors in the Temple of Marr. Please enlighten your soul with the followings of Erollisi Marr of Mithaniel Marr.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
